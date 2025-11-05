#!/usr/bin/env python3
"""
Script to upload files from the spec-sheets folder to an S3 bucket.
This script maintains the folder structure in S3 and supports various file types.

Usage:
    python scripts/upload_to_s3.py

Make sure to:
1. Update the bucket_name variable below with your S3 bucket name
2. Configure AWS credentials (AWS CLI, environment variables, or IAM role)
3. Place your documents in the spec-sheets folder
"""

import os
import sys
import boto3
import mimetypes
from pathlib import Path
from botocore.exceptions import ClientError, NoCredentialsError

# Configuration
BUCKET_NAME = "your-bucket-name-here"  # TODO: Update this with your actual S3 bucket name
LOCAL_FOLDER = "spec-sheets"  # Local folder containing files to upload
S3_PREFIX = ""  # Optional: prefix for S3 keys (e.g., "documents/")

# Supported file types for Bedrock Knowledge Base
SUPPORTED_EXTENSIONS = {
    '.pdf', '.txt', '.md', '.html', '.csv', '.doc', '.docx',
    '.xls', '.xlsx', '.ppt', '.pptx'
}

def get_s3_client():
    """
    Create and return an S3 client.
    """
    try:
        s3_client = boto3.client('s3')
        # Test the credentials by listing buckets
        s3_client.list_buckets()
        return s3_client
    except NoCredentialsError:
        print("Error: AWS credentials not found. Please configure your credentials.")
        print("You can use:")
        print("  - AWS CLI: aws configure")
        print("  - Environment variables: AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY")
        print("  - IAM role (if running on EC2)")
        sys.exit(1)
    except Exception as e:
        print(f"Error creating S3 client: {e}")
        sys.exit(1)

def check_bucket_exists(s3_client, bucket_name):
    """
    Check if the S3 bucket exists and is accessible.
    """
    try:
        s3_client.head_bucket(Bucket=bucket_name)
        return True
    except ClientError as e:
        error_code = e.response['Error']['Code']
        if error_code == '404':
            print(f"Error: Bucket '{bucket_name}' does not exist.")
        elif error_code == '403':
            print(f"Error: Access denied to bucket '{bucket_name}'. Check your permissions.")
        else:
            print(f"Error checking bucket '{bucket_name}': {e}")
        return False

def get_content_type(file_path):
    """
    Determine the content type of a file.
    """
    content_type, _ = mimetypes.guess_type(file_path)
    if content_type is None:
        content_type = 'application/octet-stream'
    return content_type

def upload_file(s3_client, local_file_path, bucket_name, s3_key):
    """
    Upload a single file to S3.
    """
    try:
        content_type = get_content_type(local_file_path)
        
        with open(local_file_path, 'rb') as file:
            s3_client.upload_fileobj(
                file,
                bucket_name,
                s3_key,
                ExtraArgs={
                    'ContentType': content_type,
                    'ServerSideEncryption': 'AES256'
                }
            )
        
        file_size = os.path.getsize(local_file_path)
        print(f"  ✓ Uploaded: {s3_key} ({file_size:,} bytes)")
        return True
        
    except Exception as e:
        print(f"  ✗ Failed to upload {s3_key}: {e}")
        return False

def get_files_to_upload(local_folder):
    """
    Get a list of files to upload from the local folder.
    """
    files_to_upload = []
    local_path = Path(local_folder)
    
    if not local_path.exists():
        print(f"Error: Local folder '{local_folder}' does not exist.")
        return files_to_upload
    
    if not local_path.is_dir():
        print(f"Error: '{local_folder}' is not a directory.")
        return files_to_upload
    
    # Recursively find all files
    for file_path in local_path.rglob('*'):
        if file_path.is_file():
            # Check if file extension is supported
            file_extension = file_path.suffix.lower()
            if file_extension in SUPPORTED_EXTENSIONS:
                # Calculate relative path for S3 key
                relative_path = file_path.relative_to(local_path)
                s3_key = str(relative_path).replace('\\', '/')  # Ensure forward slashes
                
                if S3_PREFIX:
                    s3_key = f"{S3_PREFIX.rstrip('/')}/{s3_key}"
                
                files_to_upload.append((str(file_path), s3_key))
            else:
                print(f"  ⚠ Skipping unsupported file type: {file_path}")
    
    return files_to_upload

def main():
    """
    Main function to upload files to S3.
    """
    print("AWS S3 File Upload Script for Bedrock Knowledge Base")
    print("=" * 55)
    
    # Validate configuration
    if BUCKET_NAME == "your-bucket-name-here":
        print("Error: Please update the BUCKET_NAME variable in this script with your actual S3 bucket name.")
        sys.exit(1)
    
    # Create S3 client
    print("Initializing S3 client...")
    s3_client = get_s3_client()
    
    # Check if bucket exists
    print(f"Checking bucket '{BUCKET_NAME}'...")
    if not check_bucket_exists(s3_client, BUCKET_NAME):
        sys.exit(1)
    
    # Get files to upload
    print(f"Scanning local folder '{LOCAL_FOLDER}'...")
    files_to_upload = get_files_to_upload(LOCAL_FOLDER)
    
    if not files_to_upload:
        print(f"No supported files found in '{LOCAL_FOLDER}'.")
        print(f"Supported file types: {', '.join(sorted(SUPPORTED_EXTENSIONS))}")
        return
    
    # Display upload plan
    print(f"\nFound {len(files_to_upload)} file(s) to upload:")
    for local_file, s3_key in files_to_upload:
        file_size = os.path.getsize(local_file)
        print(f"  {local_file} -> s3://{BUCKET_NAME}/{s3_key} ({file_size:,} bytes)")
    
    # Confirm upload
    response = input(f"\nProceed with uploading {len(files_to_upload)} file(s) to '{BUCKET_NAME}'? (y/N): ")
    if response.lower() not in ['y', 'yes']:
        print("Upload cancelled.")
        return
    
    # Upload files
    print(f"\nUploading files to s3://{BUCKET_NAME}/...")
    successful_uploads = 0
    failed_uploads = 0
    
    for local_file, s3_key in files_to_upload:
        if upload_file(s3_client, local_file, BUCKET_NAME, s3_key):
            successful_uploads += 1
        else:
            failed_uploads += 1
    
    # Summary
    print(f"\nUpload Summary:")
    print(f"  ✓ Successful: {successful_uploads}")
    print(f"  ✗ Failed: {failed_uploads}")
    print(f"  📁 Bucket: s3://{BUCKET_NAME}/")
    
    if successful_uploads > 0:
        print(f"\n📝 Next steps:")
        print(f"  1. Go to the AWS Bedrock console")
        print(f"  2. Navigate to your Knowledge Base")
        print(f"  3. Sync the data source to ingest the uploaded documents")
        print(f"  4. Wait for the sync to complete before querying")
    
    if failed_uploads > 0:
        print(f"\n⚠ Some uploads failed. Please check the error messages above.")

if __name__ == "__main__":
    main()
