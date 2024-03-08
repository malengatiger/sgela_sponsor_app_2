import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:sgela_services/data/city.dart';
import 'package:sgela_services/data/country.dart';
import 'package:sgela_services/data/holder.dart';
import 'package:sgela_services/data/org_user.dart';
import 'package:sgela_services/data/organization.dart';
import 'package:sgela_services/services/auth_service.dart';
import 'package:sgela_services/sgela_util/registration_stream_handler.dart';
import 'package:sgela_services/sgela_util/sponsor_prefs.dart';
import 'package:sgela_shared_widgets/widgets/busy_indicator.dart';
import 'package:sgela_services/services/rapyd_payment_service.dart';
import 'package:sgela_services/services/repository.dart';
import 'package:sgela_sponsor_app/ui/country_city_selector.dart';
import 'package:sgela_sponsor_app/util/navigation_util.dart';
import '../../util/functions.dart';

class RegistrationFormFinal extends StatefulWidget {
  const RegistrationFormFinal({super.key, required this.variables});

  final Map<String, dynamic> variables;

  @override
  RegistrationFormFinalState createState() => RegistrationFormFinalState();
}

class RegistrationFormFinalState extends State<RegistrationFormFinal>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  City? _city;
  bool _busy = false;

  final RepositoryService repositoryService =
      GetIt.instance<RepositoryService>();
  final AuthService authService = GetIt.instance<AuthService>();
  CompletionStreamHandler handler =
      GetIt.instance<CompletionStreamHandler>();

  final RapydPaymentService paymentService =
      GetIt.instance<RapydPaymentService>();
  static const mm = '🌀🌀🌀🌀🌀RegistrationFormFinal 🌀🌀';

  @override
  void initState() {
    _controller = AnimationController(vsync: this);
    super.initState();
    ppx('$mm ......... initState ..... variables : ${widget.variables}');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  _onSubmit(Map<String, dynamic> map) async {
    ppx('$mm ......... _onSubmit ..... map: $map 🌀🌀variables : ${widget.variables}');
    ppx('$mm ......... _onSubmit ..... 🌀🌀city : ${_city!.toJson()}');

    if ((_country == null || _city == null)) {
      showToast(message: 'Country and City not selected', context: context);
      return;
    }

    var user = OrgUser(
        firstName: widget.variables['adminFirstName'],
        lastName: widget.variables['adminLastName'],
        cellphone: map['cellPhone'],
        email: widget.variables['email'],
        date: DateTime.now().toIso8601String(),
        organizationName: widget.variables['orgName'],
        activeFlag: true,
        organizationId: 9999,
        cityName: '',
        firebaseUserId: '',
        password: map['password'], id: DateTime.now().millisecondsSinceEpoch);

    var org = Organization(
        name: widget.variables['orgName'],
        email: widget.variables['email'],
        cellphone: map['cellPhone'],
        adminUser: user,
        country: _country,
        city: _city,
        splashUrl: '',
        logoUrl: '',
        tagLine: '',
        activeFlag: true,
        date: DateTime.now().toIso8601String(), id: DateTime.now().millisecondsSinceEpoch);

    setState(() {
      _busy = true;
    });
    ppx('$mm ..... registering org, check data!:  🌀🌀 ${org.toJson()}  🌀🌀');
    try {
      var orgResult = await repositoryService.registerOrganization(org);
      if (orgResult != null) {
        ppx('$mm ..... back from backend; orgResult:  🌀🌀 🌀🌀 🍎 🍎${orgResult.toJson()}  🍎 🍎 🌀🌀 🌀🌀');
        var prefs = GetIt.instance<SponsorPrefs>();
        prefs.saveUser(orgResult.adminUser!);
        prefs.saveOrganization(orgResult);
        prefs.saveCountry(orgResult.country!);
        ppx('$mm ..... data saved in prefs! 🌀🌀🌀🌀 sign in ...');
        await authService.signInOrgUser(user.email!, user.password!);
        ppx('$mm ..... create rapyd customer 🌀🌀🌀🌀 .......');

        CustomerRequest customerRequest = CustomerRequest(
            org.name!, null, user.email, 'SGA', null, null, user.cellphone!);
        Customer? customer = await paymentService.addCustomer(customerRequest);
        if ((customer != null)) {
          ppx('$mm ..... 🍀🍀🍀🍀🍀🍀 saving rapyd customer '
              '🌀🌀🌀🌀 ${customer.toJson()}');
          prefs.saveCustomer(customer);
        }
        handler.setCompleted();
        if (mounted) {
          Navigator.of(context).pop(true);
        }
      } else {
        if (mounted) {
          showErrorDialog(context, 'Something went wrong somewhere');
        }
      }
    } catch (e) {
      ppx(e);
      if (mounted) {
        showErrorDialog(context, 'Error: $e');
      }
    }
    if (mounted) {
      setState(() {
        _busy = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Row(
            children: [
              Text(
                'SgelaAI',
                style: myTextStyle(context, Theme.of(context).primaryColor, 24,
                    FontWeight.w900),
              ),
              gapW16,
              Text(
                'Registration: 2 of 2',
                style: myTextStyleMedium(context),
              ),
            ],
          ),
        ),
        body: ScreenTypeLayout.builder(
          mobile: (_) {
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Card(
                  child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: SingleChildScrollView(
                  child: _busy
                      ? const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            gapH32,
                            gapH32,
                            gapH32,
                            BusyIndicator(
                              caption: 'Registering your organization',
                              showClock: true,
                            ),
                          ],
                        )
                      : Column(
                          children: [
                            gapH16,
                            Text(
                              '${widget.variables['orgName']}',
                              style: myTextStyleMediumLarge(context, 20),
                            ),
                            gapH32,
                            _city == null
                                ? gapW16
                                : Text('${_city!.name}',
                                    style: myTextStyle(
                                        context,
                                        Theme.of(context).primaryColor,
                                        20,
                                        FontWeight.w900)),
                            gapH16,
                            _country == null
                                ? gapW16
                                : Text('${_country!.name}',
                                    style: myTextStyle(
                                        context,
                                        Theme.of(context).primaryColor,
                                        14,
                                        FontWeight.normal)),
                            gapH16,
                            MyForm2(
                              onSubmit: (formVariables) {
                                ppx('$mm form returned, check that form filled in: $formVariables');
                                var filledIn = false;
                                var cnt = 0;
                                if (formVariables['password'] != null) {
                                  cnt++;
                                }
                                if (formVariables['cellPhone'] != null) {
                                  cnt++;
                                }
                                if ((cnt == 2)) {
                                  filledIn = true;
                                }
                                if (filledIn) {
                                  _onSubmit(formVariables);
                                }
                              },
                              onCitySelected: (c) {
                                ppx('$mm ... city has been selected and delivered: ${c.toJson()}');
                                setState(() {
                                  _city = c;
                                });
                              },
                              showRegisterButton: _city == null ? false : true,
                              onCountrySelected: (c) {
                                ppx('$mm ... country has been selected and delivered: ${c.toJson()}');
                                setState(() {
                                  _country = c;
                                });
                              },
                            ),
                          ],
                        ),
                ),
              )),
            );
          },
        ));
  }

  Country? _country;
}

