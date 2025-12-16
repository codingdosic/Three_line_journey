class Marker {
  final String id;
  final double latitude;
  final double longitude;
  final String title;
  final String description;
  final String? imageUrl;
  final bool visibility; // 추가된 가시성 속성

  Marker({
    required this.id,
    required this.latitude,
    required this.longitude,
    required this.title,
    required this.description,
    this.imageUrl,
    this.visibility = true, // 기본값은 true, 마커가 보이도록 설정
  });

  Marker copyWith({
    String? title,
    String? description,
    bool? visibility,
  }) {
    return Marker(
      id: id,
      latitude: latitude,
      longitude: longitude,
      title: title ?? this.title,
      description: description ?? this.description,
      imageUrl: imageUrl,
      visibility: visibility ?? this.visibility,
    );
  }

  factory Marker.fromJson(Map<String, dynamic> json) {
    return Marker(
      id: json['id'],
      latitude: json['latitude'],
      longitude: json['longitude'],
      title: json['title'],
      description: json['description'],
      imageUrl: json['imageUrl'],
      visibility: json['visibility'] ?? true, // JSON에 가시성 정보가 없으면 true로 처리
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'latitude': latitude,
      'longitude': longitude,
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'visibility': visibility, // 가시성 속성 추가
    };
  }
}
