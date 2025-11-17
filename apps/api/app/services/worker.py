"""FFmpeg worker for processing audio tracks to HLS format."""

from __future__ import annotations

import logging
import os
import subprocess
import tempfile
from pathlib import Path
from uuid import UUID

from sqlalchemy import create_engine
from sqlalchemy.orm import Session

from ..core.config import get_settings
from ..core.storage import StorageClient
from ..db import models
from .audio_analysis import AudioFeatureSet, extract_audio_features

logger = logging.getLogger(__name__)


def process_track_to_hls(track_id: str) -> None:
    """Process an uploaded track to HLS format using FFmpeg.

    This function:
    1. Downloads the original audio file from R2
    2. Converts it to HLS format using FFmpeg
    3. Uploads the HLS files (.m3u8 and .ts segments) to R2
    4. Updates the track record with the HLS URL

    Args:
        track_id: UUID of the track to process
    """
    logger.info(f"Starting HLS conversion for track {track_id}")

    # Get settings
    settings = get_settings()

    # Create database session
    engine = create_engine(str(settings.database_url))
    db = Session(engine)

    try:
        # Get track from database
        track = db.get(models.Track, UUID(track_id))
        if not track:
            logger.error(f"Track {track_id} not found")
            return

        # Update status to processing
        track.processing_status = models.TrackProcessingStatus.PROCESSING
        db.commit()

        # Initialize storage client
        storage = StorageClient()

        # Create temporary directory for processing
        with tempfile.TemporaryDirectory() as tmpdir:
            tmp_path = Path(tmpdir)

            # Step 1: Download original audio file
            logger.info(f"Downloading original audio for track {track_id}")
            original_key = f"tracks/{track_id}/original.{_get_extension(track.original_audio_url)}"
            original_file = tmp_path / "original.mp3"

            # Download from R2
            storage.download_file(original_key, str(original_file))
            logger.info(f"Downloaded {original_key} to {original_file}")

            # Extract audio features before mutating the file
            audio_features: AudioFeatureSet | None = None
            try:
                audio_features = extract_audio_features(original_file)
            except Exception as feature_error:  # pragma: no cover - logging path
                logger.warning("Audio analysis failed for %s: %s", track_id, feature_error)

            # Step 2: Convert to HLS using FFmpeg
            logger.info(f"Converting track {track_id} to HLS")
            hls_dir = tmp_path / "hls"
            hls_dir.mkdir()
            playlist_file = hls_dir / "playlist.m3u8"

            # FFmpeg command for HLS conversion
            # -codec:a aac: Use AAC audio codec (widely supported)
            # -b:a 128k: Audio bitrate 128kbps
            # -hls_time 10: 10 second segments
            # -hls_list_size 0: Include all segments in playlist
            # -hls_segment_filename: Pattern for segment files
            ffmpeg_cmd = [
                "ffmpeg",
                "-i", str(original_file),
                "-codec:a", "aac",
                "-b:a", "128k",
                "-vn",  # No video
                "-hls_time", "10",
                "-hls_list_size", "0",
                "-hls_segment_filename", str(hls_dir / "segment_%03d.ts"),
                str(playlist_file),
            ]

            result = subprocess.run(
                ffmpeg_cmd,
                capture_output=True,
                text=True,
                check=True,
            )
            logger.info(f"FFmpeg conversion completed for track {track_id}")

            # Step 3: Upload HLS files to R2
            logger.info(f"Uploading HLS files for track {track_id}")

            # Upload playlist file
            playlist_key = f"tracks/{track_id}/hls/playlist.m3u8"
            storage.upload_file(
                str(playlist_file),
                playlist_key,
                content_type="application/vnd.apple.mpegurl",
            )
            logger.info(f"Uploaded playlist: {playlist_key}")

            # Upload all .ts segment files
            for segment_file in hls_dir.glob("*.ts"):
                segment_key = f"tracks/{track_id}/hls/{segment_file.name}"
                storage.upload_file(
                    str(segment_file),
                    segment_key,
                    content_type="video/MP2T",
                )
                logger.info(f"Uploaded segment: {segment_key}")

            # Step 4: Update track with HLS URL and audio descriptors
            hls_url = storage.get_public_url(playlist_key)
            track.hls_url = hls_url
            track.processing_status = models.TrackProcessingStatus.COMPLETED
            if audio_features:
                track.duration_seconds = audio_features.duration_seconds
                track.bpm = audio_features.bpm
                track.loudness_lufs = audio_features.loudness_lufs
                track.mood_valence = audio_features.mood_valence
                track.mood_energy = audio_features.mood_energy
                track.has_vocals = audio_features.has_vocals
                track.audio_embedding = audio_features.audio_embedding
            db.commit()

            logger.info(f"Successfully processed track {track_id}")
            logger.info(f"HLS URL: {hls_url}")

    except subprocess.CalledProcessError as e:
        logger.error(f"FFmpeg failed for track {track_id}: {e.stderr}")
        track.processing_status = models.TrackProcessingStatus.FAILED
        track.processing_error = f"FFmpeg error: {e.stderr[:500]}"
        db.commit()
        raise

    except Exception as e:
        logger.error(f"Failed to process track {track_id}: {e}")
        track.processing_status = models.TrackProcessingStatus.FAILED
        track.processing_error = str(e)[:500]
        db.commit()
        raise

    finally:
        db.close()


def _get_extension(url: str) -> str:
    """Extract file extension from URL.

    Args:
        url: URL containing file path

    Returns:
        File extension without dot
    """
    # Extract filename from URL
    filename = url.split("/")[-1].split("?")[0]
    ext = filename.split(".")[-1] if "." in filename else "mp3"
    return ext
