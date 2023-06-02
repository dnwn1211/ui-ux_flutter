import 'package:flutter/material.dart';
import 'AddPage.dart';
import 'image_cloud.dart';

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  List<String> textList = [];

  void _deleteItem(int index) {
    setState(() {
      textList.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text('Main Page'),
        backgroundColor: Colors.lightGreen,
        actions: [
          Tooltip(
            message: '일정 생성',
            child: IconButton(
                icon: Icon(Icons.add),
                onPressed:(){
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AddPage()),
                  ).then((result) {
                    if (result != null && result is String) {
                      setState(() {
                        textList.add(result);
                      });
                    }
                  });
                }
            ),
          )
        ],
      ),
      backgroundColor: Colors.grey[300],
      body: Container(
        child: Column(
          children: <Widget>[
            Expanded(
              child: ListView.builder(
                itemCount: textList.length,
                itemBuilder: (context, index) {
                  final listItem = textList[index].split(','); // 리스트 항목을 쉼표로 분리하여 리스트로 저장
                  final location = listItem[2].trim(); // 분리된 리스트에서 3번째 항목(location)을 가져옴
                  return InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SharePage(
                            selectedValue: textList[index],
                            onDelete: () {
                              _deleteItem(index);
                            },
                          ),
                        ),
                      );
                    },
                    child: Card(
                      child: ListTile(
                        title: Text(location),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
