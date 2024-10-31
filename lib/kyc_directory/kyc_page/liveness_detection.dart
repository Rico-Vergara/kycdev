import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:trustdevice_pro_plugin/trustdevice_pro_plugin.dart';
import '../custom_widget/kyc_dialog.dart';
import 'package:http/http.dart' as http;

class LivenessDetection extends StatefulWidget {
  const LivenessDetection({super.key});

  @override
  State<LivenessDetection> createState() => _LivenessDetectionState();
}

class _LivenessDetectionState extends State<LivenessDetection> {
  final trustDeviceProPlugin = TrustdeviceProPlugin();
  Map<String, dynamic> livenessResult = {};
  String license = '';
  Image? photo;
  String? photoString;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    getLicense();
  }

  Future<void> getLicense() async {
    // Define the URL for the API request to get the license.
    var url = 'https://sg.apitd.net/verification/kyc/sdk/liveness/license/v1?partner_code=FDSASYA_ph_test&partner_key=bc8b4499b0154b51a0f224823ebf1162';

    // Prepare the request body with the session duration.
    var body = jsonEncode({
      "session_duration": 28800  // Duration in seconds (8 hours).
    });

    // Define the headers for the HTTP request.
    var header = {
      'Content-Type': 'application/json'  // Specifies that the content is JSON.
    };

    // Make an asynchronous HTTP POST request to the URL with the given body and headers.
    final response = await http.post(Uri.parse(url), body: body, headers: header);

    // Decode the JSON response body into a Map.
    final Map<String, dynamic> data = jsonDecode(response.body);

    // Print the entire response data for debugging purposes.
    print(data);

    // Check if the response code indicates success (200).
    if (data['code'] == 200) {
      // Update the state with the license received from the response.
      setState(() {
        license = data['license'];
      });
      // Print a debug message.
      print('Helllo');
      // Initialize the plugin with the obtained options.
      _initWithOptions();
    } else {
      // Prepare error message and title for failure cases.
      var title = 'Opss!';
      var content = data['message'];
      // Show a dialog box indicating failure.
      CustomDialog.reusableFailedDialogBox(context, title, content);
    }

    // Print the license value for debugging purposes.
    print(license);
  }

  Future<void> _initWithOptions() async {
    try {
      // Define the options for initializing the plugin.
      var options = {
        "partner": "FDSASYA_ph_test",  // Partner code.
        "appKey": "4ed0812247aa65550ba98bbd6eaa140a",  // Application key.
        "appName": "forTest",  // Application name.
        "country": "sg",  // Country code (Singapore).
      };
      // Initialize the plugin with the defined options.
      await trustDeviceProPlugin.initWithOptions(options);
    } catch (e) {
      // Handle any errors during initialization.
      print("Initialization failed: $e");
      var title = 'Initialization Failed';
      var content = 'The plugin initialization failed. Please try again.';
      // Show a dialog box indicating failure.
      CustomDialog.reusableFailedDialogBox(context, title, content);
    }
  }

  Future<void> startLiveness() async {
    try {
      // Start the liveness detection process using the obtained license.
      await trustDeviceProPlugin.showLiveness(
        license,
        TDLivenessCallback(
          // Callback when liveness detection succeeds.
          onSuccess: (String seqId, int errorCode, String errorMsg, double score, String bestImageString, String livenessId) {
            print("Liveness success! seqId: $seqId, livenessId: $livenessId, score: $score");
            setState(() {
              livenessResult['message'] = 'Liveness success!';
              livenessResult['score'] = score;
              photoString = bestImageString;  // Store the best image string received.
            });
            // Convert and display the captured photo.
            convertCapturedPhoto();
          },
          // Callback when liveness detection fails.
          onFailed: (String seqId, int errorCode, String errorMsg, String livenessId) {
            print("Liveness failed! errorCode: $errorCode errorMsg: $errorMsg livenessId: $livenessId");
            var title = 'Liveness Failed!';
            var content = errorMsg;
            // Show a dialog box indicating failure.
            CustomDialog.reusableFailedDialogBox(context, title, content);
          },
        ),
      );
    } catch (e) {
      // Handle any errors that occur while starting liveness detection.
      print('Error starting liveness detection: $e');
      var title = 'Error';
      var content = 'An error occurred while starting liveness detection. Please try again.';
      // Show a dialog box indicating failure.
      CustomDialog.reusableFailedDialogBox(context, title, content);
    }
  }

  void convertCapturedPhoto() {
    if (photoString != null && photoString!.isNotEmpty) {
      List<int> imageData = base64Decode(photoString!);
      setState(() {
        photo = Image.memory(Uint8List.fromList(imageData),
            key: ValueKey(photoString));
      });
    } else {
      setState(() {
        photo = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Liveness Detection'),
      ),
        body: Center(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Container(
                      width: 300,
                      height: 300,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(5),
                        boxShadow: [
                          BoxShadow(
                            offset: const Offset(0.0, 5.0),
                            color: Colors.black.withOpacity(0.1),
                            spreadRadius: 1,
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: photo ?? Image(image: AssetImage('assets/facescan.png'))
                      ),
                    ),
                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          Text(
                            'Result: ${livenessResult['message'] ?? ''}',
                            style: const TextStyle(
                              fontFamily: 'Helvetica',
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Score: ${livenessResult['score'].toString()}',
                            style: const TextStyle(
                              fontFamily: 'Helvetica',
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SizedBox(
          width: double.infinity,
          height: 45,
          child: ElevatedButton(
            onPressed: startLiveness,
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(const Color(0xFF00b464)),
              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
            child: isLoading
                ? const CircularProgressIndicator(color: Colors.white)
                : const Center(
              child: Text(
                'Start Liveness Detection',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
