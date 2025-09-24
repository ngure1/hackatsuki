package store

import (
	"apiv2/internal/models"
	"apiv2/responses"
	"apiv2/utils"
	"errors"
	"fmt"

	"gorm.io/gorm"
)

type PostStore struct {
	db *gorm.DB
}

// GetCommentReplies implements posts.Store.
func (ps *PostStore) GetCommentReplies(commentId uint, page int, limit int) ([]models.Comment, int, error) {
	var comments []models.Comment
	var totalCount int64
	err := ps.db.Model(&models.Comment{}).Where("parent_comment_id = ?", commentId).Count(&totalCount).Error
	if err != nil {
		return nil, 0, fmt.Errorf("an unexpected error occured when counting comment replies: %s", err.Error())
	}

	offset := utils.GetOffset(page, limit)
	err = ps.db.Limit(limit).Offset(offset).Where("parent_comment_id = ?", commentId).Find(&comments).Error
	if errors.Is(err, gorm.ErrRecordNotFound) {
		return nil, 0, err
	}
	if err != nil {
		return nil, 0, fmt.Errorf("an unexpected error occured when querying comment replies: %s", err.Error())
	}

	return comments, int(totalCount), nil
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
	err = ps.db.Limit(limit).
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
			UserID:          c.UserID,
			CreatedAt:       c.CreatedAt,
			RepliesCount:    replyMap[c.ID],
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
) (*models.Comment, error) {
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

	return comment, nil
}

// LikePost implements posts.Store.
func (ps *PostStore) LikePost(postId uint, userId uint) error {
	like := &models.Like{
		PostId: postId,
		UserID: userId,
	}
	err := ps.db.Create(like).Error
	if err != nil {
		return err
	}

	return nil
}

// CreatePost implements posts.Store.
func (ps *PostStore) CreatePost(
	question string,
	description string,
	userId uint,
	crop *string,
	imageUrl *string,
) (*models.Post, error) {
	post := &models.Post{
		Question:    question,
		Description: description,
		Crop:        crop,
		ImageUrl:    imageUrl,
		UserID:      userId,
	}
	err := ps.db.Create(post).Error
	if err != nil {
		return nil, fmt.Errorf("error creating post: %s", err.Error())
	}

	return post, nil
}

// GetPost implements posts.Store.
func (ps *PostStore) GetPost(postId uint) (*models.Post, error) {
	var post models.Post
	err := ps.db.Where("id = ?", postId).First(&post).Error
	if errors.Is(err, gorm.ErrRecordNotFound) {
		return nil, err
	}
	if err != nil {
		return nil, fmt.Errorf("an unexpected error occured when retrieving post: %s", err.Error())
	}

	return &post, nil
}

// GetPosts implements posts.Store.
func (ps *PostStore) GetPosts(page int, limit int) ([]models.Post, int, error) {
	var posts []models.Post
	var totalCount int64

	if err := ps.db.Model(&models.Post{}).Count(&totalCount).Error; err != nil {
		return nil, 0, fmt.Errorf("error counting posts: %s", err)
	}

	offset := utils.GetOffset(page, limit)
	err := ps.db.Limit(limit).Offset(offset).Find(&posts).Error

	if err != nil {
		return nil, 0, fmt.Errorf("an unexpected error occured when retrieving paginated posts: %s", err.Error())
	}

	return posts, int(totalCount), nil
}

func NewPostStore(db *gorm.DB) *PostStore {
	return &PostStore{
		db: db,
	}
}
