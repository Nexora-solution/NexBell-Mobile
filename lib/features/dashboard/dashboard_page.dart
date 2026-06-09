import 'package:flutter/material.dart';
import '../../common/utils/constants.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Text(
          'Dashboard',
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
