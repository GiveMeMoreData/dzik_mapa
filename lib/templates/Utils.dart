

import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class PinInformation {
  String id;
  int adults;
  int young;
  Timestamp timestamp;
  int photos;
  String comment;
  bool preciseInfo;
  PinInformation({
    this.id,
    this.adults,
    this.young,
    this.timestamp,
    this.photos,
    this.comment,
    this.preciseInfo});
}


Future<BitmapDescriptor> setCustomMapPin({String photoPath = 'res/boar.png'}) async {
  return BitmapDescriptor.fromBytes(await _getBytesFromAsset(photoPath, 80));
}

Future<Uint8List> _getBytesFromAsset(String path, int width) async {
  ByteData data = await rootBundle.load(path);
  ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(), targetWidth: width);
  ui.FrameInfo fi = await codec.getNextFrame();
  return (await fi.image.toByteData(format: ui.ImageByteFormat.png)).buffer.asUint8List();
}

void setSystemNavBar(Color color){
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    systemNavigationBarColor: color,
  ));
}

Future<GeoPoint> getLocation() async {
  final _locationService = Location.instance;
  if (await _locationService.serviceEnabled()){
    final pos = await _locationService.getLocation();
    return GeoPoint(pos.latitude, pos.longitude);
  }
  bool result = await _locationService.requestService();
  if(result){
    return await getLocation();
  }
  return null;
}


String getNiceDate(Timestamp timestamp){
  String day;
  final date = timestamp.toDate();
  final now = DateTime.now();
  if(timestamp.millisecondsSinceEpoch>DateTime.utc(now.year, now.month,now.day).millisecondsSinceEpoch){
    // Same day
    day = "Dzisiaj";
  } else if (timestamp.millisecondsSinceEpoch>DateTime.utc(now.year, now.month,now.day).subtract(Duration(days: 1)).millisecondsSinceEpoch){
    day = "Wczoraj";
  } else {
    day = "${date.day}/${date.month}/${date.year}";
  }
  final minute = date.minute<10? "0${date.minute}" : date.minute;
  return day +" ${date.hour}:$minute";
}

Future<dynamic> myBackgroundMessageHandler(Map<String, dynamic> message) async {
  if (message.containsKey('data')) {
    // Handle data message
    final dynamic data = message['data'];
  }

  if (message.containsKey('notification')) {
    // Handle notification message
    final dynamic notification = message['notification'];
  }

  // Or do other work.
}