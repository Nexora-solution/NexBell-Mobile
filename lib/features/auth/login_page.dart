import 'package:flutter/material.dart';
import '../../common/utils/constants.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Text(
          'Login Page',
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
