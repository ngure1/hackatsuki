package store

import (
	"apiv2/internal/models"
	"apiv2/responses"
	"apiv2/utils"
	"errors"
	"fmt"
	"strings"

	"gorm.io/gorm"
)

type PostStore struct {
	db *gorm.DB
}

// DeletePost implements posts.Store.
func (ps *PostStore) DeletePost(postId uint, userId uint) error {
	post, err := ps.GetPost(postId, &userId)
	if err != nil {
		return err
	}

	if post.User.ID != userId {
		return fmt.Errorf("cannot delete another users post")
	}

	return ps.db.Delete(&models.Post{}, post.ID).Error
}

// GetCommentReplies implements posts.Store.
func (ps *PostStore) GetCommentReplies(commentId uint, page int, limit int) ([]responses.CommentsReponse, int, error) {
	var comments []models.Comment
	var totalCount int64
	err := ps.db.Model(&models.Comment{}).Where("parent_comment_id = ?", commentId).Count(&totalCount).Error
	if err != nil {
		return nil, 0, fmt.Errorf("an unexpected error occured when counting comment replies: %s", err.Error())
	}

	offset := utils.GetOffset(page, limit)
	err = ps.db.Preload("User").Limit(limit).Offset(offset).Where("parent_comment_id = ?", commentId).Find(&comments).Error
	if errors.Is(err, gorm.ErrRecordNotFound) {
		return nil, 0, err
	}
	if err != nil {
		return nil, 0, fmt.Errorf("an unexpected error occured when querying comment replies: %s", err.Error())
	}

	ids := make([]uint, len(comments))
	for i, c := range comments {
		ids[i] = c.ID
	}

	// fetch reply counts in one query
	type CountResult struct {
		ParentCommentId uint
		Count           int64
	}
	var counts []CountResult

	if len(ids) > 0 {
		ps.db.Model(&models.Comment{}).
			Select("parent_comment_id, COUNT(*) as count").
			Where("parent_comment_id IN ?", ids).
			Group("parent_comment_id").
			Scan(&counts)
	}

	// map reply counts
	replyMap := make(map[uint]int64)
	for _, c := range counts {
		replyMap[c.ParentCommentId] = c.Count
	}

	// build response DTO
	var response []responses.CommentsReponse
	for _, c := range comments {
		response = append(response, responses.CommentsReponse{
			ID:              c.ID,
			Content:         c.Content,
			ParentCommentId: c.ParentCommentId,
			PostId:          c.PostId,
			User: responses.UserResponse{
				ID:        c.User.ID,
				FirstName: c.User.FirstName,
				LastName:  c.User.LastName,
			},
			CreatedAt:    c.CreatedAt,
			RepliesCount: replyMap[c.ID],
		})
	}

	return response, int(totalCount), nil
}

// GetComments implements posts.Store.
func (ps *PostStore) GetComments(postId uint, page int, limit int) ([]responses.CommentsReponse, int, error) {
	var comments []models.Comment
	var totalCount int64
	err := ps.db.Model(&models.Comment{}).
		Where("post_id = ? AND parent_comment_id IS NULL", postId).
		Count(&totalCount).
		Order("created_at DESC").
		Error
	if err != nil {
		return nil, 0, fmt.Errorf("an unexpected error occured when counting comments: %s", err.Error())
	}
	offset := utils.GetOffset(page, limit)
	err = ps.db.Preload("User").Limit(limit).
		Offset(offset).
		Where("post_id = ? AND parent_comment_id IS NULL", postId).
		Find(&comments).
		Error
	if errors.Is(err, gorm.ErrRecordNotFound) {
		return nil, 0, err
	}
	if err != nil {
		return nil, 0, fmt.Errorf("an unexpected error occured when querying comments: %s", err.Error())
	}
	ids := make([]uint, len(comments))
	for i, c := range comments {
		ids[i] = c.ID
	}

	// fetch reply counts in one query
	type CountResult struct {
		ParentCommentId uint
		Count           int64
	}
	var counts []CountResult

	if len(ids) > 0 {
		ps.db.Model(&models.Comment{}).
			Select("parent_comment_id, COUNT(*) as count").
			Where("parent_comment_id IN ?", ids).
			Group("parent_comment_id").
			Scan(&counts)
	}

	// map reply counts
	replyMap := make(map[uint]int64)
	for _, c := range counts {
		replyMap[c.ParentCommentId] = c.Count
	}

	// build response DTO
	var response []responses.CommentsReponse
	for _, c := range comments {
		response = append(response, responses.CommentsReponse{
			ID:              c.ID,
			Content:         c.Content,
			ParentCommentId: c.ParentCommentId,
			PostId:          c.PostId,
			User: responses.UserResponse{
				ID:        c.User.ID,
				FirstName: c.User.FirstName,
				LastName:  c.User.LastName,
			},
			CreatedAt:    c.CreatedAt,
			RepliesCount: replyMap[c.ID],
		})
	}

	return response, int(totalCount), nil
}

