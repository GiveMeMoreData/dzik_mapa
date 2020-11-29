
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dzik_mapa/templates/Drawer.dart';
import 'package:dzik_mapa/templates/Utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MyReports extends StatefulWidget{
  static const routeName = "/MyReports";

  @override
  State<StatefulWidget> createState() => _MyReportsState();

}


class _MyReportsState extends State<MyReports>{



  static const double _paddingBetween = 30;
  static const double _textBottomMargin = 10;
  static const double _textLeftMargin = 15;


  List<QueryDocumentSnapshot> reports;

  Future<void> getLocations() async {
    if(reports == null){
      final _reports = await FirebaseFirestore.instance.collection('boars').where('userId', isEqualTo: FirebaseAuth.instance.currentUser.uid).orderBy('time', descending: true).get();
      setState(() {
        reports =_reports.docs;
      });
    }
  }



  @override
  void initState() {
    super.initState();
    setSystemNavBar(Color(0xFFECE5D8));
    getLocations();
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
            "Moje zgłoszenia"
        ),
      ),
      drawer: CustomDrawer(),
      body: Container(
        alignment: Alignment.topCenter,
        color: Theme.of(context).backgroundColor,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Builder(
            builder: (context){
              if(reports != null){
                return ListView.builder(
                    physics: ScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: reports.length,
                    itemBuilder: (context, index){

                      ///
                      /// list element
                      ///
                      return Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                        child: Material(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(40),
                          elevation: 5,
                          shadowColor: Color(0x2a989898),
                          child: InkWell(
                            splashColor: Theme.of(context).accentColor ,
                            highlightColor: Colors.transparent,
                            borderRadius: BorderRadius.circular(40),
                            onTap: (){
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(2.5),
                              child: Container(
                                width: MediaQuery.of(context).size.width*0.9,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(40),
                                    color: Colors.white,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Color(0xFF989898).withOpacity(0.1),
                                        spreadRadius: 2,
                                        blurRadius: 5,
                                        offset: Offset(2, 2), // changes position of shadow
                                      )
                                    ]
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 19),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Image.asset(
                                        "res/boar.png",
                                        width: 40,
                                      ),
                                      Column(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            getNiceDate(reports[index].data()['time']),
                                            style: Theme.of(context).textTheme.headline2,
                                          ),
                                          Text(
                                            "Dorosłe ${reports[index].data()['adults']}",
                                            style: Theme.of(context).textTheme.headline3.copyWith(fontSize: 16),
                                          ),
                                          Text(
                                            "Dorosłe ${reports[index].data()['young']}",
                                            style: Theme.of(context).textTheme.headline3.copyWith(fontSize: 16),
                                          ),
                                        ],
                                      ),
                                      SizedBox(
                                        width: 28,
                                        child: Visibility(
                                          visible: reports[index].data()['photos']>0,
                                          child: Icon(
                                            Icons.photo_library_outlined,
                                            color: Theme.of(context).primaryColor,
                                            size: 28,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  );

              } else {
                return CircularProgressIndicator();
              }
            },
          ),
        ),
      ),
    );
  }

}