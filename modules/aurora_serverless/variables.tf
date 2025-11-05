variable "cluster_name" {
  description = "Name of the Aurora cluster"
  type        = string
}

variable "database_name" {
  description = "Name of the database to create"
  type        = string
  default     = "vectordb"
}

variable "master_username" {
  description = "Master username for the Aurora cluster"
  type        = string
  default     = "postgres"
}

variable "master_password" {
  description = "Master password for the Aurora cluster"
  type        = string
  sensitive   = true
}

variable "vpc_id" {
  description = "ID of the VPC where Aurora will be deployed"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs for the Aurora cluster"
  type        = list(string)
}

variable "allowed_security_group_ids" {
  description = "List of security group IDs allowed to access Aurora"
  type        = list(string)
  default     = []
}

variable "allowed_cidr_blocks" {
  description = "List of CIDR blocks allowed to access Aurora"
  type        = list(string)
  default     = []
}

variable "min_capacity" {
  description = "Minimum Aurora capacity"
  type        = number
  default     = 0.5
}

variable "max_capacity" {
  description = "Maximum Aurora capacity"
  type        = number
  default     = 1
}

variable "backup_retention_period" {
  description = "Days to retain backups"
  type        = number
  default     = 7
}

variable "preferred_backup_window" {
  description = "Preferred backup window"
  type        = string
  default     = "03:00-04:00"
}

variable "preferred_maintenance_window" {
  description = "Preferred maintenance window"
  type        = string
  default     = "sun:04:00-sun:05:00"
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}