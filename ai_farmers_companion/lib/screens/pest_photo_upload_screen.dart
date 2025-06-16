import 'package:flutter/material.dart'; // Ensure Material is imported for AppLocalizations
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart'; // Import AppLocalizations
import 'package:image_picker/image_picker.dart'; // Import image_picker
import 'dart:io'; // Import dart:io for File
// Import other necessary packages

class PestPhotoUploadScreen extends ConsumerStatefulWidget {
  const PestPhotoUploadScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<PestPhotoUploadScreen> createState() => _PestPhotoUploadScreenState();
}

class _PestPhotoUploadScreenState extends ConsumerState<PestPhotoUploadScreen> {
  XFile? _selectedImage; // State for selected image

  // Method to pick an image
  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery); // Or ImageSource.camera

    setState(() {
      _selectedImage = image;
    });
  }

  // Method to submit the image (placeholder)
  void _submitImage() {
    if (_selectedImage == null) {
      // TODO: Show a message to the user that no image is selected
      return;
    }
    // TODO: Implement image submission logic (e.g., upload to backend)
    print('Submitting image: ${_selectedImage!.path}');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!; // Get the localized strings

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.pestPhotoUploadScreenTitle), // Use localized title
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Display selected image or a placeholder
              _selectedImage != null
                  ? Image.file(File(_selectedImage!.path), height: 200, width: 200, fit: BoxFit.cover)
                  : Container(
                      width: 200,
                      height: 200,
                      color: Colors.grey[200],
                      child: const Icon(
                        Icons.image,
                        size: 100,
                        color: Colors.grey,
                      ),
                    ),
              const SizedBox(height: 24.0),
              ElevatedButton(
                onPressed: _pickImage, // Call the image picking method
                child: Text(l10n.selectImageButtonLabel), // Use localized button text
              ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: _submitImage, // Call the image submission method
                child: Text(l10n.submitForAnalysisButtonLabel), // Use localized button text
              ),
            ],
          ),
        ),
      ),
    );
  }
}
