import 'package:flutter_test/flutter_test.dart';
import 'package:three_line_journey/models/marker.dart';

void main() {
  group('Marker Tests', () {
    test('Marker creation', () {
      Marker marker = Marker(
        id: 'm1',
        latitude: 37.7749,
        longitude: -122.4194,
        title: 'Golden Gate Bridge',
        description: 'A famous bridge in San Francisco.',
        imageUrl: 'https://example.com/image1.jpg',
      );

      expect(marker.id, 'm1');
      expect(marker.latitude, 37.7749);
      expect(marker.title, 'Golden Gate Bridge');
    });

    test('Marker toJson and fromJson', () {
      Marker marker = Marker(
        id: 'm1',
        latitude: 37.7749,
        longitude: -122.4194,
        title: 'Golden Gate Bridge',
        description: 'A famous bridge in San Francisco.',
        imageUrl: 'https://example.com/image1.jpg',
      );

      Map<String, dynamic> json = marker.toJson();
      Marker newMarker = Marker.fromJson(json);

      expect(newMarker.id, marker.id);
      expect(newMarker.title, marker.title);
    });
  });
}
