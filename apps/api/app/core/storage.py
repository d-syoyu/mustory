"""S3-compatible storage client for file uploads."""

import boto3
from botocore.client import Config
from botocore.exceptions import ClientError
from datetime import timedelta
import logging
from typing import Optional

from .config import get_settings

logger = logging.getLogger(__name__)


class StorageClient:
    """S3-compatible storage client (works with Cloudflare R2, AWS S3, MinIO, etc.)."""

    def __init__(self):
        settings = get_settings()

        # Initialize S3 client
        self.client = boto3.client(
            "s3",
            endpoint_url=settings.storage_endpoint or None,
            aws_access_key_id=settings.storage_access_key,
            aws_secret_access_key=settings.storage_secret_key,
            region_name=settings.storage_region,
            config=Config(signature_version="s3v4"),
        )

        self.bucket = settings.storage_bucket
        self.public_url = settings.storage_public_url

    def generate_presigned_upload_url(
        self,
        object_key: str,
        content_type: str = "audio/mpeg",
        expires_in: int = 3600,
    ) -> str:
        """
        Generate a presigned URL for uploading a file using PUT.

        Args:
            object_key: The S3 object key (path) for the file
            content_type: MIME type of the file
            expires_in: URL expiration time in seconds (default: 1 hour)

        Returns:
            Presigned PUT URL as string
        """
        try:
            # Use presigned PUT URL instead of POST (R2 compatible)
            url = self.client.generate_presigned_url(
                "put_object",
                Params={
                    "Bucket": self.bucket,
                    "Key": object_key,
                    "ContentType": content_type,
                },
                ExpiresIn=expires_in,
            )
            return url
        except ClientError as e:
            logger.error(f"Error generating presigned URL: {e}")
            raise

    def generate_presigned_download_url(
        self,
        object_key: str,
        expires_in: int = 3600,
    ) -> str:
        """
        Generate a presigned URL for downloading a file.

        Args:
            object_key: The S3 object key (path) for the file
            expires_in: URL expiration time in seconds (default: 1 hour)

        Returns:
            Presigned download URL
        """
        try:
            url = self.client.generate_presigned_url(
                "get_object",
                Params={"Bucket": self.bucket, "Key": object_key},
                ExpiresIn=expires_in,
            )
            return url
        except ClientError as e:
            logger.error(f"Error generating presigned download URL: {e}")
            raise

    def get_public_url(self, object_key: str) -> str:
        """
        Get the public URL for an uploaded file.

        Args:
            object_key: The S3 object key (path) for the file

        Returns:
            Public URL for the file
        """
        if self.public_url:
            return f"{self.public_url}/{object_key}"
        # Fallback to S3 URL format
        return f"{self.client.meta.endpoint_url}/{self.bucket}/{object_key}"

    def delete_file(self, object_key: str) -> bool:
        """
        Delete a file from storage.

        Args:
            object_key: The S3 object key (path) for the file

        Returns:
            True if successful, False otherwise
        """
        try:
            self.client.delete_object(Bucket=self.bucket, Key=object_key)
            logger.info(f"Deleted file: {object_key}")
            return True
        except ClientError as e:
            logger.error(f"Error deleting file {object_key}: {e}")
            return False

    def file_exists(self, object_key: str) -> bool:
        """
        Check if a file exists in storage.

        Args:
            object_key: The S3 object key (path) for the file

        Returns:
            True if file exists, False otherwise
        """
        try:
            self.client.head_object(Bucket=self.bucket, Key=object_key)
            return True
        except ClientError:
            return False

    def download_file(self, object_key: str, local_path: str) -> None:
        """
        Download a file from storage to local filesystem.

        Args:
            object_key: The S3 object key (path) for the file
            local_path: Local filesystem path to save the file
        """
        try:
            self.client.download_file(self.bucket, object_key, local_path)
            logger.info(f"Downloaded {object_key} to {local_path}")
        except ClientError as e:
            logger.error(f"Error downloading file {object_key}: {e}")
            raise

    def upload_file(
        self,
        local_path: str,
        object_key: str,
        content_type: str = "application/octet-stream",
    ) -> None:
        """
        Upload a file from local filesystem to storage.

        Args:
            local_path: Local filesystem path of the file to upload
            object_key: The S3 object key (path) for the file
            content_type: MIME type of the file
        """
        try:
            self.client.upload_file(
                local_path,
                self.bucket,
                object_key,
                ExtraArgs={"ContentType": content_type},
            )
            logger.info(f"Uploaded {local_path} to {object_key}")
        except ClientError as e:
            logger.error(f"Error uploading file to {object_key}: {e}")
            raise


# Singleton instance
_storage_client: Optional[StorageClient] = None


def get_storage_client() -> StorageClient:
    """Get or create the storage client singleton."""
    global _storage_client
    if _storage_client is None:
        _storage_client = StorageClient()
    return _storage_client
