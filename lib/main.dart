import 'dart:async';

import 'package:dzik_mapa/templates/SplashScreen.dart';
import 'package:dzik_mapa/views/History.dart';
import 'package:dzik_mapa/views/Login.dart';
import 'package:dzik_mapa/views/Map.dart';
import 'package:dzik_mapa/views/MyReports.dart';
import 'package:dzik_mapa/views/Profile.dart';
import 'package:dzik_mapa/views/Report.dart';
import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dzik Mapa',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        accentColor: Color(0xFF9D6300),
        primaryColor: Color(0xFF9D6300),
        backgroundColor: Color(0xFFECE5D8),
        textTheme: TextTheme(
          headline1: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 22,
            color: Color(0xFF3A3A3A)
          ),
          headline2: TextStyle(
              fontWeight: FontWeight.w400,
              fontSize: 20,
              color: Color(0xFF3A3A3A)
          ),
          headline3: TextStyle(
              fontWeight: FontWeight.w300,
              fontSize: 20,
              color: Color(0xFF3A3A3A)
          ),
        )
      ),
      initialRoute: "/SplashScreen",

      routes: {
        "/Map" : (context) => MainMap(),
        "/History" : (context) => HistoryMap(),
        "/Login" : (context) => Login(),
        "/Login/Register" : (context) => Register(),
        "/SplashScreen" : (context) => SplashScreen(),
        "/Report" : (context) => Report(),
        "/Report/Location" : (context) => ReportLocation(),
        "/Report/Extra" : (context) => ReportExtra(),
        "/MyReports" : (context) => MyReports(),
        "/Profile" : (context) => Profile(),
      },
    );
  }
}
