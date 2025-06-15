import os
import json
import re # For simple keyword search

_faq_cache = None

def load_faq_data():
    """Loads FAQ data from a JSON file."""
    global _faq_cache
    data_path = os.path.join(os.path.dirname(__file__), "..", "data", "faqs.json")
    try:
        with open(data_path, "r", encoding="utf-8") as f:
            _faq_cache = json.load(f)
        print("DEBUG - FAQ data loaded and cached.")
    except FileNotFoundError:
        print(f"ERROR - FAQ data file not found at {data_path}")
        _faq_cache = [] # Initialize as empty list on error
    except json.JSONDecodeError:
        print(f"ERROR - Error decoding FAQ data from {data_path}")
        _faq_cache = [] # Initialize as empty list on error
    except Exception as e:
        print(f"ERROR - An unexpected error occurred loading FAQ data: {e}")
        _faq_cache = [] # Initialize as empty list on error

# Load data when the module is imported
load_faq_data()

def search_faqs(query: str, top_n: int = 3) -> list[dict]:
    """
    Searches FAQs based on a query using simple keyword matching.
    Returns a list of relevant FAQs.
    """
    if not _faq_cache:
        print("WARNING - FAQ cache is empty. Attempting to reload data.")
        load_faq_data()
        if not _faq_cache:
            return []

    if not query:
        return []

    lower_query = query.lower()
    relevant_faqs = []

    for faq in _faq_cache:
        question = faq.get('question', '').lower()
        answer = faq.get('answer', '').lower()

        # Simple keyword matching
        if lower_query in question or lower_query in answer:
            relevant_faqs.append(faq)
            continue # Found a match, move to next FAQ

        # More advanced: check for individual keywords
        query_words = re.findall(r'\b\w+\b', lower_query)
        for word in query_words:
            if len(word) > 2 and (word in question or word in answer): # Ignore very short words
                relevant_faqs.append(faq)
                break # Found a match for this FAQ, move to next

    # Remove duplicates if any (due to multiple keyword matches)
    unique_faqs = []
    seen_questions = set()
    for faq in relevant_faqs:
        if faq['question'] not in seen_questions:
            unique_faqs.append(faq)
            seen_questions.add(faq['question'])

    return unique_faqs[:top_n] # Return top N relevant FAQs
