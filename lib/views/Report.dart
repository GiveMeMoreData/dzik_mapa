
import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dzik_mapa/templates/Buttons.dart';
import 'package:dzik_mapa/templates/Drawer.dart';
import 'package:dzik_mapa/templates/ReportData.dart';
import 'package:dzik_mapa/templates/Utils.dart';
import 'package:dzik_mapa/views/Map.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:image_picker/image_picker.dart';

class Report extends StatefulWidget{
  static const routeName = "/Report";

  @override
  State<StatefulWidget> createState() => _ReportState();

}


class _ReportState extends State<Report>{

  final ReportDataBase _report = ReportDataState();

  int _adults = 0;
  int _young = 0;
  bool _preciseInfo = false;
  bool _dead = false;

  static const double _paddingBetween = 30;
  static const double _textBottomMargin = 10;
  static const double _textLeftMargin = 15;

  @override
  void initState() {
    super.initState();
    setSystemNavBar(Color(0xFFECE5D8));
  }

  @override
  void dispose() {
    super.dispose();
    setSystemNavBar(Colors.white); //TODO fix lag
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            "Zgłoś dzika"
        ),
      ),
      drawer: CustomDrawer(),
      body: Container(
        alignment: Alignment.center,
        color: Theme.of(context).backgroundColor,
        child: Stack(
          alignment: Alignment.center,
          children: [


            ///
            ///  Main body
            ///

            Container(
              width: MediaQuery.of(context).size.width*0.8,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: _textLeftMargin, bottom: _textBottomMargin),
                    child: Text(
                      "Dorosłe ${_adults}",
                      style: Theme.of(context).textTheme.headline2,
                    ),
                  ),
                  Container(
                    height: 30,
                    child: ListView.builder(
                      itemCount: 10,
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (context, index){
                        return SelectableCircle(
                          selected: _adults>index,
                          onTap: (){
                            if(_adults == index+1){
                              _adults = 0;
                            } else {
                              _adults = index+1;
                            }
                            setState(() {});
                          },
                        );
                      },
                    ),
                  ),
                  SizedBox(height: _paddingBetween,),
                  Padding(
                    padding: const EdgeInsets.only(left: _textLeftMargin, bottom: _textBottomMargin),
                    child: Text(
                      "Młode ${_young}",
                      style: Theme.of(context).textTheme.headline2,
                    ),
                  ),
                  Container(
                    height: 30,
                    child: ListView.builder(
                      itemCount: 10,
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (context, index){
                        return SelectableCircle(
                          selected: _young>index,
                          onTap: (){
                            if(_young == index+1){
                              _young = 0;
                            } else {
                              _young = index+1;
                            }
                            setState(() {});
                          },
                        );
                      },
                    ),
                  ),
                  SizedBox(height: _paddingBetween,),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: _textLeftMargin, vertical: 0),
                    child: Text(
                      "Są to dokładne dane?",
                      style: Theme.of(context).textTheme.headline2,
                    ),
                  ),

                  Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [

                      SelectableTile(
                        selected: !_preciseInfo,
                        onTap: (){
                          setState(() {
                            _preciseInfo = false;
                          });
                        },

                        child: Text(
                          "Nie",
                          style: Theme.of(context).textTheme.headline3,
                        ),
                      ),
                      SelectableTile(
                        selected: _preciseInfo,
                        onTap: (){
                          setState(() {
                            _preciseInfo = true;
                          });
                        },

                        child: Text(
                          "Tak",
                          style: Theme.of(context).textTheme.headline3,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: _paddingBetween,),


                  Padding(
                    padding: const EdgeInsets.only(left: _textLeftMargin, bottom: 0),
                    child: Text(
                      "Martwe dziki?",
                      style: Theme.of(context).textTheme.headline2,
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [

                      SelectableTile(
                        selected: !_dead,
                        onTap: (){
                          setState(() {
                            _dead = false;
                          });
                        },

                        child: Text(
                          "Nie",
                          style: Theme.of(context).textTheme.headline3,
                        ),
                      ),
                      SelectableTile(
                        selected: _dead,
                        onTap: (){
                          setState(() {
                            _dead = true;
                          });
                        },

                        child: Text(
                          "Tak",
                          style: Theme.of(context).textTheme.headline3,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            ///
            /// Header
            ///

            Positioned(
              top: 20,
              child:Text(
                "Ile dzików spotkałeś?",
                style: Theme.of(context).textTheme.headline1.copyWith(fontSize: 28),
              ),
            ),

            ///
            /// Button 'next'
            ///

            Positioned(
              bottom: 20,
              child: SelectableTile(
                selected: _young +_adults>0,
                onTap: (){
                  if(_young +_adults>0){
                    _report.report.userId = FirebaseAuth.instance.currentUser.uid;
                    _report.report.time = Timestamp.now();
                    _report.report.setAdults(_adults);
                    _report.report.setYoung(_young);
                    _report.report.setPreciseInfo(_preciseInfo);
                    _report.report.setDead(_dead);
                    Navigator.of(context).pushNamed(ReportLocation.routeName);
                  }
                },

                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Dalej",
                      style: Theme.of(context).textTheme.headline2,
                    ),
                    SizedBox(width: 10,),
                    Icon(
                      Icons.arrow_forward_outlined,
                      color: Theme.of(context).backgroundColor,
                      size: 22,
                    )
                  ],
                )
              ),
            )
          ],
        ),
      ),
    );
  }

}


