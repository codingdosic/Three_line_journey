import 'package:flutter/material.dart';
import 'package:mongo_dart/mongo_dart.dart' as mongo;
import 'package:provider/provider.dart';
import '../../models/user.dart';
import '../../globalUser.dart'; // Provider 사용

class MongoService {

  static late mongo.Db db; // db 변수
  static late mongo.DbCollection usersCollection; // 사용자 스키마

  /// ✅ MongoDB 연결 함수 (앱 시작 시 1회 실행)
  static Future<void> connectDB(String connectionString, String collectionName) async {

    db = await mongo.Db.create( // 커넥션 스트링으로 연결
      connectionString
    );

    await db.open(); // db 연결

    usersCollection = db.collection(collectionName); // db 내부 폴더 연결 

    print("✅ MongoDB Atlas 연결 성공!"); // 연결 성공 시 출력

  }

  /// ✅ 사용자 정보 업데이트 (마커 추가 후 호출)
  static Future<void> updateUserInDB(User user, String mode) async {
    if(mode == "marker"){
      await usersCollection.updateOne( // 조건에 맞는 사용자 정보 업데이트
        mongo.where.eq('id', user.id), // 주어진 id 속성에 맞는 도큐먼트 검색
        mongo.modify.set('addedMarkers', user.addedMarkers.map((m) => m.toJson()).toList()), // 검색한 도큐먼트의 속성을 변경된 user의 것으로 교체
      );
    }
    else if(mode == "journey"){
      await usersCollection.updateOne( // 조건에 맞는 사용자 정보 업데이트
        mongo.where.eq('id', user.id), // 주어진 id 속성에 맞는 도큐먼트 검색
        mongo.modify.set('addedJourneys', user.addedJourneys.map((m) => m.toJson()).toList()), // 검색한 도큐먼트의 속성을 변경된 user의 것으로 교체
      );
    }

    print("✅ 사용자 정보 업데이트 완료: ${user.id}");
  }

  /// ✅ 특정 ID의 사용자가 존재하는지 확인
  static Future<bool> userExists(String id) async {
    var user = await usersCollection.findOne(mongo.where.eq('id', id));
    return user != null;
  }

  /// ✅ 사용자 추가 (해당 ID가 없을 때만)
  static Future<void> addUserIfNotExists(BuildContext context, String id, String password) async {

    bool exists = await userExists(id); // 사용자 존재여부 

    if (exists) { // 이미 존재할 경우
      print("⚠️ 이미 존재하는 사용자: $id");
      return;
    }

    // 새로운 사용자 객체 생성
    User newUser = User(id: id, password: password);

    // MongoDB에 저장
    await usersCollection.insertOne(newUser.toJson()); // json 형태로 추가
    print("✅ 새 사용자 추가 완료: $id");

    // ✅ Provider(GlobalUser)를 사용하여 현재 사용자 설정
    Provider.of<GlobalUser>(context, listen: false).setUser(newUser);
  }

  /// ✅ 로그인 함수 (ID, PW 확인 후 Provider에 저장)
  static Future<bool> loginUser(BuildContext context, String id, String password) async {
    var userData = await usersCollection.findOne(mongo.where.eq('id', id));

    if (userData != null && userData['password'] == password) {
      User loggedInUser = User.fromJson(userData);

      // ✅ Provider(GlobalUser)를 사용하여 현재 사용자 설정
      Provider.of<GlobalUser>(context, listen: false).setUser(loggedInUser);

      print("✅ 로그인 성공: ${loggedInUser.id}");
      return true;
    } else {
      print("❌ 로그인 실패: ID 또는 비밀번호 오류");
      return false;
    }
  }

  static Future<void> handleLogin(BuildContext context, String id, String password) async {

    if (id.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("아이디와 비밀번호를 입력하세요!"))
      );
      return;
    }

    // ✅ MongoDB에 사용자 추가 (없을 때만)
    await MongoService.addUserIfNotExists(context, id, password);

    // ✅ 사용자 로그인 처리 추가
    bool loginSuccess = await MongoService.loginUser(context, id, password);

    if (loginSuccess) {
      // 로그인 성공 후 메인 화면으로 이동
      Navigator.pushReplacementNamed(context, "/main");
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("로그인 실패! ID 또는 비밀번호를 확인하세요."))
      );
    }
  }
}
