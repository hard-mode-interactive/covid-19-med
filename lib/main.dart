


import 'package:coronavirusmed/root.dart';
import 'package:flutter/material.dart';
import 'services/auth.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(new MyApp());
}

class MyApp extends StatelessWidget {
final BaseAuth auth = new Auth();

  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'COVID-19 MED',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: RootPage(auth: auth,)
    );
  }
}

