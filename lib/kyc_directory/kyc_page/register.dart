import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  String? photoString;
  Image? photo;
  bool isLoading = false;
  Map<String, String> extractedFields = {};

  // This function allows the user to pick an image from the gallery.
  Future<void> captureImageFromGallery() async {
    try {
      // Pick an image from the gallery using the ImagePicker plugin.
      final pickedFile = await ImagePicker().pickImage(
        source: ImageSource.gallery,
      );

      // Check if the user has selected an image.
      if (pickedFile != null) {
        // Read the image file as bytes.
        var imageBytes = await File(pickedFile.path).readAsBytes();

        // Check if the image size exceeds 3 MB and resize if necessary.
        if (imageBytes.lengthInBytes > 3 * 1024 * 1024) {
          imageBytes = await resizeImage(imageBytes);
        }

        // Convert the image bytes to a base64-encoded string.
        String base64String = base64Encode(imageBytes);

        // Update the state with the base64-encoded string of the photo.
        setState(() {
          photoString = base64String;
        });

        // Convert the image to display.
        convertImage();
      }
    } catch (e) {
      // Print an error message if something goes wrong.
      print('Error picking image: $e');
    }
  }

// This function allows the user to capture an image using the camera.
  Future<void> captureImageFromCamera() async {
    try {
      // Capture an image using the camera.
      final image = await ImagePicker().pickImage(
        source: ImageSource.camera,
      );

      // Check if the image was captured successfully.
      if (image != null) {
        // Read the image file as bytes.
        var imageBytes = await File(image.path).readAsBytes();

        // Check if the image size exceeds 3 MB and resize if necessary.
        if (imageBytes.lengthInBytes > 3 * 1024 * 1024) {
          imageBytes = await resizeImage(imageBytes);
        }

        // Convert the image bytes to a base64-encoded string.
        String base64String = base64Encode(imageBytes);

        // Ensure the base64 string length is a multiple of 4 by appending '=' if necessary.
        while (base64String.length % 4 != 0) {
          base64String += '=';
        }

        // Update the state with the base64-encoded string of the photo.
        setState(() {
          photoString = base64String;
        });

        // Send the image to OCR (Optical Character Recognition) service for processing.
        await sendImageToOCR(photoString!);

        // Convert the image to display.
        convertImage();
      }
    } catch (e) {
      // Print an error message if something goes wrong.
      print('Error capturing image: $e');
    }
  }

// This function sends the base64-encoded image to an OCR service and processes the response.
  Future<void> sendImageToOCR(String base64Image) async {
    // Set the loading state to true and reset the extractedFields.
    setState(() {
      isLoading = true;
      extractedFields = {};
    });

    try {
      // Prepare the request body with the base64 image and additional parameters.
      final body = jsonEncode({
        "image": base64Image,
        "country": "PH",
        "scenario": "Ocr",
        "options": "images,image_quality,document_type"
      });

      // Send a POST request to the OCR API.
      final response = await http.post(
        Uri.parse(
            'https://sg.apitd.net/verification/kyc/ocr/v1?partner_code=FDSASYA_ph_test&partner_key=bc8b4499b0154b51a0f224823ebf1162'),
        body: body,
        headers: {"Content-Type": "application/json"},
      );

      // Check if the response status code indicates success (200).
      if (response.statusCode == 200) {
        // Parse the response body from JSON into a Dart map.
        final data = jsonDecode(response.body);

        // Process the response based on the 'result' field.
        if (data['result'] == 'success' || data['result'] == 'error') {
          extractFields(data);
          // Update the state to indicate loading is complete.
          setState(() {
            isLoading = false;
          });
        }
      }
    } catch (e) {
      // Print an error message if something goes wrong with the request.
      print('Error sending image to OCR: $e');
    }
  }

