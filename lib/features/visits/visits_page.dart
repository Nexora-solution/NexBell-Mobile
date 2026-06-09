import 'package:flutter/material.dart';
import '../../common/utils/constants.dart';

class VisitsPage extends StatelessWidget {
  const VisitsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Visitas',
        style: TextStyle(
          fontFamily: AppFonts.headline,
          fontSize: 24,
          color: Colors.white,
        ),
      ),
    );
  }
}
