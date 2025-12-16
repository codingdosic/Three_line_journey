import 'marker.dart'; // Marker 클래스가 별도의 파일에 정의되어 있다고 가정
import 'journey.dart'; // Marker 클래스가 별도의 파일에 정의되어 있다고 가정


class User {
  final String id; // 사용자 ID
  final String password; // 사용자 비밀번호
  final List<Marker> addedMarkers; // 사용자가 추가한 마커 리스트
  final List<Journey> addedJourneys; // 사용자가 추가한 여행기 리스트

  User({
    required this.id,
    required this.password,
    List<Marker>? addedMarkers,
    List<Journey>? addedJourneys,
  })  : addedMarkers = addedMarkers ?? [], // null인 경우 빈 리스트로 초기화
        addedJourneys = addedJourneys ?? [];

  /// JSON 데이터로부터 User 객체 생성
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      password: json['password'],
      addedMarkers: (json['addedMarkers'] as List<dynamic>?)
              ?.map((markerJson) => Marker.fromJson(markerJson))
              .toList() ??
          [],
      addedJourneys: (json['addedJourneys'] as List<dynamic>?)
              ?.map((journeyJson) => Journey.fromJson(journeyJson))
              .toList() ??
          [],
    );
  }

  /// User 객체를 JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'password': password,
      'addedMarkers': addedMarkers.map((marker) => marker.toJson()).toList(),
      'addedJourneys': addedJourneys.map((journey) => journey.toJson()).toList(),
    };
  }

  /// 마커 추가
  User addMarker(Marker marker) {
    return User(
      id: id,
      password: password,
      addedMarkers: [...addedMarkers, marker],
      addedJourneys: addedJourneys,
    );
  }

  /// 여행기 추가
  User addJourney(Journey journey) {
    return User(
      id: id,
      password: password,
      addedMarkers: addedMarkers,
      addedJourneys: [...addedJourneys, journey],
    );
  }

  /// ✅ 마커 삭제 (새로운 User 객체 반환)
  User removeMarker(String markerId) {
    return User(
      id: id,
      password: password,
      addedMarkers: addedMarkers.where((marker) => marker.id != markerId).toList(),
      addedJourneys: addedJourneys,
    );
  }

  /// ✅ 마커 수정 (새로운 User 객체 반환)
  User updateMarker(String markerId, String newTitle, String newSnippet) {
    return User(
      id: id,
      password: password,
      addedMarkers: addedMarkers.map((marker) {
        if (marker.id == markerId) {
          return Marker(
            id: marker.id,
            latitude: marker.latitude,
            longitude: marker.longitude,
            title: newTitle,
            description: newSnippet,
            imageUrl: marker.imageUrl,
            visibility: marker.visibility,
          );
        }
        return marker;
      }).toList(),
      addedJourneys: addedJourneys,
    );
  }

  User toggleMarkerVisibility(String markerId) {
    return User(
      id: id,
      password: password,
      addedMarkers: addedMarkers.map((marker) {
        if (marker.id == markerId) {
          return Marker(
            id: marker.id,
            latitude: marker.latitude,
            longitude: marker.longitude,
            title: marker.title,
            description: marker.description,
            imageUrl: marker.imageUrl,
            visibility: !marker.visibility, // ✅ 현재 값의 반대값으로 변경
          );
        }
        return marker;
      }).toList(),
      addedJourneys: addedJourneys,
    );
  }

  /// 여행기 삭제
  User removeJourney(String journeyId) {
    return User(
      id: id,
      password: password,
      addedMarkers: addedMarkers,
      addedJourneys: addedJourneys.where((journey) => journey.id != journeyId).toList(),
    );
  }

  /// 여행기 수정 (제목 및 설명 변경)
  User updateJourney(String journeyId, String newTitle, String newDescription) {
    return User(
      id: id,
      password: password,
      addedMarkers: addedMarkers,
      addedJourneys: addedJourneys.map((journey) {
        if (journey.id == journeyId) {
          return journey.copyWith(title: newTitle, description: newDescription);
        }
        return journey;
      }).toList(),
    );
  }

  /// 여행기 가시성 토글 (공개/비공개)
  User toggleJourneyVisibility(String journeyId) {
    return User(
      id: id,
      password: password,
      addedMarkers: addedMarkers,
      addedJourneys: addedJourneys.map((journey) {
        if (journey.id == journeyId) {
          return journey.copyWith(visibility: !journey.visibility);
        }
        return journey;
      }).toList(),
    );
  }

}