// This function extracts specific fields from the OCR response data.
  void extractFields(Map<String, dynamic> data) {
    // Define a list of target fields to extract.
    List<String> targetFields = [
      "result",
      "document_name",
      "document_description",
      "Document Number",
      "Issuing State Code",
      "Issuing State Name",
      "Surname And Given Names",
      "Date of Birth",
      "Age",
      "Address",
    ];

    // Temporary map to hold extracted fields.
    Map<String, String> extractedFieldsTemp = {};

    // Extracting fields from the root level of the response data.
    if (data.containsKey("result")) {
      extractedFieldsTemp["result"] = data["result"];
    }

    // Extracting fields from the document_type_info section of the response data.
    if (data.containsKey("document_type_info")) {
      if (data["document_type_info"].containsKey("document_name")) {
        extractedFieldsTemp["document_name"] =
            data["document_type_info"]["document_name"];
      }
      if (data["document_type_info"].containsKey("document_description")) {
        extractedFieldsTemp["document_description"] =
            data["document_type_info"]["document_description"];
      }
    }

    // Extracting fields from the card_info.field_list section of the response data.
    if (data.containsKey("card_info") &&
        data["card_info"].containsKey("field_list")) {
      List<dynamic> fieldList = data["card_info"]["field_list"];
      for (var field in fieldList) {
        String fieldName = field["field_name"];
        if (targetFields.contains(fieldName)) {
          extractedFieldsTemp[fieldName] = field["value_list"][0]["value"];
        }
      }
    }

    // Update the state with the extracted fields.
    setState(() {
      extractedFields = extractedFieldsTemp;
    });
  }

// This function resizes the image to ensure it does not exceed 3 MB.
  Future<Uint8List> resizeImage(Uint8List imageBytes) async {
    // Decode the image bytes into an Image object.
    final img.Image? originalImage = img.decodeImage(imageBytes);
    if (originalImage == null) {
      throw Exception('Failed to decode image.');
    }

    // Define the maximum allowed image size in bytes.
    const int maxSizeBytes = 3 * 1024 * 1024;

    // Set the initial image quality for resizing.
    int quality = 90;
    do {
      // Encode the image with the current quality setting.
      imageBytes =
          Uint8List.fromList(img.encodeJpg(originalImage, quality: quality));
      quality -= 10; // Decrease the quality for the next iteration if needed.
    } while (imageBytes.lengthInBytes > maxSizeBytes && quality > 0);

    // Return the resized image bytes.
    return imageBytes;
  }

// This function converts the base64-encoded photoString into an Image widget for display.
  void convertImage() {
    // Check if the photoString is not null and not empty.
    if (photoString != null && photoString!.isNotEmpty) {
      print('Converting image to display...');
      // Decode the base64 string into a list of bytes.
      List<int> imageData = base64Decode(photoString!);

      // Update the state with the Image widget created from the decoded bytes.
      setState(() {
        photo = Image.memory(Uint8List.fromList(imageData),
            key: ValueKey(photoString));
      });
    } else {
      // Print a message if no photoString is available.
      print('No photo string found.');

      // Update the state to set photo to null if no valid photoString is available.
      setState(() {
        photo = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // A list of field names in the order they should be displayed or processed.
    List<String> orderedFields = [
      "document_name",
      "document_description",
      "Document Number",
      "Issuing State Code",
      "Issuing State Name",
      "Surname And Given Names",
      "Date of Birth",
      "Age",
      "Address",
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('Register'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (photo != null) ...[
              Container(
                height: 300,
                decoration: BoxDecoration(
                  color: Colors.green,
                  border: Border.all(color: Color(0xFF00b464), width: 2),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: photo,
                ),
              ),
              const SizedBox(height: 16),
            ],
            if (isLoading) ...[
              const Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ],
            if (!isLoading && extractedFields.isNotEmpty) ...[
              Expanded(
                child: ListView(
                  children: [
                    if (extractedFields.containsKey("result"))
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          extractedFields[
                              "result"]!, // Display the result from the extractedFields map.
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: extractedFields["result"] == 'error'
                                ? Colors.red
                                : Colors.green,
                          ),
                        ),
                      ),
                    // Create a list of TextFormField widgets for each field in `orderedFields` that exists in `extractedFields`.
                    ...orderedFields
                        .where((key) => extractedFields.containsKey(
                            key)) // Filter fields to include only those present in `extractedFields`.
                        .map((key) {
                      // Map each field to a TextFormField widget.
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: TextFormField(
                          readOnly: true,
                          controller:
                              TextEditingController(text: extractedFields[key]),
                          decoration: InputDecoration(
                            labelText: key,
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 19.0, horizontal: 12.0),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(bottom: 16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 16),
            GestureDetector(
              onTap: captureImageFromGallery,
              child: Container(
                width: MediaQuery.of(context).size.width * 0.4,
                padding: EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  color: Color(0xFF00b464),
                  borderRadius: BorderRadius.circular(8),
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
            const SizedBox(width: 16),
            GestureDetector(
              onTap: captureImageFromCamera,
              child: Container(
                width: MediaQuery.of(context).size.width * 0.4,
                padding: EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  color: Color(0xFF00b464),
                  borderRadius: BorderRadius.circular(8),
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
      ),
    );
  }
}
