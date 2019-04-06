import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:http/http.dart' as http;

import 'dart:async';
import 'dart:convert';
import 'dart:core';


Future<Map> getStockChartData(String companySymbol) async {
  String apiUrl = "https://api.iextrading.com/1.0/stock/"+ companySymbol + "/chart/2y";

  Map map = new Map();

  try {
    // Await basically pauses execution until the get() function returns a Response
    http.Response response = await http.get(apiUrl);


    map = json.decode(response.body).asMap();

    print("list " + map.toString());
  } catch (e) {
    print(e);
  }

  // Using the JSON class to decode the JSON String
  return map;
}


class SimpleTimeSeriesChart extends StatelessWidget {
  final List<TimeSeriesSales> tsData;
  final bool animate;

  SimpleTimeSeriesChart(this.tsData, {this.animate});

  @override
  Widget build(BuildContext context) {

    var series = [
      new charts.Series<TimeSeriesSales, DateTime>(
        id: 'Sales',
        colorFn: (_, __) => charts.MaterialPalette.yellow.shadeDefault,
        domainFn: (TimeSeriesSales sales, _) => sales.time,
        measureFn: (TimeSeriesSales sales, _) => sales.price,
        data: tsData,


      )
    ];

    var chart = charts.TimeSeriesChart(
      series,
      animate: animate,
      // Optionally pass in a [DateTimeFactory] used by the chart. The factory
      // should create the same type of [DateTime] as the data provided. If none
      // specified, the default creates local date time.

      domainAxis: new charts.DateTimeAxisSpec(
        renderSpec: charts.GridlineRendererSpec(
            axisLineStyle: charts.LineStyleSpec(
              color: charts.MaterialPalette.white, // this also doesn't change the Y axis labels
            ),
            labelStyle: new charts.TextStyleSpec(
              fontSize: 15,
              color: charts.MaterialPalette.white
            ),
            lineStyle: charts.LineStyleSpec(
              thickness: 0,
              color: charts.MaterialPalette.white,
            )
        ),
        
      ),
      primaryMeasureAxis: new charts.NumericAxisSpec(
          renderSpec: new charts.GridlineRendererSpec(

            // Tick and Label styling here.
              labelStyle: new charts.TextStyleSpec(
                  fontSize: 18, // size in Pts.
                  color: charts.MaterialPalette.white),

              // Change the line colors to match text color.
              lineStyle: new charts.LineStyleSpec(
                  color: charts.MaterialPalette.white))),
    );

    return new Container(
      child: new Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          new Padding(
            padding: new EdgeInsets.fromLTRB(10,0,10,10),
            child: new SizedBox(
              height: 200.0,
              child: chart,
            ),
          ),
        ],
      ),
    );
  }
}

/// Sample time series data type.
class TimeSeriesSales {
  final DateTime time;
  final double price;

  TimeSeriesSales(this.time, this.price);
}

