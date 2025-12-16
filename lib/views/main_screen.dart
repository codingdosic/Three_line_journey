import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:three_line_journey/controllers/maps_controller.dart';
import 'package:three_line_journey/globalUser.dart';
import 'package:three_line_journey/models/marker.dart' as custom;
import 'package:three_line_journey/models/user.dart';
import 'package:three_line_journey/widgets/addJourneyDialog.dart';
import 'package:three_line_journey/widgets/expandableFab.dart';
import 'package:three_line_journey/widgets/markerInputDialog.dart';
import 'package:three_line_journey/widgets/markerListView.dart'; // 커스텀 마커 모델 사용

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {

  final MapsController mapsController = MapsController(); 
  late GoogleMapController googleMapController;

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(title: const Text('3줄 여행기')),
      
      body: Stack( // stack 아래에 맵스와 버튼 배치치

        children: [

          Consumer<GlobalUser>(

            builder: (context, userProvider, child){
              
              return GoogleMap(
                polylines: mapsController.getPolyLines(context),
                initialCameraPosition: CameraPosition(
                target: mapsController.mapsModel.initialPosition,
                zoom: mapsController.mapsModel.zoomLevel,
              ),

                markers: mapsController.getMarkers(context),

              onMapCreated: (controller) {
                googleMapController = controller;
              },

              onTap: (LatLng position) async {
                  if (mapsController.markerAddMode) {
                    // 다이얼로그를 띄워 사용자 입력 받기
                    await _showMarkerInputDialog(context, position, true, null);
                  }
                },
              );
            }
          ),

          // ✅ 하단 드로어 열기 버튼
          Positioned(

            bottom: 16,
            right: 16,

            child: ExpandableFab(
              mapsController: mapsController,
              onBtn1: () {
                setState(() {
                  mapsController.toggleMarkerAddMode();
                });
              },
              onBtn2: () {
                print("여행기 버튼 클릭됨");
                final userProvider = Provider.of<GlobalUser>(context, listen: false);
                User? currentUser = userProvider.user;

                _showBottomDrawer(context, currentUser, false);
              },
              onBtn3: () {
                final userProvider = Provider.of<GlobalUser>(context, listen: false);
                User? currentUser = userProvider.user; // ✅ Provider에서 현재 사용자 가져오기

                _showBottomDrawer(context, currentUser, true);
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showMarkerInputDialog(BuildContext context, LatLng? position, bool isNew, custom.Marker? marker) async {

    await showDialog(

      context: context,

      builder: (BuildContext context) {

        return MarkerInputDialog(

          isNew: isNew,
          position: position,
          marker: marker,

          onSubmit: (String title, String snippet, String? base64String) {
            if (isNew) {
              mapsController.addMarker(
                context,
                position!,
                title: title,
                snippet: snippet,
                imageUrl: base64String, // 현재는 비워둠
              );
            } else {
              mapsController.updateMarker(context, marker!.id, title, snippet);
            }
          },
        );
      },
    );
  }


  /// ✅ 하단 드로어 (화면의 절반 높이 & 스크롤 가능 목록)
  void _showBottomDrawer(BuildContext context, currentUser, bool mode) {

    showModalBottomSheet(

      context: context, // 컨텍스트
  
      isScrollControlled: true, // 스크롤 여부

      shape: RoundedRectangleBorder( // 형태
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),

      builder: (context) { // 표시할 것 return으로 반환

        
        return Consumer<GlobalUser>( // ✅ Provider 변경 감지

          builder: (context, userProvider, child) {

            final currentUser = userProvider.user; // ✅ 현재 사용자 정보 가져오기
            
            if(mode){
              return MarkerListView(
                listViewTitle1: "내 마커 목록",
                listViewTitle2: "내 여행기 목록", 
                user: currentUser, 
                mapsController: mapsController, 
                googleMapController: googleMapController, 
                showMarkerInputDialog: _showMarkerInputDialog
              );
            }
            else{
              return AddJourneyDialog(
                listViewTitle1: "내 마커 목록", 
                user: currentUser, 
                mapsController: mapsController, 
                googleMapController: googleMapController, 
                showMarkerInputDialog: _showMarkerInputDialog
                );
            }
            
            },
          );
        }      
      );
    }
  }

