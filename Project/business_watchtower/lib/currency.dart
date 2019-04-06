import 'dart:async';
import 'dart:convert';
import 'dart:core';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

import 'generic.dart';

// Common currency file contains symbols of different currencies, this is mapped to it's own map
Future<Map> loadAsset(String symbolsFilePath) async {
  String common = await rootBundle.loadString(symbolsFilePath);
  Map curCommon = json.decode(common);
  return curCommon;
}

class CurrencyListWidget extends GenericListWidget {
  final Map _currencyCommon;

  @override
  CurrencyListWidget(mapping, this._currencyCommon, appTitle, favorites)
      : super(mapping, appTitle, favorites);

  @override
  GenericListWidgetState createState() => CurrencyListWidgetState(mapping, _currencyCommon, appTitle, favorites);
}

class CurrencyListWidgetState extends GenericListWidgetState {
  final Map _currencyCommon;

  @override
  CurrencyListWidgetState(mapping, this._currencyCommon, appTitle, favorites)
      : super(mapping, appTitle, favorites);

  @override
  Widget getListViewWidget(BuildContext context) {
    // List containing the currency abbreviations
    // Used in itemBuilder to get data from mapping and _currencyCommon
    final List keys = mapping['rates'].keys.toList();
    // We want the ListView to have the flexibility to expand to fill the
    // available space in the vertical axis
    return new  Flexible(
        child: new ListView.builder(
            // The number of items to show
            itemCount: mapping['rates'].length,
            // Callback that should return ListView children
            // The index parameter = 0...(itemCount-1)
            itemBuilder: (context, index) {
              // Get the currency at this position
              double currencyRate = mapping['rates'][keys[index]];
              String currencyName =
                  _currencyCommon[keys[index]]['name'].toString();
              String currencySymbol =
                  _currencyCommon[keys[index]]['symbol_native'].toString();

              Map data = {"abbr": keys[index], "name": currencyName, "symbol": currencySymbol, "rate": currencyRate};
              print(data.toString());

              // Get the icon color. Since x mod y, will always be less than y,
              // this will be within bounds
              final MaterialColor color = colors[index % colors.length];

              return getListItemWidget(data, color, context);
            }));
  }

  @override
  Text getSubtitleWidget(var currencySymbol, var rate) {
    return Text('$rate $currencySymbol / €uro',
        style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 18));
  }

  @override
  ListTile getListTile(Map data, MaterialColor color) {
    return ListTile(
      leading: getLeadingWidget(data["abbr"], data["abbr"].length, color),
      title: getTitleWidget(data["name"]),
      subtitle: getSubtitleWidget(data["symbol"], data["rate"])
    );
  }
}
