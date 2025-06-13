import 'package:flutter/material.dart';

class LanguageSelectionScreen extends StatelessWidget {
  final void Function(String) onLanguageSelected;

  const LanguageSelectionScreen({super.key, required this.onLanguageSelected});

  @override
  Widget build(BuildContext context) {
    final languages = {
      'en': 'English',
      'am': 'አማርኛ',
      'om': 'Afaan Oromo',
      'so': 'Somali',
      'ti': 'ትግርኛ',
    };

    return Scaffold(
      appBar: AppBar(title: const Text('Select Language')),
      body: GridView.count(
        crossAxisCount: 2,
        padding: const EdgeInsets.all(16),
        children: languages.entries
            .map(
              (e) => Card(
                child: InkWell(
                  onTap: () => onLanguageSelected(e.key),
                  child: Center(
                    child: Text(
                      e.value,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 18),
                    ),
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}
