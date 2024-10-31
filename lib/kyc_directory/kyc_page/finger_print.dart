import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class FingerPrint extends StatefulWidget {
  const FingerPrint({super.key});

  @override
  State<FingerPrint> createState() => _FingerPrintState();
}

class _FingerPrintState extends State<FingerPrint> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Finger Print'),
      ),
      body: Text('hello'),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ElevatedButton(
            onPressed: () {},
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(Color(0xFF00b460)),
              shape: MaterialStateProperty.all<OutlinedBorder>(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6.0),
                ),
              ),
            ),
            child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.7,
                height: 50,
                child: const Center(
                    child: Text(
                  'Scan Fingerprint',
                  style: TextStyle(color: Colors.white, fontSize: 15),
                )))),
      ),
    );
  }
}
