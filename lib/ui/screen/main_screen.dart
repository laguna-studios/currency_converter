import 'dart:io';

import 'package:currency_calculator/bloc/ads_cubit.dart';
import 'package:currency_calculator/bloc/app_cubit.dart';
import 'package:currency_calculator/bloc/currency_selection_cubit.dart';
import 'package:currency_calculator/data/types.dart';
import 'package:currency_calculator/ui/widget/currency_selection.dart';
import 'package:currency_calculator/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart' as ads;
import 'package:in_app_review/in_app_review.dart';
import 'package:intl/intl.dart';

import '../../bloc/review_cubit.dart';
import '../widget/flag.dart';

const int startupsBeforeReview = 4;

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen>{

  @override
  Widget build(BuildContext context) {
    return BlocListener<ReviewCubit, int>(
      listener: (_, __) {
        try {
          InAppReview.instance.requestReview();
        } catch (_) {}
      },
      listenWhen: (previous, current) => current == startupsBeforeReview,
      child: SafeArea(
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          appBar: AppBar(
            title: Text(
              FlutterI18n.translate(context, "title"),
            ),
            centerTitle: true,
            actions: [
              BlocBuilder<AppCubit, AppState>(builder: (context, state) {
                if (state.uiState == AppUIState.loading) {
                  return Container();
                } else if (state.uiState == AppUIState.updating) {
                  return const RotatingIcon();
                }
                return IconButton(
                    onPressed: state.uiState == AppUIState.loaded
                        ? AppCubit.of(context).update
                        : AppCubit.of(context).load,
                    icon: const Icon(Icons.refresh));
              })
            ],
          ),
          drawer: const AppDrawer(),
          body: BlocListener<AppCubit, AppState>(
            listenWhen: (previous, current) =>
                previous.message != current.message && current.message != null,
            listener: (context, state) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Row(
                children: [
                  const Icon(
                    Icons.announcement,
                    color: Colors.white,
                  ),
                  const SizedBox(
                    width: 16,
                  ),
                  Text(FlutterI18n.translate(context, "msg.${state.message}")),
                ],
              )));
            },
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 4),
              child:
                  BlocBuilder<AppCubit, AppState>(builder: (context, appState) {
                if (appState.uiState == AppUIState.error) {
                  return const ErrorPage();
                } else if (appState.uiState == AppUIState.loading) {
                  return const LoadingPage();
                }

                return LoadedPage(
                    from: appState.from!,
                    to: appState.to!,
                    conversionRate: appState.conversionRate!,
                    refreshDate: appState.refreshDate!,
                    onChangeFromCurrency: _onChangeFromCurrency,
                    onChangeToCurrency: _onChangeToCurrency);
              }),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _changeCurrency(
      BuildContext context, Function(Currency) callback) async {
    CurrencySelectionCubit cubit = CurrencySelectionCubit.of(context);
    cubit.init(context);
    Currency? currency = await showModalBottomSheet<Currency>(
        context: context,
        isScrollControlled: true,
        builder: (_) => FractionallySizedBox(
            heightFactor: 0.7, child: CurrencySelection()));

    cubit.reorderCurrencencies();
    if (currency == null) return;
    callback(currency);
    AdsCubit.of(context).showInterstitial();
  }

  void _onChangeFromCurrency(BuildContext context) async {
    _changeCurrency(context,
        (currency) => AppCubit.of(context).setCurrencies(from: currency));
  }

  void _onChangeToCurrency(BuildContext context) {
    _changeCurrency(context,
        (currency) => AppCubit.of(context).setCurrencies(to: currency));

  }
}

class LoadedPage extends StatelessWidget {
  final Currency from;
  final Currency to;
  final double conversionRate;
  final DateTime refreshDate;
  final Function(BuildContext) onChangeFromCurrency;
  final Function(BuildContext) onChangeToCurrency;

