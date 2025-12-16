import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart'; // ✅ image_picker 추가
import '../models/marker.dart' as custom;

class MarkerInputDialog extends StatefulWidget {
  final bool isNew;
  final LatLng? position;
  final custom.Marker? marker;
  final Function(String, String, String?) onSubmit;

  MarkerInputDialog({
    required this.isNew,
    this.position,
    this.marker,
    required this.onSubmit,
  });

  @override
  _MarkerInputDialogState createState() => _MarkerInputDialogState();
}

class _MarkerInputDialogState extends State<MarkerInputDialog> {
  late TextEditingController titleController;
  late TextEditingController snippetController;
  File? selectedImage; // ✅ 선택된 이미지 파일
  String? base64String;

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.isNew ? "" : widget.marker?.title ?? "");
    snippetController = TextEditingController(text: widget.isNew ? "" : widget.marker?.description ?? "");
  }


  /// ✅ 갤러리에서 이미지 선택 & Base64 인코딩
  Future<void> pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      File imageFile = File(image.path);
      List<int> imageBytes = await imageFile.readAsBytes();
      String base64String = base64Encode(imageBytes); // Base64 인코딩

      setState(() {
        selectedImage = imageFile;
        base64String = base64String;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.isNew ? "새 마커 추가" : "마커 수정"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          /// ✅ 클릭하면 이미지 선택할 수 있는 컨테이너
          GestureDetector(
            onTap: pickImage, // 클릭 시 갤러리 열기
            child: Container(
              width: double.infinity,
              height: 150,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(10),
                color: Colors.grey[200],
              ),
              child: selectedImage != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.file(selectedImage!, fit: BoxFit.contain),
                    )
                  : Center(child: Text("이미지를 선택하세요")),
            ),
          ),
          SizedBox(height: 10),
          TextField(
            controller: titleController,
            decoration: InputDecoration(labelText: "마커 제목"),
          ),
          TextField(
            controller: snippetController,
            decoration: InputDecoration(labelText: "마커 설명"),
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
            print("사진 $base64String");
            widget.onSubmit(titleController.text.trim(), snippetController.text.trim(), base64String);
            Navigator.of(context).pop(); // 다이얼로그 닫기
          },
          child: Text(widget.isNew ? "추가" : "수정"),
        ),
      ],
    );
  }
}
