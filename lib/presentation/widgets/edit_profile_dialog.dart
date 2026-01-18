import 'package:flutter/material.dart';
import '../../core/models/profile.dart';

class EditProfileDialog extends StatefulWidget {
  final UserProfile? initialProfile;

  const EditProfileDialog({super.key, this.initialProfile});

  @override
  State<EditProfileDialog> createState() => _EditProfileDialogState();
}

class _EditProfileDialogState extends State<EditProfileDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _ageController;
  late TextEditingController _sexController;
  late TextEditingController _pronounsController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.initialProfile?.name ?? '',
    );
    _ageController = TextEditingController(
      text:
          widget.initialProfile?.age.toString() == '0'
              ? ''
              : widget.initialProfile?.age.toString() ?? '',
    );
    _sexController = TextEditingController(
      text: widget.initialProfile?.sex ?? '',
    );
    _pronounsController = TextEditingController(
      text: widget.initialProfile?.pronouns ?? '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _sexController.dispose();
    _pronounsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Profile'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Name'),
                validator:
                    (value) =>
                        value == null || value.isEmpty
                            ? 'Please enter a name'
                            : null,
              ),
              TextFormField(
                controller: _ageController,
                decoration: const InputDecoration(labelText: 'Age'),
                keyboardType: TextInputType.number,
                validator:
                    (value) =>
                        value == null || value.isEmpty
                            ? 'Please enter an age'
                            : null,
              ),
              TextFormField(
                controller: _sexController,
                decoration: const InputDecoration(labelText: 'Sex'),
              ),
              TextFormField(
                controller: _pronounsController,
                decoration: const InputDecoration(labelText: 'Pronouns'),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              final age = int.tryParse(_ageController.text) ?? 0;
              final profile = UserProfile(
                name: _nameController.text,
                pronouns: _pronounsController.text,
                age: age,
                sex: _sexController.text,
                isPregnant: widget.initialProfile?.isPregnant ?? false,
                allergies: widget.initialProfile?.allergies ?? [],
                conditions: widget.initialProfile?.conditions ?? [],
                medicalNotes: widget.initialProfile?.medicalNotes ?? '',
                memberSince:
                    widget.initialProfile?.memberSince ?? DateTime.now(),
              );
              Navigator.of(context).pop(profile);
            }
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
