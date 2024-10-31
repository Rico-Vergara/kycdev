import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:ekyc/register_flow/registration.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:trustdevice_pro_plugin/trustdevice_pro_plugin.dart';

// Screen to display recommended ID types
class RecommendedIdScreen extends StatelessWidget {
  RecommendedIdScreen({super.key});

  // List of approved ID types
  final List<String> approvedIdTypes = [
    'Social Security System',
    'Unified Multi-Purpose ID',
    'Tax Identification Number',
    'Professional Regulation Commission',
    'Driver\'s License',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Recommended IDs',
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: BackButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => KYCForm()), // Navigate back to KYCForm
            );
          },
        ),
      ),
      body: ListView.builder(
        itemCount: approvedIdTypes.length, // Number of IDs to display
        itemBuilder: (context, index) {
          return _buildListItem(
            context,
            Icons.person, // Icon to display next to ID type
            approvedIdTypes[index], // ID type name
          );
        },
      ),
    );
  }

  // Method to build each list item for ID types
  Widget _buildListItem(BuildContext context, IconData icon, String title) {
    return GestureDetector(
      onTap: () {
        // Navigate to ImagePickerScreen if ID is approved
        if (approvedIdTypes.contains(title)) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ImagePickerScreen(idType: title),
            ),
          );
        }
      },
      child: Card(
        color: Colors.green,
        elevation: 2,
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        child: ListTile(
          leading: CircleAvatar(
            child: Icon(icon),
          ),
          title: Text(title),
          trailing: const Icon(Icons.arrow_forward_ios), // Right arrow icon
        ),
      ),
    );
  }
}

// Screen to pick and handle images (camera/gallery)
class ImagePickerScreen extends StatefulWidget {
  final String idType; // ID type passed from previous screen

  const ImagePickerScreen({super.key, required this.idType});

  @override
  _ImagePickerScreenState createState() => _ImagePickerScreenState();
}

class _ImagePickerScreenState extends State<ImagePickerScreen> {
  Image? idPhoto;
  Image? photo;
  String? photoString;
  String? idPhotoString;
  File? _imageFile; // Image file picked by the user
  bool isLoading = false; // Loading state to show progress

  final ImagePicker _picker = ImagePicker(); // Image picker instance

  // Liveness and facial recognition variables
  String license = '';
  final _trustdeviceProPlugin = TrustdeviceProPlugin();
  Map<String, dynamic> facialRecognition = {};
  Map<String, dynamic> livenessResult = {};
  bool faceCompareLoading = false;
  bool successFinishRegistration = false;
  bool livenessError = false;
  bool faceCompareError = false;
  String statusDisplay = '';
  String errorMsgDisplay = '';

  @override
  void initState() {
    super.initState();
    getLicense(); // Initialize license for liveness check
  }

  Future<void> _initWithOptions() async {
    var options = {
      "partner": "FDSASYA_ph_test", // Partner code.
      "appKey": "4ed0812247aa65550ba98bbd6eaa140a", // Application key.
      "appName": "forTest", // Application name.
      "country": "sg", // Country code (Singapore).
    };
    _trustdeviceProPlugin.initWithOptions(options);
    _trustdeviceProPlugin.getBlackboxAsync();
  }

  Future<void> getLicense() async {
    var url =
        'https://sg.apitd.net/verification/kyc/sdk/liveness/license/v1?partner_code=FDSASYA_ph_test&partner_key=bc8b4499b0154b51a0f224823ebf1162';
    final response = await http
        .post(Uri.parse(url), headers: {"Content-Type": "application/json"});

    final data = jsonDecode(response.body);
    if (data['code'] == 200) {
      setState(() {
        license = data['license'];
      });
      _initWithOptions();
    } else {
      showFailedDialog(context, 'License Error', data['message']);
    }
  }

  Future<void> handleLiveness() async {
    await _trustdeviceProPlugin.showLiveness(
        license,
        TDLivenessCallback(
          onSuccess: (String seqId, int errorCode, String errorMsg,
              double score, String bestImageString, String livenessId) async {
            setState(() {
              photoString = bestImageString;
              faceCompareLoading = true;
            });
            await handleFaceCompare(); // Trigger face comparison on success
          },
          onFailed: (String seqId, int errorCode, String errorMsg,
              String livenessId) {
            setState(() {
              livenessError = true;
              statusDisplay = 'Liveness failed';
              errorMsgDisplay = errorMsg;
            });
            showFailedDialog(context, 'Liveness Failed', errorMsg);
          },
        ));
  }

