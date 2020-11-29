import 'package:auto_size_text/auto_size_text.dart';
import 'package:dzik_mapa/views/History.dart';
import 'package:dzik_mapa/views/Login.dart';
import 'package:dzik_mapa/views/Map.dart';
import 'package:dzik_mapa/views/MyReports.dart';
import 'package:dzik_mapa/views/Profile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';



class CustomDrawer extends StatelessWidget{

  final User user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {

    return Drawer(
      child: Column(
        children: <Widget>[

          // drawer header
          Material(
            elevation: 10,
            child: Container(
              color: Colors.white,
              height: kToolbarHeight + MediaQuery.of(context).padding.top,
              alignment: AlignmentDirectional.bottomStart,
              child: Padding(
                padding: const EdgeInsets.symmetric( vertical: 10, horizontal: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    GestureDetector(
                        onTap: Navigator.of(context).pop,
                        child: Icon(
                          Icons.arrow_back,
                          color: Theme.of(context).primaryColor,
                          size: 30,
                        )
                    ),
                    SizedBox(
                      width: 15,
                    ),
                    AutoSizeText(
                      "Menu",
                      maxLines: 1,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w400,
                        color: Theme.of(context).primaryColor,
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),

          // spacer
          SizedBox(
            height: 40,
          ),


          // user's profile
          GestureDetector(
            onTap: (){
              Navigator.of(context).popUntil((route) => Navigator.of(context).canPop());
              Navigator.of(context).pushNamed(Profile.routeName);
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Icon(Icons.person, size: 32, color: Theme.of(context).primaryColor,),
                  SizedBox(
                    width: 20,
                  ),
                  Container(
                    alignment: AlignmentDirectional.centerStart,
                    child: AutoSizeText(
                        "Profil",
                        maxLines: 1,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w300,
                          color: Colors.black ,
                        )
                    ),
                  ),
                ],
              ),
            ),
          ),


          // spacer
          SizedBox(
            height: 30,
          ),


          // user's profile
          GestureDetector(
            onTap: (){
              Navigator.of(context).popUntil((route) => Navigator.of(context).canPop());
              Navigator.of(context).pushReplacementNamed(MainMap.routeName);
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Icon(Icons.map, size: 32, color: Theme.of(context).primaryColor,),
                  SizedBox(
                    width: 20,
                  ),
                  Container(
                    alignment: AlignmentDirectional.centerStart,
                    child: AutoSizeText(
                        "Mapa",
                        maxLines: 1,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w300,
                          color: Colors.black ,
                        )
                    ),
                  ),
                ],
              ),
            ),
          ),
          // spacer
          SizedBox(
            height: 30,
          ),


          // user's profile
          GestureDetector(
            onTap: (){
              Navigator.of(context).popUntil((route) => Navigator.of(context).canPop());
              Navigator.of(context).pushNamed(HistoryMap.routeName);
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Icon(Icons.map_outlined, size: 32, color: Theme.of(context).primaryColor,),
                  SizedBox(
                    width: 20,
                  ),
                  Container(
                    alignment: AlignmentDirectional.centerStart,
                    child: AutoSizeText(
                        "Historia",
                        maxLines: 1,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w300,
                          color: Colors.black ,
                        )
                    ),
                  ),
                ],
              ),
            ),
          ),
          // spacer
          SizedBox(
            height: 30,
          ),


          // user's profile
          GestureDetector(
            onTap: (){
              Navigator.of(context).popUntil((route) => Navigator.of(context).canPop());
              Navigator.of(context).pushNamed(MyReports.routeName);
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Icon(Icons.person_pin_rounded, size: 32, color: Theme.of(context).primaryColor,),
                  SizedBox(
                    width: 20,
                  ),
                  Container(
                    alignment: AlignmentDirectional.centerStart,
                    child: AutoSizeText(
                        "Moje zgłoszenia",
                        maxLines: 1,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w300,
                          color: Colors.black ,
                        )
                    ),
                  ),
                ],
              ),
            ),
          ),
          // spacer
          SizedBox(
            height: 30,
          ),

          // log out button
          GestureDetector(
            onTap: (){
              Navigator.of(context).popUntil((route) => Navigator.of(context).canPop());
              FirebaseAuth.instance.signOut();
              Navigator.of(context).pushReplacementNamed(Login.routeName);
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Icon(Icons.logout, size: 32, color: Theme.of(context).primaryColor,),
                  SizedBox(
                    width: 20,
                  ),
                  Container(
                    alignment: AlignmentDirectional.centerStart,
                    child: AutoSizeText(
                        "Wyloguj",
                        maxLines: 1,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w300,
                          color: Colors.black ,
                        )
                    ),
                  ),
                ],
              ),
            ),
          ),

        ],
      ),
    );
  }

}



class CustomEndDrawer extends StatelessWidget{

  final User user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {

    return Drawer(
      child: Column(
        children: <Widget>[

          // drawer header
          Material(
            elevation: 10,
            child: Container(
              color: Colors.white,
              height: kToolbarHeight + MediaQuery.of(context).padding.top,
              alignment: AlignmentDirectional.bottomStart,
              child: Padding(
                padding: const EdgeInsets.symmetric( vertical: 10, horizontal: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    GestureDetector(
                        onTap: Navigator.of(context).pop,
                        child: Icon(
                          Icons.arrow_back,
                          color: Theme.of(context).primaryColor,
                          size: 30,
                        )
                    ),
                    SizedBox(
                      width: 15,
                    ),
                    AutoSizeText(
                      "Menu",
                      maxLines: 1,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w400,
                        color: Theme.of(context).primaryColor,
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),

          // spacer
          SizedBox(
            height: 40,
          ),


          // user's profile
          GestureDetector(
            onTap: (){

            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Icon(Icons.person_outline, size: 24, color: Theme.of(context).accentColor,),
                  SizedBox(
                    width: 20,
                  ),
                  Container(
                    alignment: AlignmentDirectional.centerStart,
                    child: AutoSizeText(
                        "Profil",
                        maxLines: 1,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w300,
                          color: Colors.black ,
                        )
                    ),
                  ),
                ],
              ),
            ),
          ),

          // spacer
          SizedBox(
            height: 20,
          ),

          // log out button
          GestureDetector(
            onTap: (){
              Navigator.of(context).popUntil((route) => Navigator.of(context).canPop());
              FirebaseAuth.instance.signOut();
              Navigator.of(context).pushReplacementNamed(Login.routeName);
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Container(
                    alignment: AlignmentDirectional.centerStart,
                    child: AutoSizeText(
                        "Wyloguj",
                        maxLines: 1,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w300,
                          color: Colors.black ,
                        )
                    ),
                  ),
                ],
              ),
            ),
          ),

        ],
      ),
    );
  }

}