import 'package:flutter/material.dart';
import 'package:sgela_services/data/city.dart';
import 'package:sgela_services/data/country.dart';
import 'package:sgela_sponsor_app/util/functions.dart';

class CityList extends StatelessWidget {
  const CityList({super.key, required this.cities, required this.onCityTapped, required this.country});

  final List<City> cities;
  final Country country;
  final Function(City) onCityTapped;

  @override
  Widget build(BuildContext context) {
    cities.sort((a,b) => a.name!.compareTo(b.name!));
    return Column(
      children: [
        Text('${country.name}',style: myTextStyle(context, Theme.of(context).primaryColor,
            18, FontWeight.w900) ),
        gapH8,
        Expanded(
          child: ListView.builder(
              itemCount: cities.length,
              itemBuilder: (_, index) {
                var city = cities.elementAt(index);
            return GestureDetector(
              onTap: (){
                onCityTapped(city);
              },
              child: Card(
                elevation: 8,
                child: Padding(
                  padding: const EdgeInsets.all(0.0),
                  child: ListTile(
                    title: Text('${city.name}', style: myTextStyleSmall(context),),
                    leading: Text('${index+1}', style: myTextStyle(context, Theme.of(context).primaryColor,
                        14, FontWeight.w900),),
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}
