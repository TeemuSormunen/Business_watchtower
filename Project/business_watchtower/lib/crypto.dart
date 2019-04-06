import 'dart:core';
import 'dart:ui';

import 'package:flutter/material.dart';

import 'generic.dart';

class CryptoListWidget extends GenericListWidget {
  CryptoListWidget(mapping, appTitle, favorites) : super(mapping, appTitle, favorites);

  @override
  GenericListWidgetState createState() => CryptoListWidgetState(mapping, appTitle, favorites);
}

class CryptoListWidgetState extends GenericListWidgetState {
  @override
  CryptoListWidgetState(mapping, appTitle, favorites) : super(mapping, appTitle, favorites);

  @override
  Widget getListViewWidget(BuildContext context) {
    // We want the ListView to have the flexibility to expand to fill the
    // available space in the vertical axis
    return Flexible(
        child: ListView.builder(
            // The number of items to show
            itemCount: mapping.length,
            // Callback that should return ListView children
            // The index parameter = 0...(itemCount-1)
            itemBuilder: (context, index) {
              // Get the currency at this position
              final Map currency = mapping[index];

              // Get the icon color. Since x mod y, will always be less than y,
              // this will be within bounds
              final MaterialColor color = colors[index % colors.length];

              return getListItemWidget(currency, color, context);
            }));
  }

  @override
  Text getSubtitleWidget(var priceEur, var percentChange1h) {
    String price = (priceEur).toStringAsFixed(4);
    return Text("$price €\n1 hour: $percentChange1h%",
        style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 18));
  }

  @override
  ListTile getListTile(Map data, MaterialColor color) {
    int nameLength = 3;
    if(data['name'].length < nameLength){
      nameLength = data['name'].length;
    }
    return ListTile(
      leading: getLeadingWidget(data['name'], nameLength, color),
      title: getTitleWidget(data['name']),
      subtitle: getSubtitleWidget(
          double.parse(data['price_eur']), data['percent_change_1h']),
      isThreeLine: true
    );
  }
}
