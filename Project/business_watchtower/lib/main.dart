import 'dart:async';
import 'dart:core';
import 'dart:ui';

import 'package:flutter/material.dart';

import 'crypto.dart';
import 'currency.dart';
import 'generic.dart';
import 'stock.dart';
import 'fancy_fab.dart';
import 'diagonal_clipper.dart';


const String CRYPTO = "Cryptocurrencies";
const String STOCKS = "Stocks";
const String CURRENCIES = "Currencies";
const String APP_TITLE = "Business Watchtower";

const List<String> API_LIST = ['https://api.coinmarketcap.com/v1/ticker/?convert=EUR&limit=50',
                              'https://api.exchangeratesapi.io/latest'];

Map favorites;

void main() async{
  favorites = await getFavoriteStocks();
  print(favorites);
  runApp(BusinessWatchtower());
}
class BusinessWatchtower extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: MainMenu());
  }
}

class MainMenu extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final title = APP_TITLE;

    return MaterialApp(
      title: title,
        theme: ThemeData(fontFamily: 'Slabo27px', ),
        home: Scaffold(
          appBar: AppBar(title: Text(APP_TITLE),
          backgroundColor: Color(0xFF25233f).withOpacity(0.99)),
            backgroundColor: Color(0xFF25233f),
            body: Stack(
              children: <Widget>[
                buildImage(),
                ListWidget()
            ]
        )
      )
    );
  }
}


// Using stateful widget because state changes when user taps some of the list items
class ListWidget extends StatefulWidget {
  static StartListWidgetState of(BuildContext context) => context.ancestorStateOfType(const TypeMatcher<StartListWidgetState>());
  // Creating state for stateful widget
  @override
  StartListWidgetState createState() => StartListWidgetState();
}

class StartListWidgetState extends State<ListWidget> {
  final List<MaterialColor> colors = [Colors.blue, Colors.indigo, Colors.red];
  bool _isLoading = false;
  // Async because we don't want the user to think the app has frozen while retrieving data
  void _getStuff(String choice, BuildContext context) async {
    // Every time this method is called, the state is set and stateful widget and it's children will be re-rendered
    setState(() {
      _isLoading = true;
    });
    _isLoading = await navigate(context, choice);
    changeFavoriteState();
  }