  Future<void> handleFaceCompare() async {
    if (photoString != null && idPhotoString != null) {
      final faceComparisonResult =
          await sendImagesToFacialRecognition(photoString!, idPhotoString!);

      if (faceComparisonResult['status'] == 'success') {
        setState(() {
          successFinishRegistration = true;
          faceCompareLoading = false;
        });
      } else {
        setState(() {
          faceCompareError = true;
          statusDisplay = faceComparisonResult['status'];
          errorMsgDisplay = faceComparisonResult['message'];
          faceCompareLoading = false;
        });
      }
    }
  }

  Future<Map<String, dynamic>> sendImagesToFacialRecognition(
      String face, String id) async {
    final body =
        jsonEncode({"face_image": face, "id_image": id, "country": "PH"});
    final response = await http.post(
      Uri.parse(
          'https://sg.apitd.net/verification/kyc/identity/v1?partner_code=FDSASYA_ph&partner_key=0c3da8aaab2e46a4a2fd6f3103738eaa'),
      body: body,
      headers: {"Content-Type": "application/json"},
    );

    final facialRecognition = jsonDecode(response.body);
    if (response.statusCode == 200 && facialRecognition['code'] == 200) {
      return {
        "status": facialRecognition['result'] == 'pass' ? "success" : "fail",
        "result": facialRecognition['result'],
        "similarity": facialRecognition['similarity']
      };
    } else {
      return {"status": "error", "message": facialRecognition['message']};
    }
  }

  // Method to capture an image from the camera
  Future<void> captureImageFromCamera() async {
    await _pickImage(ImageSource.camera, true);
  }

  // Method to select an image from the gallery
  Future<void> selectImageFromGallery() async {
    await _pickImage(ImageSource.gallery, false);
  }

  // Method to handle picking image from the camera or gallery
  Future<void> _pickImage(ImageSource source, bool isForPicture) async {
    try {
      setState(() => isLoading = true);

      // Pick the image using the specified source (camera or gallery)
      final image = await _picker.pickImage(
        source: source,
      );

      final response = await http.post(
        Uri.parse(
            'https://sg.apitd.net/verification/kyc/idverify/v1?partner_code=FDSASYA_ph_test&partner_key=bc8b4499b0154b51a0f224823ebf1162'),
        headers: {"Content-Type": "application/json"},
      );

      if (image != null) {
        var imageBytes = await File(image.path).readAsBytes();

        // Resize the image if larger than 3 MB
        if (imageBytes.lengthInBytes > 3 * 1024 * 1024) {
          imageBytes = await _resizeImage(imageBytes);
        }
        String base64String = base64Encode(imageBytes);

        // Ensure the base64 string length is a multiple of 4 by appending '=' if necessary.
        while (base64String.length % 4 != 0) {
          base64String += '=';
        }

        // Update the state with the new image data
        setState(
          () {
            if (isForPicture) {
              // If the image is for a picture, store it in `photoString` and process it.
              photoString = base64String;
              convertCapturedPhoto();
            } else {
              // If the image is for an ID, store it in `idPhotoString` and process it.
              idPhotoString = base64String;
              convertCapturedId();
            }

            // Update the _imageFile as well
            _imageFile = File(image.path);
          },
        );
      }
    } catch (e) {
      print(e);
      showFailedDialog(context, 'System Error', 'Please try again later');
    } finally {
      setState(() => isLoading = false);
    }
  }

  // This function converts a base64-encoded photo string into an image and updates the state accordingly.
  void convertCapturedPhoto() {
    // Check if the photoString is not null and not empty.
    if (photoString != null && photoString!.isNotEmpty) {
      // Decode the base64-encoded photoString into a list of bytes.
      List<int> imageData = base64Decode(photoString!);

      // Update the state to display the image.
      setState(() {
        // Create an Image widget from the decoded byte data and assign it to the `photo` variable.
        // The `ValueKey` ensures that the widget is uniquely identified based on the `photoString`.
        photo = Image.memory(Uint8List.fromList(imageData),
            key: ValueKey(photoString));
      });
    } else {
      // If the photoString is null or empty, update the state to remove the image.
      setState(() {
        photo = null;
      });
    }
  }

