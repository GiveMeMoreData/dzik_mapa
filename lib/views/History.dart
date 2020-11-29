

import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dzik_mapa/templates/Drawer.dart';
import 'package:dzik_mapa/templates/Utils.dart';
import 'package:dzik_mapa/views/Report.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class HistoryMap extends StatefulWidget{
  static const routeName = "/History";
  @override
  State<StatefulWidget> createState() => _HistoryMapState();

}


class _HistoryMapState extends State<HistoryMap>{

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final _scaffoldKey = GlobalKey<ScaffoldState>();
  BitmapDescriptor pinLocationIcon;
  Map markers = Map<MarkerId, PinInformation>();
  Map<MarkerId, Marker> mapMarkers = {};


  bool _locationDisabled = false;
  Location _locationService  = new Location();
  GoogleMapController _controller;
  bool _animationInProgress = false;
  ///
  /// Boar data
  ///

  List<QueryDocumentSnapshot> allBoars = [];
  List<QueryDocumentSnapshot> curBoars = [];

  ///
  /// History settings
  ///
  Timestamp _startTime = Timestamp.fromDate(DateTime.now().subtract(Duration(days: 1)));
  Timestamp _endTime = Timestamp.now();
  int nSteps = 20; // 60 frames per second x 10 seconds
  Duration _visibleTime = Duration(hours: 2);

  static final CameraPosition _initialCameraPosition = CameraPosition(
    target: LatLng(53.46439, 20.28454),
    zoom: 12,
  );

  void loadBoars() async {
    final boars = await _firestore.collection('boars').where('time', isGreaterThanOrEqualTo: _startTime).where('time', isLessThanOrEqualTo: _endTime).get();
    allBoars = boars.docs;
  }

  void initBoars() async {
    pinLocationIcon = await setCustomMapPin();
    loadBoars();
  }

  Future<void> playAnimation() async {

    final int _timeStep = (_endTime.millisecondsSinceEpoch - _startTime.millisecondsSinceEpoch)~/nSteps;
    final Stopwatch _stopwatch = Stopwatch();

    setState(() {
      _animationInProgress = true;
    });

    for(int i = 0 ; i<nSteps ; i++){
      setState(() {
        _stopwatch.reset();
        _stopwatch.start();

        // filtering boars
        curBoars = allBoars.where((boar) =>
        boar.get('time').millisecondsSinceEpoch<(_startTime.millisecondsSinceEpoch+i*_timeStep) &&
            boar.get('time').millisecondsSinceEpoch>(_startTime.millisecondsSinceEpoch+i*_timeStep-_visibleTime.inMilliseconds)).toList();

        print("Step ${i} | ${curBoars.length} boars");
        _setMarkers(curBoars);

        _stopwatch.stop();
        sleep(Duration(milliseconds: max(0, 500-_stopwatch.elapsedMilliseconds)));
      });
    }

    setState(() {
      _animationInProgress = false;
    });
  }



  void _setMarkers(List<QueryDocumentSnapshot> boars)  {
    mapMarkers = {};
    boars.forEach((boar) {

      final MarkerId markerId = MarkerId(boar.id);
      final GeoPoint pos = boar.get('location');

      final Marker marker = Marker(
        markerId: markerId,
        position: LatLng(
          pos.latitude,
          pos.longitude,
        ),
        onTap: () {},
        icon: pinLocationIcon,
      );
      mapMarkers.putIfAbsent(marker.markerId, () => marker);
    });
  }


  void listenForEnabled() {
    Timer timer;
    _locationDisabled = true;
    timer = Timer.periodic(Duration(seconds: 1), (timer) async {
      if(!mounted){
        timer.cancel();
        return;
      }
      if(await _locationService.serviceEnabled()){
        timer.cancel();
        setState(() {
          _locationDisabled = false;
        });
        setUserLocation();
        return;
      }
    });
  }

  void showDrawer(BuildContext context){
    Scaffold.of(context).openDrawer();
  }

  void setUserLocation() async {
    final pos = await getLocation();
    if(pos == null) {
      setState(() {
        _locationDisabled = true;
      });
      listenForEnabled();
      return;
    }

    // zooming in current user location
    if(_controller != null) {
      final _newCameraPosition = CameraPosition(
          target: LatLng(pos.latitude, pos.longitude),
          zoom: 16
      );
      _controller.animateCamera(
          CameraUpdate.newCameraPosition(_newCameraPosition));
    }
  }

  void initPlatformState() async {
    await setUserLocation();
  }

  @override
  void initState() {
    super.initState();
    setSystemNavBar(Colors.white);
    initPlatformState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: CustomDrawer(),
      endDrawer: CustomDrawer(),
      body: Container(
        child: Stack(
          alignment: AlignmentDirectional.bottomCenter,
          children: [
            GoogleMap(
              mapType: MapType.normal,
              initialCameraPosition: _initialCameraPosition,
              mapToolbarEnabled: false,
              zoomControlsEnabled: false,
              tiltGesturesEnabled: false,
              compassEnabled: false,
              markers: Set.from(mapMarkers.values.toList()),
              onMapCreated: (GoogleMapController controller) {
                _controller=controller;
                initBoars();
              },
            ),

            Builder(
              builder: (ctx) => Positioned(
                top: 45,
                right: 20,
                child: InkWell(
                  onTap: (){
                    Scaffold.of(ctx).openEndDrawer();
                  },
                  child: Icon(
                    Icons.settings,
                    size: 40,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ),
            ),

            Builder(
              builder: (ctx) => Positioned(
                top: 45,
                left: 20,
                child: InkWell(
                  onTap: (){
                    Scaffold.of(ctx).openDrawer();
                  },
                  child: Icon(
                    Icons.menu_rounded,
                    size: 40,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ),
            ),

            Positioned(
              bottom: 20,
              child: Material(
                elevation: 10,
                color: Theme.of(context).backgroundColor,
                borderRadius: BorderRadius.circular(25),
                child: InkWell(
                  onTap: () async {
                    playAnimation();
                  },
                  borderRadius: BorderRadius.circular(25),
                  splashColor: Theme.of(context).primaryColor,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 45, vertical: 12),
                    child: Text(
                      _animationInProgress? "..." : "Start",
                      style: Theme.of(context).textTheme.headline2.copyWith(fontSize: 22),
                    ),
                  ),
                ),
              ),
            ),
          ],

        ),

      ),
    );
  }

}