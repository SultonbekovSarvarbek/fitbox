import 'package:flutter/material.dart';

import 'pose_analyzer.dart';

/// Kamerada mashqni tekshirish — ML Kit olib tashlangan vaqtinchalik zaglushka.
/// To'liq versiya `pose_check_screen.dart.mlkit` faylida (pubspec'ga
/// `google_mlkit_pose_detection` qaytarilsa, shu faylga ko'chiriladi).
class PoseCheckScreen extends StatelessWidget {
  const PoseCheckScreen({
    super.key,
    required this.exerciseName,
    required this.exercise,
    required this.targetReps,
  });

  final String exerciseName;
  final TrackedExercise exercise;
  final int targetReps;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(exerciseName)),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'Kamera orqali tekshirish bu qurilmada o\'chirilgan.',
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
