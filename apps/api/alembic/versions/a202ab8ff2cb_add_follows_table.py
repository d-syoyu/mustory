"""add_follows_table

Revision ID: a202ab8ff2cb
Revises: 03fb9409bad7
Create Date: 2025-11-18 15:51:10.649602

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects import postgresql

# revision identifiers, used by Alembic.
revision: str = 'a202ab8ff2cb'
down_revision: Union[str, None] = '03fb9409bad7'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    op.create_table(
        'follows',
        sa.Column('follower_id', postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column('followee_id', postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column('created_at', sa.DateTime(timezone=True), server_default=sa.text('now()'), nullable=False),
        sa.ForeignKeyConstraint(['follower_id'], ['users.id'], ondelete='CASCADE'),
        sa.ForeignKeyConstraint(['followee_id'], ['users.id'], ondelete='CASCADE'),
        sa.PrimaryKeyConstraint('follower_id', 'followee_id'),
        sa.UniqueConstraint('follower_id', 'followee_id', name='unique_follow')
    )

    # Create indexes for efficient queries
    op.create_index('ix_follows_follower_id', 'follows', ['follower_id'])
    op.create_index('ix_follows_followee_id', 'follows', ['followee_id'])


def downgrade() -> None:
    op.drop_index('ix_follows_followee_id', table_name='follows')
    op.drop_index('ix_follows_follower_id', table_name='follows')
    op.drop_table('follows')
