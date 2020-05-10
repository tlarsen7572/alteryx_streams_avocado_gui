import 'dart:convert';

import 'package:flutter/material.dart';
import 'dart:html';
import 'package:http/http.dart';


var url = window.location.href.replaceAll("#\\", "");

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Alteryx Streams Avocados',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Alteryx Streams Avocados!'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var _calc = 0.0;
  var _error = '';
  bool _busy = false;
  var _editor = TextEditingController(text: '');
  static const _availFields = ['[Date]','[AveragePrice]','[Total Volume]','[4046]','[4225]','[4770]','[Total Bags]','[Small Bags]','[Large Bags]','[XLarge Bags]','[type]','[year]','[region]'];

  Future _msgAlteryx() async {
    setState(() {
      _busy = true;
    });
    var response = await post(url, body: _editor.text);
    if (response.statusCode != 200){
      _busy = false;
      _calc = 0;
      setState(()=> _error = 'Error: status ${response.statusCode}');
      return;
    }
    try {
      var decoded = json.decode(response.body);
      _error = decoded['Error'];
      _calc = decoded['Calc'];
      setState(() {
        _busy = false;
      });
    } catch (ex) {
      _error = ex.toString();
      _calc = 0;
      setState(() {
        _busy = false;
      });
    }
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              maxLines: 10,
              controller: _editor,
              style: TextStyle(fontFamily: 'Courier'),
            ),
            Text(
              'Result: $_calc',
            ),
            _error == '' ? Container() : Text(
              _error,
              style: TextStyle(color: Colors.red),
            ),
            RaisedButton(
              onPressed: _busy ? null : () async => await _msgAlteryx(),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text('Query Alteryx'),
                  _busy ? CircularProgressIndicator() : Container(),
                ],
              ),
            ),
            Text("Available fields:"),
            ListView(
              children: _availFields.map((e)=>Text(e)).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
