import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:three_line_journey/models/journey.dart';
import 'package:three_line_journey/models/maps.dart';
import 'package:three_line_journey/models/marker.dart' as custom; // Marker 모델 사용
import 'package:three_line_journey/controllers/db_controller.dart';
import 'package:three_line_journey/models/user.dart';
import 'package:three_line_journey/globalUser.dart'; // GlobalUser Provider 사용

class MapsController {

  bool _markerAddMode = false; // 마커 추가기능 동작 여부

  Set<Polyline> getPolyLines(BuildContext context) {

    final userProvider = Provider.of<GlobalUser>(context, listen: false);
    User? currentUser = userProvider.user;

    return currentUser!.addedJourneys
        .where((journey) => journey.visibility && journey.polyline != null) // 공개된 여행기만 필터링
        .map((journey) => journey.polyline!) // null이 아닌 폴리라인만 리스트로 변환
        .toSet();
  }

  final MapsModel mapsModel = MapsModel( // 구글 맵스 모델 생성성
    initialPosition: LatLng(37.7749, -122.4194), // 초기 위도/경도
    zoomLevel: 14.0, // 확대 레벨
  );

  // ✅ 마커 추가 (DB 업데이트 포함, Provider 사용)
  Future<void> addMarker(BuildContext context, LatLng position, {required String title, required String snippet, required String? imageUrl}) async {
    
    final userProvider = Provider.of<GlobalUser>(context, listen: false);
    User? currentUser = userProvider.user; // ✅ Provider에서 현재 사용자 가져오기

    if (currentUser == null) { // 사용자 없을 시
      print("⚠️ 로그인된 사용자가 없습니다.");
      return;
    }

    // 새 마커 생성
    final newMarker = custom.Marker(
      id: DateTime.now().toIso8601String(), // 고유 id생성
      latitude: position.latitude,
      longitude: position.longitude,
      title: title,
      description: snippet,
      imageUrl: imageUrl,
      visibility: true,
    );

    // ✅ Provider에서 현재 사용자 업데이트
    userProvider.setUser(currentUser.addMarker(newMarker));

    // ✅ MongoDB 업데이트
    await MongoService.updateUserInDB(userProvider.user!, "marker");

    // ✅ Google Maps 마커 모델에도 추가
    final googleMarker = Marker(
      markerId: MarkerId(newMarker.id),
      position: position,
      infoWindow: InfoWindow(title: title, snippet: snippet),
    );
    mapsModel.addMarker(googleMarker);

    print("✅ 마커 추가 완료: ${newMarker.title}");
    print("현재 사용자 정보: ${currentUser.addedMarkers}");
  }

  // ✅ 현재 사용자의 마커 반환 (Provider 사용)
  // Set<Marker> getMarkers(BuildContext context) {
  //   final userProvider = Provider.of<GlobalUser>(context);
  //   User? currentUser = userProvider.user;

  //   if (currentUser == null) return {};
    
  //   return currentUser.addedMarkers.map((m) => Marker(
  //     markerId: MarkerId(m.id),
  //     position: LatLng(m.latitude, m.longitude),
  //     infoWindow: InfoWindow(title: m.title, snippet: m.description),
  //   )).toSet();
  // }
  Set<Marker> getMarkers(BuildContext context) {
  final userProvider = Provider.of<GlobalUser>(context, listen: false);
  final markers = userProvider.user?.addedMarkers ?? [];

  return markers
      .where((marker) => marker.visibility) // 🔥 가시성이 true인 마커만 필터링
      .map((marker) => Marker(
            markerId: MarkerId(marker.id),
            position: LatLng(marker.latitude, marker.longitude),
            infoWindow: InfoWindow(title: marker.title, snippet: marker.description),
          ))
      .toSet();
}


  // ✅ 마커 추가 모드 상태 반환
  bool get markerAddMode => _markerAddMode;

  // ✅ 마커 추가 모드 토글
  void toggleMarkerAddMode() {
    _markerAddMode = !_markerAddMode;
  }

  void performActionIfAddMode() {
    if (_markerAddMode) {
      print('마커 추가 모드에서 실행되는 로직');
    }
  }

