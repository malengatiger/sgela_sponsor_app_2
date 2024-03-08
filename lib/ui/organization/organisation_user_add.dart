import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:sgela_services/data/branding.dart';
import 'package:sgela_services/data/organization.dart';
import 'package:sgela_services/services/auth_service.dart';
import 'package:sgela_services/sgela_util/sponsor_prefs.dart';
import 'package:sgela_shared_widgets/widgets/busy_indicator.dart';
import 'package:sgela_shared_widgets/widgets/org_logo_widget.dart';
import 'package:sgela_sponsor_app/util/functions.dart';
import 'package:sgela_services/data/org_user.dart';


class OrganisationUserAdd extends StatefulWidget {
  const OrganisationUserAdd({super.key});

  @override
  OrganisationUserAddState createState() => OrganisationUserAddState();
}

class OrganisationUserAddState extends State<OrganisationUserAdd>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  SponsorPrefs prefs = GetIt.instance<SponsorPrefs>();
  AuthService authService = GetIt.instance<AuthService>();

  String? logoUrl;
  Organization? organization;
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  static const mm = '🧡🧡🧡🧡🧡🧡 OrganisationUserAdd: 🧡';
  bool _busy = false;
  Branding? branding;
  @override
  void initState() {
    _controller = AnimationController(vsync: this);
    super.initState();
    _getBranding();
  }

  _getBranding() async {
    var variableName = prefs.getBrandings();
    if (variableName.isNotEmpty) {
      branding = variableName.first;
    }
    organization = prefs.getOrganization();
    setState(() {});
  }

  _submitUser() async {
    ppx('$mm ... _submitUser ... check controllers ...');
    if (firstNameController.text.isEmpty) {
      showToast(
          message: 'Please enter user first name',
          backgroundColor: Colors.red,
          textStyle: myTextStyleMediumWithColor(context, Colors.white),
          padding: 24.0,
          context: context);
      return;
    }
    if (lastNameController.text.isEmpty) {
      showToast(
          message: 'Please enter user surname',
          backgroundColor: Colors.red,
          textStyle: myTextStyleMediumWithColor(context, Colors.white),
          padding: 24.0,
          context: context);
      return;
    }
    if (emailController.text.isEmpty) {
      showToast(
          message: 'Please enter user email address',
          backgroundColor: Colors.red,
          textStyle: myTextStyleMediumWithColor(context, Colors.white),
          padding: 24.0,
          context: context);
      return;
    }
    _dismissKeyboard(context);
    setState(() {
      _busy = true;
    });
    try {
      var user = OrgUser(
        firstName: firstNameController.text,
        lastName: lastNameController.text,
        email: emailController.text,
        organizationId: organization!.id!,
        organizationName: organization!.name!,
        activeFlag: true, cellphone: '', date: '', id: 65676,
      );
      //await authService.authenticateUser(user);
      if (mounted) {
        showToast(message: 'User added to organization app', context: context);
        Navigator.of(context).pop(user);
      }
    } catch (e) {
      ppx(e);
      if (mounted) {
        showErrorDialog(context, '$e');
      }
    }
    setState(() {
      _busy = false;
    });
  }

  void _dismissKeyboard(BuildContext context) {
    final currentFocus = FocusScope.of(context);
    if (!currentFocus.hasPrimaryFocus && currentFocus.hasFocus) {
      FocusManager.instance.primaryFocus?.unfocus();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String name = '';
    if (organization != null) {
      name = organization!.name!;
    }
    return SafeArea(
        child: Scaffold(
      appBar: AppBar(
        title: OrgLogoWidget(
          branding: branding,
        ),
      ),
      body: ScreenTypeLayout.builder(
        mobile: (_) {
          return Stack(
            children: [
              SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Card(
                    elevation: 8,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        gapH32,
                        _busy? gapH32: gapH4,
                        _busy
                            ? const BusyIndicator(
                                caption: 'Sending new user',
                                showClock: true,
                              )
                            : UserForm(
                                firstNameController: firstNameController,
                                lastNameController: lastNameController,
                                emailController: emailController,
                                onDone: () {
                                  _submitUser();
                                }),
                      ],
                    ),
                  ),
                ),
              )
            ],
          );
        },
        tablet: (_) {
          return const Stack();
        },
        desktop: (_) {
          return const Stack();
        },
      ),
    ));
  }
}

class UserForm extends StatelessWidget {
  const UserForm(
      {super.key,
      required this.firstNameController,
      required this.lastNameController,
      required this.emailController,
      required this.onDone});

  final TextEditingController firstNameController;
  final TextEditingController lastNameController;
  final TextEditingController emailController;

  final Function onDone;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 460,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'User Form',
              style: myTextStyle(
                  context, Theme.of(context).primaryColor, 24, FontWeight.w900),
            ),
            gapH32,
            TextField(
              controller: firstNameController,
              keyboardType: TextInputType.name,
              decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  label: Text('First Name'),
                  hintText: 'Please enter first name'),
            ),
            gapH16,
            TextField(
              controller: lastNameController,
              keyboardType: TextInputType.name,
              decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  label: Text('Surname'),
                  hintText: 'Please enter surname'),
            ),
            gapH16,
            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  label: Text('Email Address'),
                  hintText: 'Please enter user email address'),
            ),
            gapH16,
            gapH32,
            SizedBox(
              width: 300,
              child: ElevatedButton(
                  style: const ButtonStyle(
                    elevation: MaterialStatePropertyAll(8.0),
                  ),
                  onPressed: () {
                    onDone();
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Text(
                      'Submit User',
                      style: myTextStyle(
                          context,
                          Theme.of(context).primaryColor,
                          20,
                          FontWeight.normal),
                    ),
                  )),
            )
          ],
        ),
      ),
    );
  }
}
