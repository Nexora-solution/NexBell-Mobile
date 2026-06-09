import 'package:flutter/material.dart';
import '../../common/utils/constants.dart';

class AccessPage extends StatelessWidget {
  const AccessPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Text(
          'Registrar Visita (Acceso)',
          style: TextStyle(
            fontFamily: AppFonts.headline,
            fontSize: 24,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
