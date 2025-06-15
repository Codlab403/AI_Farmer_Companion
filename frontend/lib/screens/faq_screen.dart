import 'package:flutter/material.dart';
import 'package:ai_farmers_companion/services/faq_service.dart'; // Import FaqService

class FaqScreen extends StatefulWidget {
  const FaqScreen({super.key});

  @override
  State<FaqScreen> createState() => _FaqScreenState();
}

class _FaqScreenState extends State<FaqScreen> {
  List<Map<String, String>> _allFaqs = []; // Store all FAQs
  List<Map<String, String>> _displayedFaqs = []; // Store FAQs currently displayed
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Load all FAQs when the screen initializes
    _allFaqs = FaqService.getAllFaqs();
    _displayedFaqs = _allFaqs; // Initially display all FAQs

    // Add listener to search controller to filter FAQs
    _searchController.addListener(_performSearch); // Call _performSearch on text change
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _performSearch() async {
    final query = _searchController.text;
    // Call the searchFaqs method from FaqService
    final results = await FaqService.searchFaqs(query);
    setState(() {
      _displayedFaqs = results;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crop FAQs'),
        bottom: PreferredSize( // Add search bar below AppBar
          preferredSize: const Size.fromHeight(kToolbarHeight),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Search FAQs...',
                border: OutlineInputBorder(
                  borderSide: BorderSide.none,
                  borderRadius: BorderRadius.all(Radius.circular(8.0)),
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 0),
              ),
            ),
          ),
        ),
      ),
      body: _displayedFaqs.isEmpty
          ? const Center(child: Text('No matching FAQs found.'))
          : ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: _displayedFaqs.length,
              itemBuilder: (context, index) {
                final faq = _displayedFaqs[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 4.0),
                  child: ExpansionTile(
                    title: Text(
                      faq['question'] ?? 'No Question',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(faq['answer'] ?? 'No Answer'),
                      ),
                    ],
                  ),
                );
              },
            ),
