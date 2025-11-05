# Model Parameters Explanation

## Author: Ahmad
## Date: November 5, 2025

This document explains two critical parameters that control the behavior of Large Language Models (LLMs) in Amazon Bedrock: **Temperature** and **Top-P**.

---

## Temperature

**Temperature** controls the randomness and creativity of the AI's responses. It affects how the model selects the next token (word) when generating text.

### How It Works:
- **Range**: 0.0 to 1.0
- **Low Temperature (0.0 - 0.3)**: Makes the model more deterministic and focused
  - The model selects the most likely next token
  - Responses are more predictable and consistent
  - Best for factual queries where precision matters
  
- **Medium Temperature (0.4 - 0.7)**: Balanced creativity and consistency
  - Allows some variation while maintaining coherence
  - Good for general conversational AI
  
- **High Temperature (0.8 - 1.0)**: Increases randomness and creativity
  - Model explores less likely options
  - More creative but potentially less accurate responses
  - Useful for brainstorming or creative writing

### Example in Our Application:
```python
# In bedrock_utils.py
def generate_response(prompt, model_id=MODEL_ID, temperature=0.1, top_p=0.9):
    # temperature=0.1 ensures our machinery assistant gives accurate, 
    # consistent technical information rather than creative responses
```

**For our heavy machinery assistant**, we use a low temperature (0.1) because:
1. Technical specifications must be accurate
2. Safety information cannot be creative or variable
3. Maintenance procedures need consistent, reliable answers

---

## Top-P (Nucleus Sampling)

**Top-P** (also called nucleus sampling) controls the diversity of word choices by limiting the model to the smallest set of words whose cumulative probability exceeds the threshold P.

### How It Works:
- **Range**: 0.0 to 1.0
- **How it selects words**:
  1. Model calculates probability for all possible next words
  2. Sorts them from most to least likely
  3. Includes words until their cumulative probability reaches P
  4. Only samples from this subset

### Values Explained:
- **Low Top-P (0.1 - 0.5)**: Very focused selection
  - Only considers the most likely words
  - Produces safe, predictable responses
  - Can be repetitive
  
- **Medium Top-P (0.6 - 0.8)**: Balanced approach
  - Reasonable variety while maintaining quality
  - Good for most applications
  
- **High Top-P (0.9 - 1.0)**: Maximum diversity
  - Considers a wider range of possible words
  - More varied and natural-sounding responses
  - May occasionally include unexpected choices

### Example:
If the model is completing "The excavator's maximum digging..." and Top-P=0.9:
- It might consider words like: "depth" (40%), "capacity" (25%), "reach" (15%), "force" (10%), "range" (5%), etc.
- With Top-P=0.9, it includes words until 90% cumulative probability is reached
- With Top-P=0.3, it might only consider "depth" and "capacity"

---

## Temperature vs. Top-P: Key Differences

| Aspect | Temperature | Top-P |
|--------|-------------|-------|
| **Controls** | Probability distribution shape | Word selection pool size |
| **Effect** | How peaked/flat the distribution is | Which words are candidates |
| **Low Value** | Deterministic, focused | Limited vocabulary |
| **High Value** | Random, creative | Diverse vocabulary |
| **Best For** | Controlling creativity level | Controlling output diversity |

---

## Our Application's Settings

In our heavy machinery RAG application, we use:
- **Temperature: 0.1** - For accurate, consistent technical responses
- **Top-P: 0.9** - For natural-sounding but reliable answers

### Validation Function Settings:
```python
def valid_prompt(prompt, model_id=MODEL_ID):
    response = bedrock.invoke_model(
        ...
        body=json.dumps({
            "max_tokens": 10,
            "temperature": 0,      # Completely deterministic for classification
            "top_p": 0.1,          # Only most likely classifications
        })
    )
```

**Why these specific settings?**
- Temperature=0: We want the exact same classification every time
- Top-P=0.1: Only consider the most confident category assignments

### Response Generation Settings:
```python
def generate_response(prompt, model_id=MODEL_ID, temperature=0.1, top_p=0.9):
    response = bedrock.invoke_model(
        ...
        body=json.dumps({
            "max_tokens": 500,
            "temperature": 0.1,    # Mostly factual with slight flexibility
            "top_p": 0.9,          # Natural language while staying accurate
        })
    )
```

**Why these specific settings?**
- Temperature=0.1: Prioritizes accuracy while allowing natural phrasing
- Top-P=0.9: Enables varied, natural responses without sacrificing reliability

---

## Impact on RAG Applications

For Retrieval-Augmented Generation (RAG) systems like ours:

1. **Lower Temperature is Better** because:
   - Retrieved context provides the creativity
   - Model should stick to the provided information
   - Reduces hallucination risk
   
2. **Moderate-to-High Top-P Works Well** because:
   - Allows natural paraphrasing of retrieved content
   - Maintains readability and flow
   - Doesn't restrict the model too much when summarizing

3. **Balance is Key**:
   - Too restrictive (both low): Robotic, repetitive answers
   - Too permissive (both high): May deviate from retrieved facts
   - Our combination (0.1, 0.9): Accurate yet natural responses

---

## Conclusion

Understanding Temperature and Top-P is crucial for fine-tuning LLM behavior:
- **Temperature** adjusts the confidence/creativity spectrum
- **Top-P** controls vocabulary diversity
- Together, they allow precise control over model outputs
- For technical RAG applications, low temperature with moderate-to-high Top-P typically yields the best results

In our heavy machinery assistant, these parameters ensure users receive accurate, reliable technical information presented in a natural, professional manner.

