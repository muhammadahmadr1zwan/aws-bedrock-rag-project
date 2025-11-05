variable "aws_region" {
  description = "AWS region for resources"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Name of the project - used for resource naming"
  type        = string
  default     = "bedrock-kb"
}

variable "environment" {
  description = "Environment name (e.g., dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "knowledge_base_name" {
  description = "Name for the Bedrock Knowledge Base (optional - will be auto-generated if not provided)"
  type        = string
  default     = ""
}

variable "knowledge_base_description" {
  description = "Description for the Bedrock Knowledge Base"
  type        = string
  default     = "Knowledge Base for document retrieval and Q&A"
}

variable "s3_bucket_arn" {
  description = "ARN of the S3 bucket containing documents"
  type        = string
}

variable "s3_bucket_name" {
  description = "Name of the S3 bucket containing documents"
  type        = string
}

variable "s3_object_key_prefix" {
  description = "Optional prefix for S3 objects to include in the knowledge base"
  type        = string
  default     = ""
}

variable "aurora_cluster_arn" {
  description = "ARN of the Aurora PostgreSQL cluster"
  type        = string
}

variable "aurora_database_name" {
  description = "Name of the Aurora database"
  type        = string
  default     = "vectordb"
}

variable "aurora_master_username" {
  description = "Master username for Aurora cluster"
  type        = string
  default     = "postgres"
}

variable "aurora_master_password" {
  description = "Master password for Aurora cluster"
  type        = string
  sensitive   = true
}

variable "aurora_table_name" {
  description = "Name of the table for storing vectors"
  type        = string
  default     = "bedrock_kb_vectors"
}

variable "embedding_model_arn" {
  description = "ARN of the embedding model to use"
  type        = string
  default     = "arn:aws:bedrock:us-east-1::foundation-model/amazon.titan-embed-text-v1"
}

variable "chunking_strategy" {
  description = "Chunking strategy for document processing"
  type        = string
  default     = "FIXED_SIZE"
  
  validation {
    condition     = contains(["FIXED_SIZE", "NONE"], var.chunking_strategy)
    error_message = "Chunking strategy must be either FIXED_SIZE or NONE."
  }
}

variable "max_tokens" {
  description = "Maximum tokens per chunk (only used with FIXED_SIZE chunking)"
  type        = number
  default     = 300
}

variable "overlap_percentage" {
  description = "Overlap percentage between chunks (only used with FIXED_SIZE chunking)"
  type        = number
  default     = 20
  
  validation {
    condition     = var.overlap_percentage >= 1 && var.overlap_percentage <= 99
    error_message = "Overlap percentage must be between 1 and 99."
  }
}

variable "tags" {
  description = "Additional tags to apply to resources"
  type        = map(string)
  default     = {}
}