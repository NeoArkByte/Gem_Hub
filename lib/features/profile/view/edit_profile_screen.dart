import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EditProfileScreen extends StatefulWidget {
  final String currentUsername;
  final String currentDescription;
  final String? currentAvatarUrl;

  const EditProfileScreen({
    super.key,
    required this.currentUsername,
    required this.currentDescription,
    required this.currentAvatarUrl,
  });

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _supabase = Supabase.instance.client;

  late TextEditingController _usernameCtrl;
  late TextEditingController _descriptionCtrl;
  
  String? _localImagePath;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _usernameCtrl = TextEditingController(text: widget.currentUsername);
    _descriptionCtrl = TextEditingController(text: widget.currentDescription);
  }

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _descriptionCtrl.dispose();
    super.dispose();
  }

  // 📸 Step A: Let user select a local gallery photo
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery, imageQuality: 75);
    if (image != null) {
      setState(() => _localImagePath = image.path);
    }
  }

  // ⚡ Step B: Process uploads & updates on Supabase
  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    final user = _supabase.auth.currentUser;

    if (user == null) {
      setState(() => _isSaving = false);
      return;
    }

    try {
      String? finalAvatarUrl = widget.currentAvatarUrl;

      // 1. Handle Image Upload if image changed locally
      if (_localImagePath != null) {
        final file = File(_localImagePath!);
        // Create a unique file path filename variant to avoid aggressive image caching
        final fileExtension = file.path.split('.').last;
        final pathName = '${user.id}/avatar_${DateTime.now().millisecondsSinceEpoch}.$fileExtension';

        // Upload the image file to your Supabase storage bucket named 'avatars'
        await _supabase.storage.from('avatars').upload(
              pathName,
              file,
              fileOptions: const FileOptions(upsert: true),
            );

        // Retrieve the signed public URL string
        finalAvatarUrl = _supabase.storage.from('avatars').getPublicUrl(pathName);
      }

      // 2. Perform Single Row Record Database Update on the table
      await _supabase.from('profiles').update({
        'username': _usernameCtrl.text.trim(),
        'description': _descriptionCtrl.text.trim(),
        'avatar_url': finalAvatarUrl,
      }).eq('id', user.id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully!'), backgroundColor: Colors.green),
        );
        Navigator.pop(context, true); // Return true to notify target listener to refresh
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating profile: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Personal Profile', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // ── AVATAR IMAGE WORKPLACE LAYER ─────────────────────────────────
              GestureDetector(
                onTap: _pickImage,
                child: Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.yellow.shade600, width: 2),
                      ),
                      child: CircleAvatar(
                        radius: 60,
                        backgroundColor: Colors.grey.shade200,
                        backgroundImage: _localImagePath != null
                            ? FileImage(File(_localImagePath!)) as ImageProvider
                            : (widget.currentAvatarUrl != null
                                ? NetworkImage(widget.currentAvatarUrl!) as ImageProvider
                                : NetworkImage('https://i.pravatar.cc/150?u=${_supabase.auth.currentUser?.id}')),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(color: Colors.blue, shape: BoxShape.circle),
                      child: const Icon(Icons.edit, color: Colors.white, size: 16),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // ── USERNAME FIELD ──────────────────────────────────────────────
              TextFormField(
                controller: _usernameCtrl,
                decoration: const InputDecoration(
                  labelText: 'Username *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person_outline),
                ),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Username cannot be empty' : null,
              ),
              const SizedBox(height: 20),

              // ── DESCRIPTION FIELD ───────────────────────────────────────────
              TextFormField(
                controller: _descriptionCtrl,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Profile Description',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.description_outlined),
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 40),

              // ── ACTION BUTTON ────────────────────────────────────────────────
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _updateProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: _isSaving
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Save Changes', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}