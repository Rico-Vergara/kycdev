import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';

import '../custom_widget/kyc_dialog.dart';

class FaceComparison extends StatefulWidget {
  const FaceComparison({super.key});

  @override
  State<FaceComparison> createState() => _FaceComparisonState();
}

class _FaceComparisonState extends State<FaceComparison> {
  Map<String, dynamic> facialRecognition = {};
  String? photoString;
  Image? photo;
  String? idPhotoString;
  Image? idPhoto;
  bool isLoading = false;
  bool uploadPicture = false;
  bool uploadId = false;

  // This function handles picking an image from the image library or capturing a new image with the camera.
// `source` specifies whether the image is from the gallery or the camera.
// `isForPicture` is a boolean that determines if the image is for a picture or an ID.
  Future<void> pickImage(ImageSource source, bool isForPicture) async {
    try {
      // Use the ImagePicker to pick an image from the specified source (camera or gallery).
      final image = await ImagePicker().pickImage(
        source: source,
      );

      // Check if the user selected an image.
      if (image != null) {
        // Read the image file as bytes.
        var imageBytes = await File(image.path).readAsBytes();

        // Check if the image size exceeds 3 MB.
        if (imageBytes.lengthInBytes > 3 * 1024 * 1024) {
          // Resize the image if it's too large.
          imageBytes = await resizeImage(imageBytes);
        }

        // Convert the image bytes to a base64 encoded string.
        String base64String = base64Encode(imageBytes);

        // Ensure the base64 string length is a multiple of 4 by appending '=' if necessary.
        while (base64String.length % 4 != 0) {
          base64String += '=';
        }

        // Update the state with the base64 encoded image string.
        setState(() {
          if (isForPicture) {
            // If the image is for a picture, store it in `photoString` and process it.
            photoString = base64String;
            convertCapturedPhoto();
          } else {
            // If the image is for an ID, store it in `idPhotoString` and process it.
            idPhotoString = base64String;
            convertCapturedId();
          }
        });
      }
    } catch (e) {
      // Print any errors that occur during the image picking process.
      print('Error picking image: $e');
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

// This function sends selected images for facial recognition to a remote API and handles the response.
  Future<void> sendImagesToFacialRecognition() async {
    // Check if both photoString and idPhotoString are provided.
    if (photoString == null || idPhotoString == null) {
      // Display an error dialog if either image is missing.
      CustomDialog.reusableFailedDialogBox(
          context, 'Error', 'Please select both images.');
      return; // Exit the function if images are not provided.
    }

    // Set the loading state to true to indicate that the image processing is in progress.
    setState(() {
      isLoading = true;
    });

    // Prepare the request body by encoding the images and additional data to JSON format.
    final body = jsonEncode({
      "face_image": photoString,
      "id_image": idPhotoString,
      "country": "PH"
    });

    try {
      // Send a POST request to the facial recognition API with the JSON body and appropriate headers.
      final response = await http.post(
        Uri.parse(
            'https://sg.apitd.net/verification/kyc/identity/v1?partner_code=FDSASYA_ph_test&partner_key=bc8b4499b0154b51a0f224823ebf1162'),
        body: body,
        headers: {"Content-Type": "application/json"},
      );

      // Parse the response body from JSON into a Dart map.
      facialRecognition = jsonDecode(response.body);

      // Delay for 2 seconds to simulate processing time before updating the loading state.
      await Future.delayed(const Duration(seconds: 2), () {
        // Update the state to indicate that the loading process is complete.
        setState(() {
          isLoading = false;
        });

        // Process the response based on the status code.
        try {
          if (response.statusCode == 200) {
            // Extract the message and similarity score from the response.
            final title = facialRecognition['message'];
            final similarity =
                double.tryParse(facialRecognition['similarity'].toString()) ??
                    0;
            final result = similarity >= 90
                ? 'pass'
                : 'fail'; // Determine the result based on similarity.
            final content =
                'Face Comparison Result: $result\nSimilarity: ${facialRecognition['similarity']}%';

            // Display success dialog if the comparison passes and code is 200.
            if (facialRecognition['code'] == 200 && result == 'pass') {
              CustomDialog.reusableSuccessDialogBox(context, title, content,
                  () {
                Navigator.of(context)
                    .pop(); // Close the dialog on confirmation.
              });
            } else {
              // Display failure dialog if the comparison fails or the code is not 200.
              CustomDialog.reusableFailedDialogBox(context, 'Opss!', content);
            }
          } else {
            // Display failure dialog if the response status code is not 200.
            CustomDialog.reusableFailedDialogBox(
                context, 'Opss!', 'Face Comparison failed.');
          }
        } catch (e) {
          // Handle any exceptions during response processing and display an error dialog.
          CustomDialog.reusableFailedDialogBox(
              context, 'Opss!', 'Face Comparison failed.');
        }
      });
    } catch (e) {
      // Handle any exceptions during the HTTP request and display an error dialog.
      setState(() {
        isLoading =
            false; // Ensure loading state is updated in case of an error.
      });
      CustomDialog.reusableFailedDialogBox(
          context, 'Error', 'Failed to send images for facial recognition.');
    }
  }

  // Future<void> sendImagesToFacialRecognition() async {
  //   if (photoString == null || idPhotoString == null) {
  //     CustomDialog.reusableFailedDialogBox(context, 'Error', 'Please select both images.');
  //     return;
  //   }
  //
  //   setState(() {
  //     isLoading = true;
  //   });
  //
  //   final body =
  //       jsonEncode({"face_image": photoString, "id_image": idPhotoString, "country": "PH"});
  //
  //   final response = await http.post(
  //     Uri.parse(
  //         'https://sg.apitd.net/verification/kyc/identity/v1?partner_code=FDSASYA_ph_test&partner_key=bc8b4499b0154b51a0f224823ebf1162'),
  //     body: body,
  //     headers: {"Content-Type": "application/json"},
  //   );
  //
  //   facialRecognition = jsonDecode(response.body);
  //
  //   await Future.delayed(const Duration(seconds: 2), () {
  //     setState(() {
  //       isLoading = false;
  //     });
  //     try {
  //       if (response.statusCode == 200) {
  //         final title = facialRecognition['message'];
  //         final content =
  //             'Face Comparison Result: ${facialRecognition['result']}\nSimilarity: ${facialRecognition['similarity']}%';
  //         if (facialRecognition['code'] == 200 && facialRecognition['result'] == 'pass') {
  //           CustomDialog.reusableSuccessDialogBox(context, title, content, () {
  //             Navigator.of(context).pop();
  //           });
  //         } else {
  //           CustomDialog.reusableFailedDialogBox(context, 'Opss!', content);
  //         }
  //       } else {
  //         CustomDialog.reusableFailedDialogBox(context, 'Opss!', 'Face Comparison failed.');
  //       }
  //     } catch (e) {
  //       CustomDialog.reusableFailedDialogBox(context, 'Opss!', 'Face Comparison failed.');
  //     }
  //   });
  // }
  /*resize lang yung image*/
  Future<Uint8List> resizeImage(Uint8List imageBytes) async {
    final img.Image? originalImage = img.decodeImage(imageBytes);
    if (originalImage == null) {
      throw Exception('Failed to decode image.');
    }

    const int maxSizeBytes = 3 * 1024 * 1024;

    int quality = 90;
    do {
      imageBytes =
          Uint8List.fromList(img.encodeJpg(originalImage, quality: quality));
      quality -= 10;
    } while (imageBytes.lengthInBytes > maxSizeBytes && quality > 0);

    return imageBytes;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Face Comparison'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            children: [
              //ID Image
              Text(
                'Upload your ID',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 12),
              //if empty yung image, icon pag meron edi yung picture!
              idPhoto != null
                  //ETO YUNG PICTURE pag may uploaded na image
                  ? Container(
                      width: 200,
                      height: 200,
                      child: idPhoto,
                      decoration: BoxDecoration(
                          border: Border.all(color: Color(0xFF00b464)),
                          borderRadius: BorderRadius.circular(6)),
                    )
                  //Pag wala eto lalabas!
                  : Container(
                      width: 200,
                      height: 200,
                      color: Colors.grey[300],
                      child: const Icon(
                        Icons.credit_card_outlined,
                        color: Colors.black,
                        size: 40,
                      ),
                    ),
              const SizedBox(height: 10),

              //Button para sa GALLERY
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: ElevatedButton(
                      //onpressed, para matrigger yung pickImage function!
                      onPressed: () => pickImage(ImageSource.gallery, false),
                      style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all(Color(0xFF00b464)),
                        shape:
                            MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                        padding: MaterialStateProperty.all<EdgeInsets>(
                          EdgeInsets.symmetric(vertical: 9.0),
                        ),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.photo_library_outlined,
                            color: Colors.white,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Gallery',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  //Button para sa Camera
                  SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      //para sa pickIMage trigger hehehehehehe
                      onPressed: () => pickImage(ImageSource.camera, false),
                      style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all(Color(0xFF00b464)),
                        shape:
                            MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                        padding: MaterialStateProperty.all<EdgeInsets>(
                          EdgeInsets.symmetric(vertical: 9.0),
                        ),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.camera_alt_outlined,
                            color: Colors.white,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Camera',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              const Padding(
                padding: EdgeInsets.all(5.0),
                child: Divider(),
              ),

              //Component para sa ur face
              //Face Image
              const Text(
                'Upload your Picture',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 12),
              //checking if may image or wala
              photo != null
                  //Etong container lalabas pag meron
                  ? Container(
                      width: 200,
                      height: 200,
                      child: photo,
                      decoration: BoxDecoration(
                          border: Border.all(color: Color(0xFF00b464)),
                          borderRadius: BorderRadius.circular(6)),
                    )
                  //pag wala ETO!
                  : Container(
                      width: 200,
                      height: 200,
                      color: Colors.grey[300],
                      child: const Icon(Icons.camera_alt,
                          color: Colors.black, size: 40),
                    ),
              const SizedBox(height: 10),

              //Create Row widget, para sa GAllery at Camera Button
              //Same lang sa taas yung onPressed
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => pickImage(ImageSource.gallery, true),
                      style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all(Color(0xFF00b464)),
                        shape:
                            MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                        padding: MaterialStateProperty.all<EdgeInsets>(
                          EdgeInsets.symmetric(vertical: 9.0),
                        ),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.photo_library_outlined,
                            color: Colors.white,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Gallery',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => pickImage(ImageSource.camera, true),
                      style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all(Color(0xFF00b464)),
                        shape:
                            MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                        padding: MaterialStateProperty.all<EdgeInsets>(
                          EdgeInsets.symmetric(vertical: 9.0),
                        ),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.camera_alt_outlined,
                            color: Colors.white,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Camera',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),

      //button para matrigger yung sendImagesToFacialRecognition
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SizedBox(
          width: double.infinity,
          height: 45,
          child: ElevatedButton(
            onPressed: sendImagesToFacialRecognition,
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
                      'Compare',
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
