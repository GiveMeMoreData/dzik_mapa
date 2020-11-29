


import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dzik_mapa/templates/Buttons.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Login extends StatefulWidget{
   static const routeName = "/Login";

  @override
  State<StatefulWidget> createState() => _LoginState();
}



class _LoginState extends State<Login>{

  bool _selected = false;
  final formKey = new GlobalKey<FormState>();
  String _email;
  String _password;

  String _name;
  String _phoneNumber;
  String _photoUrl;


  bool _passwordMistake = false;

  bool validateAndSave (){
    final form = formKey.currentState;
    if(form.validate()){
      form.save();
      print("Form is valid");
      print("Email: $_email");
      print("Password: $_password");
      return true;
    }
    return false;
  }
  Future<void> _signInWithGoogle(BuildContext context) async {

    final GoogleSignIn googleSignIn = GoogleSignIn();

    // get user account
    try{
      final GoogleSignInAccount googleSignInAccount = await googleSignIn.signIn();
      if (googleSignInAccount == null){

        return;
      }

      final GoogleSignInAuthentication gsa = await googleSignInAccount.authentication;

      // get credentials necessary for logging in
      final AuthCredential credential = GoogleAuthProvider.credential(
        idToken: gsa.idToken,
        accessToken: gsa.accessToken,
      );

      // log in to firebase auth
      final UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
      final User firebaseUser = userCredential.user;
      final User currentUser = FirebaseAuth.instance.currentUser;
      assert(firebaseUser.uid == currentUser.uid);

      // after logged in sing out from google sign in
      googleSignIn.disconnect();
      googleSignIn.signOut();

      // register if new user
      if(!(await userInDatabase(firebaseUser.uid))){

        //add user to database
        await addUserFromGoogle(firebaseUser);

        // Set Preferences
        final prefs = await SharedPreferences.getInstance();
        prefs.setBool('notify', false);
        prefs.setString('location_from', null);
        prefs.setDouble('observe_radious', 500);
      }
      Navigator.pushReplacementNamed(context, "/Map");


    } catch (e) {
      print(e);
    }
  }

  Future<bool> userInDatabase(String userId) async {
    final user = await FirebaseFirestore.instance.collection("users").doc(userId).get();
    return user.data() != null;
  }