  void _showDeleteDialog (String _symbol, String _name, BuildContext context) {
    print("show dialog " + context.toString());
    showDialog(
        context: context,
        builder: (BuildContext bContext) {
          return AlertDialog(
              title: new Text("Warning"),
              content: new Text("Do you want to delete " + _name + " from favorites?"),
              actions: <Widget>[
                new FlatButton(
                    child: new Text("Delete"),
                    onPressed: () {
                      addToFavorites(_symbol, context);
                      changeFavoriteState();
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


  void changeFavoriteState() {
    print("change favorite state " + favorites.toString());
   // addToFavorites(_symbol).then((saved) {
      getFavoriteStocks().then((favs) {
        // If we need to rebuild the widget with the resulting data,
        // make sure to use `setState`
        setState(() {
          favorites = favs;
          build(this.context);
        });
      });
  //  });
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

  @override
  Widget build(BuildContext context) {
    // If the state isn't set to loading, show user the the list view
    if (!_isLoading) {
      return  Container(
        margin: const EdgeInsets.fromLTRB(8.0, 20.0, 8.0, 0.0),
        //decoration: BoxDecoration(color: Colors.black.withOpacity(0.6)),
        child: Stack(
          children: <Widget>[
            Column(children: <Widget>[
              getListViewWidget()]),
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



  //copied from generic

  Widget getListViewWidget() {
    // We want the ListView to have the flexibility to expand to fill the
    // available space in the vertical axis
    return Flexible(
        child: ListView.builder(
          // The number of items to show
            itemCount: favorites.length,
            // Callback that should return ListView children
            // The index parameter = 0...(itemCount-1)
            itemBuilder: (context, index) {
              // Get the icon color. Since x mod y, will always be less than y,
              // this will be within bounds
              final MaterialColor color = colors[index % colors.length];

              return getListItemWidget(favorites[index], color, context);
            }));
  }

  // Nice circle to make list more appealing
  CircleAvatar getLeadingWidget(String name, int length, MaterialColor color) {
    return CircleAvatar(backgroundColor: color, maxRadius: 25.0, child: Text(name.substring(0, length)));
  }

  // Title of a given value
  Text getTitleWidget(String entryName) {
    return Text(entryName,
        style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
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
    int nameLength = 3;
    if(data['companyName'].length < nameLength){
      nameLength = data['companyName'].length;
    }
    return ListTile(
        leading: getLeadingWidget(data['companyName'], nameLength, color),
        title: getTitleWidget(data['companyName']),
        subtitle: getSubtitleWidget(
            data['latestPrice'], data['changePercent']),
        isThreeLine: true);
  }

  // Make the tiles visually separate from each other
  Container getListItemWidget(
      Map data, MaterialColor color, BuildContext context) {
    print("stockwidgetstate " + this.toString());
    // Returns a container widget that has a card child and a top margin of 5.0
    return Container(
      color: Colors.amber,
        margin: const EdgeInsets.fromLTRB(8.0, 10.0, 8.0, 10.0),
        child: Container(
          child: Column(
            children: <Widget>[
              GestureDetector(
                  onTap: () => getStockData(data['symbol'], context),
                  onLongPress: () => _showDeleteDialog(data['symbol'], data['companyName'], context),
                  child: Card(
                      color: Color(0xFF69668c).withOpacity(0.7),
                      elevation: 6.0,
                      child: getListTile(data, color))),
            ],
          ),
        ));
  }
}

Widget buildImage(){
  return new ClipPath(
      clipper: new DiagonalClipper(),
      child: new Image.asset(
        'assets/logo.png',
        fit: BoxFit.fitHeight,
        height: 420.0,
        width: 1200.0,
        colorBlendMode: BlendMode.srcOver,
        color:  new Color.fromARGB(120, 20, 10, 40),
      )
  );
}


Future<bool> navigate(BuildContext context, String choice) async {
  /* Function to handle getting data from APIs
   * Depending on what the user wants to see, data is retrieved from the APIs and sent
   * to specific classes to show said data to user */
  /* Navigator is used to change views and it works as a stack
   * Every new view is pushed to the top and when user wants to return, the view on the top is pushed away
   * Navigator needs BuildContext, so that's why we need to send it around as a parameter */

  Map valueMappings;

  switch (choice) {
    case CRYPTO:
      {
        valueMappings = await getDataFromApi(
            API_LIST[0]);

        List<String> favorites = await getFavorites();

        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => CryptoListWidget(valueMappings, choice, favorites)));
        return false;
      }

    case STOCKS:
      {
        String searches = "";
        searches = await getSavedStocks();
        if(searches == "") {
          searches = "tsla";
        }
        String url = 'https://api.iextrading.com/1.0/stock/market/quote/batch?symbols=' + searches + '&filter=symbol,companyName,latestPrice,changePercent';
        valueMappings = await getDataFromApi(url);
        List<String> favorites = await getFavorites();

       await Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => StockListWidget(valueMappings, choice, favorites)));
       print(context);

        return false;
      }

    case CURRENCIES:
      {
        valueMappings = await getDataFromApi(
            API_LIST[1]);

        Map currencySymbols = await loadAsset('assets/Common-Currency.json');

        List<String> favorites = await getFavorites();

        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => CurrencyListWidget(
                    valueMappings, currencySymbols, choice, favorites)));
        return false;
      }

    default:
      {
        // If for some reason, no case gets activated, default to showing main menu
        MainMenu();
        return false;
      }
  }
}

//bit ugly, but shows tesla stock as a placeholder if there's no favorites stored
//TODO make this better
Future<Map> getFavoriteStocks() async{
  String _symbols = "";
  List<String> _favorites = List<String>();
  _favorites = await getFavorites();

  if (_favorites != null) {
    for (String symbol in _favorites) {
      if (_symbols == "") {
        _symbols = symbol;
      }
      else {
        _symbols += "," + symbol;
      }
    }
  }
  if(_symbols == "") {
    _symbols = "tsla";
  }
  Map stockMappings;
  String url = 'https://api.iextrading.com/1.0/stock/market/quote/batch?symbols=' + _symbols + '&filter=symbol,companyName,latestPrice,changePercent';
  stockMappings = await getDataFromApi(url);

  return stockMappings;
}

