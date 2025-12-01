"""add_recommended_tracks_table

Revision ID: 202512011500
Revises: 202502181000
Create Date: 2025-12-01 15:00:00.000000

"""
from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects import postgresql

# revision identifiers, used by Alembic.
revision = '202512011500'
down_revision = '202502181000'
branch_labels = None
depends_on = None


def upgrade():
    op.create_table(
        'recommended_tracks',
        sa.Column('id', postgresql.UUID(as_uuid=True), primary_key=True, server_default=sa.text('gen_random_uuid()')),
        sa.Column('user_id', postgresql.UUID(as_uuid=True), sa.ForeignKey('users.id', ondelete='CASCADE'), nullable=False),
        sa.Column('track_id', postgresql.UUID(as_uuid=True), sa.ForeignKey('tracks.id', ondelete='CASCADE'), nullable=False),
        sa.Column('score', sa.Float(), nullable=False),
        sa.Column('created_at', sa.DateTime(timezone=True), server_default=sa.func.now(), nullable=False),
        sa.UniqueConstraint('user_id', 'track_id', name='unique_user_track_recommendation')
    )
    op.create_index('ix_recommended_tracks_user_id', 'recommended_tracks', ['user_id'])
    op.create_index('ix_recommended_tracks_score', 'recommended_tracks', ['score'])


def downgrade():
    op.drop_table('recommended_tracks')
