import 'package:currency_calculator/data/repository.dart';
import 'package:currency_calculator/data/types.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

class CurrencySelectionCubit extends HydratedCubit<CurrencySelectionState> {
  final BaseRepository repository;
  Iterable<Currency> _currencies = [];
  final Map<Currency, List<String>> _searchMap = {};
  final TextEditingController controller = TextEditingController();

  static CurrencySelectionCubit of(BuildContext context) => RepositoryProvider.of<CurrencySelectionCubit>(context);

  CurrencySelectionCubit(this.repository, super.initialState);

  Future<void> init(BuildContext context) async {
    if (_currencies.isNotEmpty) return; 

    _currencies = (await repository.getCurrencies())!;
    _currencies = List.from(state.favorites ?? [])..addAll(_currencies.where((element) => !(state.favorites ?? []).contains(element)));
    _prepareSearchMap(context);

    emit(state.copyWith(initialized: true, currencies: _currencies.toList(), showClear: false, favorites: state.favorites ?? []));
  }

  void _prepareSearchMap(BuildContext context) {
    if (_searchMap.isEmpty) {
      for (Currency c in _currencies) {
      List<String> tags = [];
      tags.add(c.id.toLowerCase());
      tags.add(FlutterI18n.translate(context, "currency.${c.id}").toLowerCase());
      tags.add(c.flagCode.toLowerCase());
      tags.add(c.symbol.toLowerCase());
      tags.addAll(c.countryIds.map((id) => FlutterI18n.translate(context, "country.$id").toLowerCase()));
      _searchMap[c] = tags;
    }
    }
  }

  Future<void> onOpenSelection() async {}

  Future<void> search(String query) async {
    if (query.isEmpty) {
      emit(state.copyWith(currencies: _currencies.toList(), showClear: false));
    }
    List<Currency> result = _currencies.where((c) => _searchMap[c]!.any((tag) => tag.contains(query.toLowerCase()))).toList();
    emit(state.copyWith(currencies: result, showClear: true));
  }

  Future<void> clearSearch() async {
    controller.clear();
    emit(state.copyWith(currencies: _currencies.toList(), showClear: false));
  }

  Future<void> toggleLike(Currency currency) async {
    List<Currency> newFavorites = List.from(state.favorites!);
    if (newFavorites.contains(currency)) {
      newFavorites.remove(currency);
    } else {
      newFavorites.add(currency);
    }
    emit(state.copyWith(favorites: newFavorites));
  }

  Future<void> reorderCurrencencies() async {
    List<Currency> newCurrencies = List.from(state.favorites!)..addAll(_currencies.where((element) => !state.favorites!.contains(element)));
    emit(state.copyWith(currencies: newCurrencies));
  }
  
  @override
  CurrencySelectionState? fromJson(Map<String, dynamic> json) => CurrencySelectionState.fromJson(json);
  
  @override
  Map<String, dynamic>? toJson(CurrencySelectionState state) => state.toJson();
}