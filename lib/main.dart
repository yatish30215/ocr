// ignore_for_file: unnecessary_string_escapes, prefer_typing_uninitialized_variables
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http;
// ignore: library_prefixes
import 'dart:io' as Io;
// ignore: unused_import
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:open_file/open_file.dart';
// import 'globals.dart' as globals;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OCR',
      theme: ThemeData(
        primarySwatch: Colors.teal,
      ),
      home: const MyHomePage(title: 'Image to Text OCR'),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  get globals => null;

  @override
  Widget build(BuildContext context) {
    // ignore: unused_local_variable
    var widget;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Image to text OCR'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          const Padding(
            padding: EdgeInsets.only(top: 50),
            child: Text(
              'Please click Image or upload an Image',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ),
          const SizedBox(height: 25),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  primary: Colors.teal,
                  onPrimary: Colors.white,
                  shadowColor: Colors.tealAccent,
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5.0)),
                  minimumSize: const Size(100, 50), //////// HERE
                ),
                onPressed: () {
                  pickImage();
                },
                icon: const Icon(Icons.camera),
                label: const Text('Click Photo'),
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  primary: Colors.teal,
                  onPrimary: Colors.white,
                  shadowColor: Colors.tealAccent,
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5.0)),
                  minimumSize: const Size(100, 50), //////// HERE
                ),
                onPressed: () {
                  _pickFile();
                },
                icon: const Icon(Icons.upload),
                label: const Text('Upload Photo'),
              ),
            ],
          ),
          const SizedBox(height: 35),
          const Text(
            'Your result is:',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          Text(globals.toString())
        ],
      ),
    );
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(allowMultiple: true);

    // if no file is picked
    if (result == null) return;

    // we get the file from result object
    final file = result.files.first;

    _openFile(file);
  }

  Future<void> _plateCall(String img64) async {
    setState(() async {
      var url = Uri.parse('https://api.platerecognizer.com/v1/plate-reader/');
      var response = await http.post(url, body: {
        'upload': img64,
        'regions': 'in',
      }, headers: {
        "Authorization": "Token 497717d5ef388c529bc0eaa84f6924baa3a4acbf"
      });
      // ignore: avoid_print
      print('Response status: ${response.statusCode}');
      // ignore: avoid_print
      print('Response body: ${response.body}');
      final responseJson = json.decode(response.body);
      // ignore: avoid_print, unnecessary_brace_in_string_interps
      print('Response Vehicle: ${responseJson["results"][0]["vehicle"]}');
      // ignore: avoid_print
      final globals = responseJson["results"][0]["plate"];
      // ignore: avoid_print
      print('Response plate: $globals');
    });
  }

  Future<void> _openFile(PlatformFile file) async {
    OpenFile.open(file.path);
    debugPrint(file.path);
    final bytes = Io.File(file.path.toString()).readAsBytesSync();
    String img64 = base64Encode(bytes);
    debugPrint(file.path.toString());
    _plateCall(img64);
  }

  Io.File? image;
  Future pickImage() async {
    try {
      final image = await ImagePicker().pickImage(source: ImageSource.camera);
      if (image == null) return;

      final imageTemporary = Io.File(image.path);
      debugPrint(imageTemporary.toString());
      setState(() => this.image = imageTemporary);
      final bytes = Io.File(image.path.toString()).readAsBytesSync();
      String img64 = base64Encode(bytes);
      debugPrint(image.path.toString());
      var url = Uri.parse('https://api.platerecognizer.com/v1/plate-reader/');
      var response = await http.post(url, body: {
        'upload': img64,
      }, headers: {
        "Authorization": "Token 497717d5ef388c529bc0eaa84f6924baa3a4acbf"
      });
      // ignore: avoid_print
      print('Response status: ${response.statusCode}');
      // ignore: avoid_print
      print('Response body: ${response.body}');
      final responseJson = json.decode(response.body);
      // ignore: avoid_print, unnecessary_brace_in_string_interps
      print('Response Vehicle: ${responseJson["results"][0]["vehicle"]}');
      // ignore: avoid_print
      final globals = responseJson["results"][0]["plate"];
      // ignore: avoid_print
      print('Response plate: $globals');
    } on PlatformException catch (e) {
      // ignore: avoid_print
      print('Failed to catch image: $e');
    }
  }
}
