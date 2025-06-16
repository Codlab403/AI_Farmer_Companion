import 'dart:io'; // Keep dart:io import
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ai_farmers_companion/services/api_service.dart';

// TODO: Improve Pest Diagnosis Feature
// 1. Enhance UI for displaying diagnosis results (e.g., show image with highlighted areas).
// 2. Handle different image formats and sizes more robustly.
// 3. Provide more detailed information in the diagnosis result display.
// 4. Consider integrating with a different or fine-tuned model if Gemini's accuracy is insufficient.
// 5. Implement offline diagnosis capability if a local model is available.

class PestHelpScreen extends StatefulWidget {

class _PestHelpScreenState extends State<PestHelpScreen> {
  final ImagePicker _picker = ImagePicker();
  File? _imageFile;
  Map<String, dynamic>? _diagnosisResult;
  bool _isLoading = false;
  String? _error;

  Future<void> _pickAndDiagnoseImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _imageFile = File(image.path);
        _isLoading = true;
        _diagnosisResult = null; // Clear previous results
        _error = null;
      });

      try {
        final result = await ApiService.diagnosePest(image.path);
        setState(() {
          // Check if the API returned a specific error message in the JSON
          if (result.containsKey('error')) {
            _error = result['error'];
            _diagnosisResult = null;
          } else {
            _diagnosisResult = result;
            _error = null;
          }
        });
      } catch (e) {
        setState(() {
          // Provide a more generic error message for unexpected errors
          _error = 'An error occurred during diagnosis. Please try again.';
          _diagnosisResult = null;
        });
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pest Help')),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_imageFile == null)
                  const Icon(Icons.bug_report, size: 100, color: Colors.brown),
                if (_imageFile != null)
                  Image.file(
                    _imageFile!,
                    height: 250,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                const SizedBox(height: 20),
                const Text(
                  'Upload a photo of the affected crop for diagnosis.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 30),
                ElevatedButton.icon(
                  icon: const Icon(Icons.photo_library),
                  label: const Text('Select from Gallery'),
                  onPressed: _isLoading ? null : _pickAndDiagnoseImage,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  ),
                ),
                const SizedBox(height: 30),
                if (_isLoading)
                  const CircularProgressIndicator(),
                if (_error != null)
                  Text(
                    _error!,
                    style: const TextStyle(color: Colors.red, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                if (_diagnosisResult != null && _error == null) // Only show card if result is valid
                  Card(
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Diagnosis:',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _diagnosisResult!['diagnosis'],
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Confidence:',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${(_diagnosisResult!['confidence'] * 100).toStringAsFixed(2)}%',
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Recommendation:',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _diagnosisResult!['recommendation'],
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
