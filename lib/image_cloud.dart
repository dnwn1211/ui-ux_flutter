import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';
import 'package:traveldiary/memo.dart';

class SharePage extends StatefulWidget {
  final String selectedValue;
  final Function onDelete;

  SharePage({required this.selectedValue, required this.onDelete});

  @override
  _SharePageState createState() => _SharePageState();
}

class _SharePageState extends State<SharePage> {
  final FirebaseStorage storage = FirebaseStorage.instance;
  late List<String> uploadedImageUrls;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>(); // Scaffold를 위한 GlobalKey 생성

  @override
  void initState() {
    super.initState();
    uploadedImageUrls = [];
    _getUploadedImageUrls();
  }

  void printImageFolderContents() async {
    Reference storageReference = storage.ref().child('images/');
    ListResult result = await storageReference.listAll();

    for (Reference ref in result.items) {
      print('이미지 파일: ${ref.name}');
    }
  }

  void _showDeleteConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('일정 삭제'),
          content: Text('정말로 삭제하시겠습니까?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // 닫기 버튼을 누르면 다이얼로그를 닫음
              },
              child: Text('취소'),
            ),
            TextButton(
              onPressed: () {
                widget.onDelete(); // 삭제 함수 호출
                Navigator.of(context).pop(); // 확인 버튼을 누르면 다이얼로그를 닫음
                Navigator.of(context).pop(); // 이전 페이지로 돌아감
              },
              child: Text('삭제'),
            ),
          ],
        );
      },
    );
  }

  void _getUploadedImageUrls() async {
    try {
      Reference storageReference = storage.ref().child('images/');
      ListResult result = await storageReference.listAll();
      List<Reference> imageFiles = result.items;

      List<String> imageUrls = [];

      for (Reference ref in imageFiles) {
        String imageUrl = await ref.getDownloadURL();
        imageUrls.add(imageUrl);
      }

      setState(() {
        uploadedImageUrls = imageUrls;
      });
    } catch (e) {
      print('이미지 가져오기 에러: $e');
    }
  }

  // 이미지 업로드 함수
  void _uploadImage() async {
    try {
      // 이미지 선택
      FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.image);
      if (result == null || result.files.isEmpty) return; // 이미지를 선택하지 않은 경우 종료

      // 선택한 이미지를 Firebase Storage에 업로드
      PlatformFile file = result.files.first;
      String fileName = file.name!;
      String location = widget.selectedValue.split(',')[2].trim(); // location 값 가져오기
      Reference storageReference = storage.ref().child('images/$location/$fileName');
      await storageReference.putData(file.bytes!);

      // 업로드한 이미지의 다운로드 URL 가져오기
      String imageUrl = await storageReference.getDownloadURL();

      // 업로드된 이미지 URL 리스트 업데이트
      setState(() {
        uploadedImageUrls.add(imageUrl);
      });
    } catch (e) {
      print('이미지 업로드 에러: $e');
    }
  }

  // 이미지 선택 삭제 함수
  void _deleteImage(String imageUrl) async {
    try {
      // Firebase Storage에서 이미지 삭제
      Reference storageReference = storage.refFromURL(imageUrl);
      await storageReference.delete();

      // 업로드된 이미지 URL 리스트에서 제거
      setState(() {
        uploadedImageUrls.remove(imageUrl);
      });
    } catch (e) {
      print('이미지 삭제 에러: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final firstValue = widget.selectedValue.split(',')[0].trim();
    final secondValue = widget.selectedValue.split(',')[1].trim();
    final thirdValue = widget.selectedValue.split(',')[2].trim();

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('image_cloud'),
        backgroundColor: Colors.lightGreen,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
          tooltip: '뒤로 가기',
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.upload_file),
            onPressed: () {
              _uploadImage();
            },
            tooltip: '사진 업로드',
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.lightGreen,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '메뉴',
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 10),
                  ListTile(
                    title: Text(
                      '메모하기',
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                    leading: Icon(Icons.mark_unread_chat_alt),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => MemoInputPage()),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),

      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 265,
            width: 600,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('image/six.png'),
                fit: BoxFit.cover,
              ),
            ),
            child: Stack(
              children: [
                // 배경 이미지
                Positioned.fill(
                  child: Image.asset(
                    'image/six.png',
                    fit: BoxFit.cover,
                  ),
                ),
                // delete 버튼
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Padding(
                    padding: EdgeInsets.all(10),
                    child: IconButton(
                      onPressed: () {
                        _showDeleteConfirmationDialog(context);
                      },
                      icon: Icon(Icons.delete),
                      color: Colors.white,
                      tooltip: '삭제하기',
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 30,
                  child: Padding(
                    padding: EdgeInsets.all(10),
                    child: IconButton(
                      onPressed: () {
                        launch(firstValue);
                      },
                      icon: Icon(Icons.document_scanner),
                      color: Colors.white,
                      tooltip: '일기장',
                    ),
                  ),
                ),
                Positioned(
                  top: 0,
                  left: 0,
                  child: Padding(
                    padding: EdgeInsets.all(10),
                    child: IconButton(
                      onPressed: () {
                        _scaffoldKey.currentState!.openDrawer(); // Open the drawer
                      },
                      icon: Icon(Icons.list),
                      color: Colors.white,
                      tooltip: '목록',
                    ),
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[300],
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 10),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: EdgeInsets.only(left: 5.0),
                        child: Text('$secondValue' + ' ' + '$thirdValue' + ' ' + '에서 생긴 일..'),
                      ),
                    ),
                    GridView.builder(
                      shrinkWrap: true,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                      ),
                      itemCount: uploadedImageUrls.length,
                      itemBuilder: (context, index) {
                        String imageUrl = uploadedImageUrls[index];
                        return Stack(
                          children: [
                            Image.network(
                              imageUrl,
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                            ),
                            Positioned(
                              right: 5,
                              child: IconButton(
                                onPressed: () {
                                  _deleteImage(imageUrl);
                                },
                                icon: Icon(Icons.delete),
                                color: Colors.red[100],
                                tooltip: '이미지 삭제',
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}