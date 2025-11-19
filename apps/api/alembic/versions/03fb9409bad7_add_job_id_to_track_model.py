"""Add job_id to Track model

Revision ID: 03fb9409bad7
Revises: 202502181000
Create Date: 2025-11-17 20:48:05.507735

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision: str = '03fb9409bad7'
down_revision: Union[str, None] = '202502181000'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    # Add job_id column to tracks table for tracking RQ job status
    op.add_column('tracks', sa.Column('job_id', sa.String(length=255), nullable=True))


def downgrade() -> None:
    # Remove job_id column from tracks table
    op.drop_column('tracks', 'job_id')