  const LoadedPage(
      {super.key,
      required this.from,
      required this.to,
      required this.conversionRate,
      required this.refreshDate,
      required this.onChangeFromCurrency,
      required this.onChangeToCurrency});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onTap: () => onChangeFromCurrency(context),
                    child: Flag(
                      code: from.flagCode,
                      height: 100,
                      width: 100,
                      borderRadius: 80,
                    ),
                  ),
                  const SizedBox(height: 12,),
                  TextField(
                    onChanged: (_) => AppCubit.of(context).onFromValueChanged(),
                    controller: AppCubit.of(context).fromController,
                    decoration: InputDecoration(
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8)),
                        hintText: from.id.toUpperCase(),
                        suffix: Text(from.symbol)),
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.number,
                  )
                ],
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: 100,
                  child: Center(
                    child: IconButton(
                      iconSize: 40,
                      icon: const Icon(
                        Icons.swap_horiz,
                      ),
                      onPressed: AppCubit.of(context).switchCurrencies,
                    ),
                  ),
                ),
                 const SizedBox(height: 28,),
                const Text(
                  "≈",
                  style: TextStyle(fontSize: 20),
                )
              ],
            ),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onTap: () => onChangeToCurrency(context),
                    child: Flag(
                      code: to.flagCode,
                      height: 100,
                      width: 100,
                      borderRadius: 80,
                    ),
                  ),
                   const SizedBox(height: 12,),
                  TextField(
                    onChanged: (_) => AppCubit.of(context).onToValueChanged(),
                    controller: AppCubit.of(context).toController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8)),
                      hintText: to.id.toUpperCase(),
                      suffix: Text(to.symbol),
                    ),
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.number,
                  )
                ],
              ),
            )
          ],
        ),
        const SizedBox(height: 12,),
        Text(
          FlutterI18n.translate(context, "overview"),
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Expanded(
          flex: 8,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Text(
                        from.id.toUpperCase(),
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 16),
                      ),
                      Text(to.id.toUpperCase(),
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 16))
                    ],
                  ),
                  ...[
                    for (double i in from.bills) ...[
                      const Divider(),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Text(from.format.replaceAll("value",
                                i.toStringAsFixed(from.decimalPlaces))),
                            Text(to.format.replaceAll(
                                "value",
                                (i * conversionRate)
                                    .toStringAsFixed(to.decimalPlaces))),
                          ])
                    ]
                  ]
                ],
              ),
            ),
          ),
        ),
        Expanded(
          child: Center(
              child: Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              "${FlutterI18n.translate(context, "refresh")} ${DateFormat.yMd("de").format(refreshDate)}",
              style: TextStyle(color: Colors.grey.shade400),
            ),
          )),
        ),
        BlocBuilder<AdsCubit, bool>(builder: ((context, adLoaded) {
          return adLoaded
              ? Center(
                  child: SizedBox(
                      height: 50,
                      width: 320,
                      child: ads.AdWidget(ad: AdsCubit.of(context).banner!)),
                )
              : Container();
        })),
      ],
    );
  }
}

class LoadingPage extends StatelessWidget {
  const LoadingPage({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Center(child: CircularProgressIndicator());
  }
}

class ErrorPage extends StatelessWidget {
  const ErrorPage({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              FlutterI18n.translate(context, "error.message"),
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ),
          OutlinedButton.icon(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              AppCubit.of(context).load();
            },
            label: Text(FlutterI18n.translate(context, "error.retry")),
          )
        ],
      ),
    );
  }
}

class AppDrawer extends StatelessWidget {
  const AppDrawer({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
                boxShadow: [BoxShadow(offset: Offset(0, 4), blurRadius: 4)]),
            padding: EdgeInsets.zero,
            child: Image.asset("assets/store/icon_round_1000.png",
                fit: BoxFit.cover),
          ),
          if (Platform.isAndroid) ListTile(
            leading: const Icon(Icons.favorite),
            title: Text(FlutterI18n.translate(context, "like")),
            onTap: openLikeUrl,
          ),
          if (Platform.isAndroid) ListTile(
            leading: const Icon(Icons.workspace_premium),
            title: Text(FlutterI18n.translate(context, "get_pro")),
            onTap: openProVersionUrl,
          ),
          if (Platform.isAndroid) const Divider(),
          ListTile(
            leading: const Icon(Icons.contact_mail),
            title: Text(FlutterI18n.translate(context, "contact")),
            onTap: () => openContactInformation(context),
          ),
          ListTile(
            leading: const Icon(Icons.gavel),
            title: Text(FlutterI18n.translate(context, "terms")),
            onTap: () => openTermsOfUse(context),
          ),
          ListTile(
            leading: const Icon(Icons.lock),
            title: Text(FlutterI18n.translate(context, "privacy")),
            onTap: () => openPrivacyPolicy(context),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.person),
            title: Text(FlutterI18n.translate(context, "about")),
            onTap: () => showAboutDialog(
              context: context,
              applicationName: FlutterI18n.translate(context, "title"),
              applicationVersion: "1.0.0",
            ),
          ),
        ],
      ),
    );
  }
}

class RotatingIcon extends StatefulWidget {
  const RotatingIcon({super.key});

  @override
  State<RotatingIcon> createState() => _RotatingIconState();
}

class _RotatingIconState extends State<RotatingIcon>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: RotationTransition(
          turns: _controller, child: const Icon(Icons.refresh)),
    );
  }
}
