import 'package:alleymap_app/screen/alleyExplorationScreen.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';


void main() {

  // 안하면 또 잔소리 1.22.1
  WidgetsFlutterBinding.ensureInitialized();
  GestureBinding.instance.resamplingEnabled = true;
  //

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: AlleyExplortionScreen(),
    );
  }
}

