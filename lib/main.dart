import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LoLoPedia',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List champs = [];
  
  @override
  void initState() {
    super.initState();
    getChamps();
  }

  Future<void> getChamps() async {
    final response =
        await http.get(Uri.parse('https://ddragon.leagueoflegends.com/cdn/14.2.1/data/en_US/champion.json'));

    if (response.statusCode == 200) {
      setState(() {
        champs = jsonDecode(response.body)['data'].keys.toList();
      });
    } 
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Champions'),
      ),
      body: ListView.builder(
        itemCount: champs.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(champs[index]),
          );
        },
      ),
    );
  }
}