from pathlib import Path

import numpy as np
import soundfile as sf

from app.services.audio_analysis import extract_audio_features


def test_extract_audio_features_returns_expected_dimensions(tmp_path: Path) -> None:
    sample_rate = 22_050
    duration_seconds = 2
    t = np.linspace(0, duration_seconds, sample_rate * duration_seconds, endpoint=False)
    # Simple 440Hz tone with moderate amplitude
    waveform = 0.3 * np.sin(2 * np.pi * 440 * t)
    audio_path = tmp_path / "tone.wav"
    sf.write(audio_path, waveform, sample_rate)

    features = extract_audio_features(audio_path)

    assert features.duration_seconds == duration_seconds
    assert features.audio_embedding
    assert len(features.audio_embedding) == 128
    assert -80 <= features.loudness_lufs <= 0
    assert 0 <= features.mood_valence <= 1
    assert 0 <= features.mood_energy <= 1
