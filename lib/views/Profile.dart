
import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dzik_mapa/templates/Buttons.dart';
import 'package:dzik_mapa/templates/Drawer.dart';
import 'package:dzik_mapa/templates/Utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Profile extends StatefulWidget{
  static const routeName = "/Profile";

  @override
  State<StatefulWidget> createState() => _ProfileState();

}


class _ProfileState extends State<Profile>{

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;


  DocumentSnapshot userData;
  SharedPreferences prefs;
  bool _notify = false;
  String _locationFrom;
  double _observeRadius = 500;

  LatLng _locationTemp;
  GeoPoint _location;

  void loadPreferences() async {
    prefs = await SharedPreferences.getInstance();
    setState(() {
      _notify = prefs.getBool('notify');
      _locationFrom = prefs.getString('location_from');
      _observeRadius = prefs.getDouble('observe_radious');
    });
  }

  void downloadUserData() async {
    userData = await _firestore.collection('users').doc(FirebaseAuth.instance.currentUser.uid).get();
    setState(() {});
}
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
                              _locationFrom = "selected";
                            });
                            prefs.setString('location_from', _locationFrom);
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
  void initState() {
    super.initState();
    setSystemNavBar(Color(0xFFECE5D8));
    loadPreferences();
    downloadUserData();
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
            "Profil"
        ),
      ),
      drawer: CustomDrawer(),
      body: Container(
        color: Theme.of(context).backgroundColor,
        child: Builder(
          builder: (context){
            if(userData != null){
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 40),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    ///
                    /// Avatar
                    ///

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          userData.get('name').toString().replaceFirst(" ", "\n"),
                          style: Theme.of(context).textTheme.headline1,
                          maxLines: 2,
                        ),

                        Container(
                          height: 80,
                          width: 80,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(50),
                            border: Border.all(
                              color: Colors.white,
                              width: 5,
                            ),
                          ),
                          child: Builder(
                            builder: (context){
                              if(userData.get('photo_url') != null){
                                return CircleAvatar(
                                  radius: 35,
                                  backgroundImage: NetworkImage(userData.get('photo_url')),
                                  backgroundColor: Colors.transparent,
                                );
                              }
                              return Icon(
                                Icons.person,
                                color: Theme.of(context).primaryColor,
                                size: 40,
                              );
                            },
                          ),
                        )
                      ],
                    ),
                    SizedBox(height: 15,),
                    Text(
                      userData.get('email'),
                      textAlign: TextAlign.start,
                      style: Theme.of(context).textTheme.headline3,
                    ),
                    SizedBox(height: 30,),
                    Text(
                      "Wyślij powiadomienie gdy pojawi się dzik w pobliżu?",
                      maxLines: 2,
                      style: Theme.of(context).textTheme.headline2,
                    ),
                    SizedBox(height: 15,),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SelectableTile(
                          selected: !_notify,
                          onTap: (){
                            setState(() {
                              _notify = false;
                            });
                            prefs.setBool('notify', _notify);
                          },

                          child: Text(
                            "Nie",
                            style: Theme.of(context).textTheme.headline3,
                          ),
                        ),
                        SelectableTile(
                          selected: _notify,
                          onTap: (){
                            setState(() {
                              _notify = true;
                            });
                            prefs.setBool('notify', _notify);
                          },

                          child: Text(
                            "Tak",
                            style: Theme.of(context).textTheme.headline3,
                          ),
                        ),
                      ],
                    ),

                    ///
                    /// Location source
                    ///


                    SizedBox(height: 30,),
                    Text(
                      "Wybierz lokalizacje domu",
                      maxLines: 1,
                      style: Theme.of(context).textTheme.headline2,
                    ),
                    SizedBox(height: 15,),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SelectableTile(
                          selected: _locationFrom == "selected",
                          onTap: showLocationPicker,

                          child: AutoSizeText(
                            "Tak",
                            style: Theme.of(context).textTheme.headline3,
                          ),
                        ),
                        SelectableTile(
                          selected: _locationFrom == "location",
                          onTap: () async {
                            final GeoPoint location = await getLocation();
                            if (location != null){
                              setState(() {
                                _location = location;
                                _locationFrom = "location";
                              });
                            }
                            prefs.setString('location_from', _locationFrom);
                          },

                          child: AutoSizeText(
                            "Nie",
                            style: Theme.of(context).textTheme.headline3,
                          ),
                        ),
                      ],
                    ),

                    ///
                    /// Distance
                    ///


                    SizedBox(height: 30,),
                    Text(
                      "Ostrzegaj o dzikach w odległści",
                      maxLines: 1,
                      style: Theme.of(context).textTheme.headline2,
                    ),
                    SizedBox(height: 15,),
                    Slider(
                      value: _observeRadius,
                      min: 300,
                      max: 1500,
                      divisions: 100,
                      label: "${_observeRadius.round()}m",
                      activeColor: Theme.of(context).primaryColor,
                      inactiveColor: Theme.of(context).backgroundColor,
                      onChanged: (double value) {
                        setState(() {
                          _observeRadius = value;
                        });
                        prefs.setDouble('observe_radious', _observeRadius);
                      },
                    )

                  ],
                ),
              );
            }
            return CircularProgressIndicator();
          },
        ),
      ),
    );
  }

}