  void deleteMarker(BuildContext context, String markerId) {
    final userProvider = Provider.of<GlobalUser>(context, listen: false);

    // ✅ 마커 삭제 후 새로운 User 객체 반환
    User updatedUser = userProvider.user!.removeMarker(markerId);

    // ✅ 사용자 정보 갱신
    userProvider.setUser(updatedUser);

    // ✅ DB에도 반영
    MongoService.updateUserInDB(updatedUser, "marker");
  }

  void updateMarker(BuildContext context, String markerId, String newTitle, String newSnippet) {
    final userProvider = Provider.of<GlobalUser>(context, listen: false);

    // ✅ 마커 수정 후 새로운 User 객체 반환
    User updatedUser = userProvider.user!.updateMarker(markerId, newTitle, newSnippet);

    // ✅ 사용자 정보 갱신
    userProvider.setUser(updatedUser);

    // ✅ DB에도 반영
    MongoService.updateUserInDB(updatedUser, "marker");
  }

  void toggleMarkerVisibility(BuildContext context, String markerId) {
    final userProvider = Provider.of<GlobalUser>(context, listen: false);

    // ✅ 가시성 토글 후 새로운 User 객체 반환
    User updatedUser = userProvider.user!.toggleMarkerVisibility(markerId);

    // ✅ 사용자 정보 갱신
    userProvider.setUser(updatedUser);

    // ✅ DB에도 반영
    MongoService.updateUserInDB(updatedUser, "marker");
  }

  

  // ✅ 여행기 추가 (DB 업데이트 포함)
  Future<void> addJourney(BuildContext context,
      {required List<custom.Marker> markers, required String title, required String description, required String imageUrl}) async {

    final userProvider = Provider.of<GlobalUser>(context, listen: false);
    User? currentUser = userProvider.user;

    if (currentUser == null) {
      print("⚠️ 로그인된 사용자가 없습니다.");
      return;
    }

    String journeyId = DateTime.now().toIso8601String();
    
    List<LatLng> journeyPath = markers
        .map((marker) => LatLng(marker.latitude, marker.longitude))
        .toList();

    var polyline = Polyline(
      polylineId: PolylineId(journeyId), // 여행기 ID를 사용하여 고유한 Polyline ID 생성
      color: Colors.blue, // 경로 색상
      width: 5, // 선 두께
      points: journeyPath, // 마커들의 위치를 경로로 설정
    );

    
    final newJourney = Journey(
      id: journeyId,
      markers: markers,
      title: title,
      description: description,
      imageUrl: imageUrl,
      visibility: true,
      polyline: polyline,
    );

    print(newJourney.title);

    userProvider.setUser(currentUser.addJourney(newJourney));
    await MongoService.updateUserInDB(userProvider.user!, "journey");

    print("✅ 여행기 추가 완료: ${newJourney.title}");
  }

  // ✅ 현재 사용자의 여행기 리스트 반환
  List<Journey> getJourneys(BuildContext context) {
    final userProvider = Provider.of<GlobalUser>(context, listen: false);
    return userProvider.user?.addedJourneys ?? [];
  }

  // ✅ 여행기 삭제
  void deleteJourney(BuildContext context, String journeyId) {
    final userProvider = Provider.of<GlobalUser>(context, listen: false);
    User updatedUser = userProvider.user!.removeJourney(journeyId);

    userProvider.setUser(updatedUser);
    MongoService.updateUserInDB(updatedUser, "journey");

    print("🗑 여행기 삭제 완료: $journeyId");
  }

  // ✅ 여행기 업데이트 (제목 및 설명 수정)
  void updateJourney(BuildContext context, String journeyId, String newTitle, String newDescription) {
    final userProvider = Provider.of<GlobalUser>(context, listen: false);
    User updatedUser = userProvider.user!.updateJourney(journeyId, newTitle, newDescription);

    userProvider.setUser(updatedUser);
    MongoService.updateUserInDB(updatedUser, "journey");

    print("📝 여행기 수정 완료: $newTitle");
  }

  // ✅ 여행기 가시성 토글 (공개/비공개)
  void toggleJourneyVisibility(BuildContext context, String journeyId) {
    final userProvider = Provider.of<GlobalUser>(context, listen: false);
    User updatedUser = userProvider.user!.toggleJourneyVisibility(journeyId);

    userProvider.setUser(updatedUser);
    MongoService.updateUserInDB(updatedUser, "journey");

    print("👀 여행기 가시성 변경 완료: $journeyId");
  }

}
