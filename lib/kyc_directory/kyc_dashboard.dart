import 'package:ekyc/kyc_directory/kyc_page/face_comparison.dart';
import 'package:ekyc/kyc_directory/kyc_page/finger_print.dart';
import 'package:ekyc/kyc_directory/kyc_page/id_verification.dart';
import 'package:ekyc/kyc_directory/kyc_page/liveness_detection.dart';
import 'package:ekyc/kyc_directory/kyc_page/register.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class KycDashboard extends StatefulWidget {
  const KycDashboard({super.key});

  @override
  State<KycDashboard> createState() => _KycDashboardState();
}

class _KycDashboardState extends State<KycDashboard> {
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(6.0),
            child: Column(
              children: [
                const Text(
                  'E-KYC',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 40),
                ),
                const Text(
                  'Lorem ipsum dolor sit amet,\n lorem lorem sinta',
                  style: TextStyle(color: Colors.black54),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 24),
                const Image(height: 150, image: AssetImage('assets/lock_icon.png')),
                SizedBox(height: 50),
                ElevatedButton(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => Register()));
                    },
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(Color(0xFF00b464)),
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
                              'Register',
                              style: TextStyle(color: Colors.white,  fontSize: 15),
                            )))),
                SizedBox(height: 6),
                ElevatedButton(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => FaceComparison()));
                    },
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(Color(0xFF00b464)),
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
                              'Face Comparison',
                              style: TextStyle(color: Colors.white,  fontSize: 15),
                            )))),
                SizedBox(height: 6),
                ElevatedButton(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => LivenessDetection()));
                    },
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
                              'Liveness Detection',
                              style: TextStyle(color: Colors.white,  fontSize: 15),
                            )))),
                SizedBox(height: 6),
                ElevatedButton(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => IdVerification()));
                    },
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
                              'ID Verification',
                              style: TextStyle(color: Colors.white,  fontSize: 15),
                            )))),
                SizedBox(height: 6),
                ElevatedButton(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => FingerPrint()));
                    },
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
                              'Finger Print',
                              style: TextStyle(color: Colors.white,  fontSize: 15),
                            )))),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
