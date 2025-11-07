🚀 AWS Bedrock RAG Application – Heavy Machinery Knowledge Base

This project delivers a Retrieval-Augmented Generation (RAG) system that enables intelligent querying of heavy machinery documentation using AWS Bedrock, Aurora PostgreSQL Serverless (pgvector), and S3. Designed for low-latency retrieval, prompt validation, and scalable semantic search.

🧠 Project Features

Retrieval-Augmented Generation (RAG): Combines vector search and generative AI for contextual responses.

Prompt Validation: AI-based filter ensures only machinery-related queries are processed.

Semantic Search: Uses pgvector embeddings for similarity retrieval from Aurora Serverless.

Secure Infrastructure: Terraform-based deployment using VPCs, IAM, and Secrets Manager.

Low-Latency Architecture: Parallelized query flow for sub-second response generation.

🏗️ Architecture Overview

Infrastructure Layer

Aurora PostgreSQL Serverless v2 with pgvector for semantic indexing

Amazon S3 for document storage and retrieval

AWS Secrets Manager and IAM for secure access control

AI Layer

Amazon Bedrock Knowledge Base powered by Titan Embeddings G1 – Text v1.2

Claude Sonnet 3.5 for retrieval-grounded text generation

Python-based orchestration layer for prompt validation and context augmentation

Pipeline Flow

Query → Validation (Claude) → Vector Retrieval (Aurora) → Context Assembly → Response Generation

📊 Results

66.7% reduction in query latency using Aurora Serverless

40% lower operational cost compared to standard retrieval systems

High-accuracy responses with AI-driven prompt filtering and validation

⚙️ Tech Stack

Core Services: AWS Bedrock, Aurora Serverless, S3, IAM, Secrets Manager

Languages: Python, SQL

Tools: Terraform, boto3, pgvector

Models: Claude Sonnet 3.5, Titan Embeddings G1 – Text v1.2

🔍 Focus Areas

RAG architecture • Vector databases • Semantic search • AI safety • Cloud infrastructure • Terraform automation

📬 Contact

Developed by Muhammad Ahmad Rizwan
📎 LinkedIn

📂 Repository
