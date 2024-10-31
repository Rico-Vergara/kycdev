import 'package:flutter/material.dart';

void showFailedDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0), // Rounded corners
        ),
        title: const Row(
          children: [
            Icon(
              Icons.error_outline, // Error icon
              color: Colors.red, // Red for failed status
              size: 30,
            ),
            SizedBox(width: 10),
            Text("Failed", style: TextStyle(color: Colors.red)), // Title text
          ],
        ),
        content: const Text(
          "Something went wrong. Please try again.",
          style: TextStyle(color: Colors.black87), // Error message
        ),
        actions: [
          TextButton(
            child: const Text(
              "OK",
              style: TextStyle(color: Colors.red), // Button text color
            ),
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
            },
          ),
        ],
      );
    },
  );
}
