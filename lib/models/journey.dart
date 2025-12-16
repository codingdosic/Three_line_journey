import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'marker.dart' as custom; // Marker 클래스가 별도의 파일에 정의되어 있다고 가정

class Journey {
  final String id; // 여행기 고유 ID
  final List<custom.Marker> markers; // 여행기에 포함된 마커 객체들
  final String title; // 여행기 제목
  final String description; // 여행기 설명
  final String imageUrl; // 여행기 대표 이미지
  final bool visibility; // 여행기의 가시성 (true: 공개, false: 비공개)
  final Polyline polyline; // 여행 경로 (Polyline)

  Journey({
    required this.id,
    required this.markers,
    required this.title,
    required this.description,
    required this.imageUrl,
    this.visibility = true, // 기본값: 공개 상태
    required this.polyline,
  });

  /// ✅ JSON 데이터를 Journey 객체로 변환
  factory Journey.fromJson(Map<String, dynamic> json) {
    return Journey(
      id: json['id'] ?? '', // 기본값 처리
      markers: (json['markers'] as List<dynamic>?)
              ?.map((markerJson) => custom.Marker.fromJson(markerJson))
              .toList() ?? [],
      title: json['title'] ?? '제목 없음', // 기본값 추가
      description: json['description'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      visibility: json['visibility'] ?? true,
      polyline: Polyline(
        polylineId: PolylineId(json['id'] ?? ''), // ID를 Polyline ID로 사용
        color: Colors.blue,
        width: json['polyline']['width'] ?? 5,
        points: (json['polyline']['points'] as List<dynamic>?)
                ?.map((point) => LatLng(point['lat'], point['lng']))
                .toList() ??
            [],
      ),
    );
  }

  /// ✅ Journey 객체를 JSON 데이터로 변환
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'markers': markers.map((marker) => marker.toJson()).toList(),
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'visibility': visibility,
      'polyline': {
        'color': polyline.color.value, // 색상을 int 값으로 변환
        'width': polyline.width,
        'points': polyline.points
            .map((point) => {'lat': point.latitude, 'lng': point.longitude})
            .toList(),
      },
    };
  }

  /// ✅ 불변성 유지하면서 값 수정 가능
  Journey copyWith({
    String? id,
    List<custom.Marker>? markers,
    String? title,
    String? description,
    String? imageUrl,
    bool? visibility,
    Polyline? polyline,
  }) {
    return Journey(
      id: id ?? this.id,
      markers: markers ?? this.markers,
      title: title ?? this.title,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      visibility: visibility ?? this.visibility,
      polyline: polyline ?? this.polyline,
    );
  }

  /// ✅ 여행기의 가시성 토글 (공개 <-> 비공개)
  Journey toggleVisibility() {
    return copyWith(visibility: !visibility);
  }
}
