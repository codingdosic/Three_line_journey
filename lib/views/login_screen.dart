import 'package:flutter/material.dart';
import 'package:three_line_journey/controllers/db_controller.dart'; // MongoDB 서비스 임포트

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  final TextEditingController _idController = TextEditingController(); // id 입력 필드 컨트롤러
  final TextEditingController _passwordController = TextEditingController(); // pw 입력 필드 컨트롤러

  // 로그인 로직
  void _handleLogin(){
    MongoService.handleLogin(context, _idController.text.trim(), _passwordController.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: Padding(

        padding: EdgeInsets.all(16),

        child: Column(

          mainAxisAlignment: MainAxisAlignment.center,

          children: [

            TextField(
              controller: _idController,
              decoration: InputDecoration(labelText: "아이디"),
            ),

            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(labelText: "비밀번호"),
            ),

            SizedBox(height: 20),

            ElevatedButton(

              onPressed: _handleLogin,
               // 로그인 버튼 클릭 시 실행
              child: Text("로그인"),
            ),
          ],
        ),
      ),
    );
  }
}
