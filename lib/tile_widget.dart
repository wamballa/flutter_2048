import 'package:flutter/material.dart';

class Tile extends StatelessWidget {
  final int value;

  Tile({required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black, width: 1),
      ),
      child: Center(
        child: Text(
          value != 0 ? '$value' : '',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
