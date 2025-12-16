import 'package:flutter_test/flutter_test.dart';
import 'package:three_line_journey/models/journey.dart';
import 'package:three_line_journey/models/marker.dart';

void main() {
  group('Journey Tests', () {
    test('Journey creation', () {
      Journey journey = Journey(
        id: 'j1',
        title: 'California Adventure',
        description: 'A journey across California.',
        markers: [],
      );

      expect(journey.id, 'j1');
      expect(journey.title, 'California Adventure');
      expect(journey.description, 'A journey across California.');
      expect(journey.markers.isEmpty, true); // 초기에는 마커 리스트가 비어 있어야 함
    });

    test('Journey with markers', () {
      Marker marker1 = Marker(
        id: 'm1',
        latitude: 37.7749,
        longitude: -122.4194,
        title: 'Golden Gate Bridge',
        description: 'A famous bridge in San Francisco.',
        imageUrl: 'https://example.com/image1.jpg',
      );

      Marker marker2 = Marker(
        id: 'm2',
        latitude: 34.0522,
        longitude: -118.2437,
        title: 'Los Angeles',
        description: 'The city of angels.',
        imageUrl: 'https://example.com/image2.jpg',
      );

      Journey journey = Journey(
        id: 'j1',
        title: 'California Adventure',
        description: 'A journey across California.',
        markers: [marker1, marker2],
      );

      expect(journey.markers.length, 2); // 마커가 2개 있어야 함
      expect(journey.markers[0].title, 'Golden Gate Bridge');
      expect(journey.markers[1].title, 'Los Angeles');
    });

    test('Journey toJson and fromJson', () {
      Marker marker1 = Marker(
        id: 'm1',
        latitude: 37.7749,
        longitude: -122.4194,
        title: 'Golden Gate Bridge',
        description: 'A famous bridge in San Francisco.',
        imageUrl: 'https://example.com/image1.jpg',
      );

      Marker marker2 = Marker(
        id: 'm2',
        latitude: 34.0522,
        longitude: -118.2437,
        title: 'Los Angeles',
        description: 'The city of angels.',
        imageUrl: 'https://example.com/image2.jpg',
      );

      Journey journey = Journey(
        id: 'j1',
        title: 'California Adventure',
        description: 'A journey across California.',
        markers: [marker1, marker2],
      );

      Map<String, dynamic> json = journey.toJson(); // 객체를 JSON으로 변환
      Journey newJourney = Journey.fromJson(json); // JSON에서 객체로 복원

      expect(newJourney.id, journey.id);
      expect(newJourney.title, journey.title);
      expect(newJourney.markers.length, journey.markers.length);
      expect(newJourney.markers[0].id, journey.markers[0].id); // 첫 번째 마커 비교
      expect(newJourney.markers[1].id, journey.markers[1].id); // 두 번째 마커 비교
    });

    test('Add marker to Journey', () {
      Journey journey = Journey(
        id: 'j1',
        title: 'California Adventure',
        description: 'A journey across California.',
        markers: [],
      );

      Marker marker = Marker(
        id: 'm1',
        latitude: 37.7749,
        longitude: -122.4194,
        title: 'Golden Gate Bridge',
        description: 'A famous bridge in San Francisco.',
        imageUrl: 'https://example.com/image1.jpg',
      );

      journey.markers.add(marker); // 마커 추가
      expect(journey.markers.length, 1);
      expect(journey.markers[0].title, 'Golden Gate Bridge');
    });
  });
}
