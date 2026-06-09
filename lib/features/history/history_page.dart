import 'package:flutter/material.dart';
import '../../common/utils/constants.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Historial',
        style: TextStyle(
          fontFamily: AppFonts.headline,
          fontSize: 24,
          color: Colors.white,
        ),
      ),
    );
  }
}
