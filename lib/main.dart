import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';

String currentVersion = '14.12.1';
Future<void> updateApiUrl() async {
  try {
    final response = await http.get(Uri.parse('https://ddragon.leagueoflegends.com/api/versions.json'));
    if (response.statusCode == 200) {
      List versions = jsonDecode(response.body);
      currentVersion = versions[0];
    }
  } catch (e) {
    print('Failed to fetch latest version: $e');
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await updateApiUrl();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LoLoPedia',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

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
    final response = await http.get(Uri.parse(
        'https://ddragon.leagueoflegends.com/cdn/$currentVersion/data/en_US/champion.json'));

    if (response.statusCode == 200) {
      setState(() {
        champs = jsonDecode(response.body)['data'].keys.toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    List filteredChamps = champs
        .where((champ) => champ.toLowerCase().contains(filter.toLowerCase()))
        .toList();
    return Scaffold(
      appBar: AppBar(
        title: const Text('LoLoPedia'),
      ),
      body: Center(
        child: SizedBox(
          width: ScreenUtil.calculateMaxWidth(context),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(8),
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
                          imageUrl:
                              "https://ddragon.leagueoflegends.com/cdn/$currentVersion/img/champion/${filteredChamps[index]}.png",
                          placeholder: (context, url) =>
                              const CircularProgressIndicator(),
                          errorWidget: (context, url, error) =>
                              const Icon(Icons.error),
                        ),
                        title: Text(filteredChamps[index]),
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => DetailPage(
                                      champ: filteredChamps[index])));
                        },
                      );
                    }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DetailPage extends StatelessWidget {
  final String champ;

  const DetailPage({super.key, required this.champ});

  Future<Map> getChampDetails() async {
    final response = await http.get(Uri.parse(
        'https://ddragon.leagueoflegends.com/cdn/$currentVersion/data/en_US/champion/$champ.json'));
    return jsonDecode(response.body)['data'][champ];
  }

  @override
  Widget build(BuildContext context) {
    double maxWidth = ScreenUtil.calculateMaxWidth(context);
    return Scaffold(
      body: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          Center(
            child: SizedBox(
              width: maxWidth,
              child: FutureBuilder<Map>(
                future: getChampDetails(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    Map data = snapshot.data as Map;
                    return Column(
                      children: [
                        // Image scrolls
                        ClipRect(
                            child: AspectRatio(
                          aspectRatio: 3 / 2,
                          child: Image.network(
                              "https://ddragon.leagueoflegends.com/cdn/img/champion/splash/${champ}_0.jpg",
                              height: 300,
                              width: maxWidth,
                              fit: BoxFit.cover),
                        )),

                        // Title & Tags underneath image
                        Container(
                            padding: const EdgeInsets.all(10),
                            child: Column(children: [
                              Text(data['name'],
                                  style: const TextStyle(
                                      fontSize: 48,
                                      fontWeight: FontWeight.bold)),
                              Wrap(
                                spacing: 10,
                                children: data['tags'].map<Widget>((tag) {
                                  return Chip(label: Text(tag));
                                }).toList(),
                              )
                            ])),

                        // Lore
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 10),
                          child: Text(data['lore'],
                              style: const TextStyle(fontSize: 18)),
                        ),

                        const SizedBox(height: 20),

                        // Spells
                        SpellSection(
                            spells: data['spells'], passive: data['passive'])
                      ],
                    );
                  } else {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                },
              ),
            ),
          )
        ],
      ),
    );
  }
}

class SpellSection extends StatelessWidget {
  final List spells;
  final Map passive;

  const SpellSection({super.key, required this.spells, required this.passive});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          leading: Image.network(
            "https://ddragon.leagueoflegends.com/cdn/$currentVersion/img/passive/${passive['image']['full']}",
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return const CircularProgressIndicator();
            },
          ),
          title: Text("(P) ${passive['name']}"),
          subtitle: Text(passive['description']),
        ),
        ...spells.map((spell) {
          int spellIndex = spells.indexOf(spell);
          String spellKey = "";
          switch (spellIndex) {
            case 0:
              spellKey = "Q";
              break;
            case 1:
              spellKey = "W";
              break;
            case 2:
              spellKey = "E";
              break;
            case 3:
              spellKey = "R";
              break;
          }

          return ListTile(
            leading: Image.network(
              "https://ddragon.leagueoflegends.com/cdn/$currentVersion/img/spell/${spell['id']}.png",
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return const CircularProgressIndicator();
              },
            ),
            title: Text("($spellKey) ${spell['name']}"),
            subtitle: Text(spell['description']),
          );
        })
      ],
    );
  }
}

class ScreenUtil {
  static double calculateMaxWidth(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    bool isFullScreen = MediaQuery.of(context).viewInsets.bottom == 0.0;

    double maxWidth = screenSize.width;
    if (isFullScreen) {
      maxWidth = 800.0; // Adjust this value to your desired width
    }

    return maxWidth;
  }
}