  Future<void> addUserFromGoogle(User user) async {

    SharedPreferences prefs = await SharedPreferences.getInstance();
    Map<String, Object> data = {
      "name": user.displayName,
      "email": user.email,
      "number" : user.phoneNumber,
      "photo_url": user.photoURL,
      "observe_location": null,
      "observe_radious" : 500,
      "send_alert": false,
      "fcm_token": prefs.get('FCM_token'),
    };

    try{
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set(data);
    } catch (e) {
      Scaffold.of(formKey.currentContext).showSnackBar(SnackBar(content: Text(e.message),));
      print('Error: $e');
    }
  }
  void validateAndSubmit() async {

    if (validateAndSave()) {
      try {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
            email: _email.trim(), password: _password);
        User user = FirebaseAuth.instance.currentUser;
        if(!user.emailVerified){
          formKey.currentState.reset();
          Scaffold.of(formKey.currentContext).showSnackBar(SnackBar(content: Text("Konto nieaktywne, użyj linku aktywacyjnego wysłanego na podany mail"), duration: Duration(seconds: 5),));
          user.sendEmailVerification();
          return;
        }
        print("Signed in ${user.uid}");
        Navigator.pop(context);
        Navigator.pushNamed(context, '/');
        formKey.currentState.reset();
      }

      catch (e) {
        if( e.code=="wrong-password"){
          setState(() {
            _passwordMistake = true;
          });
        }
        final errorMessage = e.message;
        formKey.currentState.reset();
        Scaffold.of(formKey.currentContext).showSnackBar(SnackBar(content: Text(errorMessage),));
        print('Error: $e');

      }
    }
  }
  void setSystemNavBar(BuildContext context){
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      systemNavigationBarColor: Color(0xFFECE5D8),
    ));
  }

  @override
  void initState() {
    super.initState();
    setSystemNavBar(context);
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        alignment: Alignment.center,
        color: Theme.of(context).backgroundColor,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                  "res/boar.png",
                  height: 100,
              ),
              SizedBox(height: 40,),

              ///
              /// Login fields
              ///

              Container(
                width: MediaQuery.of(context).size.width*0.7,
                child: Form(
                  key: formKey,
                  child: Column(
                      children: <Widget>[
                        TextFormField(
                          onChanged: (value){
                            _email = value;
                          },
                          validator: (value) => value.isEmpty? "Proszę wpisać e-mail": null,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                              filled: true,
                              hintStyle: TextStyle(color: Colors.grey[800],),
                              hintText: "email",
                              contentPadding: EdgeInsets.symmetric(vertical: 18, horizontal: 24),
                              fillColor: Colors.transparent
                          ),
                        ),
                        Icon(null, size: 20,),
                        TextFormField(
                          obscureText: true,
                          autocorrect: false,
                          onChanged: (value){
                            _password = value;
                          },
                          validator: (value) => value.isEmpty? "Proszę wpisać hasło": null,
                          decoration: InputDecoration(
                              filled: true,
                              hintStyle: TextStyle(color: Colors.grey[800]),
                              hintText: "hasło",
                              contentPadding: EdgeInsets.symmetric(vertical: 18, horizontal: 24),
                            fillColor: Colors.transparent
                          ),
                        ),
                      ]
                  ),
                ),
              ),
              SizedBox(height: 60,),

              ///
              /// Login button
              ///

              Material(
                color: Colors.white,
                borderRadius: BorderRadius.circular(100),
                child: InkWell(
                  splashColor: Theme.of(context).backgroundColor ,
                  highlightColor: Colors.transparent,
                  borderRadius: BorderRadius.circular(100),
                  onTap: validateAndSubmit,
                  child: Container(
                    width: MediaQuery.of(context).size.width*0.6,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(100),
                      border: Border.all(
                          width: 3,
                          color: Colors.white
                      ),
                      color: Colors.transparent,

                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                      child: Center(
                        child: Text(
                          "Zaloguj",
                          style: Theme.of(context).textTheme.headline1,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              SizedBox(height: 10,),
              GestureDetector(
                onTap: (){
                  Navigator.of(context).pushNamed(Register.routeName);
                },
                child: Text(
                    "zarejestruj",
                  style: Theme.of(context).textTheme.headline3.copyWith(
                      fontSize: 16,
                      decoration: TextDecoration.underline
                  ),
                ),
              ),
              SizedBox(height: 20,),

              SelectableTile(
                onTap: (){
                  _signInWithGoogle(context);
                },
                selected: _selected,
                child: Text(
                  "Zaloguj przez Google",
                  style: Theme.of(context).textTheme.headline3.copyWith(fontSize: 16),
                ),
              ),
              SelectableTile(
                onTap: (){

                },
                selected: _selected,
                child: Text(
                  "Zaloguj przez Facebooka",
                  style: Theme.of(context).textTheme.headline3.copyWith(fontSize: 16),
                ),
              ),


            ],
          ),
        ),
      )
    );
  }
}


class Register extends StatefulWidget{
  static const routeName = "/Login/Register";

  @override
  State<StatefulWidget> createState() => _RegisterState();
}



class _RegisterState extends State<Register>{

  bool _selected = false;
  final formKey = new GlobalKey<FormState>();
  String _email;
  String _password;
  String _passwordRepeat;

  String _name;
  String _phoneNumber;
  String _photoUrl;


  bool _passwordMistake = false;

  bool validateAndSave (){
    final form = formKey.currentState;
    if(form.validate()){
      form.save();
      print("Form is valid");
      print("Email: $_email");
      return true;
    }
    return false;
  }


  void pushUserToDatabase(String userId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    Map<String, Object> data = {
      "name": _name.trim(),
      "email": _email.trim(),
      "number": _phoneNumber,
      "photo_url": _photoUrl,
      "observe_location": null,
      "observe_radious" : 500,
      "send_alert": false,
      "fcm_token": prefs.get('FCM_token'),
    };

    await FirebaseFirestore.instance.collection('users').doc(userId).set(data);
  }

