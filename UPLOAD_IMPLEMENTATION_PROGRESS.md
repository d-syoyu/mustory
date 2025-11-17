# Track Upload Feature - Implementation Progress

## 📅 Date: 2025-11-17

## ✅ Completed - Backend API

### 1. Database Schema Updates
- ✅ Added `TrackProcessingStatus` enum (PENDING, PROCESSING, COMPLETED, FAILED)
- ✅ Extended `Track` model with upload fields:
  - `original_audio_url` - Raw uploaded audio file location
  - `processing_status` - Current processing state
  - `processing_error` - Error message if processing fails
  - `duration_seconds` - Track duration (populated by FFmpeg)
- ✅ Created and ran Alembic migration successfully

### 2. Storage Configuration
- ✅ Added S3-compatible storage settings to `config.py`
  - Storage endpoint, access key, secret key
  - Bucket name and region
  - Public URL base
- ✅ Implemented `StorageClient` class ([storage.py](apps/api/app/core/storage.py))
  - Presigned URL generation for uploads
  - Presigned URL generation for downloads
  - File existence checking
  - File deletion

### 3. Upload API Endpoints
Created 3 new endpoints in [tracks.py](apps/api/app/api/routes/tracks.py):

#### POST /tracks/upload/init
- Initializes track upload
- Creates Track record with PENDING status
- Generates presigned URLs for audio + optional artwork upload
- Returns upload URLs and form fields for client

**Request:**
```json
{
  "title": "My Song",
  "artist_name": "Artist Name",
  "file_extension": "mp3",
  "file_size": 5242880,
  "artwork_extension": "jpg"
}
```

**Response:**
```json
{
  "track_id": "uuid",
  "audio_upload_url": "https://...",
  "audio_upload_fields": {...},
  "artwork_upload_url": "https://...",
  "artwork_upload_fields": {...}
}
```

#### POST /tracks/upload/complete
- Marks upload as complete
- Updates status to PROCESSING
- Triggers FFmpeg job (TODO: implement queue)

**Request:**
```json
{
  "track_id": "uuid"
}
```

#### GET /tracks/upload/status/{track_id}
- Returns processing status
- Shows progress percentage (TODO: from Redis job)
- Returns error message if failed

**Response:**
```json
{
  "track_id": "uuid",
  "status": "processing",
  "progress": 75,
  "error": null
}
```

### 4. Schema Definitions
- ✅ `TrackUploadInitRequest` - Upload initialization request
- ✅ `TrackUploadInitResponse` - Presigned URLs response
- ✅ `TrackUploadCompleteRequest` - Mark upload complete
- ✅ `TrackProcessingStatusResponse` - Processing status response

### 5. Testing
- ✅ All 20 existing API tests passing
- ✅ No regressions introduced
- ✅ Database migration successful

---

## 🔄 In Progress - Flutter Mobile App

### Next Tasks
1. **Upload UI Components**
   - File picker for audio files
   - Image picker for artwork
   - Metadata input form (title, artist name)
   - Upload progress indicator

2. **Upload Flow**
   - Call `/tracks/upload/init` to get presigned URLs
   - Upload audio file to S3 with progress tracking
   - Upload artwork to S3 (optional)
   - Call `/tracks/upload/complete` to trigger processing
   - Poll `/tracks/upload/status/{id}` for processing updates

3. **State Management**
   - Create `UploadController` with Riverpod
   - Handle upload states (idle, uploading, processing, completed, failed)
   - Track upload progress percentage

---

## 🚧 TODO - Worker & FFmpeg Integration

### FFmpeg Worker Tasks
1. **Queue System**
   - Set up Redis-backed job queue (RQ or Celery)
   - Create job enqueue function in API

2. **FFmpeg Processing**
   - Download original audio from S3
   - Convert to HLS format (m3u8 + segments)
   - Extract duration and metadata
   - Upload HLS files back to S3
   - Update Track record with HLS URL and status

3. **Error Handling**
   - Retry logic for failed jobs
   - Error logging and reporting
   - Update Track.processing_error on failure

---

## 📚 Dependencies Needed

### Backend (Python)
```bash
pip install boto3  # S3 client (already in requirements)
pip install rq  # Redis queue (TODO)
pip install ffmpeg-python  # FFmpeg wrapper (TODO)
```

### Flutter (Dart)
```yaml
dependencies:
  file_picker: ^6.0.0  # File selection
  image_picker: ^1.0.0  # Image selection
  http: ^1.1.0  # HTTP client for S3 upload
  dio: ^5.4.0  # Already installed
```

---

## 🎯 Current Status

**Backend:** ✅ Ready for testing (minus FFmpeg worker)
**Frontend:** 🔄 Next step - build upload UI
**Worker:** 📋 TODO - implement queue and FFmpeg processing

The upload API is fully functional and can be tested with curl or Postman once storage credentials are configured.

---

## 🔐 Environment Variables Needed

Add to `apps/api/.env`:
```env
# S3-Compatible Storage (Cloudflare R2 / AWS S3)
STORAGE_ENDPOINT=https://your-account.r2.cloudflarestorage.com
STORAGE_ACCESS_KEY=your_access_key
STORAGE_SECRET_KEY=your_secret_key
STORAGE_BUCKET=mustory-audio
STORAGE_REGION=auto
STORAGE_PUBLIC_URL=https://pub-xxxxx.r2.dev
```
