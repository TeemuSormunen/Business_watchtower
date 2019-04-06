import 'package:autocomplete_textfield/autocomplete_textfield.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'main.dart';
import 'prefs.dart';
import 'stock.dart';
import 'generic.dart';
import 'diagonal_clipper.dart';
import 'package:http/http.dart' as http;


Future<List> getStockNames() async {
  String apiUrl = 'https://api.iextrading.com/1.0/ref-data/symbols';
  // Make a HTTP GET request to the API.
  List list = new List();
  try {
    // Await basically pauses execution until the get() function returns a Response
    http.Response response = await http.get(apiUrl);
    list = json.decode(response.body);
  } catch (e) {
    print(e);
  }

  return list;
}


class SearchPage extends StatefulWidget {
  final List<String> _stockNames;
  final GenericListWidgetState _state;

  // This is a constructor in Dart. We are assigning the value passed to the constructor
  // to the _currencies variable
  SearchPage(this._stockNames, this._state);
  @override
  _SearchPageState createState() => new _SearchPageState(_stockNames, _state);
}

class _SearchPageState extends State<SearchPage> {
  List<String> added = [];
  String currentText = "";

  final List<String> _names;
  final GenericListWidgetState _state;

  _SearchPageState(this._names, this._state);

  GlobalKey<AutoCompleteTextFieldState<String>> key = new GlobalKey();
  AutoCompleteTextField textField;

  @override
  Widget build(BuildContext context) {
 textField = getAutoCompleteTextField();
 Column body = new Column();
 body = getColumn();
 body.children.addAll(added.map((item) {
  return new ListTile(title: new Text(item));
}));
    return new Scaffold(
        backgroundColor: Color(0xFF6B75FF),
        body: Stack(
            children: <Widget>[
              //_buildImage(),
              getAppTitleWidget(context),
              body
              //getTile(test),
            ]
        )
    );

  }

  Widget getColumn () {
    return Column(
        children: [
          new Container(
            margin: EdgeInsets.fromLTRB(0, 60.0, 0, 0),
            child: new Column(
              children: <Widget>[
                new ListTile(
                  title: getAutoCompleteTextField(),
                ),
              ],
            )),

      new RaisedButton(onPressed: () => _saveToPrefs(added, _state, context),
          child: Text("Save"))]);
  }

  Widget getAutoCompleteTextField () {
    return AutoCompleteTextField<String>(
        decoration: new InputDecoration(
          hintText: "Search Item",
          hintStyle: TextStyle(
            //color: Colors.white.withOpacity(0.8),
              fontSize: 26.0
          )
        ),
        key: key,
        submitOnSuggestionTap: true,
        clearOnSubmit: true,
        suggestions: _names,
        textInputAction: TextInputAction.go,
        textChanged: (item) {
          currentText = item;
        },
        itemSubmitted: (item) {
          setState(() {
            currentText = item;
            added.add(currentText);
            print("added.add " + currentText);
            currentText = "";
          });
        },
        itemBuilder: (context, item) {
          return new Padding(
              padding: EdgeInsets.all(8.0), child: new Text(item,));
        },
        itemSorter: (a, b) {
          return a.compareTo(b);
        },
        itemFilter: (item, query) {
          return item.toLowerCase().startsWith(query.toLowerCase());
        });
  }

  Widget getTile(Column body) {
    print("prii");
    body.children.addAll(added.map((item) {
      return new ListTile(title: new Text(item,
      style: TextStyle(
          color: Colors.white.withOpacity(0.8),
          fontSize: 26.0
      )));
    }));
  }

  Widget getAppTitleWidget(BuildContext context){
    return Container(
        margin: const EdgeInsets.fromLTRB(8.0, 20.0, 8.0, 0.0),
        child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[Text(
                "Stock search",
                style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontWeight: FontWeight.bold,
                    fontSize: 36.0
                )
            )]));
  }
}

void _saveToPrefs (List<String> _addedNames, GenericListWidgetState _state, BuildContext context) async {
  print("save pressed");
  List<String> _storableList = new List<String>();
  for(String name in _addedNames) {

    Prefs prefs = new Prefs();
    Map _symbols = await prefs.getStoredStocksMap();

    print(_symbols[name].toString());
    _storableList.add(_symbols[name]);
  }
  Prefs preferences = new Prefs();
  bool saved = await preferences.storeSelectedStocks(_storableList);
  if(saved) {
    print("saved to prefs succesfully");

    String searches = "";
    searches = await getSavedStocks();
    String url = 'https://api.iextrading.com/1.0/stock/market/quote/batch?symbols=' + searches + '&filter=symbol,companyName,latestPrice,changePercent';
    Map valueMappings = await getDataFromApi(url);
    _state.changeState(valueMappings);
    Navigator.pop(context);
  }
}

/* currently not used, because changing font color doesn't work as intended on autoComplete Textfield
Widget _buildImage(){
  return new ClipPath(
      clipper: new HorizontalClipper(),
      child: new Image.asset(
        'assets/logo.png',
        fit: BoxFit.fitHeight,
        height: 420.0,
        width: 1200.0,
        colorBlendMode: BlendMode.srcOver,
        color:  new Color.fromARGB(120, 20, 10, 40),
      )
  );
}*/
