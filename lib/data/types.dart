import 'package:freezed_annotation/freezed_annotation.dart';

part 'types.freezed.dart';
part 'types.g.dart';

enum AppUIState {
  loading,
  loaded,
  updating,
  error
}

@freezed
class Currency with _$Currency {
  const factory Currency({
    required String id,
    required String flagCode,
    required String symbol,
    required List<String> countryIds,
    required List<double> bills,
    required String format,
    required int decimalPlaces
  }) = _Currency;

  factory Currency.fromJson(Map<String, Object?> json) => _$CurrencyFromJson(json);
}

@freezed
class CurrencySelectionState with _$CurrencySelectionState {
  const factory CurrencySelectionState({
    required bool initialized,
    bool? showClear,
    List<Currency>? currencies,
    List<Currency>? favorites
  }) = _CurrencySelectionState;

  factory CurrencySelectionState.fromJson(Map<String, Object?> json) => _$CurrencySelectionStateFromJson(json);
}

@freezed
class AppState with _$AppState {
  const factory AppState({
    required AppUIState uiState,
    Currency? from,
    Currency? to,
    double? conversionRate,
    DateTime? refreshDate,
    String? message
  }) = _AppState;

  factory AppState.fromJson(Map<String, Object?> json)
      => _$AppStateFromJson(json);
}