// CreateComment implements posts.Store.
func (ps *PostStore) CreateComment(
	content string,
	postId uint,
	userId uint,
	parentCommentId *uint,
) (*responses.CommentsReponse, error) {
	comment := &models.Comment{
		Content:         content,
		PostId:          postId,
		UserID:          userId,
		ParentCommentId: parentCommentId,
	}
	err := ps.db.Create(comment).Error
	if err != nil {
		return nil, err
	}

	// Preload the user for the response
	err = ps.db.Preload("User").First(comment).Error
	if err != nil {
		return nil, err
	}

	response := &responses.CommentsReponse{
		ID:              comment.ID,
		Content:         comment.Content,
		ParentCommentId: comment.ParentCommentId,
		PostId:          comment.PostId,
		User: responses.UserResponse{
			ID:        comment.User.ID,
			FirstName: comment.User.FirstName,
			LastName:  comment.User.LastName,
		},
		CreatedAt:    comment.CreatedAt,
		RepliesCount: 0, // New comment has no replies
	}

	return response, nil
}

// ToggleLikePost implements posts.Store.
func (ps *PostStore) ToggleLikePost(postId uint, userId uint) (bool, error) {
	var existingLike models.Like
	err := ps.db.Where("post_id = ? AND user_id = ?", postId, userId).First(&existingLike).Error

	if errors.Is(err, gorm.ErrRecordNotFound) {
		// Like doesn't exist, create it
		like := &models.Like{
			PostId: postId,
			UserID: userId,
		}
		err = ps.db.Create(like).Error
		if err != nil {
			return false, err
		}
		return true, nil // liked
	}

	if err != nil {
		return false, err
	}

	// Like exists, delete it (unlike)
	err = ps.db.Delete(&existingLike).Error
	if err != nil {
		return false, err
	}

	return false, nil // unliked
}

// CreatePost implements posts.Store.
func (ps *PostStore) CreatePost(
	question string,
	description string,
	userId uint,
	crop *string,
	imageUrl *string,
	chatUrl *string,
	tags *string,
) (*models.Post, error) {
	post := &models.Post{
		Question:    question,
		Description: description,
		Crop:        crop,
		ImageUrl:    imageUrl,
		Tags:        tags,
		ChatUrl:     chatUrl,
		UserID:      userId,
	}
	err := ps.db.Create(post).Error
	if err != nil {
		return nil, fmt.Errorf("error creating post: %s", err.Error())
	}

	return post, nil
}

