import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';
import 'package:flutter_swipe_detector/flutter_swipe_detector.dart';
import 'game.dart';
import 'package:audioplayers/audioplayers.dart';
import 'tile_widget.dart';
import 'flutter_2048_widget.dart';
import 'menu_screen.dart';
import 'about_screen.dart';

// https://github.com/anuranBarman/2048

void main() {
  runApp(MaterialApp(
    // home: Flutter2048(),
    // home: MenuScreen(),
    initialRoute: '/',
    routes: {
      '/': (context) => MenuScreen(),
      '/game': (context) => Flutter2048(),
      // '/settings': (context) => SettingsScreen(),
      '/about': (context) => AboutScreen(),
    },
    debugShowCheckedModeBanner: false,
  ));
}

class Flutter2048 extends StatefulWidget {
  @override
  Flutter2048State createState() => Flutter2048State();
}
