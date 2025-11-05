# AWS Bedrock RAG Application - Heavy Machinery Knowledge Base

A production-ready **Retrieval-Augmented Generation (RAG)** system built on AWS that enables intelligent querying of heavy machinery documentation. This application leverages Amazon Bedrock's Claude models, Aurora PostgreSQL Serverless with pgvector, and S3 to create a semantic search system specifically designed for machinery-related queries.

##  Project Purpose

This project was developed as part of the AWS AI/ML Scholars AI Engineer Nanodegree program. It demonstrates a complete RAG implementation that:

- **Validates user queries** using AI-powered classification to ensure only machinery-related questions are processed
- **Performs semantic search** across vectorized document embeddings stored in Aurora PostgreSQL
- **Generates contextualized responses** using Claude Sonnet, grounded in retrieved knowledge
- **Maintains security** through prompt validation, preventing system manipulation and inappropriate queries

##  Architecture Overview

The system follows a multi-stage RAG pipeline:

\\\
User Query  Prompt Validation (Claude)  Knowledge Base Retrieval  Context Augmentation  Response Generation (Claude)
\\\

### Key Components

**Infrastructure Layer (Stack 1)**
- **VPC Architecture**: Isolated network with public/private subnets for secure resource deployment
- **Aurora PostgreSQL Serverless v2**: Auto-scaling vector database with pgvector extension (1536-dimensional embeddings)
- **S3 Bucket**: Document storage for machinery specifications, safety procedures, and technical manuals
- **Secrets Manager**: Encrypted credential management for database access

**AI/ML Layer (Stack 2)**
- **Bedrock Knowledge Base**: Orchestrates semantic search using Titan Embeddings G1 - Text v1.2
- **Vector Store**: Aurora PostgreSQL with HNSW indexing for fast similarity search
- **IAM Integration**: Secure role-based access for Bedrock services

**Application Layer**
- **Python Chat Interface**: Orchestrates the complete RAG workflow
- **Prompt Validator**: AI-powered query classification (5 categories, accepts only Category E - machinery queries)
- **Knowledge Retriever**: Semantic vector search returning top 3 most relevant chunks
- **Response Generator**: Claude Sonnet with configurable temperature and top_p parameters

##  Project Structure

\\\
aws-bedrock-rag-project/

 stack1/                          # Infrastructure Foundation
    main.tf                      # VPC, Aurora Serverless, S3, Secrets Manager
    outputs.tf                   # Resource identifiers for Stack 2
    variables.tf                 # Configuration parameters

 stack2/                          # Bedrock Knowledge Base
    main.tf                      # Knowledge Base, Data Source, IAM Roles
    outputs.tf                   # KB ID and ARN
    variables.tf                 # KB configuration

 modules/                         # Reusable Terraform Modules
    aurora_serverless/           # Aurora cluster and instance configuration
    bedrock_kb/                  # Bedrock Knowledge Base module
    database/                    # Database-specific configurations

 scripts/                         # Application Code
    bedrock_utils.py             # Core RAG functions (validation, retrieval, generation)
    chat.py                      # Main chat application orchestrator
    aurora_sql.sql               # Database schema setup (pgvector, tables, indexes)
    upload_to_s3.py             # Document upload utility

 spec-sheets/                     # Knowledge Base Documents
    [machinery specification PDFs]
    [safety procedure documents]
    [technical manuals]

 Screenshots/                     # Deployment Evidence
     Terraform deployment outputs
     Database configuration verification
     Knowledge Base deployment
     Code implementation snippets
\\\

##  Quick Start

### Prerequisites

- AWS Account with admin permissions
- AWS CLI configured (\ws configure\)
- Terraform >= 1.0
- Python 3.7+ with boto3
- Access to Amazon Bedrock foundation models (request access in AWS Console)

### Deployment Steps

#### 1. Deploy Infrastructure (Stack 1)

\\\ash
cd stack1
terraform init
terraform plan  # Review the infrastructure plan
terraform apply # Creates VPC, Aurora, S3, Secrets Manager
\\\

**Important Outputs to Save:**
- \urora_arn\: Cluster ARN for Stack 2
- \urora_endpoint\: Database connection endpoint
- \ds_secret_arn\: Secrets Manager ARN
- \s3_bucket_name\: S3 bucket for documents

#### 2. Configure Vector Database

Connect to Aurora using AWS Query Editor v2:
- Database: \hmad_bedrock_db\
- Secret ARN: Use the ARN from Stack 1 outputs
- Execute \scripts/aurora_sql.sql\ to:
  - Enable \pgvector\ extension
  - Create \hmad_bedrock_schema\ schema
  - Create \hmad_knowledge_base\ table with vector column
  - Add HNSW index for vector similarity search
  - Add GIN index for full-text search (required by Bedrock KB)

#### 3. Deploy Knowledge Base (Stack 2)

\\\ash
cd ../stack2
# Update main.tf with Stack 1 outputs
terraform init
terraform apply # Creates Bedrock KB and data source
\\\

This creates:
- Knowledge Base: \hmad-bedrock-rag-kb\
- Data source linking S3 bucket
- IAM roles for Bedrock access

#### 4. Populate Knowledge Base

\\\ash
# Add documents to spec-sheets/ folder
python scripts/upload_to_s3.py

# Sync in AWS Console:
# Bedrock  Knowledge Bases  ahmad-bedrock-rag-kb  Sync
\\\

##  Core Implementation

### Prompt Validation (\alid_prompt\)

