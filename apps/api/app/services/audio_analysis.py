from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path
from typing import Iterable

import librosa
import numpy as np


@dataclass(slots=True)
class AudioFeatureSet:
    """Normalized bundle of per-track audio descriptors."""

    duration_seconds: int
    bpm: float | None
    loudness_lufs: float
    mood_valence: float
    mood_energy: float
    has_vocals: bool
    audio_embedding: list[float]


def extract_audio_features(audio_path: str | Path) -> AudioFeatureSet:
    """Run lightweight audio analysis for a track."""
    waveform, sample_rate = librosa.load(
        str(audio_path),
        sr=22_050,
        mono=True,
    )
    duration_seconds = int(round(librosa.get_duration(y=waveform, sr=sample_rate)))

    bpm = _estimate_bpm(waveform, sample_rate)
    loudness = _estimate_loudness(waveform)
    valence, energy = _estimate_mood(waveform, sample_rate)

    mel_spectrogram = librosa.feature.melspectrogram(
        y=waveform,
        sr=sample_rate,
        n_mels=128,
        fmin=60,
        fmax=12_000,
        hop_length=512,
    )
    embedding = _build_audio_embedding(mel_spectrogram)
    has_vocals = _estimate_vocals(mel_spectrogram)

    return AudioFeatureSet(
        duration_seconds=duration_seconds,
        bpm=bpm,
        loudness_lufs=loudness,
        mood_valence=valence,
        mood_energy=energy,
        has_vocals=has_vocals,
        audio_embedding=embedding,
    )


def _estimate_bpm(waveform: np.ndarray, sample_rate: int) -> float | None:
    try:
        tempo, _ = librosa.beat.beat_track(y=waveform, sr=sample_rate)
        return float(tempo) if tempo and tempo > 0 else None
    except Exception:
        return None


def _estimate_loudness(waveform: np.ndarray) -> float:
    rms = float(np.mean(librosa.feature.rms(y=waveform)))
    return float(20 * np.log10(max(rms, 1e-8)))


def _estimate_mood(waveform: np.ndarray, sample_rate: int) -> tuple[float, float]:
    rms = float(np.mean(librosa.feature.rms(y=waveform)))
    centroid = float(np.mean(librosa.feature.spectral_centroid(y=waveform, sr=sample_rate)))

    energy = float(np.clip(rms / 0.4, 0.0, 1.0))
    valence = float(np.clip((centroid - 500) / 5000, 0.0, 1.0))
    return valence, energy


def _build_audio_embedding(mel_spectrogram: np.ndarray) -> list[float]:
    log_mel = librosa.power_to_db(mel_spectrogram + 1e-9, ref=np.max)
    embedding = log_mel.mean(axis=1)
    embedding = (embedding - embedding.mean()) / (embedding.std() + 1e-6)
    normalized = embedding / (np.linalg.norm(embedding) + 1e-6)
    return normalized.astype(float).tolist()


def _estimate_vocals(mel_spectrogram: np.ndarray) -> bool:
    freqs = librosa.mel_frequencies(
        n_mels=mel_spectrogram.shape[0],
        fmin=60,
        fmax=12_000,
    )
    vocal_mask = (freqs >= 300) & (freqs <= 3_400)
    vocal_energy = float(mel_spectrogram[vocal_mask].sum())
    total_energy = float(mel_spectrogram.sum()) + 1e-9
    ratio = vocal_energy / total_energy
    return ratio > 0.28


__all__: Iterable[str] = ["AudioFeatureSet", "extract_audio_features"]
