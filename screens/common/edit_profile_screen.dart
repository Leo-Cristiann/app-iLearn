import 'package:flutter/material.dart';
import 'package:project_ilearn/providers/auth_provider.dart';
import 'package:project_ilearn/utils/validators.dart';
import 'package:project_ilearn/widgets/common/custom_button.dart';
import 'package:project_ilearn/widgets/common/custom_text_field.dart';
import 'package:project_ilearn/widgets/common/loading_indicator.dart';
import 'package:provider/provider.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _bioController = TextEditingController();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeForm();
  }

  void _initializeForm() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.user;

    if (user != null) {
      final profileData = user.profileData;
      _fullNameController.text = profileData['fullName'] ?? '';
      _phoneController.text = profileData['phone'] ?? '';
      _bioController.text = profileData['bio'] ?? '';
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      
      final profileData = {
        'fullName': _fullNameController.text.trim(),
        'phone': _phoneController.text.trim(),
        'bio': _bioController.text.trim(),
      };

      await authProvider.updateProfile(profileData);

      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated successfully'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
      ),
      body: _isLoading
          ? const LoadingIndicator()
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    const Text(
                      'Edit your profile information',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Full Name
                    CustomTextField(
                      labelText: 'Full Name',
                      controller: _fullNameController,
                      prefixIcon: Icons.person,
                      validator: (value) => Validators.validateRequired(
                        value,
                        'Full name is required',
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Phone
                    CustomTextField(
                      labelText: 'Phone',
                      controller: _phoneController,
                      prefixIcon: Icons.phone,
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 16),
                    // Bio
                    CustomTextField(
                      labelText: 'Bio',
                      controller: _bioController,
                      prefixIcon: Icons.info,
                      maxLines: 3,
                    ),
                    const SizedBox(height: 32),
                    // Save Button
                    CustomButton(
                      text: 'Save Profile',
                      onPressed: _saveProfile,
                      prefixIcon: Icons.save,
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}