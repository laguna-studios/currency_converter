// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'types.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$_Currency _$$_CurrencyFromJson(Map<String, dynamic> json) => _$_Currency(
      id: json['id'] as String,
      flagCode: json['flagCode'] as String,
      symbol: json['symbol'] as String,
      countryIds: (json['countryIds'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      bills: (json['bills'] as List<dynamic>)
          .map((e) => (e as num).toDouble())
          .toList(),
      format: json['format'] as String,
      decimalPlaces: json['decimalPlaces'] as int,
    );

Map<String, dynamic> _$$_CurrencyToJson(_$_Currency instance) =>
    <String, dynamic>{
      'id': instance.id,
      'flagCode': instance.flagCode,
      'symbol': instance.symbol,
      'countryIds': instance.countryIds,
      'bills': instance.bills,
      'format': instance.format,
      'decimalPlaces': instance.decimalPlaces,
    };

_$_CurrencySelectionState _$$_CurrencySelectionStateFromJson(
        Map<String, dynamic> json) =>
    _$_CurrencySelectionState(
      initialized: json['initialized'] as bool,
      showClear: json['showClear'] as bool?,
      currencies: (json['currencies'] as List<dynamic>?)
          ?.map((e) => Currency.fromJson(e as Map<String, dynamic>))
          .toList(),
      favorites: (json['favorites'] as List<dynamic>?)
          ?.map((e) => Currency.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$$_CurrencySelectionStateToJson(
        _$_CurrencySelectionState instance) =>
    <String, dynamic>{
      'initialized': instance.initialized,
      'showClear': instance.showClear,
      'currencies': instance.currencies,
      'favorites': instance.favorites,
    };

_$_AppState _$$_AppStateFromJson(Map<String, dynamic> json) => _$_AppState(
      uiState: $enumDecode(_$AppUIStateEnumMap, json['uiState']),
      from: json['from'] == null
          ? null
          : Currency.fromJson(json['from'] as Map<String, dynamic>),
      to: json['to'] == null
          ? null
          : Currency.fromJson(json['to'] as Map<String, dynamic>),
      conversionRate: (json['conversionRate'] as num?)?.toDouble(),
      refreshDate: json['refreshDate'] == null
          ? null
          : DateTime.parse(json['refreshDate'] as String),
      message: json['message'] as String?,
    );

Map<String, dynamic> _$$_AppStateToJson(_$_AppState instance) =>
    <String, dynamic>{
      'uiState': _$AppUIStateEnumMap[instance.uiState]!,
      'from': instance.from,
      'to': instance.to,
      'conversionRate': instance.conversionRate,
      'refreshDate': instance.refreshDate?.toIso8601String(),
      'message': instance.message,
    };

const _$AppUIStateEnumMap = {
  AppUIState.loading: 'loading',
  AppUIState.loaded: 'loaded',
  AppUIState.updating: 'updating',
  AppUIState.error: 'error',
};
