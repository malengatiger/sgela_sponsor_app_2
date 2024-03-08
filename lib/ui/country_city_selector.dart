import 'package:badges/badges.dart' as bd;
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:sgela_services/data/city.dart';
import 'package:sgela_services/data/country.dart';
import 'package:sgela_services/services/firestore_service_sponsor.dart';
import 'package:sgela_services/sgela_util/dark_light_control.dart';
import 'package:sgela_services/sgela_util/sponsor_prefs.dart';
import 'package:sgela_services/sgela_util/widget_prefs.dart';
import 'package:sgela_shared_widgets/util/widget_prefs.dart';
import 'package:sgela_shared_widgets/widgets/color_gallery.dart';
import 'package:sgela_sponsor_app/ui/city_list.dart';
import 'package:sgela_sponsor_app/ui/country_list.dart';
import 'package:sgela_sponsor_app/ui/widgets/row_content_view.dart';
import 'package:sgela_sponsor_app/util/navigation_util.dart';

import '../util/functions.dart';

class CountryCitySelector extends StatefulWidget {
  const CountryCitySelector({super.key, required this.onCountrySelected, required this.onCitySelected});

  final Function(Country) onCountrySelected;
  final Function(City) onCitySelected;
  @override
  CountryCitySelectorState createState() => CountryCitySelectorState();
}

