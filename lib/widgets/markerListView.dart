import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:three_line_journey/models/journey.dart';
import 'package:three_line_journey/models/user.dart';
import 'package:three_line_journey/widgets/addJourneyDialog.dart';
import 'package:three_line_journey/widgets/journeyInputDialog.dart';
import '../controllers/maps_controller.dart';
import 'package:three_line_journey/models/marker.dart' as custom;
import '../models/marker.dart';

class MarkerListView extends StatefulWidget {
  final String listViewTitle1;
  final String listViewTitle2;
  final User? user;
  final MapsController mapsController;
  final GoogleMapController googleMapController;
  final Future<void> Function(BuildContext, LatLng?, bool, custom.Marker?) showMarkerInputDialog;

  const MarkerListView({
    super.key,
    required this.listViewTitle1,
    required this.listViewTitle2,
    required this.user,
    required this.mapsController,
    required this.googleMapController,
    required this.showMarkerInputDialog,
  });

  @override
  _MarkerListViewState createState() => _MarkerListViewState();
}

class _MarkerListViewState extends State<MarkerListView> {
  bool _isMarkerViewMode = true; // 🔥 뷰 모드 (true: 리스트, false: 다른 모드)
  Set<Polyline> _polylines = {};

  void _toggleViewMode() {
    setState(() {
      _isMarkerViewMode = !_isMarkerViewMode;
    });
  }

void _setAllMarkersVisible(bool isVisible, {Journey? journey}) {
  setState(() {
    Set<String> journeyMarkerIds = journey?.markers.map((m) => m.id).toSet() ?? {};

    for (var marker in widget.user!.addedMarkers) {
      if (journeyMarkerIds.contains(marker.id)) {
        // ✅ 여행기에 속한 마커이고, 비활성화 상태라면 활성화
        if (!marker.visibility) {
          widget.mapsController.toggleMarkerVisibility(context, marker.id);
        }
      } else {
        // ✅ 여행기에 속하지 않은 마커는 가시성이 true일 때만 숨김
        if (marker.visibility) {
          widget.mapsController.toggleMarkerVisibility(context, marker.id);
        }
      }
    }
  });
}

Future<void> _showJourneyInputDialog(Journey journey) async {
    await showDialog(
      context: context, 
      builder: (BuildContext context){
        return journeyInputDialog(
          isNew: false, 
          onSubmit: (String title, String snippet) {      
              widget.mapsController.updateJourney(context, journey.id, title, snippet);
          },
          journey: journey,
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
              Text(_isMarkerViewMode ? 
                widget.listViewTitle1 : widget.listViewTitle2,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: Icon(_isMarkerViewMode ? Icons.route_outlined : Icons.location_on_outlined), // 뷰 모드에 따라 아이콘 변경
                onPressed: _toggleViewMode,
              ),
            ],
          ),

          const SizedBox(height: 10),

          // ✅ 리스트 뷰 & 다른 뷰 모드 전환
          Expanded(
            child: _isMarkerViewMode
                ? ListView.builder(
                    itemCount: widget.user!.addedMarkers.length,
                    itemBuilder: (context, index) {
                      final marker = widget.user!.addedMarkers[index];

                      return Card(
                        child: ListTile(
                          title: Text(marker.title),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(Icons.delete),
                                onPressed: () {
                                  widget.mapsController.deleteMarker(context, marker.id);
                                },
                              ),
                              IconButton(
                                icon: Icon(Icons.edit),
                                onPressed: () {
                                  widget.showMarkerInputDialog(context, null, false, marker);
                                },
                              ),
                              IconButton(
                                icon: Icon(marker.visibility ? Icons.visibility_off : Icons.visibility),
                                onPressed: () {
                                  widget.mapsController.toggleMarkerVisibility(context, marker.id);
                                },
                              ),
                            ],
                          ),
                          onTap: () {
                            widget.googleMapController.animateCamera(
                              CameraUpdate.newLatLng(
                                LatLng(marker.latitude, marker.longitude),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  )
                : ListView.builder(
                    itemCount: widget.user!.addedJourneys.length,
                    itemBuilder: (context, index) {
                      final journey = widget.user!.addedJourneys[index];

                      return Card(
                        child: ListTile(
                          title: Text(journey.title),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(Icons.delete),
                                onPressed: () {
                                  widget.mapsController.deleteJourney(context, journey.id);
                                },
                              ),
                              IconButton(
                                icon: Icon(Icons.edit),
                                onPressed: () {
                                  _showJourneyInputDialog(journey);
                                  
                                },
                              ),
                              IconButton(
                                icon: Icon(journey.visibility ? Icons.visibility_off : Icons.visibility),
                                onPressed: () {
                                  widget.mapsController.toggleJourneyVisibility(context, journey.id);
                                },
                              ),
                            ],
                          ),
                          onTap: () {
                            print("여행기 클릭됨");

                          },
                        ),
                      );
              }
            )
          ),
        ],
      ),
    );
  }
}
