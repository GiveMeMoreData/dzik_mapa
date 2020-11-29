

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dzik_mapa/templates/Drawer.dart';
import 'package:dzik_mapa/templates/PhotoContainer.dart';
import 'package:dzik_mapa/templates/Utils.dart';
import 'package:dzik_mapa/views/Report.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:location/location.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MainMap extends StatefulWidget{
  static const routeName = "/Map";
  @override
  State<StatefulWidget> createState() => _MainMapState();

}


class _MainMapState extends State<MainMap>{

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Map markers = Map<MarkerId, PinInformation>();

  final _scaffoldKey = GlobalKey<ScaffoldState>();
  Map<MarkerId, Marker> mapMarkers = {};
  BitmapDescriptor pinBoar;
  BitmapDescriptor pinBoarPhoto;
  double pinPillPosition = -400;
  PinInformation currentlySelectedPin = PinInformation(
      timestamp: Timestamp.now(),
      photos: 0,
      preciseInfo: false,
  );

  Location _locationService  = new Location();
  GoogleMapController _controller;
  GeoPoint currentMarkerGeoPoint;
  bool _locationDisabled = true;

  PhotoContainer _photoContainer;

  static final CameraPosition _initialCameraPosition = CameraPosition(
    target: LatLng(53.46439, 20.28454),
    zoom: 12,
  );


  void initBoars() async {
     pinBoar = await setCustomMapPin();
     pinBoarPhoto = await setCustomMapPin(photoPath: "res/boar_photo.png");
     final boars = await _firestore.collection('boars').where('dead', isEqualTo: false).get();
     _setMarkers(boars.docs);
  }

  void listenToDatabase(){
    _firestore.collection('boars').where('dead', isEqualTo: false).snapshots().listen((data) {
      _setMarkers(data.docs);
    });
  }

  void _onMarkerTapped(MarkerId markerId, double lat, double long) async {

    // Getting info about marker
    currentlySelectedPin = markers[markerId];


    // Update photo container
    if(currentlySelectedPin.photos>0){
      _photoContainer = null;
      _photoContainer = PhotoContainer(
        "images/${currentlySelectedPin.id}/1.png",
      );
    }


    // Setting current marker geo point reference
    currentMarkerGeoPoint = GeoPoint(lat, long);


    setState(() {
      pinPillPosition = 0;
    });
  }

  void _setMarkers(List<QueryDocumentSnapshot> boars)  {
    boars.forEach((boar) {

      final MarkerId markerId = MarkerId(boar.id);
      final GeoPoint pos = boar.get('location');
      final photos = boar.get('photos');

      final Marker marker = Marker(
        markerId: markerId,
        position: LatLng(
          pos.latitude,
          pos.longitude,
        ),
        onTap: () {
          _onMarkerTapped(markerId, pos.latitude, pos.longitude);
        },
        icon: photos == 0? pinBoar : pinBoarPhoto,
      );

      // creating info about marker
      final PinInformation markerInfo = PinInformation(
        id: boar.id,
        adults: boar.get('adults'),
        young: boar.get('young'),
        timestamp: boar.get('time'),
        preciseInfo: boar.get('precise_info'),
        photos: boar.get('photos'),

      );

      print("[INFO] Adding marker");

      // adding a new marker to map
      markers[markerId] = markerInfo;
      mapMarkers.putIfAbsent(marker.markerId, () => marker);

      if(mounted){
        setState(() {
        });
      }
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
      endDrawer: CustomEndDrawer(),
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
              onTap: (_){
                setState(() {
                  pinPillPosition = -400;
                });
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
                  onTap: (){
                    Navigator.of(context).pushNamed(Report.routeName);
                  },
                  borderRadius: BorderRadius.circular(25),
                  splashColor: Theme.of(context).primaryColor,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 45, vertical: 12),
                    child: Text(
                        "Zgłoś dzika",
                        style: Theme.of(context).textTheme.headline2.copyWith(fontSize: 22),
                    ),
                  ),
                ),
              ),
            ),

            AnimatedPositioned(
                bottom: pinPillPosition,
                duration: Duration(milliseconds: 400),
                // aligned at the bottom of the screen
                child: Container(
                  margin: EdgeInsets.all(20),
                  width: MediaQuery.of(context).size.width*0.7,
                  decoration: BoxDecoration(
                      color: Theme.of(context).backgroundColor.withOpacity(0.95),
                      borderRadius: BorderRadius.all(Radius.circular(50)),
                      boxShadow: <BoxShadow>[
                        BoxShadow(
                            blurRadius: 10,
                            spreadRadius: 2,
                            offset: Offset(4,4),
                            color: Colors.grey.withOpacity(0.4)
                        )]
                  ),

                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 30),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        // Header
                        Center(
                          child: Text(
                            "Zgłoszone dziki",
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.headline1.copyWith(
                              decoration: TextDecoration.underline,
                              fontSize: 26
                            ),
                          ),
                        ),
                        SizedBox(height: 10,),
                        Center(
                          child: Text(
                            getNiceDate(currentlySelectedPin.timestamp),
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.headline2.copyWith(
                              fontSize: 24,
                            ),
                          ),
                        ),
                        SizedBox(height: 20,),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "Dorosłe ${currentlySelectedPin.adults}",
                              style: Theme.of(context).textTheme.headline3
                            ),
                          ],
                        ),
                        Text(
                            "Młode ${currentlySelectedPin.young}",
                            style: Theme.of(context).textTheme.headline3
                        ),
                        Text(
                            "Dokładne dane: ${currentlySelectedPin.preciseInfo? "Tak" : "Nie"}",
                            style: Theme.of(context).textTheme.headline3
                        ),
                        SizedBox(height: 20,),
                        Text(
                            "Zdjęcia ",
                            style: Theme.of(context).textTheme.headline3
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                          child: Builder(
                            builder: (_){
                              if(currentlySelectedPin.photos>0){
                                return _photoContainer;
                              }
                              return Text(
                                  "Brak",
                                  style: Theme.of(context).textTheme.headline3
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                )
            ),
          ],

        ),

      ),
    );
  }

}