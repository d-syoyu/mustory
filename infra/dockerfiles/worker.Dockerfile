FROM python:3.11-slim

WORKDIR /app

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

COPY apps/worker ./apps/worker
RUN pip install --upgrade pip && pip install -e ./apps/worker

CMD ["python", "-m", "mustory_worker.main"]