  void validateAndSubmit() async {

    if(validateAndSave()){
      try{
        // create account and save it in firebase auth
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
            email: _email.trim(), password: _password);
        User user = FirebaseAuth.instance.currentUser;

        // sends verification email from Firebase template
        user.sendEmailVerification();

        // adds user to firestore cloud with all provided info
        pushUserToDatabase(user.uid);


        Scaffold.of(formKey.currentContext).showSnackBar(SnackBar(content: Text("Aktywuj konto linkem wysłanym na podany email"),));
        formKey.currentState.reset();

        // switches screen back to login
        setState(() {
          Navigator.of(context).pop();
        });
      } catch (e) {
        switch(e.code) {
          case'ERROR_EMAIL_ALREADY_IN_USE':
            print("Error message: ${e.message}");
            Scaffold.of(formKey.currentContext).showSnackBar(SnackBar(content: Text("Ten email jest już przypisany do istniejącego konta"),));

            break;
          default:
            print("Unknown type of error");
            print('Error: $e');
        }
      }
    }
  }
  void setSystemNavBar(BuildContext context){
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      systemNavigationBarColor: Color(0xFFECE5D8),
    ));
  }

  @override
  void initState() {
    super.initState();
    setSystemNavBar(context);
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
          alignment: Alignment.center,
          color: Theme.of(context).backgroundColor,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  "res/boar.png",
                  height: 100,
                ),
                SizedBox(height: 40,),

                ///
                /// Login fields
                ///

                Container(
                  width: MediaQuery.of(context).size.width*0.7,
                  child: Form(
                    key: formKey,
                    child: Column(
                        children: <Widget>[
                          TextFormField(
                            onChanged: (value){
                              _name = value;
                            },
                            validator: (value) => value.isEmpty? "Proszę wpisać imię i nazwisko": null,
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                                filled: true,
                                hintStyle: TextStyle(color: Colors.grey[800],),
                                hintText: "imię i nazwisko",
                                contentPadding: EdgeInsets.symmetric(vertical: 18, horizontal: 24),
                                fillColor: Colors.transparent
                            ),
                          ),
                          Icon(null, size: 20,),
                          TextFormField(
                            onChanged: (value){
                              _email = value;
                            },
                            validator: (value) => value.isEmpty? "Proszę wpisać e-mail": null,
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                                filled: true,
                                hintStyle: TextStyle(color: Colors.grey[800],),
                                hintText: "email",
                                contentPadding: EdgeInsets.symmetric(vertical: 18, horizontal: 24),
                                fillColor: Colors.transparent
                            ),
                          ),
                          Icon(null, size: 20,),
                          TextFormField(
                            obscureText: true,
                            autocorrect: false,
                            onChanged: (value){
                              _password = value;
                            },
                            validator: (value) => _password != value? "Proszę wpisać hasło": null,
                            decoration: InputDecoration(
                                filled: true,
                                hintStyle: TextStyle(color: Colors.grey[800]),
                                hintText: "hasło",
                                contentPadding: EdgeInsets.symmetric(vertical: 18, horizontal: 24),
                                fillColor: Colors.transparent
                            ),
                          ),
                          Icon(null, size: 20,),
                          TextFormField(
                            obscureText: true,
                            autocorrect: false,
                            onChanged: (value){
                              _passwordRepeat = value;
                            },
                            validator: (value) => value.isEmpty? "Proszę powtórzyć hasło": null,
                            decoration: InputDecoration(
                                filled: true,
                                hintStyle: TextStyle(color: Colors.grey[800]),
                                hintText: "powtórz hasło",
                                contentPadding: EdgeInsets.symmetric(vertical: 18, horizontal: 24),
                                fillColor: Colors.transparent
                            ),
                          ),
                          Icon(null, size: 20,),
                          TextFormField(
                            autocorrect: false,
                            onChanged: (value){
                              _phoneNumber = value;
                            },
                            validator: (value) => value.isEmpty? "Proszę wpisać numer telefonu": null,
                            keyboardType: TextInputType.phone,
                            decoration: InputDecoration(
                                filled: true,
                                hintStyle: TextStyle(color: Colors.grey[800]),
                                hintText: "numer telefonu",
                                contentPadding: EdgeInsets.symmetric(vertical: 18, horizontal: 24),
                                fillColor: Colors.transparent
                            ),
                          ),
                        ]
                    ),
                  ),
                ),
                SizedBox(height: 60,),

                ///
                /// Login button
                ///

                Material(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(100),
                  child: InkWell(
                    splashColor: Theme.of(context).backgroundColor ,
                    highlightColor: Colors.transparent,
                    borderRadius: BorderRadius.circular(100),
                    onTap: validateAndSubmit,
                    child: Container(
                      width: MediaQuery.of(context).size.width*0.6,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(100),
                        border: Border.all(
                            width: 3,
                            color: Colors.white
                        ),
                        color: Colors.transparent,

                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                        child: Center(
                          child: Text(
                            "Zarejestruj",
                            style: Theme.of(context).textTheme.headline1,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 10,),
                GestureDetector(
                  onTap: Navigator.of(context).pop,
                  child: Text(
                    "zaloguj",
                    style: Theme.of(context).textTheme.headline3.copyWith(
                        fontSize: 16,
                        decoration: TextDecoration.underline
                    ),
                  ),
                ),
              ],
            ),
          ),
        )
    );
  }
}