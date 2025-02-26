import 'package:flutter/material.dart';

void showCustomSnackBar(
  BuildContext context, {
  required String message,
  bool isError = false,
  Duration duration = const Duration(seconds: 2),
}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isError
                ? [
                    Colors.red.shade900,
                    Colors.red.shade700
                  ] // Error: Deep red gradient
                : [Colors.green.shade800, Colors.green.shade600],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.check_circle_outline,
              color: Colors.white,
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ],
        ),
      ),
      backgroundColor: Colors.transparent, // Transparent to let gradient shine
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isError ? Colors.red.shade300 : Colors.blueGrey.shade300,
          width: 1,
        ),
      ),
      elevation: 10,
      duration: duration,
      padding: const EdgeInsets.all(0), // Remove default padding
    ),
  );
}
