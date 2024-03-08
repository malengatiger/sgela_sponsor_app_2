import 'package:flutter/material.dart';
import 'package:sgela_services/data/country.dart';
import 'package:sgela_sponsor_app/util/functions.dart';


class CountryList extends StatelessWidget {
  const CountryList(
      {super.key,
      required this.countries,
      required this.onCountryTapped,
      required this.showAsGrid});

  final List<Country> countries;
  final Function(Country) onCountryTapped;
  final bool showAsGrid;

  @override
  Widget build(BuildContext context) {
    countries.sort((a, b) => a.name!.compareTo(b.name!));
    if (showAsGrid) {
      return GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2),
          itemCount: countries.length,
          itemBuilder: (_, index) {
            var country = countries.elementAt(index);

            return CountryCard(
              onCountryTapped: (c) {
                onCountryTapped(c);
              },
              country: country,
              showAsGrid: showAsGrid,
            );
          });
    }
    return ListView.builder(
        itemCount: countries.length,
        itemBuilder: (_, index) {
          var country = countries.elementAt(index);
          return CountryCard(
            onCountryTapped: (c) {
              onCountryTapped(c);
            },
            country: country,
            showAsGrid: showAsGrid,
          );
        });
  }
}

class CountryCard extends StatelessWidget {
  const CountryCard(
      {super.key,
      required this.onCountryTapped,
      required this.country,
      required this.showAsGrid});

  final Function(Country) onCountryTapped;
  final Country country;
  final bool showAsGrid;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        ppx('CountryList: country: ${country.toJson()}');
        onCountryTapped(country);
      },
      child: Card(
        elevation: 8,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: showAsGrid
              ? SizedBox(height: 48,
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        '${country.emoji}',
                        style: const TextStyle(fontSize: 28),
                      ),
                      gapH16,
                      Text(
                        '${country.name}',
                        style: myTextStyleSmall(context),
                      ),
                    ],
                  ),
              )
              : Row(
                  children: [
                    Text(
                      '${country.emoji}',
                      style: const TextStyle(fontSize: 20),
                    ),
                    gapW16,
                    Text(
                      '${country.name}',
                      style: myTextStyleMedium(context),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
