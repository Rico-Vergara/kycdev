import 'package:flutter/material.dart';

class VerificationResultScreen extends StatelessWidget {
  final Map<String, dynamic> verificationData;

  const VerificationResultScreen({super.key, required this.verificationData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'ID INFORMATION',
          overflow: TextOverflow.ellipsis,
          softWrap: false,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            _buildInfoRow(
              'Result',
              verificationData['result'] ?? 'No data available',
            ),
            const SizedBox(height: 20),
            if (verificationData['additionalInfo'] != null)
              _buildInfoRow(
                'Additional Info',
                verificationData['additionalInfo'],
              ),
            const SizedBox(height: 20),
            // Display more fields if available in the API response
            if (verificationData['idNumber'] != null)
              _buildInfoRow(
                'ID Number',
                verificationData['idNumber'],
              ),
            if (verificationData['name'] != null)
              _buildInfoRow(
                'Name',
                verificationData['name'],
              ),
            if (verificationData['dateOfBirth'] != null)
              _buildInfoRow(
                'Date of Birth',
                verificationData['dateOfBirth'],
              ),
            const Spacer(),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // Go back to the previous screen
                },
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.green),
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                ),
                child: const Text(
                  'Done',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Reusable widget to build info rows
  Widget _buildInfoRow(String title, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '$title:',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: const TextStyle(
              fontSize: 16,
            ),
          ),
        ),
      ],
    );
  }
}
