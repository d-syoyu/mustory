from uuid import UUID

from fastapi import APIRouter, HTTPException, status

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
