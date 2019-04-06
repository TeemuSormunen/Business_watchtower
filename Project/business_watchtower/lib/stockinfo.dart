import 'dart:async';
import 'dart:convert';
import 'dart:core';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'drawChart.dart';
import 'diagonal_clipper.dart';

Future<Map> getStockInfo(String companySymbol) async {
  String apiUrl = 'https://api.iextrading.com/1.0/stock/market/batch?symbols=' +
      companySymbol +
      '&types=quote';
  // Make a HTTP GET request to the API.
  Map map = new Map();
  try {
    // Await basically pauses execution until the get() function returns a Response
    http.Response response = await http.get(apiUrl);
    //decode the json to map
    map = json.decode(response.body);
  } catch (e) {
    print(e);
  }
  return map;
}

class StockDataWidget extends StatelessWidget {
  // This is a list of material colors. Feel free to add more colors, it won't break the code
  final List<MaterialColor> _colors = [Colors.blue, Colors.indigo, Colors.red];

  // The underscore before a variable name marks it as a private variable
  final Map _stockData;

  final List<TimeSeriesSales> tsData;
  final bool animate;

  // This is a constructor in Dart. We are assigning the value passed to the constructor
  // to the _currencies variable
  StockDataWidget(this._stockData, this.tsData, {this.animate});

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      backgroundColor: Color(0xFF25233f),
      body:Stack(
        children: <Widget>[
          _buildImage(),
          _buildBody(context),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    return new Container(
        margin: const EdgeInsets.fromLTRB(8.0, 30.0, 8.0, 10.0),
            child: new Column(
              // A column widget can have several widgets that are placed in a top down fashion
              children: <Widget>[
                _getAppTitleWidget(_stockData['companyName']),
                _getAppTitleWidget("2 year change"),
                SimpleTimeSeriesChart(tsData),
                _getAppTitleWidget("General info"),
                _getListViewWidget(),
              ],
           )
    );
   }

  Widget _buildImage(){
    return new ClipPath(
        clipper: new DiagonalClipper(),
        child: new Image.asset(
          'assets/logo.png',
          fit: BoxFit.fitHeight,
          height: 420.0,
          width: 1200.0,
          //colorBlendMode: BlendMode.srcOver,
          //color:  new Color.fromARGB(120, 20, 10, 40),
        )
    );
  }

//Text on the top of the screen
  Widget _getAppTitleWidget(String text) {
    return new Text(
      //show the chosen company's name as a title
      text,
      style: new TextStyle(
          color: Colors.white.withOpacity(0.8),
          fontWeight: FontWeight.bold,
          fontSize: 24.0),
    );
  }

  //List that shows all the available data on the selected stock
  Widget _getListViewWidget() {
    // We want the ListView to have the flexibility to expand to fill the
    // available space in the vertical axis
    return new Flexible(
        child: new Container(
            margin: const EdgeInsets.only(top: 20.0),
            child: new Container(
                color: Color(0xFF69668c).withOpacity(0.7),
                child: new ListView.builder(

                  // The number of items to show
                    itemCount: _stockData.length,
                    // Callback that should return ListView children
                    // The index parameter = 0...(itemCount-1)
                    itemBuilder: (context, index) {
                      // Get the currency at this position
                      var keys = _stockData.keys.toList();
                      String key = keys[index].toString();
                      String stockValue = _stockData[keys[index]].toString();
                      String keyValue =
                          key.substring(0, 1).toUpperCase() + key.substring(1);

                      // Get the icon color. Since x mod y, will always be less than y,
                      // this will be within bounds
                      final MaterialColor color =
                      _colors[index % _colors.length];

                      return _getListItemWidget(keyValue, stockValue, color);
                    }))));
  }

// key is the name of the info, for example sector, and value is the value for that, for example Technology
  Text _getTitleWidget(String key, String stockValue) {
    return new Text(
        key + ": " + stockValue,
        style: new TextStyle(
            fontWeight: FontWeight.bold, color: Colors.white.withOpacity(0.9)
        )
    );
  }

  ListTile _getListTile(String key, String stockValue, MaterialColor color) {
    return new ListTile(title: _getTitleWidget(key, stockValue));
  }

  // each line is basically it's own tile
  Container _getListItemWidget(
      String key, String stockValue, MaterialColor color) {
    // Returns a container widget that has a card child and a top margin of 5.0
    if (stockValue != "null") {
      return new Container(
          margin: const EdgeInsets.only(top: 5.0),
          child: _getListTile(key, stockValue, color)
      );
    }
    return new Container();
  }
}
