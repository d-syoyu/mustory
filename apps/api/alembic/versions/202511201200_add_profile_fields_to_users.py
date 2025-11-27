"""add_profile_fields_to_users

Revision ID: 202511201200
Revises: a202ab8ff2cb
Create Date: 2025-11-20 12:00:00.000000
"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects import postgresql

# revision identifiers, used by Alembic.
revision: str = "202511201200"
down_revision: Union[str, None] = "a202ab8ff2cb"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    # Add new profile fields (nullable first for data backfill)
    op.add_column("users", sa.Column("username", sa.String(length=64), nullable=True))
    op.add_column("users", sa.Column("avatar_url", sa.String(length=2048), nullable=True))
    op.add_column("users", sa.Column("bio", sa.String(length=200), nullable=True))
    op.add_column("users", sa.Column("location", sa.String(length=120), nullable=True))
    op.add_column("users", sa.Column("link_url", sa.String(length=2048), nullable=True))
    op.add_column(
        "users",
        sa.Column(
            "updated_at",
            sa.DateTime(timezone=True),
            server_default=sa.text("now()"),
            nullable=False,
        ),
    )

    # Backfill username with a slug based on display_name + short uuid to ensure uniqueness
    op.execute(
        """
        UPDATE users
        SET username = lower(regexp_replace(display_name, '[^a-zA-Z0-9]+', '_', 'g')) || '_' || substr(id::text, 1, 8)
        WHERE username IS NULL;
        """
    )

    # Enforce NOT NULL and uniqueness on username after backfill
    op.alter_column("users", "username", existing_type=sa.String(length=64), nullable=False)
    op.create_unique_constraint("uq_users_username", "users", ["username"])
    op.create_index("ix_users_username", "users", ["username"])


def downgrade() -> None:
    op.drop_index("ix_users_username", table_name="users")
    op.drop_constraint("uq_users_username", "users", type_="unique")
    op.drop_column("users", "updated_at")
    op.drop_column("users", "link_url")
    op.drop_column("users", "location")
    op.drop_column("users", "bio")
    op.drop_column("users", "avatar_url")
    op.drop_column("users", "username")
