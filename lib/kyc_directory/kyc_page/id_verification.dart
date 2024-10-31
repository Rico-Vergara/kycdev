import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../custom_widget/kyc_dialog.dart';

class IdVerification extends StatefulWidget {
  const IdVerification({super.key});

  @override
  State<IdVerification> createState() => _IdVerificationState();
}

class _IdVerificationState extends State<IdVerification> {
  String? selectedId;
  bool isLoading = false;
  String? taskId;
  final TextEditingController idNumber = TextEditingController();
  final TextEditingController phoneNumber = TextEditingController();
  final TextEditingController name = TextEditingController();
  final TextEditingController country = TextEditingController();

  final _formKey =
      GlobalKey<FormState>(); // Global key to manage the state of the form.
  bool isIdTypeValid(String idType) {
    // Checks if the provided ID type is valid by checking if it exists in the idTypes list.
    return idTypes.contains(idType);
  }

  final List<String> idTypes = [
    'SSS',
    'UMID',
    'TIN',
    'PRC',
    'DL'
  ]; // List of valid ID types.

  List<DropdownMenuItem<String>> get dropdownItems {
    // Converts the idTypes list into a list of DropdownMenuItem widgets.
    return idTypes.map((String value) {
      return DropdownMenuItem<String>(
        value: value,
        child: Text(value == 'DL'
            ? 'Driver\'s License'
            : value), // Displays 'Driver\'s License' for 'DL' value.
      );
    }).toList();
  }

  void onChanged(String? value) {
    // Updates the selectedId state when the dropdown value changes.
    setState(() {
      selectedId = value;
    });
  }

  Future<void> verifyId() async {
    // Validates the form and processes ID verification.
    if (_formKey.currentState?.validate() ?? false) {
      // Shows loading state.
      setState(
        () {
          isLoading = true;
        },
      );

      // Constructs the request body with form values.
      final body = jsonEncode(
        {
          "country": country.text,
          "phone_number": phoneNumber.text,
          "id_type": selectedId,
          "id_number": idNumber.text,
          "name": name.text
        },
      );

      try {
        // Makes a POST request to verify the ID.
        final response = await http.post(
          Uri.parse(
              'https://sg.apitd.net/verification/kyc/idverify/v1?partner_code=FDSASYA_ph_test&partner_key=bc8b4499b0154b51a0f224823ebf1162'),
          body: body,
          headers: {"Content-Type": "application/json"},
        );

        // Checks the response status and processes the result.
        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          if (data['message'] == 'success') {
            // Sets the task ID and calls validationOfId method.
            taskId = data['task_id'];
            await validationOfId();
          } else {
            // Shows a dialog box if the ID is invalid.
            CustomDialog.reusableFailedDialogBox(
                context, 'Ops!', 'Your ID is Invalid');
          }
        } else {
          // Logs error details if the response status is not 200.
          print('Error: ${response.statusCode} - ${response.body}');
        }
      } catch (e) {
        // Logs network errors.
        print('Network error: $e');
      } finally {
        // Hides loading state.
        setState(() {
          isLoading = false;
        });
      }
    } else {
      // Logs if the form is not filled correctly.
      print('Please fill in all fields.');
    }
  }

  Future<void> validationOfId() async {
    // Checks if taskId is available before querying.
    if (taskId == null) {
      print('Task ID is not available.');
      return;
    }

    bool queryInProgress =
        true; // Flag to check if the query is still in progress.
    int attemptCount = 0; // Number of attempts to query the ID status.
    int maxAttempts = 5; // Maximum number of attempts to query the ID status.

    while (queryInProgress && attemptCount < maxAttempts) {
      // Logs the task ID for debugging.
      print('TASK ID for request: $taskId');

      // Constructs the request body with the task ID.
      final body = jsonEncode({
        "task_id": taskId,
      });

      try {
        // Makes a POST request to check the ID status.
        final response = await http.post(
          Uri.parse(
              'https://sg.apitd.net/verification/kyc/idverify/query/v1?partner_code=FDSASYA_ph_test&partner_key=bc8b4499b0154b51a0f224823ebf1162'),
          body: body,
          headers: {"Content-Type": "application/json"},
        );

        // Logs the response for debugging.
        print('Validation response: ${response.body}');

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);

          if (data['code'] == 12001) {
            // If the status code indicates that the ID is still being processed, wait and retry.
            attemptCount++;
            await Future.delayed(const Duration(seconds: 5));
          } else if (data['result'] != null &&
              data['result']['status'] != null) {
            // If a valid result status is returned, stop querying.
            queryInProgress = false;

            // Checks the result status and shows the appropriate dialog.
            if (data['result']['status'] == 'id_found') {
              CustomDialog.reusableSuccessDialogBox(
                  context, 'Verification Success', 'Your ID is Valid', () {
                Navigator.of(context).pop();
              });
            } else if (data['result']['status'] == "id_not_found") {
              CustomDialog.reusableFailedDialogBox(
                  context, 'Opss!', 'Your ID is Invalid');
            }
          } else {
            // Logs if the response format is unexpected.
            print('Unexpected response format: ${response.body}');
            queryInProgress = false;
          }
        } else {
          // Logs error details if the response status is not 200.
          print('Error: ${response.statusCode} - ${response.body}');
          queryInProgress = false;
        }
      } catch (e) {
        // Logs network errors.
        print('Network error: $e');
        queryInProgress = false;
      }
    }
    // Logs if the maximum number of attempts is reached without final status.
    if (attemptCount == maxAttempts) {
      print('Maximum attempts reached. Could not retrieve a final status.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ID Verification'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                DropdownButtonFormField<String>(
                  value: selectedId,
                  items: dropdownItems,
                  onChanged: onChanged,
                  validator: (value) {
                    if (value == null) {
                      return "Please select your ID type";
                    }
                    return null;
                  },
                  decoration: const InputDecoration(
                    labelText: 'Select ID Type',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 20),
                // selectedId == 'SSS'
                //     ?
                Column(
                  children: [
                    TextFormField(
                      controller: idNumber,
                      decoration: InputDecoration(
                        labelText: 'Enter $selectedId ID Number',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.text,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Please enter your $selectedId ID number";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
                // : Container(),
                TextFormField(
                  controller: phoneNumber,
                  decoration: const InputDecoration(
                    labelText: 'Enter Your Phone Number',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter your phone number";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: country,
                  decoration: const InputDecoration(
                    labelText: 'Enter Country',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.text,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter your country";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: name,
                  decoration: const InputDecoration(
                    labelText: 'Enter Your Name',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.text,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter your name";
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SizedBox(
          width: double.infinity,
          height: 45,
          child: ElevatedButton(
            onPressed: isLoading ? null : verifyId,
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(Color(0xFF00b464)),
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
                      'Verify',
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
