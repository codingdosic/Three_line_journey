import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:three_line_journey/models/journey.dart';
import '../models/marker.dart' as custom;

class journeyInputDialog extends StatelessWidget {

  final bool isNew;
  final Journey? journey;
  final Function(String, String) onSubmit;

  journeyInputDialog({
    required this.isNew,
    this.journey,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    
    TextEditingController titleController = TextEditingController(
        text: isNew ? "" : journey?.title ?? "");
    TextEditingController snippetController = TextEditingController(
        text: isNew ? "" : journey?.description ?? "");

    return AlertDialog(
      title: Text(isNew ? "새 여행기 추가" : "여행기 수정"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: titleController,
            decoration: InputDecoration(labelText: "여행기 제목"),
          ),
          TextField(
            controller: snippetController,
            decoration: InputDecoration(labelText: "여행기 설명"),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(); // 다이얼로그 닫기
          },
          child: Text("취소"),
        ),
        TextButton(
          onPressed: () {
            onSubmit(titleController.text.trim(), snippetController.text.trim());
            Navigator.of(context).pop(); // 다이얼로그 닫기
          },
          child: Text(isNew ? "추가" : "수정"),
        ),
      ],
    );
  }
}
