import 'package:currency_calculator/bloc/currency_selection_cubit.dart';
import 'package:currency_calculator/data/types.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_i18n/flutter_i18n.dart';

import 'flag.dart';

class CurrencySelection extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CurrencySelectionCubit, CurrencySelectionState>(
      builder: (context, state) {
        if (!state.initialized) {
          return const Center(child: CircularProgressIndicator(),);
        }

        return CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 2),
            sliver: SliverAppBar(
              leading: Container(),
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              elevation: 0,
              leadingWidth: 0,
              floating: true,
              title: SizedBox(
                height: 50,
                child: TextField(
                  controller: CurrencySelectionCubit.of(context).controller,
                  onChanged: CurrencySelectionCubit.of(context).search,
                  textAlignVertical: TextAlignVertical.bottom,
                  decoration: InputDecoration(
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                      prefixIcon: const Icon(Icons.search),
                      hintText: FlutterI18n.translate(context, "searchHint"),
                      suffixIcon: state.showClear!
                          ? IconButton(
                              onPressed: () {
                                CurrencySelectionCubit.of(context).clearSearch();
                              },
                              icon: const Icon(Icons.clear))
                          : null),
                ),
              ),
            ),
          ),
          
          
          SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {

            Currency currency = state.currencies![index];
          
            return ListTile(
              onTap: () {
                CurrencySelectionCubit.of(context).clearSearch();
                Navigator.pop(context, currency);
              },
              leading: Flag(
                code: currency.flagCode,
                width: 80,
                borderRadius: 8,
                square: false,
              ),
              title:
                  Text(FlutterI18n.translate(context, "currency.${currency.id}")),
              subtitle: Text(currency.countryIds.map((e) => FlutterI18n.translate(context, "country.$e")).join(", "), maxLines: 1, overflow: TextOverflow.ellipsis),
              trailing: IconButton(icon: Icon(state.favorites!.contains(currency) ? Icons.star : Icons.star_border), onPressed: (() {
                CurrencySelectionCubit.of(context).toggleLike(currency);
              })),
            );
          }, childCount: state.currencies!.length))
        ],
      );
      },
    );
  }
}
