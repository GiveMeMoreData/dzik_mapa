import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';


abstract class BoarBase{

  @protected
  List<QueryDocumentSnapshot> boars;

  @protected
  List<QueryDocumentSnapshot> initialBoars;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;


  void listenToDatabase(){
    _firestore.collection('boars').snapshots().listen((data) {
      boars = data.docs;
    });
  }

  void reset(){
    boars = initialBoars;
  }
}


class BoarState extends BoarBase {
  static final BoarState _instance = BoarState._internal();

  factory BoarState() {
    return _instance;
  }

BoarState._internal() {
  initialBoars = [];
  boars = initialBoars;
  }
}