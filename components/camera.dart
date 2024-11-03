import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class CameraCapturePage extends StatefulWidget {
  @override
  _CameraCapturePageState createState() => _CameraCapturePageState();
}

class _CameraCapturePageState extends State<CameraCapturePage> {
  final ImagePicker _picker = ImagePicker();
  File? _image;

  // Function to open the camera and capture an image
  Future<void> _openCamera() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Camera Capture")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Display the captured image
            if (_image != null)
              Image.file(_image!)
            else
              Text("No image captured"),
            SizedBox(height: 20),
            // Button to open the camera
            ElevatedButton(
              onPressed: _openCamera,
              child: Icon(Icons.camera_alt),
            ),
          ],
        ),
      ),
    );
  }
}
