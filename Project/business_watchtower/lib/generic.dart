import 'dart:convert';
import 'dart:core';
import 'dart:ui';

import 'prefs.dart';
import 'main.dart';
import 'fancy_fab.dart';
import 'diagonal_clipper.dart';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;


Future<Map> getDataFromApi(String apiUrl) async {
  // Make a HTTP GET request to the CoinMarketCap API.
  Map map = new Map();
  try {
    // Await basically pauses execution until the get() function returns a HTTP Response
    http.Response response = await http.get(apiUrl);
    // Using the JSON class to decode the JSON String
    var temp = json.decode(response.body);
    // Check type of response and cast it into a map object
    if (temp is List) {
      map = temp.asMap();
    } else {
      map = temp;
    }
  } catch (e) {
    print(e);
  }
  return map;
}

class GenericListWidget extends StatefulWidget {

  final Map mapping;
  final String appTitle;
  final List<String> favorites;

  // Constructor in Dart
  GenericListWidget(this.mapping, this.appTitle, this.favorites);

  @override
  GenericListWidgetState createState() => GenericListWidgetState(mapping, appTitle, favorites);
  }

class GenericListWidgetState extends State<GenericListWidget> {

  bool _isLoading = false;
  final List<MaterialColor> colors = [Colors.blue, Colors.indigo, Colors.red];

  Map mapping;
  String appTitle;
  List<String> favorites;

  // Constructor in Dart
  GenericListWidgetState(this.mapping, this.appTitle, this.favorites);

  void changeState(Map map) {
    setState(() {
      mapping = map;
    build(this.context);
    });
  }

  void changeFavoriteState(String _symbol) {
    print("change favorite state " + favorites.toString());
    addToFavorites(_symbol, context).then((saved) {
      getFavorites().then((favs) {
        print("change favorite state " + favorites.toString());
        print("change favorite state " + favs.toString());
        // If we need to rebuild the widget with the resulting data,
        // make sure to use `setState`
        setState(() {
          favorites = favs;
          build(this.context);
        });
      });
    });
  }

  void _getStuff(String choice, BuildContext context) async {
    // Every time this method is called, the state is set and stateful widget and it's children will be re-rendered
    setState(() {
      _isLoading = true;
    });
    _isLoading = await navigate(context, choice);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF25233f),
        body: Stack(
          children:<Widget>[
            buildImage(),
            buildBody(context),
            getAppTitleWidget(context)
            //_
          ],
        ),
    );
  }



  Widget buildBody(BuildContext context) {
    if (!_isLoading) {
      return  Container(
        margin: const EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 0.0),
        //decoration: BoxDecoration(color: Colors.black.withOpacity(0.6)),
        child: Stack(
            children: <Widget>[
              Container(
                  margin: const EdgeInsets.fromLTRB(0.0, 80.0, 0.0, 70.0),
                  child: Column(children: <Widget>[
                getListViewWidget(context)])),
              _buildFab()
            ]),

      );
    }
    // If state is set to loading, show user the loading animation
    else {
      return Container(
          alignment: Alignment(-0.05, 0.05),
          child: CircularProgressIndicator(
              strokeWidth: 25.0,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.amberAccent)));
    }
  }

  Widget getAppTitleWidget(BuildContext context){
    return Container(
        margin: const EdgeInsets.fromLTRB(8.0, 20.0, 8.0, 0.0),
        child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[Text(
    appTitle,
    style: TextStyle(
    color: Colors.white.withOpacity(0.8),
    fontWeight: FontWeight.bold,
    fontSize: 36.0
    )
    )]));
  }

  // List that shows values
  Widget getListViewWidget(BuildContext context) {
 return ListWidget();
  }

  // Nice circle to make list more appealing
  CircleAvatar getLeadingWidget(String name, int length, MaterialColor color) {
    return CircleAvatar(backgroundColor: color, maxRadius: 32.0, child: Text(name.substring(0, length)));
  }

  // Title of a given value
  Text getTitleWidget(String entryName) {
    return Text(entryName,
        style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
            color: Colors.white.withOpacity(0.9)));
  }

  // More info of a given value
  Text getSubtitleWidget(var price, var percentChange) {
    String change = (percentChange).toStringAsFixed(4);
    return Text('\$$price\nDaily change: $change%',
        style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 18));
  }

  // ListTile is one tile in a list, every set of values is shown as it's own tile
  ListTile getListTile(Map data, MaterialColor color) {
    String imagePath =  "assets/this_is_not_important.png";
    if(favorites != null) {
      if (favorites.contains(data['symbol'])) {
        imagePath = "assets/this_is_important.png";
      }
    }
    int nameLength = 3;
    if(data['companyName'].length < nameLength){
      nameLength = data['companyName'].length;
    }
    return ListTile(
        leading: getLeadingWidget(data['companyName'], nameLength, color),
        title: getTitleWidget(data['companyName']),
        subtitle: getSubtitleWidget(
            data['latestPrice'], data['changePercent']),
        trailing: GestureDetector(
          onTap: () => changeFavoriteState(data['symbol']),
          child:  Image(
              image: AssetImage(imagePath),
              width: 50),
        ),
        isThreeLine: true);
  }

  // Make the tiles visually separate from each other
  Container getListItemWidget(Map data, MaterialColor color, BuildContext context) {
    // Returns a container widget that has a card child and a top margin of 5.0
    return Container(
        child: Card(
          color: Color(0xFF69668c).withOpacity(0.7),
          elevation: 6.0,
          child: Container(
            padding: EdgeInsets.fromLTRB(0.0, 5.0, 0.0, 5.0),
            child: getListTile(data, color),
          )
        ));
  }

  //these are used to update main menu on return
  Future<bool> _onWillPop(){
    Navigator.pop(context);
  }

  WillPopScope getWillPopScope(){
    return new WillPopScope(child: null,
        onWillPop: _onWillPop);
  }

  Widget _buildFab(){
    final Map<String, Function()> funcMapping = {STOCKS: () => _getStuff(STOCKS, context), CURRENCIES: () => _getStuff(CURRENCIES, context), CRYPTO: () => _getStuff(CRYPTO, context)};
    final Map<String, String> tooltipsMapping = {STOCKS: STOCKS, CURRENCIES: CURRENCIES, CRYPTO: CRYPTO};
    final Map<String, Icon> iconsMapping = {STOCKS: Icon(Icons.show_chart), CURRENCIES: Icon(Icons.euro_symbol), CRYPTO: Icon(Icons.lock_outline)};
    return Container(
        padding: new EdgeInsets.only(bottom: 8.0),
        alignment: Alignment(0.0, 0.0),
        child: new FancyFab(onPressed: funcMapping, tooltips: tooltipsMapping, icons: iconsMapping)
    );
  }
}

Future<bool> addToFavorites(String _symbol, BuildContext context) async{
  Prefs prefs = new Prefs();
  bool added = await prefs.addToFavorites(_symbol);
  print("context: " +  Navigator.defaultRouteName.toString());
  //ListWidget.of(context).changeFavoriteState();
  return added;
}

Future<List<String>> getFavorites () async{
  Prefs prefs = new Prefs();
  List<String> _favorites = await prefs.getFavorites();
  return _favorites;
}
