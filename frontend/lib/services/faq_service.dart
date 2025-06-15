import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

class FaqService {
  // Placeholder for FAQ data
  static List<Map<String, String>> _faqData = [];

  /// Load FAQ data from a local asset file (placeholder).
  static Future<void> loadFaqData() async {
    try {
      // TODO: Load actual FAQ data from a local source (e.g., JSON file, SQLite)
      // For now, using a small hardcoded placeholder list
      _faqData = [
        {'question': 'What is the best time to plant maize?', 'answer': 'The best time to plant maize depends on your region and rainfall patterns. Generally, planting should occur at the onset of the rainy season.'},
        {'question': 'How to control fall armyworm?', 'answer': 'Monitor your fields regularly. For small infestations, handpicking can be effective. Biopesticides or recommended insecticides can be used for larger outbreaks.'},
        {'question': 'What fertilizer should I use for teff?', 'answer': 'For teff, it is generally recommended to use NPS fertilizer at planting and Urea for topdressing. Consult local extension for specific rates.'},
      ];
      print('DEBUG - FAQ data loaded (placeholder).');
    } catch (e) {
      print('ERROR - Failed to load FAQ data: $e');
      _faqData = []; // Initialize as empty list on error
    }
  }

  /// Get all loaded FAQs.
  static List<Map<String, String>> getAllFaqs() {
    return _faqData;
  }

  /// Search FAQs based on a query (currently uses simple text matching, TODO: implement vector search).
  static Future<List<Map<String, String>>> searchFaqs(String query) async {
    // TODO: Implement vector search here for more relevant results
    // Steps for implementing vector search:
    // 1. Choose a vector search library/approach (e.g., a local library like vector_math, or integrate with a vector database).
    // 2. Choose or integrate an embedding model (e.g., a small local model like BertTiny or DistilBERT, or use a cloud-based embedding API).
    // 3. Generate vector embeddings for all FAQ questions and answers when loading the data.
    // 4. Generate a vector embedding for the user's search query.
    // 5. Use the vector search library to find the most similar FAQ embeddings to the query embedding.
    // 6. Return the top N most relevant FAQs based on similarity score.

    // Placeholder for vector search logic:
    // if (query.isNotEmpty) {
    //   // 1. Generate embedding for the query
    //   // final queryEmbedding = await EmbeddingModel.generateEmbedding(query);
    //
    //   // 2. Calculate similarity between query embedding and FAQ embeddings
    //   // List<Map<String, dynamic>> scoredFaqs = _faqData.map((faq) {
    //   //   final faqEmbedding = faq['embedding']; // Assuming embeddings are stored with FAQ data
    //   //   final similarity = VectorMath.cosineSimilarity(queryEmbedding, faqEmbedding);
    //   //   return {...faq, 'score': similarity};
    //   // }).toList();
    //
    //   // 3. Sort by similarity and return top N
    //   // scoredFaqs.sort((a, b) => b['score'].compareTo(a['score']));
    //   // return scoredFaqs.take(10).map((faq) => {'question': faq['question'], 'answer': faq['answer']}).toList();
    // }


    // For now, perform simple case-insensitive text matching as a fallback
    final lowerCaseQuery = query.toLowerCase();
    return _faqData.where((faq) {
      final question = faq['question']?.toLowerCase() ?? '';
      final answer = faq['answer']?.toLowerCase() ?? '';
      return question.contains(lowerCaseQuery) || answer.contains(lowerCaseQuery);
    }).toList();
  }
}
