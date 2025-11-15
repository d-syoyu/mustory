# Infrastructure

The `infra/` folder centralizes local orchestration resources:

- `docker-compose.yml`: spins up Postgres, Redis, API, and worker containers.
- `dockerfiles/`: production-ready build contexts for API/worker services.

## Local bootstrap

```bash
docker compose -f infra/docker-compose.yml up --build
```

## Next steps

1. Mirror this compose file into Railway templates (api + worker).
2. Add storage mock (MinIO/R2) for media uploads once ffmpeg integration is ready.
3. Wire CI to build these Dockerfiles on pull requests.
