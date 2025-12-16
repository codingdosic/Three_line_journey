import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:three_line_journey/globalUser.dart';
import 'package:three_line_journey/views/login_screen.dart';
import 'package:three_line_journey/views/main_screen.dart';
import 'package:three_line_journey/views/splash_screen.dart';
import 'package:three_line_journey/controllers/db_controller.dart'; // MongoDB 서비스 임포트

void main() async {
  
  WidgetsFlutterBinding.ensureInitialized(); // 비동기 코드 실행 보장
  await MongoService.connectDB("mongodb+srv://admin:admin@practice.esvba.mongodb.net/?retryWrites=true&w=majority&appName=Practice", "users"); // DB 연결 후 앱 실행

  runApp( // 진입지점, 최상위 위젯을 실행
    MultiProvider( // 여러개의 provider를 감싸서 사용

      providers: [ // provider 리스트
        ChangeNotifierProvider(create: (context) => GlobalUser()), // ✅ provider의 GlobalUser 사용, 상태 변화 시 반영됨
      ],

      child: const MainApp(), // 최상위 위젯
    ),
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(

      debugShowCheckedModeBanner: false, // 디버그 라벨 지우기

      title: "three", // 앱 이름

      initialRoute: '/', // 시작 라우트

      routes: {
        '/': (context) => const SplashScreen(), // 스플래시 스크린
        '/login': (context) => const LoginScreen(), // 로그인 화면
        '/main': (context) => const MainScreen(), // 메인 화면
      },

    );
  }
}
