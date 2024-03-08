import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:sgela_shared_widgets/widgets/org_logo_widget.dart';
import 'package:sgela_sponsor_app/ui/organization/registration_form2.dart';
import 'package:sgela_sponsor_app/util/navigation_util.dart';
import 'package:sgela_services/sgela_util/registration_stream_handler.dart';

import '../../util/functions.dart';

class RegistrationForm extends StatefulWidget {
  const RegistrationForm({super.key});

  @override
  RegistrationFormState createState() => RegistrationFormState();
}

class RegistrationFormState extends State<RegistrationForm>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  CompletionStreamHandler handler =
      GetIt.instance<CompletionStreamHandler>();
  late StreamSubscription<bool> regSubscription;

  @override
  void initState() {
    _controller = AnimationController(vsync: this);
    super.initState();
    _listen();
  }

  _listen() {
    regSubscription = handler.registrationStream.listen((completed) {
      ppx('$mm registrationStream ... completed: $completed');
      if (completed) {
        if (mounted) {
          Navigator.of(context).pop();
        }
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const OrgLogoWidget(
          ),
        ),
        body: ScreenTypeLayout.builder(
          mobile: (_) {
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Card(
                  child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: MyForm(
                  onNext: (map) async {
                    ppx('$mm Next pressed ... check that all fields are filled in: $map');
                    bool filledIn = false;
                    int cnt = 0;
                    if (map['orgName'] != null) {
                      cnt++;
                    }
                    if (map['adminFirstName'] != null) {
                      cnt++;
                    }
                    if (map['adminLastName'] != null) {
                      cnt++;
                    }
                    if (map['email'] != null) {
                      cnt++;
                    }
                    if (cnt == 4) {
                      filledIn = true;
                    }
                    if (filledIn) {
                      _navigateToForm2(context, map);
                    }
                  },
                ),
              )),
            );
          },
        ));
  }

  void _navigateToForm2(BuildContext context, Map<String, dynamic> map) async {
    var ok = await NavigationUtils.navigateToPage(
        context: context,
        widget: RegistrationFormFinal(
          variables: map,
        ));
  }

  static const mm = '🌀🌀🌀🌀🌀RegistrationForm 🌀🌀';
}

class MyForm extends StatelessWidget {
  const MyForm({super.key, required this.onNext});

  final Function(Map<String, dynamic>) onNext;

  FormGroup buildForm() => fb.group(<String, Object>{
        'email': FormControl<String>(
          validators: [Validators.required, Validators.email],
        ),
        'orgName': FormControl<String>(
          validators: [Validators.required, Validators.email],
        ),
        'adminFirstName': FormControl<String>(
          validators: [Validators.required, Validators.email],
        ),
        'adminLastName': FormControl<String>(
          validators: [Validators.required, Validators.email],
        ),
      });

  @override
  Widget build(BuildContext context) {
    return ReactiveFormBuilder(
        form: buildForm,
        builder: (context, form, child) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  gapH8,
                  ReactiveTextField<String>(
                    formControlName: 'orgName',
                    keyboardType: TextInputType.name,
                    validationMessages: {
                      ValidationMessage.required: (_) =>
                          'The Organization must not be empty',
                    },
                    textInputAction: TextInputAction.next,
                    style: myTextStyleSmall(context),
                    decoration: const InputDecoration(
                      labelText: 'Organization Name',
                      helperText: '',
                      helperStyle: TextStyle(height: 0.6),
                      errorStyle: TextStyle(height: 0.6),
                    ),
                  ),
                  gapH16,
                  ReactiveTextField<String>(
                    formControlName: 'adminFirstName',
                    keyboardType: TextInputType.name,
                    style: myTextStyleSmall(context),
                    validationMessages: {
                      ValidationMessage.required: (_) =>
                          'The Administrator first name must not be empty',
                    },
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: 'Administrator First Name',
                      helperText: '',
                      helperStyle: TextStyle(height: 0.6),
                      errorStyle: TextStyle(height: 0.6),
                    ),
                  ),
                  gapH16,
                  ReactiveTextField<String>(
                    formControlName: 'adminLastName',
                    keyboardType: TextInputType.name,
                    validationMessages: {
                      ValidationMessage.required: (_) =>
                          'The Administrator surname must not be empty',
                    },
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: 'Administrator Surname',
                      helperText: '',
                      helperStyle: TextStyle(height: 0.6),
                      errorStyle: TextStyle(height: 0.6),
                    ),
                  ),
                  gapH16,
                  ReactiveTextField<String>(
                    formControlName: 'email',
                    keyboardType: TextInputType.emailAddress,
                    validationMessages: {
                      ValidationMessage.required: (_) =>
                          'The email must not be empty',
                      ValidationMessage.email: (_) =>
                          'The email value must be a valid email',
                      'unique': (_) => 'This email is already in use',
                    },
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      helperText: '',
                      helperStyle: TextStyle(height: 0.6),
                      errorStyle: TextStyle(height: 0.6),
                    ),
                  ),
                  gapH32,
                  ElevatedButton(
                    style: const ButtonStyle(
                      elevation: MaterialStatePropertyAll(8.0),
                    ),
                    onPressed: () {
                      if (form.valid) {
                        ppx(form.value);
                      } else {
                        form.markAllAsTouched();
                      }
                      _onNext(form, context);
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'Next',
                        style: myTextStyleMediumLarge(context, 24),
                      ),
                    ),
                  ),
                  gapH32,
                ],
              ),
            ),
          );
        });
  }

  _onNext(FormGroup formGroup, BuildContext context) {
    ppx('$mm _onNext: formGroup.value : ${formGroup.value}');
    onNext(formGroup.value);
  }

  static const mm = '🌍🌍🌍RegistrationForm1';
}
