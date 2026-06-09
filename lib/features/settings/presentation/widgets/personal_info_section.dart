import 'package:flutter/material.dart';
import '../../../../common/utils/constants.dart';

class PersonalInfoSection extends StatefulWidget {
  final String initialName;
  final String initialEmail;

  const PersonalInfoSection({
    super.key,
    required this.initialName,
    required this.initialEmail,
  });

  @override
  State<PersonalInfoSection> createState() => _PersonalInfoSectionState();
}

class _PersonalInfoSectionState extends State<PersonalInfoSection> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName);
    _emailController = TextEditingController(text: widget.initialEmail);

    _nameController.addListener(_checkForChanges);
    _emailController.addListener(_checkForChanges);
  }

  void _checkForChanges() {
    final changed = _nameController.text != widget.initialName ||
        _emailController.text != widget.initialEmail;
    if (changed != _hasChanges) {
      setState(() {
        _hasChanges = changed;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            children: [
              Icon(Icons.person_outline, color: AppColors.primary, size: 20),
              SizedBox(width: 8),
              Text(
                'Personal Info',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontFamily: AppFonts.body,
                ),
              ),
            ],
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16.0),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              _buildTextField('NAME', _nameController),
              const Divider(color: Colors.grey, height: 1),
              _buildTextField('EMAIL', _emailController),
            ],
          ),
        ),
        if (_hasChanges)
          Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: const EdgeInsets.only(top: 8.0, right: 16.0),
              child: TextButton(
                onPressed: () {
                  // TODO: Implement save logic
                  setState(() => _hasChanges = false);
                },
                style: TextButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.neutral,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Save Changes'),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 10,
              fontWeight: FontWeight.bold,
              fontFamily: AppFonts.label,
            ),
          ),
          TextField(
            controller: controller,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontFamily: AppFonts.body,
            ),
            decoration: const InputDecoration(
              isDense: true,
              border: InputBorder.none,
              contentPadding: EdgeInsets.only(top: 4),
            ),
          ),
        ],
      ),
    );
  }
}
