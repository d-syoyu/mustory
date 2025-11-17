"""Add audio analysis fields to tracks

Revision ID: 202502181000
Revises: a4b234ae0229
Create Date: 2025-02-18 10:00:00.000000
"""

from __future__ import annotations

from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision = "202502181000"
down_revision = "a4b234ae0229"
branch_labels = None
depends_on = None


def upgrade() -> None:
    op.add_column("tracks", sa.Column("bpm", sa.Float(), nullable=True))
    op.add_column("tracks", sa.Column("loudness_lufs", sa.Float(), nullable=True))
    op.add_column("tracks", sa.Column("mood_valence", sa.Float(), nullable=True))
    op.add_column("tracks", sa.Column("mood_energy", sa.Float(), nullable=True))
    op.add_column("tracks", sa.Column("has_vocals", sa.Boolean(), nullable=True))
    op.add_column("tracks", sa.Column("audio_embedding", sa.JSON(), nullable=True))
    op.add_column("tracks", sa.Column("tags", sa.JSON(), nullable=True))


def downgrade() -> None:
    op.drop_column("tracks", "tags")
    op.drop_column("tracks", "audio_embedding")
    op.drop_column("tracks", "has_vocals")
    op.drop_column("tracks", "mood_energy")
    op.drop_column("tracks", "mood_valence")
    op.drop_column("tracks", "loudness_lufs")
    op.drop_column("tracks", "bpm")
