

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dzik_mapa/templates/BoarData.dart';
import 'package:dzik_mapa/templates/Utils.dart';
import 'package:dzik_mapa/views/Login.dart';
import 'package:dzik_mapa/views/Map.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';


class SplashScreen extends StatelessWidget{
  static const routeName = "/SplashScreen";


  Future<void> initializeApp(BuildContext context) async {
    await initializeFirebase();
    await checkIfLogged(context);
    await configureFCM();
  }

  Future<void> configureFCM() async {
    final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
    _firebaseMessaging.configure(
      onLaunch: (Map<String, dynamic> message) {
        print('onLaunch called');
        return;
      },
      onResume: (Map<String, dynamic> message) {
        print('onResume called');
        return;
      },
      onMessage: (Map<String, dynamic> message) {
        print('onMessage called');
        return;
      },
      onBackgroundMessage: myBackgroundMessageHandler,
    );
    _firebaseMessaging.subscribeToTopic('all');
    _firebaseMessaging.requestNotificationPermissions(IosNotificationSettings(
      sound: true,
      badge: true,
      alert: true,
    ));
    _firebaseMessaging.onIosSettingsRegistered
        .listen((IosNotificationSettings settings) {
      print('Hello');
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();
    _firebaseMessaging.getToken().then((token) {
      prefs.setString("FCM_token", token);
      print("device FCM token: $token");
    });
  }

  Future<void> initializeFirebase() async {
    final FirebaseOptions firebaseOptions = const FirebaseOptions(
      appId: '1:599371167248:android:360590baff22de8ae77c95',
      apiKey: 'AIzaSyAjSF67ZDheaLwVNTqezKqNAkik1lI3wOs',
      projectId: 'boarmap',
      messagingSenderId: '599371167248',
    );

    FirebaseApp app = await Firebase.initializeApp( options:  firebaseOptions);
    assert(app != null);
    print('Initialized default app $app');
  }

  Future<void> checkIfLogged(BuildContext context) async {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null){
      Navigator.pushReplacementNamed(context, Login.routeName);
    } else {
      Navigator.pushReplacementNamed(context, MainMap.routeName);
    }
  }


  void setSystemNavBar(BuildContext context){
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      systemNavigationBarColor: Theme.of(context).backgroundColor,
    ));
  }
  @override
  Widget build(BuildContext context) {
    setSystemNavBar(context);
    initializeApp(context);
    return Scaffold(
      body: Container(
        color: Theme.of(context).backgroundColor,
        alignment: Alignment.center,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Dzik",
              style: GoogleFonts.kanit(
                  fontSize: 60,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF3A3A3A)
              ),
            ),
            Image.asset(
              "res/boar.png",
              height: 160,
            ),
            Text(
              "Mapa",
              style: GoogleFonts.kanit(
                  fontSize: 60,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF3A3A3A)
              ),
            )
          ],
        ),
      ),
    );
  }

}