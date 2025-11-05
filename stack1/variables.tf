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

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets"
  type        = list(string)
  default     = ["10.0.11.0/24", "10.0.12.0/24"]
}

variable "s3_bucket_name" {
  description = "Name for S3 bucket (optional - will be auto-generated if not provided)"
  type        = string
  default     = ""
}

variable "db_master_password" {
  description = "Master password for Aurora PostgreSQL cluster"
  type        = string
  sensitive   = true
  
  validation {
    condition     = length(var.db_master_password) >= 8
    error_message = "Database master password must be at least 8 characters long."
  }
}

variable "aurora_min_capacity" {
  description = "Minimum capacity for Aurora Serverless"
  type        = number
  default     = 0.5
}

variable "aurora_max_capacity" {
  description = "Maximum capacity for Aurora Serverless"
  type        = number
  default     = 1
}

variable "tags" {
  description = "Additional tags to apply to resources"
  type        = map(string)
  default     = {}
}