import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

///This class is used to store and fetch data from phones memory. Basically it stores users favorites and what stocks user wants to see
class Prefs {

  final String _stockKey = "stocksymbols";
  final String _stockMapKey = "stockmap";
  final String _favoritesKey = "favorites";

  Future<bool> storeSelectedStocks(List<String> _symbolList) async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    List<String> _previouslySaved = await getStoredStocks();

    List<String> _storableList = new List.from(_symbolList);
    if (_previouslySaved != null) {
      for(String s in _previouslySaved) {
        if(!_storableList.contains(s)) {
          _storableList.add(s);
        }
      }
    }
    return preferences.setStringList(_stockKey, _storableList);
  }

  Future<List<String>> getStoredStocks() async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    List<String> favorites = await getFavorites();
    return preferences.getStringList(_stockKey);
  }

  Future<bool> storeStocksMap(Map _stockMap) async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();

    String _stocks = json.encode(_stockMap);

    return preferences.setString(_stockMapKey, _stocks);
  }

  Future<Map> getStoredStocksMap() async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    return json.decode(preferences.getString(_stockMapKey));
  }

  Future<bool> deleteStock(String _deletable) async {
    final List<String> _stored = await getStoredStocks();
    _stored.removeWhere((item) => item == _deletable);
    bool _hasPurged = await purge();
    if (!_hasPurged) {
      return _hasPurged;
    }
    return storeSelectedStocks(_stored);
  }

  Future<bool> purge() async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    return preferences.remove(_stockKey);
  }

  Future<List<String>> getFavorites() async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    return preferences.getStringList(_favoritesKey);
  }

  Future<bool> addToFavorites(String _newFavorite) async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    List<String> _previouslySaved = await getFavorites();

    if (_previouslySaved != null) {
      if (_previouslySaved.contains(_newFavorite)) {
        _previouslySaved.remove(_newFavorite);
      }
      else {
        _previouslySaved.add(_newFavorite);
      }
    }
    else {
      _previouslySaved = [_newFavorite];

    }
    return preferences.setStringList(_favoritesKey, _previouslySaved);
  }
}