// GetPost implements posts.Store.
func (ps *PostStore) GetPost(postId uint, userId *uint) (*responses.PostResponse, error) {
	var post models.Post
	err := ps.db.Preload("Comments").Preload("User").Preload("Likes").Where("id = ?", postId).First(&post).Error
	if errors.Is(err, gorm.ErrRecordNotFound) {
		return nil, err
	}
	if err != nil {
		return nil, fmt.Errorf("an unexpected error occured when retrieving post: %s", err.Error())
	}

	commentCount := len(post.Comments)
	likesCount := len(post.Likes)
	user := responses.UserResponse{
		ID:        post.User.ID,
		FirstName: post.User.FirstName,
		LastName:  post.User.LastName,
	}

	// Check if user has liked this post
	isLiked := false
	if userId != nil {
		for _, like := range post.Likes {
			if like.UserID == *userId {
				isLiked = true
				break
			}
		}
	}

	postResp := &responses.PostResponse{
		ID:            post.ID,
		Question:      post.Question,
		Description:   post.Description,
		Crop:          post.Crop,
		ImageUrl:      post.ImageUrl,
		Tags:          post.Tags,
		User:          user,
		CommentsCount: int64(commentCount),
		LikesCount:    int64(likesCount),
		IsLiked:       isLiked,
		CreatedAt:     post.CreatedAt,
		UpdatedAt:     post.UpdatedAt,
	}

	return postResp, nil
}

// GetPosts implements posts.Store.
func (ps *PostStore) GetPosts(page int, limit int, userId *uint, tags *string) ([]responses.PostResponse, int, error) {
	var posts []models.Post
	var response []responses.PostResponse
	var totalCount int64

	// Build base query
	query := ps.db.Model(&models.Post{})

	// Add tag filtering if tags parameter is provided
	if tags != nil && strings.TrimSpace(*tags) != "" {
		tagList := strings.Split(*tags, ",")
		var tagConditions []string
		var tagValues []interface{}

		for _, tag := range tagList {
			tag = strings.TrimSpace(tag)
			if tag != "" {
				tagConditions = append(tagConditions, "tags LIKE ?")
				tagValues = append(tagValues, "%"+tag+"%")
			}
		}

		if len(tagConditions) > 0 {
			query = query.Where(strings.Join(tagConditions, " OR "), tagValues...)
		}
	}

	// Count total records with filtering applied
	if err := query.Count(&totalCount).Error; err != nil {
		return nil, 0, fmt.Errorf("error counting posts: %s", err)
	}

	// Get paginated results with preloading
	offset := utils.GetOffset(page, limit)
	finalQuery := ps.db.Preload("Comments").Preload("User").Preload("Likes")

	// Apply the same filtering to the final query
	if tags != nil && strings.TrimSpace(*tags) != "" {
		tagList := strings.Split(*tags, ",")
		var tagConditions []string
		var tagValues []interface{}

		for _, tag := range tagList {
			tag = strings.TrimSpace(tag)
			if tag != "" {
				tagConditions = append(tagConditions, "tags LIKE ?")
				tagValues = append(tagValues, "%"+tag+"%")
			}
		}

		if len(tagConditions) > 0 {
			finalQuery = finalQuery.Where(strings.Join(tagConditions, " OR "), tagValues...)
		}
	}

	err := finalQuery.Limit(limit).Offset(offset).Order("created_at DESC").Find(&posts).Error
	if err != nil {
		return nil, 0, fmt.Errorf("an unexpected error occured when retrieving paginated posts: %s", err.Error())
	}

	// Build response DTOs
	for _, post := range posts {
		commentCount := len(post.Comments)
		likesCount := len(post.Likes)
		user := responses.UserResponse{
			ID:        post.User.ID,
			FirstName: post.User.FirstName,
			LastName:  post.User.LastName,
		}

		// Check if user has liked this post
		isLiked := false
		if userId != nil {
			for _, like := range post.Likes {
				if like.UserID == *userId {
					isLiked = true
					break
				}
			}
		}

		postResp := &responses.PostResponse{
			ID:            post.ID,
			Question:      post.Question,
			Description:   post.Description,
			Crop:          post.Crop,
			ImageUrl:      post.ImageUrl,
			Tags:          post.Tags,
			User:          user,
			CommentsCount: int64(commentCount),
			LikesCount:    int64(likesCount),
			IsLiked:       isLiked,
			CreatedAt:     post.CreatedAt,
			UpdatedAt:     post.UpdatedAt,
		}
		response = append(response, *postResp)
	}

	return response, int(totalCount), nil
}

func NewPostStore(db *gorm.DB) *PostStore {
	return &PostStore{
		db: db,
	}
}
