import 'dart:core';

import 'package:flutter/material.dart';

import 'generic.dart';
import 'stockinfo.dart';
import 'drawChart.dart';
import 'prefs.dart';
import 'search.dart';


Future<String> getSavedStocks() async {
  String _symbols = "";
  Prefs preferences = new Prefs();
  List<String> _savedStocks = List<String>();
  _savedStocks = await preferences.getStoredStocks();

  if (_savedStocks != null) {
    for (String symbol in _savedStocks) {
      if (_symbols == "") {
        _symbols = symbol;
      }
      else {
        _symbols += "," + symbol;
      }
    }
  }
  return _symbols;
}

class StockListWidget extends GenericListWidget {

  StockListWidget(mapping, appTitle, favorites) : super(mapping, appTitle, favorites);

  @override
  GenericListWidgetState createState() => StockListWidgetState(mapping, appTitle, favorites);
}


class StockListWidgetState extends GenericListWidgetState {
  bool _isLoading = false;
  StockListWidgetState(mapping, appTitle, favorites) : super(mapping, appTitle, favorites);

  void _getSearchables() async {
    // Every time this method is called, the state is set and stateful widget and it's children will be re-rendered
    setState(() {
      _isLoading = true;
    });
    _isLoading = await startSearch(context, this);
  }

  void _purge() async {
    await startPurge();
    String url = 'https://api.iextrading.com/1.0/stock/market/quote/batch?symbols=tsla&filter=symbol,companyName,latestPrice,changePercent';
    Map valueMappings = await getDataFromApi(url);
    setState(() {
      mapping = valueMappings;
      build(this.context);
    });
  }

  void _showDeleteDialog (String _symbol, String _name, BuildContext context) {
    print("show dialog " + context.toString());
    showDialog(
        context: context,
        builder: (BuildContext bContext) {
          return AlertDialog(
              title: new Text("Warning"),
              content: new Text("Do you want to delete " + _name + "?"),
              actions: <Widget>[
                new FlatButton(
                    child: new Text("Delete"),
                    onPressed: () {
                      _deleteStock(_symbol, context);
                      Navigator.of(bContext).pop();
                    }
                ),
                new FlatButton(
                    child: new Text("Cancel"),
                    onPressed: () {
                      Navigator.of(bContext).pop();
                    }
                )
              ]
          );
        });
  }

  void _deleteStock(String _symbol, BuildContext context) async {
    print("delete " + context.toString());
    Prefs prefs = new Prefs();
    bool _deleted = await prefs.deleteStock(_symbol);

    if (_deleted) {
      String searches = "";
      searches = await getSavedStocks();
      if (searches == "") {
        searches = "tsla";
      }
      String url = 'https://api.iextrading.com/1.0/stock/market/quote/batch?symbols=' +
          searches + '&filter=symbol,companyName,latestPrice,changePercent';
      Map valueMappings = await getDataFromApi(url);
      setState(() {
        mapping = valueMappings;
        build(this.context);
      });
    }
  }

  @override
  Widget getAppTitleWidget(BuildContext context){
    return Container(
        margin: const EdgeInsets.fromLTRB(0.0, 20.0, 0.0, 0.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            GestureDetector(
              onTap: () => _purge(),
              child: Container(
                padding: EdgeInsets.only(right:20),
                child: Icon(
                    Icons.delete,
                    color: Colors.white.withOpacity(0.8)
                ),
              ),
            ),
            Text(
                appTitle,
                style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontWeight: FontWeight.bold,
                    fontSize: 36.0
                )
            ),
            GestureDetector(
              onTap: () => _getSearchables(),
              child: Container(
                padding: EdgeInsets.only(left:20),
                child: Icon(
                    Icons.search,
                    color: Colors.white.withOpacity(0.8)
                ),
              ),
            ),
          ],
        )
    );
  }

  @override
  Widget getListViewWidget(BuildContext context) {
    // We want the ListView to have the flexibility to expand to fill the
    // available space in the vertical axis
    if (!_isLoading) {
      return Flexible(
          child: ListView.builder(
            // The number of items to show
              itemCount: mapping.length,
              // Callback that should return ListView children
              // The index parameter = 0...(itemCount-1)
              itemBuilder: (context, index) {
                // Get the icon color. Since x mod y, will always be less than y,
                // this will be within bounds
                final MaterialColor color = colors[index % colors.length];

                return getListItemWidget(mapping[index], color, context);
              }));
    }
    // If state is set to loading, show user the loading animation
    else {
      return Container(
          margin: const EdgeInsets.only(top: 275.0),
          alignment: Alignment(-0.05, 0.05),
          child: CircularProgressIndicator(
              strokeWidth: 25.0,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.amberAccent)));
    }
  }

  // Make the tiles visually separate from each other
  @override
  Container getListItemWidget(
      Map data, MaterialColor color, BuildContext context) {
    print("stockwidgetstate " + this.toString());
    // Returns a container widget that has a card child and a top margin of 5.0
    return Container(
        margin: const EdgeInsets.only(top: 5.0),
        child: GestureDetector(
            onTap: () => getStockData(data['symbol'], context),
            onLongPress: () => _showDeleteDialog(data['symbol'], data['companyName'], context),
            child: Card(
                color: Colors.deepPurple[800].withOpacity(.7),
                elevation: 6.0,
                child: getListTile(data, color))));
  }

}

// This is called on user tapping one of the stock tiles, WIP
void getStockData(String companySymbol, BuildContext context) async {
  Map<String, dynamic> stockData = await getStockInfo(companySymbol);

  Map chartData = await getStockChartData(companySymbol);
  List<TimeSeriesSales> chartSeries = [];

  chartData.forEach((k, v) =>
      chartSeries.add(new TimeSeriesSales(new DateTime(DateTime.parse(v['date']).year,DateTime.parse(v['date']).month,DateTime.parse(v['date']).day), v['high'].toDouble())));
  print(chartData.toString());

  Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) =>
              StockDataWidget(stockData[companySymbol]['quote'], chartSeries)));
}


Future<bool> startSearch(BuildContext context, GenericListWidgetState state) async{
  List _stockData = await getStockNames();
  print(_stockData);
  print("calling iteration");

  Map<String,String> _stockSymbols = new Map<String,String>();

  List<String> names = new List<String>();
  //List<String> stockSymbols = new List<String>();
  for (Map listValues in _stockData) {
    names.add(listValues['name']);
    _stockSymbols[listValues['name']] = listValues['symbol'];
  }
  print(_stockSymbols.toString());

  Prefs prefs = new Prefs();
  bool _hasStored = await prefs.storeStocksMap(_stockSymbols);

  if(_hasStored) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => SearchPage(names, state)));
  }
  return false;
}

Future<bool> startPurge() async{
  Prefs prefs = new Prefs();
  bool purged = await prefs.purge();
  if (purged) {
    print("purged");
  }
  return false;
}
