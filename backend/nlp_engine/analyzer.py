import json
import os
import torch
import re
import nltk
from sentence_transformers import SentenceTransformer, util

# Ensure NLTK punkt is available
try:
    nltk.data.find('tokenizers/punkt')
except LookupError:
    nltk.download('punkt')

# Check for hardware acceleration
device = 'cuda' if torch.cuda.is_available() else 'cpu'
print(f"Initializing Analysis Engine on device: {device}")

# Upgraded Semantic Model: BAAI/bge-large-en-v1.5
# This model is a top-tier performer for retrieval and semantic mapping
model = SentenceTransformer('BAAI/bge-large-en-v1.5', device=device)

# Load ISO 27001 knowledge base
current_dir = os.path.dirname(os.path.abspath(__file__))
json_path = os.path.join(current_dir, "..", "database", "iso27001_rules.json")

with open(json_path, "r", encoding="utf-8") as file:
    iso_knowledge_base = json.load(file)

rule_ids = []
rule_titles = []
rule_descriptions = []
rule_themes = []
rule_texts = []

for theme in iso_knowledge_base.get('themes', []):
    theme_name = theme.get('name', 'Unknown Domain')
    for control in theme.get('controls', []):
        rule_ids.append(control.get('id', 'Unknown Control'))
        rule_titles.append(control.get('title', ''))
        rule_descriptions.append(control.get('description', ''))
        rule_themes.append(theme_name)
        # Contextual text for embedding (Corpus)
        rule_texts.append(f"Control {control.get('id', '')} - {control.get('title', '')}: {control.get('description', '')}")

# Pre-calculate embeddings for the database (Corpus)
rule_embeddings = model.encode(rule_texts, convert_to_tensor=True)

def extract_policy_keywords(user_text: str):
    """
    Analyzes clean text payload and maps it to multiple ISO 27001 controls using chunking.
    """
    if not user_text or not user_text.strip():
        return []

    # 1. Clean input text
    clean_text = re.sub(r'[^\x20-\x7E\n\r\t]+', ' ', user_text)
    clean_text = re.sub(r'\s+', ' ', clean_text).strip()

    # 2. Break down into logical sentences using NLTK
    raw_sentences = nltk.tokenize.sent_tokenize(clean_text)
    
    # 3. Group sentences into chunks
    chunks = []
    current_chunk = []
    current_length = 0
    
    for sent in raw_sentences:
        words = sent.split()
        if len(words) < 5: 
            continue
            
        if current_length + len(words) > 200: 
            chunks.append(" ".join(current_chunk))
            current_chunk = [sent]
            current_length = len(words)
        else:
            current_chunk.append(sent)
            current_length += len(words)
            
    if current_chunk:
        chunks.append(" ".join(current_chunk))

    if not chunks:
        return []

    # 4. Batch Encoding & Deduplicated Mapping
    # For BGE models, we add the retrieval instruction to the queries (chunks)
    instruction = "Represent this sentence for searching relevant passages: "
    queries = [instruction + chunk for chunk in chunks]
    
    chunk_embeddings = model.encode(queries, batch_size=32, convert_to_tensor=True)

    # 5. Run Semantic Search
    search_results = util.semantic_search(chunk_embeddings, rule_embeddings, top_k=1)

    best_matches = {}

    for i, hits in enumerate(search_results):
        chunk_text = chunks[i]
        for hit in hits:
            control_idx = hit['corpus_id']
            score = float(hit['score'])
            confidence = int(score * 100)
            control_id = rule_ids[control_idx]

            # Confidence score filter threshold
            if score < 0.40:
                continue

            if control_id not in best_matches or confidence > best_matches[control_id]['confidence']:
                # System Reasoning Logic
                if confidence >= 80:
                    reasoning = "High Alignment: The Analysis Engine identified a direct correlation between this requirement and the policy documentation."
                elif confidence >= 55:
                    reasoning = "Moderate Alignment: The Semantic Mapper detected overlapping security objectives and related terminology."
                else:
                    reasoning = "Potential Alignment: System Reasoning suggests topical relevance; auditor verification required."

                suggested_justification = (
                    f"Automated match confirmed with {confidence}% confidence. "
                    f"The document section addresses {rule_titles[control_idx].lower()}. "
                    f"Evidence extracted: \"{chunk_text[:150]}...\""
                )

                best_matches[control_id] = {
                    "match": control_id,
                    "theme": rule_themes[control_idx],
                    "confidence": confidence,
                    "description": f"{rule_titles[control_idx]}: {rule_descriptions[control_idx]}",
                    "reasoning": reasoning,
                    "evidence": chunk_text,
                    "justification": suggested_justification
                }

    final_results = sorted(best_matches.values(), key=lambda x: x['confidence'], reverse=True)
    
    return final_results
