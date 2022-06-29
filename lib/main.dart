// ignore_for_file: unnecessary_string_escapes, prefer_typing_uninitialized_variables
import 'dart:convert';
// import 'dart:html';
// import 'dart:html';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_image/flutter_native_image.dart';
// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http;
// ignore: library_prefixes
import 'dart:io' as Io;
// ignore: unused_import
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

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
      home: const MyHomePage(title: 'Number Plate OCR'),
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
  String globals = '';

  @override
  void initState() {
    super.initState();
    globals;
  }

  @override
  Widget build(BuildContext context) {
    // ignore: unused_local_variable
    var widget;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Number Plate OCR'),
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
                  clickImage();
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
                  pickImage();
                },
                icon: const Icon(Icons.upload),
                label: const Text('Upload Photo'),
              ),
            ],
          ),
          const SizedBox(height: 35),
          image != null
              ? Image.file(
                  image!,
                  width: 200,
                  height: 200,
                  fit: BoxFit.cover,
                )
              : const SizedBox(height: 20),
          const SizedBox(height: 20),
          const Text(
            'Your result is:',
            style: TextStyle(fontWeight: FontWeight.w500, fontSize: 18),
          ),
          const SizedBox(height: 10),
          FutureBuilder(
              // future: globals,
              builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Text(
                snapshot.error.toString(),
              );
            } else {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(globals,
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold)),
                ],
              );
            }
          })
        ],
      ),
    );
  }

  Io.File? image;
  Future clickImage() async {
    await Future.delayed(const Duration(seconds: 1));
    var client = http.Client();

    try {
      final image = await ImagePicker()
          .pickImage(source: ImageSource.camera, imageQuality: 25);
      if (image == null) return;

      final imagePermanent = await saveImagePermanently(image.path);
      debugPrint(imagePermanent.toString());
      setState(() => this.image = imagePermanent);
      final bytes = Io.File(image.path.toString()).readAsBytesSync();
      String img64 = base64Encode(bytes);
      debugPrint(image.path.toString());

      try {
        var url = Uri.parse('https://api.platerecognizer.com/v1/plate-reader/');
        debugPrint('start');
        debugPrint(img64);
        debugPrint('end');
        var response = await client.post(url, body: {
          'upload': img64,
        }, headers: {
          "Authorization": "Token 497717d5ef388c529bc0eaa84f6924baa3a4acbf"
        });
        debugPrint('Response status: ${response.statusCode}');
        debugPrint('Response body: ${response.body}');
        setState(() {
          final responseJson = json.decode(response.body);
          globals = '';
          globals = responseJson["results"][0]["plate"];
          debugPrint('Response plate: $globals');
        });
      } on PlatformException catch (e) {
        debugPrint('Failed to parse: $e');
      } finally {
        client.close();
      }
    } on PlatformException catch (e) {
      debugPrint('Failed to catch image: $e');
    }
  }

  Future pickImage() async {
    await Future.delayed(const Duration(seconds: 1));
    try {
      final image = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (image == null) return;

      // final imageTemporary = Io.File(image.path);
      final imagePermanent = await saveImagePermanently(image.path);
      debugPrint(imagePermanent.toString());
      setState(() => this.image = imagePermanent);
      final bytes = Io.File(image.path.toString()).readAsBytesSync();
      String img64 = base64Encode(bytes);
      debugPrint(image.path.toString());

      var url = Uri.parse('https://api.platerecognizer.com/v1/plate-reader/');
      debugPrint('start');
      debugPrint(img64);
      debugPrint('end');
      var response = await http.post(url, body: {
        'upload': img64,
      }, headers: {
        "Authorization": "Token 497717d5ef388c529bc0eaa84f6924baa3a4acbf"
      });
      debugPrint('Response status: ${response.statusCode}');
      debugPrint('Response body: ${response.body}');

      setState(() {
        final responseJson = json.decode(response.body);
        globals = '';
        globals = responseJson["results"][0]["plate"];
        debugPrint('Response plate: $globals');
      });
    } on PlatformException catch (e) {
      debugPrint('Failed to catch image: $e');
    }
  }

  Future<Io.File> saveImagePermanently(String imagePath) async {
    final directory = await getApplicationDocumentsDirectory();
    final name = basename(imagePath);
    final image = Io.File('${directory.path}/$name');

    return Io.File(imagePath).copy(image.path);
  }

  Future<Io.File> compressFile(Io.File file) async {
    Io.File compressedFile = await FlutterNativeImage.compressImage(
      file.path,
      quality: 5,
    );
    return compressedFile;
  }
}
