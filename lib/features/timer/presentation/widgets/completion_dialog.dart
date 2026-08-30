import 'package:flutter/material.dart';
import 'package:aevum/core/constants/app_colors.dart';
import 'package:aevum/core/quotes/inspiration_quotes.dart';
import 'package:aevum/features/tasks/domain/session_record.dart';
import 'package:aevum/features/tasks/domain/task_model.dart';
import 'package:uuid/uuid.dart';

class CompletionDialog extends StatelessWidget {
  final TaskModel task;
  final int durationSeconds;
  final Function(SessionRecord) onConfirm;

  const CompletionDialog({
    super.key,
    required this.task,
    required this.durationSeconds,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    final accentColor = task.color;
    final minutes = durationSeconds ~/ 60;
    final praise = InspirationQuotes.getRandomCompletionPraise();

    return Dialog(
      backgroundColor: AppColors.forestSurfaceElevated,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(28),
        side: BorderSide(color: AppColors.glassBorderDark, width: 1),
      ),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Celebração em orb calmante
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: accentColor.withValues(alpha: 0.18),
                boxShadow: [
                  BoxShadow(
                    color: accentColor.withValues(alpha: 0.3),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Center(
                child: Icon(
                  Icons.celebration_rounded,
                  size: 42,
                  color: accentColor,
                ),
              ),
            ),
            const SizedBox(height: 20),

            const Text(
              'Meta Concluída!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: AppColors.textWhite,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 8),

            Text(
              task.title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: accentColor,
              ),
            ),
            const SizedBox(height: 12),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                '$minutes minutos registrados com sucesso',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textWhite,
                ),
              ),
            ),
            const SizedBox(height: 16),

            Text(
              praise,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                fontStyle: FontStyle.italic,
                height: 1.4,
                color: AppColors.textMuted,
              ),
            ),
            const SizedBox(height: 28),

            // Botão
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () {
                  final session = SessionRecord(
                    id: const Uuid().v4(),
                    taskId: task.id,
                    completedAt: DateTime.now(),
                    durationSeconds: durationSeconds,
                    completedGoal: true,
                  );
                  onConfirm(session);
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.sage,
                  foregroundColor: AppColors.forestDeep,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Salvar & Finalizar',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
