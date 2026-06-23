import 'package:flutter/material.dart';
import '../../../../common/utils/constants.dart';
import '../../../../common/utils/api_client.dart';

class PersonalInfoSection extends StatefulWidget {
  final String initialName;
  final String initialEmail;
  final String initialApartment;

  const PersonalInfoSection({
    super.key,
    required this.initialName,
    required this.initialEmail,
    this.initialApartment = '',
  });

  @override
  State<PersonalInfoSection> createState() => _PersonalInfoSectionState();
}

class _PersonalInfoSectionState extends State<PersonalInfoSection> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _apartmentController;
  bool _hasChanges = false;
  bool _saving = false;
  String? _errorMsg;
  String? _successMsg;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName);
    _emailController = TextEditingController(text: widget.initialEmail);
    _apartmentController = TextEditingController(text: widget.initialApartment);

    _nameController.addListener(_checkForChanges);
    _apartmentController.addListener(_checkForChanges);
  }

  void _checkForChanges() {
    final changed = _nameController.text != widget.initialName ||
        _apartmentController.text != widget.initialApartment;
    if (changed != _hasChanges) {
      setState(() {
        _hasChanges = changed;
        _errorMsg = null;
        _successMsg = null;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _apartmentController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    setState(() { _saving = true; _errorMsg = null; _successMsg = null; });

    try {
      final residentId = await ApiClient.getResidentId();
      if (residentId == null) {
        setState(() {
          _errorMsg = 'Session expired. Please log in again.';
          _saving = false;
        });
        return;
      }

      final body = <String, String>{};
      if (_nameController.text.trim().isNotEmpty) {
        body['fullName'] = _nameController.text.trim();
      }
      if (_apartmentController.text.trim().isNotEmpty) {
        body['apartmentCode'] = _apartmentController.text.trim();
      }

      final response = await ApiClient.put(
        '/api/directory/residents/$residentId/contact',
        body: body,
      );

      if (response.statusCode == 200) {
        setState(() {
          _hasChanges = false;
          _successMsg = 'Profile updated successfully';
          _saving = false;
        });
      } else {
        setState(() {
          _errorMsg = 'Error ${response.statusCode}: Could not save changes';
          _saving = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMsg = 'Network error. Please try again.';
        _saving = false;
      });
    }
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
              _buildTextField('EMAIL', _emailController, readOnly: true),
              const Divider(color: Colors.grey, height: 1),
              _buildTextField('APARTMENT NUMBER', _apartmentController,
                  hint: 'e.g. 101, 202'),
            ],
          ),
        ),
        if (_errorMsg != null)
          Padding(
            padding: const EdgeInsets.only(top: 8.0, left: 16.0, right: 16.0),
            child: Text(
              _errorMsg!,
              style: const TextStyle(color: Colors.redAccent, fontSize: 13),
            ),
          ),
        if (_successMsg != null)
          Padding(
            padding: const EdgeInsets.only(top: 8.0, left: 16.0, right: 16.0),
            child: Text(
              _successMsg!,
              style: const TextStyle(color: Colors.greenAccent, fontSize: 13),
            ),
          ),
        if (_hasChanges)
          Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: const EdgeInsets.only(top: 8.0, right: 16.0),
              child: _saving
                  ? const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  : TextButton(
                      onPressed: _saveChanges,
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

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    bool readOnly = false,
    String? hint,
  }) {
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
            readOnly: readOnly,
            style: TextStyle(
              color: readOnly ? Colors.grey : Colors.white,
              fontSize: 16,
              fontFamily: AppFonts.body,
            ),
            decoration: InputDecoration(
              isDense: true,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.only(top: 4),
              hintText: hint,
              hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}
