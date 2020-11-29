

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class ReportData{

  @protected
  int adults;
  @protected
  int young;
  @protected
  bool dead;
  @protected
  bool preciseInfo;
  @protected
  GeoPoint location;
  @protected
  List<dynamic> photos;
  @protected
  Timestamp time;
  @protected
  String comment;
  @protected
  String userId;



  void setAdults(int newAdults) {
    adults = newAdults;
  }
  void setYoung(int newYoung) {
    young = newYoung;
  }
  void setDead(bool newDead) {
    dead = newDead;
  }
  void setPreciseInfo(bool newPreciseInfo) {
    preciseInfo = newPreciseInfo;
  }
  void setLocation(GeoPoint newLocation) {
    location = newLocation;
  }
  void setPhotos(List<dynamic> newPhotos){
    photos = newPhotos;
  }
  void addPhoto(dynamic newPhoto){
    photos.add(newPhoto);
  }
  void setTime(Timestamp newTime) {
    time = newTime;
  }
  void setComment(String newComment) {
    comment = newComment;
  }
  void setUserId(String newUserId) {
    userId = newUserId;
  }

  ReportData(this.adults, this.young, this.dead, this.preciseInfo, this.location, this.photos, this.time, this.comment, this.userId);
}


abstract class ReportDataBase{

  @protected
  ReportData report;

  @protected
  ReportData initialReport;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> _uploadPhotos(String docId) async {
    int _index = 0;
    report.photos.forEach((filePath) async {
      final file = File(filePath);
      _index+=1;
      try {
        await FirebaseStorage.instance
            .ref('images/$docId/$_index.png')
            .putFile(file);
      } on FirebaseException catch (e) {
        print(e);
      }
    });
    print("$_index photos uploaded");
  }

  void sendBoarReport() async {
    final doc = await _firestore.collection('boars').add({
      'adults': report.adults,
      'young': report.young,
      'dead': report.dead,
      'location': report.location,
      'precise_info': report.preciseInfo,
      'time': report.time,
      'photos': report.photos.length,
      'userId': report.userId,
    });

    print("Added report with id: ${doc.id}");

    if(report.photos.length>0){
      _uploadPhotos(doc.id);
    }

    report = initialReport;
    }
  }


class ReportDataState extends ReportDataBase {
  static final ReportDataState _instance = ReportDataState._internal();

  factory ReportDataState() {
    return _instance;
  }

  ReportDataState._internal() {
    initialReport = ReportData(null, null, null, null, null, [], null, null, null);
    report = initialReport;
  }
}