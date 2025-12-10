import 'package:flutter/material.dart';

Future<void> showCustomDialog({
  required BuildContext context,
  required String message,
  bool isError = true,
  int displayDuration = 3000,
}) async {
  return showDialog<void>(
    context: context,
    barrierDismissible: true, // Allow dismissing by tapping outside
    builder: (context) {
      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        backgroundColor: Colors.white.withOpacity(0.9),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 35),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: Colors.white.withOpacity(0.9),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor:
                    isError
                        ? Colors.red.withOpacity(0.1)
                        : Colors.green.withOpacity(0.1),
                child: Icon(
                  isError ? Icons.error : Icons.check,
                  size: 30,
                  color: isError ? Colors.red : Colors.green,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  color: isError ? Colors.red : Colors.green,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
