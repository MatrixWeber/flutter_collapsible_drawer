import 'dart:io';

import 'package:flutter/material.dart';
import 'package:window_size/window_size.dart';

List<String> stringList = <String>[];
String resultList = '';
Map<String, int> buttonMap = {};

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    setWindowTitle('Flutter Jtagconfig');
    setWindowMaxSize(const Size(1920, 1080));
    setWindowMinSize(const Size(1920, 1080));
  }

  List<String> resultStringList = <String>[];
  var result = await Process.run(
      '/media/nvme1TB/workspace/pluscontrol_master_merge/test_management/scripts/jtagconfig.py',
      ['-h']);

  // List<String> endResultStringList = <String>[];
  if (result.stdout.toString().contains('Rack name:')) {
    resultStringList = result.stdout.toString().split('Rack name:');
  }
  var newList = resultStringList[1]
      .split('=')
      .toString()
      .split('\n')
      .toString()
      .split(',');
  for (var element = 0; element < newList.length; ++element) {
    if (element % 2 == 1) {
      if (newList[element].contains(']]')) {
        continue;
      }
      stringList.add(newList[element].trim());
    }
  }

  result = await Process.run(
      '/media/nvme1TB/workspace/pluscontrol_master_merge/test_management/scripts/jtagconfig.py',
      []);

  resultList = result.stdout;

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Jtagconfig',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter JtagConfig'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  void _incrementCounter(var stdout) {
    setState(() {
      resultList = stdout.toString().trim();
    });
  }

  List<Widget> createButtons(List<String> stringList) {
    List<Widget> widgetList = <Widget>[];
    var counter = 0;
    for (var element in stringList) {
      widgetList.add(
        ElevatedButton(
            style: const ButtonStyle(
                fixedSize: MaterialStatePropertyAll<Size>(Size.fromWidth(100)),
                backgroundColor: MaterialStatePropertyAll<Color>(Colors.green)),
            onPressed: () async {
              var result = await Process.run(
                  '/media/nvme1TB/workspace/pluscontrol_master_merge/test_management/scripts/jtagconfig.py',
                  ['-r', element]);
              _incrementCounter(result.stdout);
            },
            child:
                Text(style: const TextStyle(fontSize: 16.0), element.trim())),
      );
      widgetList.add(const Padding(padding: EdgeInsets.only(bottom: 10.0)));
      buttonMap[element] = counter++;
    }
    List<Widget> columnList = <Widget>[];
    columnList.add(
      Column(
        children: widgetList,
      ),
    );
    columnList.add(const Padding(padding: EdgeInsets.only(right: 100)));
    columnList.addAll(createListView(resultList));
    return columnList;
  }

  List<Widget> createListView(String stringList) {
    List<Widget> widget = <Widget>[];
    if (stringList.isNotEmpty) {
      widget.add(
        Text(
            style: const TextStyle(fontSize: 16.0, color: Colors.blueAccent),
            stringList),
      );
    } else {
      widget.add(const Text(
          style: TextStyle(fontSize: 16.0, color: Colors.red),
          'No Jtag available'));
    }
    return widget;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: createButtons(stringList),
      ),
    );
  }
}
