#!/usr/bin/env python3
"""
Test script for Bedrock utility functions.
Use this to verify your functions work correctly before submission.

Usage:
    python scripts/test_bedrock_functions.py --kb-id YOUR_KNOWLEDGE_BASE_ID
"""

import sys
import argparse
from bedrock_utils import (
    valid_prompt, 
    query_knowledge_base, 
    generate_response, 
    chat_with_knowledge_base
)

def test_valid_prompt():
    """Test the valid_prompt function with various inputs."""
    print("=" * 50)
    print("TESTING valid_prompt FUNCTION")
    print("=" * 50)
    
    test_cases = [
        "What is machine learning?",
        "How do I configure AWS services?", 
        "Explain quantum computing",
        "Tell me about safety procedures",
        "hack into a system",  # Should be blocked
        "steal personal information",  # Should be blocked
        "",  # Should be invalid (too short)
        "a",  # Should be invalid (too short)
        "What are the business benefits of automation?",
        "How do I troubleshoot the XL-2000 machine?"
    ]
    
    print(f"Testing {len(test_cases)} different prompts:\n")
    
    for i, prompt in enumerate(test_cases, 1):
        is_valid, category = valid_prompt(prompt)
        status = "✅ VALID" if is_valid else "❌ BLOCKED"
        print(f"{i:2d}. {status} | Category: {category:15s} | '{prompt}'")
    
    print("\n" + "=" * 50)

def test_query_knowledge_base(kb_id):
    """Test the query_knowledge_base function."""
    print("TESTING query_knowledge_base FUNCTION")
    print("=" * 50)
    
    test_queries = [
        "What are the safety features?",
        "How do I maintain the equipment?",
        "What are the technical specifications?"
    ]
    
    for query in test_queries:
        print(f"\nTesting query: '{query}'")
        print("-" * 40)
        
        try:
            results = query_knowledge_base(query, kb_id, max_results=3)
            
            if 'error' in results:
                print(f"❌ Error: {results['error']}")
            else:
                print(f"✅ Success: Found {results['total_results']} results")
                
                for i, result in enumerate(results['results'][:2], 1):  # Show first 2
                    score = result.get('score', 0)
                    content_preview = result.get('content', '')[:100] + '...'
                    print(f"  Result {i}: Score={score:.3f}")
                    print(f"    Preview: {content_preview}")
                    
                    location = result.get('location', {})
                    if location and 's3Location' in location:
                        uri = location['s3Location'].get('uri', 'Unknown')
                        print(f"    Source: {uri}")
        
        except Exception as e:
            print(f"❌ Exception: {e}")
    
    print("\n" + "=" * 50)

def test_generate_response():
    """Test the generate_response function."""
    print("TESTING generate_response FUNCTION")
    print("=" * 50)
    
    test_prompts = [
        "Explain machine learning in simple terms",
        "What is cloud computing?"
    ]
    
    for prompt in test_prompts:
        print(f"\nTesting prompt: '{prompt}'")
        print("-" * 40)
        
        try:
            response = generate_response(
                prompt, 
                temperature=0.7,
                max_tokens=200
            )
            
            if response.get('success', False):
                print(f"✅ Success: Generated {len(response['response'])} characters")
                print(f"Model: {response.get('model_id', 'Unknown')}")
                print(f"Response preview: {response['response'][:150]}...")
            else:
                print(f"❌ Error: {response.get('error', 'Unknown error')}")
        
        except Exception as e:
            print(f"❌ Exception: {e}")
    
    print("\n" + "=" * 50)

def test_chat_with_knowledge_base(kb_id):
    """Test the complete chat_with_knowledge_base function."""
    print("TESTING chat_with_knowledge_base FUNCTION")
    print("=" * 50)
    
    test_queries = [
        "What are the safety procedures for the XL-2000?",
        "How do I troubleshoot common problems?"
    ]
    
    for query in test_queries:
        print(f"\nTesting complete chat with: '{query}'")
        print("-" * 40)
        
        try:
            response = chat_with_knowledge_base(query, kb_id)
            
            print(f"Valid: {response['valid']}")
            print(f"Category: {response['category']}")
            print(f"Success: {response['success']}")
            
            if response['success']:
                print(f"Sources found: {response['source_count']}")
                print(f"Response length: {len(response['response'])} characters")
                print(f"Response preview: {response['response'][:200]}...")
                
                # Show source information
                for i, source in enumerate(response.get('sources', [])[:2], 1):
                    print(f"  Source {i}: {source.get('document_name', 'Unknown')}")
                    print(f"    Confidence: {source.get('confidence_score', 0):.3f}")
            else:
                print(f"Error: {response.get('error', 'Unknown error')}")
        
        except Exception as e:
            print(f"❌ Exception: {e}")
    
    print("\n" + "=" * 50)

def main():
    parser = argparse.ArgumentParser(description='Test Bedrock utility functions')
    parser.add_argument('--kb-id', required=False, help='Knowledge Base ID for testing')
    parser.add_argument('--skip-kb', action='store_true', help='Skip knowledge base tests')
    
    args = parser.parse_args()
    
    print("AWS BEDROCK UTILITY FUNCTIONS TEST SUITE")
    print("=" * 60)
    print()
    
    # Always test prompt validation (no AWS resources needed)
    test_valid_prompt()
    
    if args.skip_kb:
        print("Skipping knowledge base tests (--skip-kb flag used)")
        return
    
    if not args.kb_id:
        print("⚠️  Knowledge Base ID not provided.")
        print("   To test KB functions, run: python test_bedrock_functions.py --kb-id YOUR_KB_ID")
        print("   To skip KB tests, run: python test_bedrock_functions.py --skip-kb")
        return
    
    print(f"Using Knowledge Base ID: {args.kb_id}")
    print()
    
    # Test knowledge base functions
    test_query_knowledge_base(args.kb_id)
    test_generate_response()
    test_chat_with_knowledge_base(args.kb_id)
    
    print("TEST SUITE COMPLETED")
    print("=" * 60)
    print("\n📋 For submission, copy the successful outputs above as evidence")
    print("   that your functions work correctly!")

if __name__ == "__main__":
    main()
