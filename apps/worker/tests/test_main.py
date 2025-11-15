from mustory_worker.main import TranscodeJob


def test_job_dataclass_repr() -> None:
    job = TranscodeJob(
        track_id="1",
        source_url="https://example.com/foo.wav",
        output_prefix="tracks/1",
    )
    assert "track_id='1'" in repr(job)
