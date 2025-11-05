-- Enable pgvector extension for vector storage
CREATE EXTENSION IF NOT EXISTS vector;

-- Create schema for Bedrock integration
CREATE SCHEMA IF NOT EXISTS ahmad_bedrock_schema;

-- Create role for Bedrock (with error handling)
DO $$ 
BEGIN 
    CREATE ROLE bedrock_user LOGIN; 
EXCEPTION 
    WHEN duplicate_object THEN 
        RAISE NOTICE 'Role already exists'; 
END $$;

-- Grant permissions on schema
GRANT ALL ON SCHEMA ahmad_bedrock_schema TO bedrock_user;

-- Create the ahmad_knowledge_base table for storing embeddings
CREATE TABLE IF NOT EXISTS ahmad_bedrock_schema.ahmad_knowledge_base (
    id uuid PRIMARY KEY,
    embedding vector(1536),
    chunks text,
    metadata json
);

-- Create HNSW index for efficient vector similarity search
CREATE INDEX IF NOT EXISTS ahmad_kb_embedding_idx 
ON ahmad_bedrock_schema.ahmad_knowledge_base 
USING hnsw (embedding vector_cosine_ops);

-- Create GIN index on chunks column for full-text search (required by Bedrock KB)
CREATE INDEX IF NOT EXISTS ahmad_kb_chunks_text_idx 
ON ahmad_bedrock_schema.ahmad_knowledge_base 
USING gin (to_tsvector('english', chunks));