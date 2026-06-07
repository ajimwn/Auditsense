import json
import os
from sentence_transformers import SentenceTransformer, util

print("Loading AI Model...")
model = SentenceTransformer('all-MiniLM-L6-v2')

# 1. Safely locate and load the external JSON database
current_dir = os.path.dirname(os.path.abspath(__file__))
json_path = os.path.join(current_dir, "..", "database", "iso27001_rules.json")

with open(json_path, "r", encoding="utf-8") as file:
    iso_knowledge_base = json.load(file)

# 2. Convert the loaded data into AI embeddings
rule_names = []
rule_descriptions = []
rule_themes = []

for theme in iso_knowledge_base.get('themes', []):
    theme_name = theme.get('name', 'Unknown Theme')
    for control in theme.get('controls', []):
        rule_id = control.get('id', 'Unknown Control')
        rule_title = control.get('title', '')
        rule_desc = control.get('description', '')
        rule_themes.append(theme_name)
        rule_names.append(rule_id)
        rule_descriptions.append(f"{rule_title}: {rule_desc}")

rule_embeddings = model.encode(rule_descriptions)

def extract_policy_keywords(user_text: str):
    user_embedding = model.encode(user_text)
    hits = util.semantic_search(user_embedding, rule_embeddings)[0]
    
    best_match_index = hits[0]['corpus_id']
    confidence_score = round(hits[0]['score'] * 100, 1) 
    
    best_rule_name = rule_names[best_match_index]
    best_rule_desc = rule_descriptions[best_match_index]
    best_rule_theme = rule_themes[best_match_index]
    
    if confidence_score >= 60:
        reasoning = f"High Confidence ({confidence_score}%): Your input strongly matches the terminology and context of this ISO 27001 rule."
    elif confidence_score >= 35:
        reasoning = f"Moderate Confidence ({confidence_score}%): The AI detected related security concepts, but the phrasing differs slightly from the standard rule definition."
    else:
        reasoning = f"Low Confidence ({confidence_score}%): The AI detected slight topical overlap, but lacks enough context for a definitive match."

    return {
        "match": best_rule_name,
        "theme": best_rule_theme,
        "confidence": confidence_score,
        "description": best_rule_desc,
        "reasoning": reasoning
    }