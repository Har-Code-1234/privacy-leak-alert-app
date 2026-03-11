import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  File? image;
  String result = "";

  // Pick image
  Future pickImage() async {
    final picked =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    if (picked != null) {
      image = File(picked.path);
      setState(() {});
      scanImage(); // send to backend
    }
  }

  // Send image to backend
  Future scanImage() async {
    var request = http.MultipartRequest(
      'POST',
      // IMPORTANT: emulator localhost
      Uri.parse("http://10.0.2.2:5000/scan"),
    );

    request.files.add(
      await http.MultipartFile.fromPath(
        "image",
        image!.path,
      ),
    );

    var response = await request.send();
    var data = await response.stream.bytesToString();

    var jsonData = jsonDecode(data);

    setState(() {
      result =
          "Score: ${jsonData['score']}\nLevel: ${jsonData['level']}";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Privacy Scanner"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: pickImage,
              child: Text("Select Image"),
            ),

            SizedBox(height: 20),

            if (image != null)
              Image.file(image!, height: 200),

            SizedBox(height: 20),

            Text(
              result,
              style: TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}
