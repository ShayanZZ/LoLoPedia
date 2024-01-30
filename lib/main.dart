import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';

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
  
  String filter = "";

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

    List filteredChamps = champs.where((champ) => 
      champ.toLowerCase().contains(filter.toLowerCase())).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('LoLoPedia'),
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(8),
            child: TextFormField(
              onChanged: (value) {
                setState(() {
                  filter = value; 
                });
              },
            ),
          ),
                    Expanded(
            child: ListView.builder(
              itemCount: filteredChamps.length,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: CachedNetworkImage(
                    imageUrl: "http://ddragon.leagueoflegends.com/cdn/14.2.1/img/champion/${filteredChamps[index]}.png",
                    placeholder: (context, url) => CircularProgressIndicator(),
                    errorWidget: (context, url, error) => Icon(Icons.error),
                  ),
                  title: Text(filteredChamps[index]),
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(
                      builder: (context) => DetailPage(champ: filteredChamps[index])));
                  },
                );
              }  
            ),
          ),
        ],
      ),
    );
  }
}

class DetailPage extends StatelessWidget {

  final String champ;
  
  DetailPage({required this.champ});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(champ)),
      body: Center(child: Text('Champ details here!')), 
    );
  }
}