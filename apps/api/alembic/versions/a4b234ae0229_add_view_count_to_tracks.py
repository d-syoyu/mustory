"""add_view_count_to_tracks

Revision ID: a4b234ae0229
Revises: 8c40e2d36e87
Create Date: 2025-11-17 18:46:39.672285

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision: str = 'a4b234ae0229'
down_revision: Union[str, None] = '8c40e2d36e87'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    # Add view_count column to tracks table
    op.add_column('tracks', sa.Column('view_count', sa.Integer(), nullable=False, server_default='0'))


def downgrade() -> None:
    # Remove view_count column from tracks table
    op.drop_column('tracks', 'view_count')
