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

type BlogStore struct {
	db *gorm.DB
}

// DeleteBlog implements blogs.Store.
func (bs *BlogStore) DeleteBlog(blogId uint, userId uint) error {
	blog, err := bs.GetBlog(blogId, &userId)
	if err != nil {
		return err
	}

	if blog.User.ID != userId {
		return fmt.Errorf("cannot delete another users blog")
	}

	return bs.db.Delete(&models.Blog{}, blog.ID).Error
}

// GetBlogCommentReplies implements blogs.Store.
func (bs *BlogStore) GetBlogCommentReplies(commentId uint, page int, limit int) ([]responses.BlogCommentsResponse, int, error) {
	var comments []models.BlogComment
	var totalCount int64
	err := bs.db.Model(&models.BlogComment{}).Where("parent_comment_id = ?", commentId).Count(&totalCount).Error
	if err != nil {
		return nil, 0, fmt.Errorf("an unexpected error occured when counting blog comment replies: %s", err.Error())
	}

	offset := utils.GetOffset(page, limit)
	err = bs.db.Preload("User").Limit(limit).Offset(offset).Where("parent_comment_id = ?", commentId).Find(&comments).Error
	if errors.Is(err, gorm.ErrRecordNotFound) {
		return nil, 0, err
	}
	if err != nil {
		return nil, 0, fmt.Errorf("an unexpected error occured when querying blog comment replies: %s", err.Error())
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
		bs.db.Model(&models.BlogComment{}).
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
	var response []responses.BlogCommentsResponse
	for _, c := range comments {
		response = append(response, responses.BlogCommentsResponse{
			ID:              c.ID,
			Content:         c.Content,
			ParentCommentId: c.ParentCommentId,
			BlogId:          c.BlogId,
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

// GetBlogComments implements blogs.Store.
func (bs *BlogStore) GetBlogComments(blogId uint, page int, limit int) ([]responses.BlogCommentsResponse, int, error) {
	var comments []models.BlogComment
	var totalCount int64
	err := bs.db.Model(&models.BlogComment{}).
		Where("blog_id = ? AND parent_comment_id IS NULL", blogId).
		Count(&totalCount).
		Order("created_at DESC").
		Error
	if err != nil {
		return nil, 0, fmt.Errorf("an unexpected error occured when counting blog comments: %s", err.Error())
	}
	offset := utils.GetOffset(page, limit)
	err = bs.db.Preload("User").Limit(limit).
		Offset(offset).
		Where("blog_id = ? AND parent_comment_id IS NULL", blogId).
		Find(&comments).
		Error
	if errors.Is(err, gorm.ErrRecordNotFound) {
		return nil, 0, err
	}
	if err != nil {
		return nil, 0, fmt.Errorf("an unexpected error occured when querying blog comments: %s", err.Error())
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
		bs.db.Model(&models.BlogComment{}).
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
	var response []responses.BlogCommentsResponse
	for _, c := range comments {
		response = append(response, responses.BlogCommentsResponse{
			ID:              c.ID,
			Content:         c.Content,
			ParentCommentId: c.ParentCommentId,
			BlogId:          c.BlogId,
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

// CreateBlogComment implements blogs.Store.
func (bs *BlogStore) CreateBlogComment(
	content string,
	blogId uint,
	userId uint,
	parentCommentId *uint,
) (*responses.BlogCommentsResponse, error) {
	comment := &models.BlogComment{
		Content:         content,
		BlogId:          blogId,
		UserID:          userId,
		ParentCommentId: parentCommentId,
	}
	err := bs.db.Create(comment).Error
	if err != nil {
		return nil, err
	}

	// Preload the user for the response
	err = bs.db.Preload("User").First(comment).Error
	if err != nil {
		return nil, err
	}

	response := &responses.BlogCommentsResponse{
		ID:              comment.ID,
		Content:         comment.Content,
		ParentCommentId: comment.ParentCommentId,
		BlogId:          comment.BlogId,
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

// ToggleLikeBlog implements blogs.Store.
func (bs *BlogStore) ToggleLikeBlog(blogId uint, userId uint) (bool, error) {
	var existingLike models.BlogLike
	err := bs.db.Where("blog_id = ? AND user_id = ?", blogId, userId).First(&existingLike).Error

	if errors.Is(err, gorm.ErrRecordNotFound) {
		// Like doesn't exist, create it
		like := &models.BlogLike{
			BlogId: blogId,
			UserID: userId,
		}
		err = bs.db.Create(like).Error
		if err != nil {
			return false, err
		}
		return true, nil // liked
	}

	if err != nil {
		return false, err
	}

	// Like exists, delete it (unlike)
	err = bs.db.Delete(&existingLike).Error
	if err != nil {
		return false, err
	}

	return false, nil // unliked
}

// CreateBlog implements blogs.Store.
func (bs *BlogStore) CreateBlog(
	title string,
	content string,
	userId uint,
	tags *string,
) (*models.Blog, error) {
	blog := &models.Blog{
		Title:   title,
		Content: content,
		UserID:  userId,
		Tags:    tags,
	}
	err := bs.db.Create(blog).Error
	if err != nil {
		return nil, fmt.Errorf("error creating blog: %s", err.Error())
	}

	return blog, nil
}

// GetBlog implements blogs.Store.
func (bs *BlogStore) GetBlog(blogId uint, userId *uint) (*responses.BlogResponse, error) {
	var blog models.Blog
	err := bs.db.Preload("BlogComments").Preload("User").Preload("BlogLikes").Where("id = ?", blogId).First(&blog).Error
	if errors.Is(err, gorm.ErrRecordNotFound) {
		return nil, err
	}
	if err != nil {
		return nil, fmt.Errorf("an unexpected error occured when retrieving blog: %s", err.Error())
	}

	commentCount := len(blog.BlogComments)
	likesCount := len(blog.BlogLikes)
	user := responses.UserResponse{
		ID:        blog.User.ID,
		FirstName: blog.User.FirstName,
		LastName:  blog.User.LastName,
	}

	// Check if user has liked this blog
	isLiked := false
	if userId != nil {
		for _, like := range blog.BlogLikes {
			if like.UserID == *userId {
				isLiked = true
				break
			}
		}
	}

	blogResp := &responses.BlogResponse{
		ID:            blog.ID,
		Title:         blog.Title,
		Content:       blog.Content,
		User:          user,
		CommentsCount: int64(commentCount),
		LikesCount:    int64(likesCount),
		IsLiked:       isLiked,
		CreatedAt:     blog.CreatedAt,
		UpdatedAt:     blog.UpdatedAt,
	}

	return blogResp, nil
}

// GetBlogs implements blogs.Store.
func (bs *BlogStore) GetBlogs(page int, limit int, userId *uint, tags *string) ([]responses.BlogResponse, int, error) {
	var blogs []models.Blog
	var response []responses.BlogResponse
	var totalCount int64

	// Build base query for counting
	query := bs.db.Model(&models.Blog{})

	// Add tag filtering if tags parameter is provided
	if tags != nil && strings.TrimSpace(*tags) != "" {
		// Split tags by comma and create LIKE conditions for each tag
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
		return nil, 0, fmt.Errorf("error counting blogs: %s", err)
	}

	// Get paginated results with preloading
	offset := utils.GetOffset(page, limit)
	finalQuery := bs.db.Preload("BlogComments").Preload("User").Preload("BlogLikes")

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

	err := finalQuery.Limit(limit).Offset(offset).Order("created_at DESC").Find(&blogs).Error
	if err != nil {
		return nil, 0, fmt.Errorf("an unexpected error occured when retrieving paginated blogs: %s", err.Error())
	}

	// Build response DTOs
	for _, blog := range blogs {
		commentCount := len(blog.BlogComments)
		likesCount := len(blog.BlogLikes)
		user := responses.UserResponse{
			ID:        blog.User.ID,
			FirstName: blog.User.FirstName,
			LastName:  blog.User.LastName,
		}

		// Check if user has liked this blog
		isLiked := false
		if userId != nil {
			for _, like := range blog.BlogLikes {
				if like.UserID == *userId {
					isLiked = true
					break
				}
			}
		}

		blogResp := &responses.BlogResponse{
			ID:            blog.ID,
			Title:         blog.Title,
			Content:       blog.Content,
			Tags:          blog.Tags,
			User:          user,
			CommentsCount: int64(commentCount),
			LikesCount:    int64(likesCount),
			IsLiked:       isLiked,
			CreatedAt:     blog.CreatedAt,
			UpdatedAt:     blog.UpdatedAt,
		}
		response = append(response, *blogResp)
	}

	return response, int(totalCount), nil
}

func NewBlogStore(db *gorm.DB) *BlogStore {
	return &BlogStore{
		db: db,
	}
}
