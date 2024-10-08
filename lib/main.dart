import 'package:currency_calculator/ui/screen/main_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:flutter_i18n/loaders/decoders/yaml_decode_strategy.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:google_fonts/google_fonts.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart' as ads;
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:path_provider/path_provider.dart';

import 'bloc/ads_cubit.dart';
import 'bloc/app_cubit.dart';
import 'bloc/currency_selection_cubit.dart';
import 'bloc/review_cubit.dart';
import 'data/repository.dart';
import 'data/types.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // AdMob
  ads.MobileAds.instance.initialize();

  // Google Fonts
  GoogleFonts.config.allowRuntimeFetching = false;

  // Local Storage with Hive
  HydratedBloc.storage = await HydratedStorage.build(
      storageDirectory: await getApplicationDocumentsDirectory());

  final BaseRepository repository = AppRepository(
    currencyProvider: NetworkDataProvider<Iterable<Currency>>(
      url: "https://raw.githubusercontent.com/laguna-studios/currency-rates-provider/main/latest/currencies.json",
      fromJson: (json) => (json as List<dynamic>).map((item) => Currency.fromJson(item)),
    ),
    ratesProvider: NetworkDataProvider<Rates>(
      url: "https://raw.githubusercontent.com/laguna-studios/currency-rates-provider/main/latest/rates.json",
      fromJson: (json) => Map.from(json),
    )
  );

  // Launch App
  runApp(CurrencyConverterApp(repository: repository));
}

class CurrencyConverterApp extends StatelessWidget {
  final BaseRepository repository;


  const CurrencyConverterApp({super.key, required this.repository});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => AppCubit(repository, const AppState(uiState: AppUIState.loading))..load()),
        BlocProvider(create: (context) => AdsCubit(false)..init()),
        BlocProvider(create: (context) => ReviewCubit(0)..init()),
        BlocProvider(lazy: false, create: (context) => CurrencySelectionCubit(repository, const CurrencySelectionState(initialized: false))),
      ],
      child: MaterialApp(
        onGenerateTitle: (context) =>
            FlutterI18n.translate(context, 'app.title'),
        localizationsDelegates: [
          FlutterI18nDelegate(
            translationLoader: FileTranslationLoader(
                decodeStrategies: [YamlDecodeStrategy()]),
          ),
          ...GlobalMaterialLocalizations.delegates,
          GlobalWidgetsLocalizations.delegate
        ],
        supportedLocales: const [
          Locale('de'),
          Locale('en'),
        ],
        theme: ThemeData(
          primarySwatch: Colors.blueGrey
        ),
        darkTheme: ThemeData.dark(),
        home: const MainScreen(),
      ),
    );
  }
}