Uses Claude to classify queries into 5 categories:
- **Category A**: System/architecture questions   Rejected
- **Category B**: Profane/toxic content   Rejected  
- **Category C**: Non-machinery topics   Rejected
- **Category D**: Prompt injection attempts   Rejected
- **Category E**: Heavy machinery queries   Accepted

**Implementation Details:**
- Model: Claude Sonnet (via Bedrock)
- Temperature: 0 (deterministic classification)
- Top_p: 0.1 (most confident prediction)
- Max tokens: 10 (category letter only)

### Knowledge Retrieval (\query_knowledge_base\)

Performs semantic vector search:
- **Method**: Cosine similarity on 1536-dimensional embeddings
- **Results**: Top 3 most relevant document chunks
- **Storage**: Aurora PostgreSQL with pgvector
- **Index**: HNSW for sub-second query performance

### Response Generation (\generate_response\)

Generates contextualized answers:
- **Model**: Claude Sonnet 3.5
- **Temperature**: 0.1 (factual, consistent responses)
- **Top_p**: 0.9 (natural language fluency)
- **Max tokens**: 500
- **Context**: Augmented with retrieved knowledge chunks

##  Configuration

### Unique Resource Naming

All resources use the \hmad-*\ prefix for uniqueness:
- **Database**: \hmad_bedrock_db\
- **Schema**: \hmad_bedrock_schema\
- **Table**: \hmad_knowledge_base\
- **Knowledge Base**: \hmad-bedrock-rag-kb\
- **Secret**: \hmad-bedrock-rag-rds-secret\

### Model Parameters

**Temperature** (0.0 - 1.0):
- Controls randomness in output
- Lower values = more deterministic, factual responses
- Default: 0.1 for consistent, accurate answers

**Top_p** (0.0 - 1.0):
- Controls vocabulary diversity (nucleus sampling)
- Higher values = more natural, varied language
- Default: 0.9 for fluent, human-like responses

See \MODEL_PARAMETERS_EXPLANATION.md\ for detailed analysis.

##  Usage Example

\\\python
from scripts.bedrock_utils import valid_prompt, query_knowledge_base, generate_response

# User query
user_query = "What are the safety features of the XL-2000 excavator?"

# Step 1: Validate query
if valid_prompt(user_query):
    print(" Query validated - Category E (Machinery)")
    
    # Step 2: Retrieve relevant context
    kb_results = query_knowledge_base(user_query, kb_id="IHP6NULDYW")
    
    # Step 3: Build context from retrieved chunks
    context = "\n\n".join([
        f"Document: {r.get('metadata', {}).get('source', 'Unknown')}\n"
        f"Content: {r['content']['text']}"
        for r in kb_results
    ])
    
    # Step 4: Generate response with context
    prompt = f\\\Based on the following documentation, answer the user's question.

Documentation:
{context}

Question: {user_query}

Provide a detailed, accurate answer based only on the documentation provided.\\\

    response = generate_response(prompt, temperature=0.1, top_p=0.9)
    print(f"\nResponse:\n{response}")
    
    # Step 5: Show sources
    print(f"\nSources: {len(kb_results)} document chunks retrieved")
else:
    print(" Query rejected - not a machinery-related question")
\\\

##  Screenshots

The \Screenshots/\ directory contains:
-  Terraform apply outputs (Stack 1 & Stack 2)
-  Secrets Manager configuration
-  Database extensions verification (\pgvector\ enabled)
-  Schema and table creation confirmation
-  Knowledge Base deployment interface
-  Successful data synchronization
-  Code implementation snippets

##  Troubleshooting

### Common Issues

**Database Connection Fails**
- Verify security group allows port 5432
- Check Secrets Manager secret has correct credentials
- Ensure Aurora cluster status is "available"
- Confirm you're using the correct endpoint from Stack 1 outputs

**Knowledge Base Sync Fails**
- Verify IAM role (\hmad-bedrock-rag-kb-role\) has S3 read permissions
- Check documents are in supported formats (PDF, TXT, MD, etc.)
- Ensure GIN index exists on \chunks\ column (required by Bedrock)
- Review CloudWatch logs for detailed error messages

**Bedrock API Access Denied**
- Request access to foundation models in Bedrock console
- Verify your region supports Bedrock (us-east-1 recommended)
- Check IAM permissions for \edrock:InvokeModel\ and \edrock:Retrieve\

**Prompt Validation Always Fails**
- Verify KB_ID in \edrock_utils.py\ matches your Knowledge Base ID
- Check Bedrock model access permissions
- Review CloudWatch logs for classification errors

##  Cleanup

To avoid ongoing AWS charges:

\\\ash
# Destroy Stack 2 first (Knowledge Base)
cd stack2
terraform destroy

# Then destroy Stack 1 (Infrastructure)
cd ../stack1
terraform destroy
\\\

** Warning**: This will permanently delete all resources. Ensure you've backed up any important data.

##  Key Learnings

This project demonstrates:
- **RAG Architecture**: Complete implementation of retrieval-augmented generation
- **Vector Databases**: Using pgvector for semantic search at scale
- **AI Safety**: Prompt validation and content filtering
- **Infrastructure as Code**: Terraform for reproducible deployments
- **AWS Integration**: Bedrock, Aurora, S3, Secrets Manager orchestration

##  License

Educational project for AWS AI/ML Scholars AI Engineer Nanodegree program.

---

**Author**: Muhammad Ahmad Rizwan  
**Repository**: [aws-bedrock-rag-project](https://github.com/muhammadahmadr1zwan/aws-bedrock-rag-project)  
**Last Updated**: November 2025

**Note**: This deployment creates real AWS resources that incur charges. Monitor your AWS billing dashboard and destroy resources when not in use.
