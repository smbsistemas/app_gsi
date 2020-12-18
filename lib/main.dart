import 'package:flutter/material.dart';
import 'package:rgti_gsi/screens/main_menu.dart';

//import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

void main() => runApp(StartApp());

class StartApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "RGTI",
      home: MainMenu(),
    );
  }
}

Future<File> _getFile() async {
  final directory = await getApplicationDocumentsDirectory();
  return File("${directory.path}/datasgiuser.json");
}

Future<String> _readData() async {
  try {
    final file = await _getFile();
    return file.readAsString();
  } catch (e) {
    return null;
  }
}
