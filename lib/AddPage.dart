import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as path;
import 'dart:convert';
import 'dart:typed_data';

class AddPage extends StatefulWidget {
  @override
  _AddPageState createState() => _AddPageState();
}

class _AddPageState extends State<AddPage> {
  TextEditingController addressController = TextEditingController();
  TextEditingController durationController = TextEditingController();
  TextEditingController locationController = TextEditingController();
  FirebaseStorage storage = FirebaseStorage.instance;

  Future<String> _uploadText(String location, String text) async {
    Uint8List textBytes = Uint8List.fromList(utf8.encode(text));
    String fileName = 'data.txt';
    Reference storageReference = storage.ref().child(location).child(fileName);
    await storageReference.putData(textBytes);
    return storageReference.getDownloadURL();
  }

  void _createItem() async {
    String address = addressController.text;
    String duration = durationController.text;
    String location = locationController.text;

    String newData = '$address, $duration, $location';
    String fileUrl = await _uploadText(location, newData);

    String newDataWithUrl = '$address, $duration, $location, $fileUrl';
    Navigator.pop(context, newDataWithUrl);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      appBar: AppBar(
        title: Text('Add Page'),
        backgroundColor: Colors.lightGreen,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            TextField(
              controller: addressController,
              decoration: InputDecoration(
                labelText: 'URL 주소',
              ),
            ),
            Padding(padding: EdgeInsets.all(5)),
            TextField(
              controller: durationController,
              decoration: InputDecoration(
                labelText: '기간',
              ),
            ),
            Padding(padding: EdgeInsets.all(5)),
            TextField(
              controller: locationController,
              decoration: InputDecoration(
                labelText: '장소',
              ),
            ),
            Padding(padding: EdgeInsets.all(45)),
            ElevatedButton(
              onPressed: _createItem,
              child: Text('Create'),
            ),
          ],
        ),
      ),
    );
  }
}
