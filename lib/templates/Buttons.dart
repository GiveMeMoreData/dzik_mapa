

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class NormalButton extends StatefulWidget{
  @override
  State<StatefulWidget> createState() => _NormalButtonState();
}

class _NormalButtonState extends State<NormalButton>{
  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 10,
      borderRadius: BorderRadius.circular(25),

    );
  }

}





class SelectableTile extends StatefulWidget{

  SelectableTile({this.selected, this.onTap, this.child});


  bool selected;
  Function onTap;
  Widget child;

  @override
  State<StatefulWidget> createState() => _SelectableListTileState();

}
class _SelectableListTileState extends State<SelectableTile>{


  void _tileAction(){
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Material(
        color: widget.selected? Colors.white : Colors.transparent,
        borderRadius: BorderRadius.circular(50),
        child: InkWell(
          splashColor: widget.selected? Theme.of(context).backgroundColor : Colors.white ,
          highlightColor: Colors.transparent,
          borderRadius: BorderRadius.circular(50),
          onTap: (){
            _tileAction();
          },
          child: Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(50),
                border: Border.all(
                  width: 3,
                  color: Colors.white
                ),
                color: Colors.transparent,

            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
              child: Center(child: widget.child),
            ),
          ),
        ),
      ),
    );
  }
}


class SelectableCircle extends StatefulWidget{

  SelectableCircle({this.selected, this.onTap});

  bool selected;
  Function onTap;

  @override
  State<StatefulWidget> createState() => _SelectableCircleState();

}

class _SelectableCircleState extends State<SelectableCircle>{


  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8),
      child: Material(
        color: widget.selected? Colors.white : Colors.transparent,
        borderRadius: BorderRadius.circular(100),
        child: InkWell(
          splashColor: widget.selected? Theme.of(context).backgroundColor : Colors.white ,
          highlightColor: Colors.transparent,
          borderRadius: BorderRadius.circular(100),
          onTap: widget.onTap,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(100),
              border: Border.all(
                  width: 3,
                  color: Colors.white
              ),
              color: Colors.transparent,
            ),
            child: SizedBox(
              width: 24,
            ),
          ),
        ),
      ),
    );
  }

}