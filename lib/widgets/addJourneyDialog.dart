import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:three_line_journey/models/journey.dart';
import 'package:three_line_journey/models/user.dart';
import 'package:three_line_journey/widgets/journeyInputDialog.dart';
import '../controllers/maps_controller.dart';
import 'package:three_line_journey/models/marker.dart' as custom;
import '../models/marker.dart';

class AddJourneyDialog extends StatefulWidget {
  final String listViewTitle1;
  final User? user;
  final MapsController mapsController;
  final GoogleMapController googleMapController;
  final Future<void> Function(BuildContext, LatLng?, bool, custom.Marker?) showMarkerInputDialog;


  const AddJourneyDialog({
    super.key,
    required this.listViewTitle1,
    required this.user,
    required this.mapsController,
    required this.googleMapController,
    required this.showMarkerInputDialog,
  });

  @override
  _AddJourneyDialogState createState() => _AddJourneyDialogState();
}

class _AddJourneyDialogState extends State<AddJourneyDialog> {

  List<int> selectedItems = [];
  final MapsController mapsController = MapsController(); 

  void _onTapItem(int index) {
    setState(() {
      if (selectedItems.contains(index)) {
        selectedItems.remove(index); // 선택 해제
      } else {
        selectedItems.add(index); // 새로 선택
      }
    });
  }

  Future<void> _showJourneyInputDialog(bool isNew) async {
    await showDialog(
      context: context, 
      builder: (BuildContext context){
        return journeyInputDialog(
          isNew: isNew, 
          onSubmit: (String title, String snippet) {
            if (isNew) {
              mapsController.addJourney(
                markers: selectedItems
                  .map((index) => widget.user!.addedMarkers[index]) // selectedItems의 순서대로 마커를 가져옴
                  .toList(),
                context, 
                title: title, 
                description: snippet, 
                imageUrl: ""
              );
              
              Navigator.pop(context);
            }  else {
              // 기존 여행기 수정
              print("여행기 수정됨");
            }
          },
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {

    
    return Container(
      padding: EdgeInsets.all(16),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.5,
      ),
      child: Column(
        children: [
          // ✅ 제목 & 뷰 모드 변경 버튼
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,

            children: [
              Text(
                widget.listViewTitle1,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),

              IconButton(
                icon: Icon(Icons.check),
                onPressed: (){
                  // 여행기 이름이랑 설명 추가 다이얼로그
                  _showJourneyInputDialog(true);
                },
              ),
            ],
          ),

          const SizedBox(height: 10),

          // ✅ 리스트 뷰 & 다른 뷰 모드 전환
          Expanded(

            child: ListView.builder(

              itemCount: widget.user!.addedMarkers.length,
              itemBuilder: (context, index) {
                final marker = widget.user!.addedMarkers[index];
                final isSelected = selectedItems.contains(index);
                final selectionOrder = selectedItems.indexOf(index) + 1; // 터치 순서

                return Card(
                  color: isSelected ? Colors.blue.withOpacity(0.3) : Colors.white, // 활성화 색상
                  child: ListTile(
                    title: Text(marker.title),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (isSelected)
                          CircleAvatar(
                            backgroundColor: Colors.blue,
                            radius: 12,
                            child: Text(
                              "$selectionOrder",
                              style: TextStyle(color: Colors.white, fontSize: 12),
                            ),
                          ),
                      ],
                    ),
                    onTap: () => _onTapItem(index), // 터치 이벤트 처리
                  ),
                );
              },
            )
          )
        ]
      )
    );
  }
}
