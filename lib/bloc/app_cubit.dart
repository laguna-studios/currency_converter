import 'package:currency_calculator/data/repository.dart';
import 'package:currency_calculator/data/types.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

class AppCubit extends HydratedCubit<AppState> {
  static AppCubit of(BuildContext context) =>
      BlocProvider.of<AppCubit>(context);

  final BaseRepository repository;
  final TextEditingController fromController;
  final TextEditingController toController;

  Iterable<Currency> _currencies = [];
  Rates _rates = {};

  AppCubit(this.repository, super.initialState)
      : fromController = TextEditingController(),
        toController = TextEditingController();

  @override
  Future<void> close() {
    fromController.dispose();
    toController.dispose();
    return super.close();
  }

  DateTime _getRatesDate(Currency from, Currency to) {
    try {
      int timestamp = _rates[from.id]!["date"];
      return DateTime.fromMillisecondsSinceEpoch(timestamp);
    } catch (e) {
      throw DeveloperException("dev.getRatesDate");
    }
  }

  double _getConversionRate({required Currency from, required Currency to}) {
    try {
      double conversionRate = _rates[from.id]![to.id];
      return conversionRate;
    } catch (e) {
      throw DeveloperException("dev.getConversionRate");
    }
  }

  void _showMessage(String message) {
    emit(state.copyWith(message: message));
    emit(AppState(
        message: null,
        uiState: state.uiState,
        from: state.from,
        to: state.to,
        conversionRate: state.conversionRate,
        refreshDate: state.refreshDate));
  }

  // UI callbacks
  Future<void> load({bool useCache = true}) async {
    try {
      emit(state.copyWith(uiState: AppUIState.loading));
      _currencies = (await repository.getCurrencies(maxCacheAge: Duration.zero))!;
      _rates = (await repository.getRates(maxCacheAge: Duration.zero))!;
      

      // load initial values
      Currency from =
          state.from ?? _currencies.firstWhere((element) => element.id == "eur");
      Currency to =
          state.to ?? _currencies.firstWhere((element) => element.id == "usd");
      double conversionRate = _getConversionRate(from: from, to: to);
      DateTime refreshDate = _getRatesDate(from, to);
      fromController.clear();
      toController.clear();

      emit(state.copyWith(
        uiState: AppUIState.loaded,
        from: from,
        to: to,
        conversionRate: conversionRate,
        refreshDate: refreshDate,
      ));
    } catch (e) {
      emit(state.copyWith(uiState: AppUIState.error));
    }
  }

  Future<void> update() async {
    try {
      assert(state.uiState == AppUIState.loaded);
      emit(state.copyWith(uiState: AppUIState.updating));
      _rates = (await repository.getRates(maxCacheAge: Duration.zero))!;

      // update values
      double conversionRate = _getConversionRate(from: state.from!, to: state.to!);
      DateTime refreshDate = _getRatesDate(state.from!, state.to!);
      
      emit(state.copyWith(
        uiState: AppUIState.loaded,
        conversionRate: conversionRate,
        refreshDate: refreshDate,
      ));

      _calculateValues(newFromValue: true);
      _showMessage("updated");
    } catch (e) {
      emit(state.copyWith(uiState: AppUIState.error));
    }
  }

  void onFromValueChanged() => _calculateValues(newFromValue: true);

  void onToValueChanged() => _calculateValues(newFromValue: false);

  void setCurrencies({Currency? from, Currency? to}) {
    try {
      assert(state.uiState == AppUIState.loaded);
      double conversionRate =
          _getConversionRate(from: from ?? state.from!, to: to ?? state.to!);
      emit(state.copyWith(from: from ?? state.from, to: to ?? state.to, conversionRate: conversionRate));
    } catch (e) {
      _showMessage("setCurrenciesError");
    }
  }

  /// calculates new values
  /// clears the other value if the origin is not a valid double
  void _calculateValues({required bool newFromValue}) {
    double? from = double.tryParse(fromController.text);
    double? to = double.tryParse(toController.text);

    if (newFromValue) {
      if (from == null) {
        toController.clear();
        return;
      }
      double result = from * state.conversionRate!;
      toController.value = TextEditingValue(text: result.toStringAsFixed(2));
    } else {
      if (to == null) {
        fromController.clear();
        return;
      }
      double result = to / state.conversionRate!;
      fromController.value = TextEditingValue(text: result.toStringAsFixed(2));
    }
  }

  void switchCurrencies() => setCurrencies(from: state.to, to: state.from);

  // State serialization
  @override
  AppState? fromJson(Map<String, dynamic> json) => AppState.fromJson(json);

  @override
  Map<String, dynamic>? toJson(AppState state) => state.toJson();
}

class DeveloperException extends Error {
  final String message;

  DeveloperException(this.message);
}
