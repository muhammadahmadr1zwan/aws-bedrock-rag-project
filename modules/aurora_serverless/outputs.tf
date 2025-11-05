output "cluster_id" {
  description = "ID of the Aurora cluster"
  value       = aws_rds_cluster.aurora_serverless.cluster_identifier
}

output "cluster_arn" {
  description = "ARN of the Aurora cluster"
  value       = aws_rds_cluster.aurora_serverless.arn
}

output "cluster_endpoint" {
  description = "Writer endpoint of the Aurora cluster"
  value       = aws_rds_cluster.aurora_serverless.endpoint
}

output "cluster_reader_endpoint" {
  description = "Reader endpoint of the Aurora cluster"
  value       = aws_rds_cluster.aurora_serverless.reader_endpoint
}

output "cluster_port" {
  description = "Port of the Aurora cluster"
  value       = aws_rds_cluster.aurora_serverless.port
}

output "database_name" {
  description = "Name of the database"
  value       = aws_rds_cluster.aurora_serverless.database_name
}

output "master_username" {
  description = "Master username for the Aurora cluster"
  value       = aws_rds_cluster.aurora_serverless.master_username
  sensitive   = true
}

output "port" {
  description = "Port of the Aurora cluster"
  value       = aws_rds_cluster.aurora_serverless.port
}

output "security_group_id" {
  description = "ID of the Aurora security group"
  value       = aws_security_group.aurora_sg.id
}

output "subnet_group_name" {
  description = "Name of the DB subnet group"
  value       = aws_db_subnet_group.aurora_subnet_group.name
}

output "instance_id" {
  description = "ID of the Aurora instance"
  value       = aws_rds_cluster_instance.aurora_serverless_instance.identifier
}

output "instance_endpoint" {
  description = "Endpoint of the Aurora instance"
  value       = aws_rds_cluster_instance.aurora_serverless_instance.endpoint
}

output "engine_version" {
  description = "Engine version of the Aurora cluster"
  value       = aws_rds_cluster.aurora_serverless.engine_version
}