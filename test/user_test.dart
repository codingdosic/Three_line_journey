import 'package:flutter_test/flutter_test.dart';
import 'package:three_line_journey/models/user.dart';
import 'package:three_line_journey/models/marker.dart';
import 'package:three_line_journey/models/journey.dart';

void main() {
  group('User Tests', () {
    test('User creation', () {
      User user = User(
        id: 'u1',
        password: 'securePassword',
        addedMarkers: [],
        addedJourneys: [],
      );

      expect(user.id, 'u1');
      expect(user.password, 'securePassword');
      expect(user.addedMarkers.isEmpty, true); // 초기 마커 리스트는 비어 있어야 함
      expect(user.addedJourneys.isEmpty, true); // 초기 여행기 리스트는 비어 있어야 함
    });

    test('Add marker to user', () {
      User user = User(
        id: 'u1',
        password: 'securePassword',
        addedMarkers: [],
        addedJourneys: [],
      );

      Marker marker = Marker(
        id: 'm1',
        latitude: 37.7749,
        longitude: -122.4194,
        title: 'Golden Gate Bridge',
        description: 'A famous bridge in San Francisco.',
        imageUrl: 'https://example.com/image1.jpg',
      );

      user.addedMarkers.add(marker); // 사용자 마커 리스트에 마커 추가

      expect(user.addedMarkers.length, 1);
      expect(user.addedMarkers[0].title, 'Golden Gate Bridge');
    });

    test('Add journey to user', () {
      User user = User(
        id: 'u1',
        password: 'securePassword',
        addedMarkers: [],
        addedJourneys: [],
      );

      Journey journey = Journey(
        id: 'j1',
        title: 'California Adventure',
        description: 'A journey across California.',
        markers: [],
      );

      user.addedJourneys.add(journey); // 사용자 여행기 리스트에 여행기 추가

      expect(user.addedJourneys.length, 1);
      expect(user.addedJourneys[0].title, 'California Adventure');
    });

    test('User toJson and fromJson', () {
      Marker marker = Marker(
        id: 'm1',
        latitude: 37.7749,
        longitude: -122.4194,
        title: 'Golden Gate Bridge',
        description: 'A famous bridge in San Francisco.',
        imageUrl: 'https://example.com/image1.jpg',
      );

      Journey journey = Journey(
        id: 'j1',
        title: 'California Adventure',
        description: 'A journey across California.',
        markers: [marker],
      );

      User user = User(
        id: 'u1',
        password: 'securePassword',
        addedMarkers: [marker],
        addedJourneys: [journey],
      );

      Map<String, dynamic> json = user.toJson(); // 객체를 JSON으로 변환
      User newUser = User.fromJson(json); // JSON에서 객체로 복원

      expect(newUser.id, user.id);
      expect(newUser.password, user.password);
      expect(newUser.addedMarkers.length, 1);
      expect(newUser.addedMarkers[0].id, marker.id); // 저장된 마커 확인
      expect(newUser.addedJourneys.length, 1);
      expect(newUser.addedJourneys[0].id, journey.id); // 저장된 여행기 확인
    });
  });
}
