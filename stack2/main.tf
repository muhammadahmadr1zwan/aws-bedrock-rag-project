provider "aws" {
  region = "us-east-1"  # CORRECTED: Must match the region of your Stack 1 resources
}

module "bedrock_kb" {
  source = "../modules/bedrock_kb" 

  knowledge_base_name        = "ahmad-bedrock-rag-kb"  # Unique name
  knowledge_base_description = "Ahmad's RAG Knowledge Base connected to Aurora Serverless database"

  aurora_arn        = "arn:aws:rds:us-east-1:255810985536:cluster:my-aurora-serverless"
  aurora_db_name    = "ahmad_bedrock_db"  # Updated to unique database name
  aurora_endpoint   = "my-aurora-serverless.cluster-cvhslgd3b77s.us-east-1.rds.amazonaws.com"
  aurora_table_name = "ahmad_bedrock_schema.ahmad_knowledge_base"  # Updated to unique schema/table
  aurora_primary_key_field = "id"
  aurora_metadata_field = "metadata"
  aurora_text_field = "chunks"
  aurora_verctor_field = "embedding"
  aurora_username   = "dbadmin"
  aurora_secret_arn = "arn:aws:secretsmanager:us-east-1:255810985536:secret:ahmad-bedrock-rag-rds-secret-F57qY0"
  s3_bucket_arn = "arn:aws:s3:::bedrock-kb-255810985536"
}
