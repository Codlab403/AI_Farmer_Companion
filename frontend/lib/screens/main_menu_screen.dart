import 'package:flutter/material.dart';
import 'crop_info_screen.dart';
import 'market_prices_screen.dart';
import 'pest_help_screen.dart';
import 'chat_screen.dart';
import 'farm_profile_screen.dart'; // Import the new screen
import 'faq_screen.dart'; // Import the new FAQ screen

class MainMenuScreen extends StatelessWidget {
  final String languageCode;
  final VoidCallback onLoggedOut;

  const MainMenuScreen({super.key, required this.languageCode, required this.onLoggedOut});

  @override
  Widget build(BuildContext context) {
    final labels = {
      'cropInfo': {'en': 'Crop Info', 'am': 'የእርሻ መረጃ'},
      'pestHelp': {'en': 'Pest Help', 'am': 'የተባባሪ መረጃ'},
      'marketPrices': {'en': 'Market Prices', 'am': 'የገበያ ዋጋ'},
      'aiAssistant': {'en': 'AI Assistant', 'am': 'የአርቴፊሻል ኢንተለጀንስ ረዳት'},
      'farmProfile': {'en': 'Farm Profile', 'am': 'የእርሻ መገለጫ'}, // Add label for new screen
      'cropFaqs': {'en': 'Crop FAQs', 'am': 'የእርሻ ተደጋጋሚ ጥያቄዎች'}, // Add label for FAQ screen
    };

    Widget buildTile(String key, IconData icon, VoidCallback onTap) {
      return Card(
        child: InkWell(
          onTap: onTap,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 40, color: Colors.green.shade700),
              const SizedBox(height: 8),
              Text(
                labels[key]![languageCode] ?? labels[key]!['en']!,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              )
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Farmer\'s Companion'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: onLoggedOut,
          ),
        ],
      ),
      body: GridView.count(
        crossAxisCount: 2,
        padding: const EdgeInsets.all(16),
        children: [
          buildTile('cropInfo', Icons.local_florist, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CropInfoScreen()))),
          buildTile('pestHelp', Icons.bug_report, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PestHelpScreen()))),
          buildTile('marketPrices', Icons.bar_chart, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MarketPricesScreen()))),
          buildTile('aiAssistant', Icons.chat_bubble_outline, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ChatScreen()))),
          buildTile('farmProfile', Icons.account_circle, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FarmProfileScreen()))), // Add tile for new screen
          buildTile('cropFaqs', Icons.question_answer_outlined, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FaqScreen()))), // Add tile for FAQ screen
        ],
      ),
    );
  }
}
