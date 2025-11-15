from uuid import UUID

from fastapi import APIRouter, HTTPException, status
from sqlalchemy import select

from ...db import models
from ...dependencies.auth import CurrentUser
from ...dependencies.database import DbSession

router = APIRouter(prefix="/comments", tags=["comments"])


@router.delete("/{comment_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_comment(
    comment_id: UUID,
    db: DbSession,
    current_user: CurrentUser,
) -> None:
    comment = db.get(models.Comment, comment_id)
    if not comment or comment.is_deleted:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Comment not found.")
    if comment.author_user_id != current_user.id and not current_user.is_admin:
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Forbidden.")

    comment.is_deleted = True
    db.add(comment)
    db.commit()


@router.post("/{comment_id}/like", status_code=status.HTTP_201_CREATED)
def like_comment(
    comment_id: UUID,
    db: DbSession,
    current_user: CurrentUser,
) -> dict:
    """Like a comment."""
    comment = db.get(models.Comment, comment_id)
    if not comment or comment.is_deleted:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Comment not found.")

    # Check if already liked
    existing_like = db.scalar(
        select(models.LikeComment).where(
            models.LikeComment.user_id == current_user.id,
            models.LikeComment.comment_id == comment_id,
        )
    )
    if existing_like:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Comment already liked.",
        )

    # Create like
    like = models.LikeComment(user_id=current_user.id, comment_id=comment_id)
    db.add(like)

    # Increment like_count
    comment.like_count += 1

    db.commit()
    return {"message": "Comment liked successfully."}


@router.delete("/{comment_id}/like", status_code=status.HTTP_200_OK)
def unlike_comment(
    comment_id: UUID,
    db: DbSession,
    current_user: CurrentUser,
) -> dict:
    """Unlike a comment."""
    comment = db.get(models.Comment, comment_id)
    if not comment or comment.is_deleted:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Comment not found.")

    # Find existing like
    like = db.scalar(
        select(models.LikeComment).where(
            models.LikeComment.user_id == current_user.id,
            models.LikeComment.comment_id == comment_id,
        )
    )
    if not like:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Like not found.",
        )

    # Delete like
    db.delete(like)

    # Decrement like_count
    if comment.like_count > 0:
        comment.like_count -= 1

    db.commit()
    return {"message": "Comment unliked successfully."}
