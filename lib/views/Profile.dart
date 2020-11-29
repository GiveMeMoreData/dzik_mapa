
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dzik_mapa/templates/Drawer.dart';
import 'package:dzik_mapa/templates/Utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Profile extends StatefulWidget{
  static const routeName = "/Profile";

  @override
  State<StatefulWidget> createState() => _ProfileState();

}


class _ProfileState extends State<Profile>{

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  DocumentSnapshot userData;

  void downloadUserData() async {
    userData = await _firestore.collection('users').doc(FirebaseAuth.instance.currentUser.uid).get();
    setState(() {});
}

  @override
  void initState() {
    super.initState();
    setSystemNavBar(Color(0xFFECE5D8));
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
        alignment: Alignment.center,
        color: Theme.of(context).backgroundColor,
        child: Builder(
          builder: (context){
            if(userData != null){
              return Column(

                ///
                /// Avatar
                ///


              );
            }
            return CircularProgressIndicator();
          },
        ),
      ),
    );
  }

}
