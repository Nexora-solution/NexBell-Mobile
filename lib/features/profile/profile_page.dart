import 'package:flutter/material.dart';
import '../../common/utils/constants.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Perfil',
        style: TextStyle(
          fontFamily: AppFonts.headline,
          fontSize: 24,
          color: Colors.white,
        ),
      ),
    );
  }
}
