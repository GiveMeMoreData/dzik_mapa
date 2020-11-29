

import 'dart:io';
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class PhotoContainer extends StatefulWidget{

  final double height;
  final double width;
  final String photoUrl;

  const PhotoContainer(this.photoUrl, {Key key, this.height = 50, this.width = 50}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _PhotoContainerState();

}


class _PhotoContainerState extends State<PhotoContainer>{


  bool _loading = false;
  Image _image;

  Future<void> downloadPhoto() async {
    setState(() {
      _loading = true;
    });
    Directory appDocDir = await getApplicationDocumentsDirectory();
    final time = Timestamp.now().microsecondsSinceEpoch;
    File downloadToFile = File('${appDocDir.path}/$time.png');

    try {
      print("Downloading photo: ${widget.photoUrl}");
      await FirebaseStorage.instance
          .ref(widget.photoUrl)
          .writeToFile(downloadToFile);

      print("Photo downloaded: ${widget.photoUrl}");
      setState(() {
        _image = Image.file(downloadToFile);
        _loading = false;
      });
    } on FirebaseException catch (e) {
      // e.g, e.code == 'canceled'
      print("Error while downloading photo");
      print(e.toString());
    }
  }

  void showPictureFullscreen(BuildContext context){
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
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                child: Dialog(
                  elevation: 30,
                  backgroundColor: Colors.transparent,
                  child: Stack(
                    alignment: AlignmentDirectional.center,
                    children: [
                      _image,
                      Positioned(
                        left: 10,
                        top: 10,
                        child: GestureDetector(
                          onTap: (){
                            Navigator.of(context).pop();
                          },
                          child: Icon(
                            Icons.exit_to_app_rounded,
                            size: 40,
                            color: Theme.of(context).primaryColor,
                          ),
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
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: GestureDetector(
        onTap: downloadPhoto,
        child: Container(
          color: Colors.grey[200],
          child: Builder(
            builder: (context){
              if(_loading){
                CircularProgressIndicator();
              } else {
                if(_image != null){
                  return GestureDetector(
                    onTap: (){
                      showPictureFullscreen(context);
                    },
                    child: _image,
                  );
                }
              }
              return Icon(
                Icons.download_rounded,
                color: Theme.of(context).primaryColor,
                size: widget.width,
              );
            },
          ),
        ),
      ),
    );
  }

}