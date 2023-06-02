import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'main_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: FirebaseOptions(
      apiKey: 'AIzaSyAw3FKY5yYZN-EqrpEyZMpnJjTkaJyY310',
      appId: 'AIzaSyAw3FKY5yYZN-EqrpEyZMpnJjTkaJyY310',
      messagingSenderId: '854117481642',
      projectId: 'flutter-uiux-93c6c',
      authDomain: 'flutter-uiux-93c6c.firebaseapp.com',
      storageBucket: 'flutter-uiux-93c6c.appspot.com',
      measurementId: 'G-X43CYR4ZNM',
    ),
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context){
    return MaterialApp(
        home: StartPage(),
        debugShowCheckedModeBanner: false
    );
  }
}

class StartPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('image/travel_diary.png'), // 이미지 파일의 경로
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(top: 500),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    minimumSize: Size(100, 50),
                    backgroundColor: Colors.lightGreen,
                  ),
                  child: Text('Start'),
                  onPressed: () {
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) =>
                            MainPage(),
                        transitionsBuilder:
                            (context, animation, secondaryAnimation, child) {
                          return FadeTransition(
                            opacity: animation,
                            child: child,
                          );
                        },
                        transitionDuration: Duration(milliseconds: 1000),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
