import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapsModel {

  // 초기 카메라 위치
  final LatLng initialPosition;

  // 줌 레벨
  double zoomLevel;

  // 마커 목록
  final Map<String, Marker> _markers;

  // 생성자
  MapsModel({
    required this.initialPosition, // 초기 위치(필수)
    this.zoomLevel = 14.0, // 확대 레벨
    Map<String, Marker>? markers, // 마커 딕셔너리, nullable
  }) : _markers = markers ?? {}; // markers가 null이면 빈 맵, 아닐 경우 그대로

  // 마커 추가
  void addMarker(Marker marker) {
    _markers[marker.markerId.value] = marker;
  }

  // ID로 마커 삭제
  void removeMarkerById(String markerId) {
    _markers.remove(markerId);
  }

  // 현재 추가된 마커 반환
  List<Marker> get markers => _markers.values.toList();

  // 특정 ID의 마커 반환
  Marker? getMarkerById(String markerId) {
    return _markers[markerId];
  }
}
