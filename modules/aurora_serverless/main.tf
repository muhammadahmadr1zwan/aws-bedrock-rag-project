# Data source for availability zones
data "aws_availability_zones" "available" {
  state = "available"
}

# Security group for Aurora Serverless
resource "aws_security_group" "aurora_sg" {
  name_prefix = "${var.cluster_name}-aurora-sg"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = var.allowed_security_group_ids
    cidr_blocks     = var.allowed_cidr_blocks
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name = "${var.cluster_name}-aurora-sg"
  })

  lifecycle {
    create_before_destroy = true
  }
}

# DB subnet group
resource "aws_db_subnet_group" "aurora_subnet_group" {
  name       = "${var.cluster_name}-subnet-group"
  subnet_ids = var.subnet_ids

  tags = merge(var.tags, {
    Name = "${var.cluster_name}-subnet-group"
  })
}

# Aurora Serverless v2 cluster
resource "aws_rds_cluster" "aurora_serverless" {
  cluster_identifier              = var.cluster_name
  engine                         = "aurora-postgresql"
  engine_mode                    = "provisioned"
  engine_version                 = "15.8"
  database_name                  = var.database_name
  master_username                = var.master_username
  master_password                = var.master_password
  backup_retention_period        = var.backup_retention_period
  preferred_backup_window        = var.preferred_backup_window
  preferred_maintenance_window   = var.preferred_maintenance_window
  db_subnet_group_name          = aws_db_subnet_group.aurora_subnet_group.name
  vpc_security_group_ids        = [aws_security_group.aurora_sg.id]
  storage_encrypted             = true
  copy_tags_to_snapshot         = true
  deletion_protection           = false
  skip_final_snapshot          = true

  serverlessv2_scaling_configuration {
    max_capacity = var.max_capacity
    min_capacity = var.min_capacity
  }

  tags = merge(var.tags, {
    Name = var.cluster_name
  })

  depends_on = [aws_db_subnet_group.aurora_subnet_group]
}

# Aurora Serverless v2 instance
resource "aws_rds_cluster_instance" "aurora_serverless_instance" {
  identifier           = "${var.cluster_name}-instance-1"
  cluster_identifier   = aws_rds_cluster.aurora_serverless.id
  instance_class       = "db.serverless"
  engine              = aws_rds_cluster.aurora_serverless.engine
  engine_version      = "15.8"
  publicly_accessible = false

  tags = merge(var.tags, {
    Name = "${var.cluster_name}-instance-1"
  })
}