class MyForm2 extends StatelessWidget {
  const MyForm2(
      {super.key,
      required this.onSubmit,
      required this.onCitySelected,
      required this.showRegisterButton,
      required this.onCountrySelected});

  static const mm = '🍐🍐🍐🍐MyForm2';

  final Function(Map<String, dynamic>) onSubmit;
  final Function(City) onCitySelected;
  final Function(Country) onCountrySelected;
  final bool showRegisterButton;

  FormGroup buildForm() => fb.group(<String, Object>{
        'cellPhone': FormControl<String>(
          validators: [Validators.required, Validators.number],
        ),
        'password': ['', Validators.required, Validators.minLength(8)],
      });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: ReactiveFormBuilder(
          form: buildForm,
          builder: (context, form, child) {
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    gapH32,
                    ReactiveTextField<String>(
                      formControlName: 'cellPhone',
                      keyboardType: TextInputType.phone,
                      validationMessages: {
                        ValidationMessage.required: (_) =>
                            'The Cellphone must not be empty',
                      },
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'Cellphone',
                        helperText: '',
                        helperStyle: TextStyle(height: 0.7),
                        errorStyle: TextStyle(height: 0.7),
                      ),
                    ),
                    gapH8,
                    const SizedBox(height: 16.0),
                    ReactiveTextField<String>(
                      formControlName: 'password',
                      keyboardType: TextInputType.visiblePassword,
                      obscureText: true,
                      validationMessages: {
                        ValidationMessage.required: (_) =>
                            'The password must not be empty',
                        ValidationMessage.minLength: (_) =>
                            'The password must be at least 8 characters',
                      },
                      textInputAction: TextInputAction.done,
                      decoration: const InputDecoration(
                        labelText: 'Password',
                        helperText: '',
                        helperStyle: TextStyle(height: 0.7),
                        errorStyle: TextStyle(height: 0.7),
                      ),
                    ),
                    gapH32,
                    gapH32,
                    ElevatedButton(
                      style: const ButtonStyle(
                        elevation: MaterialStatePropertyAll(8.0),
                      ),
                      onPressed: () async {
                        ppx('$mm ... navigating to CountryCitySelector ...');
                        NavigationUtils.navigateToPage(
                            context: context,
                            widget: CountryCitySelector(
                              onCountrySelected: (mCountry) {
                                ppx('$mm ... onCountrySelected: ${mCountry.emoji} ${mCountry.name} ...');
                                onCountrySelected(mCountry);
                              },
                              onCitySelected: (mCity) {
                                ppx('$mm ... onCitySelected:  ${mCity.name} ...');
                                onCitySelected(mCity);
                              },
                            ));
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Text(
                          'Select Your City/Town',
                          style: myTextStyleMediumLarge(context, 16),
                        ),
                      ),
                    ),
                    gapH32,
                    gapH32,
                    showRegisterButton
                        ? ElevatedButton(
                            style: const ButtonStyle(
                              elevation: MaterialStatePropertyAll(8.0),
                            ),
                            onPressed: () {
                              if (form.valid) {
                                ppx(form.value);
                              } else {
                                form.markAllAsTouched();
                              }
                              onSubmit(form.value);
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Text(
                                'Register',
                                style: myTextStyleMediumLarge(context, 20),
                              ),
                            ),
                          )
                        : gapW16,
                    const SizedBox(height: 16.0),
                  ],
                ),
              ),
            );
          }),
    );
  }
}
