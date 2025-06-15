import 'package:flutter/material.dart';
import 'package:ai_farmers_companion/services/api_service.dart'; // Import ApiService

class FarmProfileScreen extends StatefulWidget {
  const FarmProfileScreen({super.key});

  @override
  State<FarmProfileScreen> createState() => _FarmProfileScreenState();
}

class _FarmProfileScreenState extends State<FarmProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _regionController = TextEditingController();
  final _cropFocusController = TextEditingController();
  final _landSizeController = TextEditingController();
  bool _isLoading = false;

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Prepare data to send to backend
      final profileData = {
        'region': _regionController.text.trim(),
        'crop_focus': _cropFocusController.text.trim(),
        'land_size': double.tryParse(_landSizeController.text.trim()), // Convert to double
      };

      // Send data to backend using ApiService
      // Assuming a POST endpoint at /api/v1/farm-profile
      final response = await ApiService.postFarmProfile(profileData); // Need to add postFarmProfile to ApiService

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response['message'] ?? 'Profile saved successfully!')),
      );

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save profile: ${e.toString()}')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _regionController.dispose();
    _cropFocusController.dispose();
    _landSizeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Farm Profile Setup'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView( // Use ListView for scrollability
            children: [
              TextFormField(
                controller: _regionController,
                decoration: const InputDecoration(labelText: 'Region'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your region';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _cropFocusController,
                decoration: const InputDecoration(labelText: 'Crop Focus (Optional)'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _landSizeController,
                decoration: const InputDecoration(labelText: 'Land Size (ha, Optional)'),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value != null && value.isNotEmpty && double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: _isLoading ? null : _saveProfile,
                child: _isLoading ? const CircularProgressIndicator() : const Text('Save Profile'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
