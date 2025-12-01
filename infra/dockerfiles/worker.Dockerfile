FROM python:3.11-slim

# Install FFmpeg and system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    ffmpeg \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

# Copy API app files (worker uses same codebase as API)
COPY apps/api/pyproject.toml ./apps/api/
COPY apps/api/README.md ./apps/api/
COPY apps/api/app ./apps/api/app

# Install Python dependencies
RUN pip install --upgrade pip && pip install -e ./apps/api

# Run RQ worker for track processing
CMD ["sh", "-c", "rq worker track_processing --url ${REDIS_URL:-redis://redis:6379/0}"]