enum SelectedLocation{
  none,
  myLocation,
  selected,
}

class ReportLocation extends StatefulWidget{
  static const routeName = "/Report/Location";
  @override
  State<StatefulWidget> createState() => _ReportLocationState();
}


class _ReportLocationState extends State<ReportLocation>{

  final ReportDataBase _report = ReportDataState();
  SelectedLocation _selectedLocation = SelectedLocation.none;
  GeoPoint _location;
  LatLng _locationTemp;

  void _onCameraMove(CameraPosition position) {
    _locationTemp = position.target;
  }
  
  void showLocationPicker() async {
    final CameraPosition _initialCameraPosition = CameraPosition(
      target: LatLng(53.46439, 20.28454),
      zoom: 6,
    );

    GoogleMapController _controller;

    showGeneralDialog(
        context: context,
        pageBuilder: (context, anim1, anim2) {return;},
        barrierDismissible: true,
        barrierColor: Colors.white.withOpacity(0.1),
        barrierLabel: '',
        transitionBuilder: (context, anim1, anim2, child) {
          final curvedValue = Curves.easeInOut.transform(anim1.value)- 1.0;
          return Transform(
            transform: Matrix4.translationValues(0, curvedValue*200, 0),
            child: Opacity(
              opacity: anim1.value,
              child: Dialog(
                elevation: 30,
                backgroundColor: Colors.transparent,
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height*0.8,
                  child: Stack(
                    alignment: AlignmentDirectional.center,
                    children: [
                      GoogleMap(
                        mapType: MapType.normal,
                        initialCameraPosition: _initialCameraPosition,
                        mapToolbarEnabled: false,
                        zoomControlsEnabled: true,
                        tiltGesturesEnabled: false,
                        compassEnabled: false,
                        onMapCreated: (GoogleMapController controller) {
                          _controller = controller;
                        },
                        onCameraMove: _onCameraMove,
                      ),
                      Positioned(
                        bottom: 10,
                        child: SelectableTile(
                          selected: true,
                          onTap: () async {
                            Navigator.of(context).pop();
                            setState(() {
                              _location = GeoPoint(_locationTemp.latitude, _locationTemp.longitude);
                              _selectedLocation = SelectedLocation.selected;
                            });
                          },
                          child: Text(
                            "Wybierz",
                            style: Theme.of(context).textTheme.headline2,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 42),
                        child: Icon(
                          Icons.add_location,
                          color: Theme.of(context).primaryColor,
                          size: 42,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
        transitionDuration: Duration(milliseconds: 400)
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Zgłoś dzika"
        ),
      ),
      body: Container(
        alignment: Alignment.center,
        color: Theme.of(context).backgroundColor,
        child: Stack(
          alignment: Alignment.center,
          children: [


            ///
            ///  Main body
            ///
            SizedBox(
              width: MediaQuery.of(context).size.width,
            ),
            Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width*0.8
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  ///
                  /// My location
                  ///

                  SelectableTile(
                    selected: _selectedLocation == SelectedLocation.myLocation,
                    onTap: () async {
                      final GeoPoint location = await getLocation();
                      if (location != null){
                        setState(() {
                          _location = location;
                          _selectedLocation = SelectedLocation.myLocation;
                        });
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                              "Moja lokalizacja",
                            style: Theme.of(context).textTheme.headline2,
                          ),
                          SizedBox(height: 20,),
                          Icon(
                            Icons.add_location,
                            color: Theme.of(context).primaryColor,
                            size: 40,
                          )
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 30,),

                  ///
                  /// Select loaction
                  ///

                  SelectableTile(
                    selected: _selectedLocation == SelectedLocation.selected,
                    onTap: (){
                      showLocationPicker();
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "Wskaż lokalizację",
                            style: Theme.of(context).textTheme.headline2,
                          ),
                          SizedBox(height: 20,),
                          Icon(
                            Icons.add_location_alt,
                            color: Theme.of(context).primaryColor,
                            size: 40,
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            ///
            /// Header
            ///

            Positioned(
              top: 20,
              child:Text(
                "Gdzie spotkałeś dziki?",
                style: Theme.of(context).textTheme.headline1.copyWith(fontSize: 28),
              ),
            ),

            ///
            /// Button 'back'
            ///

            Positioned(
              bottom: 20,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SelectableTile(
                    selected: true,
                    onTap: (){
                      Navigator.of(context).pop();
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Icon(
                          Icons.arrow_back_outlined,
                          color: Theme.of(context).backgroundColor,
                          size: 22,
                        ),
                        SizedBox(width: 10,),
                        Text(
                          "Wróć",
                          style: Theme.of(context).textTheme.headline2,
                        ),
                      ],
                    ),
                  ),

                  ///
                  /// Button 'next'
                  ///

                  SelectableTile(
                    selected: _selectedLocation != SelectedLocation.none,
                    onTap: (){
                      if(_location != null){
                        _report.report.setLocation(_location);
                        Navigator.of(context).pushNamed(ReportExtra.routeName);
                      }
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Dalej",
                          style: Theme.of(context).textTheme.headline2,
                        ),
                        SizedBox(width: 10,),
                        Icon(
                          Icons.arrow_forward_outlined,
                          color: _selectedLocation != SelectedLocation.none? Theme.of(context).backgroundColor : Colors.white ,
                          size: 22,
                        )
                      ],
                    ),
                  ),
                ],
              )
            )
          ],
        ),
      ),
    );
  }
}


class ReportExtra extends StatefulWidget{
  static const routeName = "/Report/Extra";
  @override
  State<StatefulWidget> createState() => _ReportExtraState();
}


class _ReportExtraState extends State<ReportExtra>{

  final ReportDataBase _report = ReportDataState();

  bool _photosAdded = false;
  List<dynamic> _photos = [];

  bool _alternativeTimeAdded = false;
  Timestamp alternativeTime;

  bool _commentAdded = false;
  String comment;


  //Creating a global Variable
  Reference storageReference = FirebaseStorage.instance.ref();

  Future<PickedFile> getImage() async {
    return await ImagePicker().getImage(source: ImageSource.gallery, imageQuality: 50);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            "Zgłoś dzika"
        ),
      ),
      body: Container(
        alignment: Alignment.center,
        color: Theme.of(context).backgroundColor,
        child: Stack(
          alignment: Alignment.center,
          children: [


            ///
            ///  Main body
            ///
            SizedBox(
              width: MediaQuery.of(context).size.width,
            ),
            Container(
              constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width*0.8
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  ///
                  /// My location
                  ///

                  SelectableTile(
                    selected: _photosAdded,
                    onTap: () async {
                     final PickedFile photo = await getImage();
                     _photos = [photo.path];
                     setState(() {
                       _photosAdded = photo != null;
                     });

                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "Dodaj zdjęcia",
                            style: Theme.of(context).textTheme.headline2,
                          ),
                          SizedBox(height: 20,),
                          Icon(
                            Icons.add_photo_alternate,
                            color: Theme.of(context).primaryColor,
                            size: 40,
                          )
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 30,),

                  ///
                  /// Select loaction
                  ///

                  SelectableTile(
                    selected: _alternativeTimeAdded,
                    onTap: (){
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child:Text(
                        "Ustaw inną godzinę",
                        style: Theme.of(context).textTheme.headline2,
                      ),
                    ),
                  ),


                  SelectableTile(
                    selected: _alternativeTimeAdded,
                    onTap: (){
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child:Text(
                        "Dodaj komentarz",
                        style: Theme.of(context).textTheme.headline2,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            ///
            /// Header
            ///

            Positioned(
              top: 20,
              child:Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Dodatkowe informacje",
                    style: Theme.of(context).textTheme.headline1.copyWith(fontSize: 28),
                  ),
                  Text(
                    "nie musisz ich uzupełniać",
                    style: Theme.of(context).textTheme.headline3,
                  ),
                ],
              ),
            ),

            ///
            /// Button 'back'
            ///

            Positioned(
                bottom: 20,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SelectableTile(
                      selected: true,
                      onTap: (){
                        Navigator.of(context).pop();
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Icon(
                            Icons.arrow_back_outlined,
                            color: Theme.of(context).backgroundColor,
                            size: 22,
                          ),
                          SizedBox(width: 10,),
                          Text(
                            "Wróć",
                            style: Theme.of(context).textTheme.headline2,
                          ),
                        ],
                      ),
                    ),


                    ///
                    /// Button 'submit'
                    ///

                    SelectableTile(
                      selected: true,
                      onTap: (){
                        _report.report.setPhotos(_photos);
                        _report.sendBoarReport();
                        Navigator.of(context).popUntil((route) => Navigator.of(context).canPop());
                        Navigator.pushReplacementNamed(context, MainMap.routeName);
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Wyślij",
                            style: Theme.of(context).textTheme.headline2,
                          ),
                          SizedBox(width: 10,),
                          Icon(
                            Icons.send,
                            color: Theme.of(context).backgroundColor,
                            size: 22,
                          )
                        ],
                      ),
                    ),
                  ],
                )
            )
          ],
        ),
      ),
    );
  }
}