class CountryCitySelectorState extends State<CountryCitySelector>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final SponsorFirestoreService firestoreService = GetIt.instance<SponsorFirestoreService>();
  bool busy = false;
  List<Country> _countries = [];
  final List<Country> _filteredCountries = [];
  List<City> _cities = [];
  final List<City> _filteredCities = [];
  Country? localCountry;
  SponsorPrefs sponsorPrefs = GetIt.instance<SponsorPrefs>();
  WidgetPrefs widgetPrefs = GetIt.instance<WidgetPrefs>();

  DarkLightControl dlc = GetIt.instance<DarkLightControl>();
  static const String mm = '🥦🥦🥦 CountryCitySelector:  🥦';

  void _dismissKeyboard(BuildContext context) {
    final currentFocus = FocusScope.of(context);
    if (!currentFocus.hasPrimaryFocus && currentFocus.hasFocus) {
      FocusManager.instance.primaryFocus?.unfocus();
    }
  }

  @override
  void initState() {
    _controller = AnimationController(vsync: this);
    super.initState();
    _getCountries();
  }

  _getCountries() async {
    ppx('$mm ... getting countries ....');
    setState(() {
      busy = true;
    });
    try {
      _countries = prefs.getCountries();
      if (_countries.isEmpty) {
        _countries = await firestoreService.getCountries();
      }
      _filteredCountries.addAll(_countries);
      ppx('$mm ... gotten countries : ${_countries.length}, filter for sou');
      localCountry = await firestoreService.getLocalCountry();
      if (localCountry != null) {
        String prefix = localCountry!.name!.substring(0,3);
        _filterCountries(prefix);
      }
    } catch (e) {
      ppx(e);
      if (mounted) {
        showErrorDialog(context, 'Error: $e');
      }
    }
    setState(() {
      busy = false;
    });
  }

  _filterCountries(String name) {
    ppx('$mm ... filter countries with: $name '
        'for ${_countries.length} countries');
    if (name.isEmpty) {
      ppx('$mm ... filter name is empty');
      _filteredCountries.clear();
      _filteredCountries.addAll(_countries);
    } else {
      var m = name.toLowerCase();
      _filteredCountries.clear();
      for (var country in _countries) {
        // pp('$mm ... country to filter: ${country.name} - using: $name');
        if (country.name!.toLowerCase().contains(m)) {
          _filteredCountries.add(country);
        }
      }
    }
    ppx('$mm ... filtered countries with: $name '
        'found: ${_filteredCountries.length} countries');

    setState(() {});
    _dismissKeyboard(context);
  }

  _filterCities(String name) {
    ppx('$mm ... filter cities with: $name for ${_cities.length} cities');
    if (name.isEmpty) {
      ppx('$mm ... filter name is empty');
      _filteredCities.clear();
      _filteredCities.addAll(_cities);
    } else {
      var m = name.toLowerCase();
      _filteredCities.clear();
      for (var city in _cities) {
        // pp('$mm ... city to filter: ${city.name} - using: $name');
        if (city.name!.toLowerCase().contains(m)) {
          _filteredCities.add(city);
        }
      }
    }
    setState(() {});
    _dismissKeyboard(context);
  }

  bool _showCityList = false;
  City? _selectedCity;

  _getCities(int countryId) async {
    setState(() {
      busy = true;
    });
    try {
      _cities = await firestoreService.getCities(countryId);
      _filteredCities.addAll(_cities);
      ppx('$mm ... cities found for country id: $countryId : ${_cities.length}');
      if (_cities.isNotEmpty) {
        _showCityList = true;
        _textEditingController = TextEditingController();
      } else {
        _showCityList = false;
      }
    } catch (e) {
      ppx(e);
      if (mounted) {
        showErrorDialog(context, 'Error: $e');
      }
    }
    setState(() {
      busy = false;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    //_dismissKeyboard(context);
    super.dispose();
  }

  TextEditingController _textEditingController = TextEditingController();
  final SponsorPrefs prefs = GetIt.instance<SponsorPrefs>();
  final ColorWatcher colorWatcher = GetIt.instance<ColorWatcher>();

  @override
  Widget build(BuildContext context) {
    var b = MediaQuery.of(context).platformBrightness;
    var isDark = isDarkMode(prefs, MediaQuery.of(context).platformBrightness);
    return SafeArea(
        child: Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Text(
              'Country City Selector',
              style: myTextStyle(
                  context, Theme.of(context).primaryColor, 14, FontWeight.w900),
            ),
            gapW16,
            busy
                ? const SizedBox(
                    height: 14,
                    width: 14,
                    child: CircularProgressIndicator(
                      strokeWidth: 6,
                      backgroundColor: Colors.pink,
                    ),
                  )
                : gapW16,
          ],
        ),
        actions: [
          IconButton(
              onPressed: () {
                ppx('$mm ... dark/light pressed, Brightness: ${b.name}');
                var mode = prefs.getMode();
                if (mode == DARK) {
                  dlc.setLightMode();
                } else {
                  dlc.setDarkMode();
                }
                setState(() {});
              },
              icon: b == Brightness.light
                  ? Icon(
                      Icons.dark_mode,
                      color: Theme.of(context).primaryColor,
                    )
                  : Icon(
                      Icons.light_mode,
                      color: Theme.of(context).primaryColor,
                    )),
          IconButton(
            onPressed: () {
              NavigationUtils.navigateToPage(
                  context: context,
                  widget:
                      ColorGallery(colorWatcher: colorWatcher));
            },
            icon: Icon(
              Icons.color_lens_outlined,
              color: Theme.of(context).primaryColor,
            ),
          ),
        ],
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(24),
          child: Column(
            children: [],
          ),
        ),
      ),
      body: ScreenTypeLayout.builder(
        mobile: (_) {
          return Stack(
            children: [
              Column(
                children: [
                  gapH16,
                  Padding(
                    padding: const EdgeInsets.only(left: 28.0, right: 28),
                    child: SearchBar(
                      controller: _textEditingController,
                      hintText: _showCityList
                          ? 'Search Cities/Towns'
                          : 'Search countries',
                      onChanged: (c) {
                        ppx('$mm onChanged, will filter: ${_textEditingController.text}');
                        if (_textEditingController.text.length > 2) {
                          if (_showCityList) {
                            _filterCities(_textEditingController.text);
                          } else {
                            _filterCountries(_textEditingController.text);
                          }
                        }
                      },
                      onSubmitted: (s) {
                        ppx('$mm ... onSub: $s');
                      },
                      elevation: const MaterialStatePropertyAll(8.0),
                      leading: const Icon(Icons.search),
                    ),
                  ),
                  gapH32,
                  _showCityList
                      ? Expanded(
                          child: Padding(
                            padding:
                                const EdgeInsets.only(left: 28.0, right: 28),
                            child: bd.Badge(
                              badgeContent: Text('${_filteredCities.length}'),
                              child: CityList(
                                cities: _filteredCities,
                                country: _selectedCountry!,
                                onCityTapped: (c) {
                                  ppx('$mm .... city tapped, will pop! ...: ${c.name}');
                                  setState(() {
                                    _selectedCity = c;
                                  });
                                  widget.onCitySelected(c);
                                  Future.delayed(
                                      const Duration(milliseconds: 1000), () {
                                    Navigator.of(context).pop(c);
                                  });
                                },
                              ),
                            ),
                          ),
                        )
                      : Expanded(
                          child: Padding(
                            padding:
                                const EdgeInsets.only(left: 28.0, right: 28),
                            child: bd.Badge(
                              badgeContent:
                                  Text('${_filteredCountries.length}'),
                              child: CountryList(
                                countries: _filteredCountries,
                                onCountryTapped: (c) {
                                  ppx('$mm .... country tapped, get cities ...: ${c.name}');
                                  _selectedCountry = c;
                                  widget.onCountrySelected(c);
                                  _getCities(c.id!);
                                },
                                showAsGrid: true,
                              ),
                            ),
                          ),
                        ),
                  _selectedCity == null
                      ? gapW16
                      : Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: SizedBox(
                            width: 420,
                            child: GestureDetector(
                              onTap: () {
                                ppx('$mm .... Das vi da nia!');
                                Navigator.of(context).pop();
                              },
                              child: Card(
                                elevation: 16,
                                child: Column(
                                  children: [
                                    gapH8,
                                    const Text('City/Town Selected'),
                                    gapH8,
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          left: 16.0,
                                          right: 16.0,
                                          top: 8,
                                          bottom: 8),
                                      child: Text(
                                        '${_selectedCity!.name}',
                                        style: myTextStyle(
                                            context,
                                            Theme.of(context).primaryColor,
                                            16,
                                            FontWeight.w900),
                                      ),
                                    ),
                                    gapH8,
                                  ],
                                ),
                              ),
                            ),
                          ),
                        )
                ],
              )
            ],
          );
        },
        tablet: (_) {
          return const Stack();
        },
        desktop: (_) {
          return Stack(
            children: [
              RowContentView(
                  leftWidget: CountryList(
                    showAsGrid: true,
                    countries: _countries,
                    onCountryTapped: (country) {
                      ppx('$mm country tapped: ${country.name}');
                      _selectedCountry = country;
                      _getCities(country.id!);
                    },
                  ),
                  rightWidget: CityList(
                      cities: _cities,
                      country: _selectedCountry!,
                      onCityTapped: (city) {
                        ppx('$mm( city tapped: ${city.name})');
                      }))
            ],
          );
        },
      ),
    ));
  }

  Country? _selectedCountry;
}
