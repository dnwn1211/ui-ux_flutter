import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:http/http.dart' as http;
import 'dart:typed_data';

class MemoInputPage extends StatefulWidget {
  @override
  _MemoInputPageState createState() => _MemoInputPageState();
}

class _MemoInputPageState extends State<MemoInputPage> {
  late TextEditingController _memoController;
  final firebase_storage.FirebaseStorage storage =
      firebase_storage.FirebaseStorage.instance;
  String _savedMemo = '';

  List<String> _savedFiles = [];

  @override
  void initState() {
    super.initState();
    _memoController = TextEditingController();
    _memoController.text = _savedMemo;
    loadSavedFiles();
  }

  @override
  void dispose() {
    _memoController.dispose();
    super.dispose();
  }

  void loadSavedFiles() async {
    firebase_storage.ListResult result =
    await storage.ref().child('일기').listAll();
    List<String> files = [];
    for (var file in result.items) {
      files.add(file.name);
    }
    setState(() {
      _savedFiles = files;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('메모 입력 페이지'),
        backgroundColor: Colors.lightGreen,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.lightGreen,
              ),
              child: Text(
                '저장된 파일',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                ),
              ),
            ),
            for (var fileName in _savedFiles)
              ListTile(
                title: Text(fileName),
                onTap: () {
                  openMemoFile(fileName); // 선택한 메모 파일 열기 및 표시
                  Navigator.pop(context); // 사이드바 닫기
                },
              ),
          ],
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '일기장',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 8),
            Expanded(
              child: TextFormField(
                controller: _memoController,
                decoration: InputDecoration(
                  hintText: '메모를 입력하세요',
                  border: OutlineInputBorder(),
                ),
                textInputAction: TextInputAction.newline,
                maxLines: null,
                onChanged: (value) {
                  _savedMemo = value;
                },
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => FilenameInputDialog(),
                ).then((fileName) {
                  if (fileName != null) {
                    saveMemoToFirebase(fileName);
                  }
                });
              },
              style: ElevatedButton.styleFrom(
                primary: Colors.lightGreen,
                onPrimary: Colors.white,
              ),
              child: Text('저장하기'),
            ),
          ],
        ),
      ),
    );
  }

  void saveMemoToFirebase(String fileName) {
    String memo = _memoController.text;
    Uint8List memoBytes = Uint8List.fromList(memo.codeUnits);

    firebase_storage.Reference ref =
    storage.ref().child('일기').child(fileName);

    firebase_storage.UploadTask uploadTask = ref.putData(memoBytes);

    uploadTask.whenComplete(() {
      if (uploadTask.snapshot.state == firebase_storage.TaskState.success) {
        print('메모가 성공적으로 저장되었습니다.');
        _savedMemo = memo;
        loadSavedFiles();
      } else {
        print('메모 저장 중 오류가 발생했습니다.');
      }
    }).catchError((error) {
      print('메모 저장 중 오류가 발생했습니다: $error');
    });
  }


  void openMemoFile(String fileName) async {
    try {
      firebase_storage.Reference ref =
      storage.ref().child('일기').child(fileName);

      final firebase_storage.FullMetadata metadata =
      await ref.getMetadata();

      if (metadata.size != null) {
        int fileSizeInBytes = metadata.size!.toInt();
        Uint8List? fileData = await ref.getData(fileSizeInBytes);

        String fileContent = String.fromCharCodes(fileData as Iterable<int>);

        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(fileName),
            content: Text(fileContent),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('닫기'),
              ),
            ],
          ),
        );
      } else {
        print('메모 파일 다운로드 오류: 파일 크기가 null입니다.');
      }
    } catch (error) {
      print('메모 파일 열기 오류: $error');
    }
  }
}

class FilenameInputDialog extends StatefulWidget {
  @override
  _FilenameInputDialogState createState() => _FilenameInputDialogState();
}

class _FilenameInputDialogState extends State<FilenameInputDialog> {
  late TextEditingController _fileNameController;

  @override
  void initState() {
    super.initState();
    _fileNameController = TextEditingController();
  }

  @override
  void dispose() {
    _fileNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('파일 이름 입력'),
      content: TextField(
        controller: _fileNameController,
        decoration: InputDecoration(
          hintText: '파일 이름',
        ),
      ),
      actions: [
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text('취소'),
        ),
        ElevatedButton(
          onPressed: () {
            String fileName = _fileNameController.text.trim();
            if (fileName.isNotEmpty) {
              Navigator.of(context).pop(fileName);
            }
          },
          child: Text('확인'),
        ),
      ],
    );
  }
}
