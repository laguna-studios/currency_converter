import 'dart:convert';

import 'package:currency_calculator/bloc/app_cubit.dart';
import 'package:currency_calculator/data/types.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

typedef Rates = Map<String, Map<String, dynamic>>;

/// interfaces
abstract class DataProvider<T> {
  Future<T?> getData({bool cache = false});
  Future<Duration?> getCacheAge();
}

abstract class BaseRepository {
  Future<Rates?> getRates();
  Future<Iterable<Currency>?> getCurrencies();
}

/// implementations

class NetworkDataProvider<T> extends DataProvider<T> {
  final String url;
  final T Function(dynamic json) fromJson;
  final String _cacheAgeKey;
  final String _cacheDataKey;

  NetworkDataProvider({required this.url, required this.fromJson})
      : _cacheAgeKey = "age+$url",
        _cacheDataKey = "data+$url";

  @override
  Future<Duration?> getCacheAge() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    try {
      int milliseconds = prefs.getInt(_cacheAgeKey)!;
      return DateTime.now()
          .difference(DateTime.fromMillisecondsSinceEpoch(milliseconds));
    } catch (_) {
      return null;
    }
  }

  @override
  Future<T?> getData({bool cache = false}) {
    return cache ? _getFromCache() : _getFromUrl();
  }

  Future<T?> _getFromCache() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? jsonDataString = prefs.getString(_cacheDataKey)!;
      return fromJson(jsonDecode(jsonDataString));
    } catch (_) {
      return null;
    }
  }

  Future<T?> _getFromUrl() async {
    try {
      http.Response resp = await http.get(Uri.parse(url));

      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString(_cacheDataKey, resp.body);
      prefs.setInt(_cacheAgeKey, DateTime.now().millisecondsSinceEpoch);

      return fromJson(json.decode(resp.body));
    } catch (_) {
      return null;
    }
  }
}

class AppRepository extends BaseRepository {
  final DataProvider<Iterable<Currency>> currencyProvider;
  final DataProvider<Rates> ratesProvider;

  AppRepository({required this.currencyProvider, required this.ratesProvider});

  Future<T?> _getData<T>({required DataProvider<T> provider, required Duration maxAge}) async {
    Duration? age = await provider.getCacheAge();
    if (age == null) {
      return provider.getData();
    }
    else if (age > maxAge) {
      T? data = await provider.getData();
      if (data != null) return data;
      return provider.getData(cache: true);
    } 
    return provider.getData(cache: true);
  }

  @override
  Future<Rates?> getRates() async {
    return _getData<Rates>(provider: ratesProvider, maxAge: const Duration(hours: 1));
  }

  @override
  Future<Iterable<Currency>?> getCurrencies() {
    return _getData<Iterable<Currency>>(provider: currencyProvider, maxAge: const Duration(days: 30));
  }
}