  // This function converts a base64-encoded ID photo string into an image and updates the state accordingly.
  void convertCapturedId() {
    // Check if the idPhotoString is not null and not empty.
    if (idPhotoString != null && idPhotoString!.isNotEmpty) {
      // Decode the base64-encoded idPhotoString into a list of bytes.
      List<int> imageData = base64Decode(idPhotoString!);

      // Update the state to display the ID photo.
      setState(() {
        // Create an Image widget from the decoded byte data and assign it to the `idPhoto` variable.
        // The `ValueKey` ensures that the widget is uniquely identified based on the `idPhotoString`.
        idPhoto = Image.memory(Uint8List.fromList(imageData),
            key: ValueKey(idPhotoString));
      });
    } else {
      // If the idPhotoString is null or empty, update the state to remove the ID photo.
      setState(() {
        idPhoto = null;
      });
    }
  }

  // Method to resize the image
  Future<Uint8List> _resizeImage(Uint8List imageBytes) async {
    img.Image? image = img.decodeImage(imageBytes);
    if (image == null) throw Exception('Failed to decode image');

    // Resize image to a maximum width of 800px
    int targetWidth = 800;
    img.Image resizedImage = img.copyResize(image,
        width: targetWidth,
        height: (image.height * targetWidth ~/ image.width));

    return Uint8List.fromList(img.encodeJpg(resizedImage));
  }

  // Helper method to display error dialog
  void showFailedDialog(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          title: Row(
            children: [
              const Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 30,
              ),
              const SizedBox(width: 30),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.red,
                ),
              ),
            ],
          ),
          content: Text(
            message,
            style: const TextStyle(
              color: Colors.black87,
            ),
          ),
          actions: [
            TextButton(
              child: const Text(
                "OK",
                style: TextStyle(
                  color: Colors.red,
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showCustomDialog(BuildContext context) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.white,
          child: SizedBox(
            width: 300,
            height: 380,
            child: Column(
              children: <Widget>[
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                            'Remove your cap, mask, or glasses',
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Image.asset('assets/face1.png', height: 200),
                      ],
                    ),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.only(bottom: 20, right: 20, left: 20),
                  child: Column(
                    children: [
                      const Text(
                          'Are you ready? Click "Start" to start scanning.',
                          textAlign: TextAlign.center),
                      SizedBox(height: 5),
                      Container(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            handleLiveness();
                          },
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: Colors.green,
                            elevation: 5,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text('Start'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          ' ${widget.idType}',
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 5),
                    Text('1. Clear and Readable and mga nakasulat sa ID'),
                    SizedBox(height: 5),
                    Text(
                        '2. Take a photo of your real and Valid ID, at hindi photocopy.'),
                    SizedBox(height: 5),
                    Text('3. Make sure na hindi expired and iyong Valid IDs.'),
                    SizedBox(height: 5),
                    Text(
                        '4. Complete and correct lahat ng personal information na nasa ID.'),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              // Show loading indicator while processing
              if (isLoading) const CircularProgressIndicator(),
              // Show image preview if image is selected
              if (!isLoading)
                Container(
                  width: 250,
                  height: 300,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: _imageFile != null
                      ? Image.file(_imageFile!)
                      : const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.image),
                            Text('No image selected'),
                          ],
                        ),
                ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: captureImageFromCamera,
                    icon: const Icon(
                      Icons.camera_alt_outlined,
                      color: Colors.green,
                    ),
                    label: const Text(
                      'Camera',
                      style: TextStyle(
                        color: Colors.green,
                      ),
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: selectImageFromGallery,
                    icon: const Icon(
                      Icons.photo_library,
                      color: Colors.green,
                    ),
                    label: const Text(
                      'Gallery',
                      style: TextStyle(
                        color: Colors.green,
                      ),
                    ),
                  ),
                ],
              ),
              // add widgets
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ElevatedButton(
          onPressed: () {
            if (_imageFile != null) {
              // Show the custom dialog to start scanning
              _showCustomDialog(context);
            } else {
              showFailedDialog(
                  context, 'Error', 'Please select an image first.');
            }
          },
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(Colors.green),
            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
            ),
          ),
          child: const Text('Next',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w600)),
        ),
      ),
    );
  }
}
