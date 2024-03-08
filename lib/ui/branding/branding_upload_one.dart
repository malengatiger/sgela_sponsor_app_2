import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:sgela_services/data/branding.dart';
import 'package:sgela_services/data/organization.dart';
import 'package:sgela_services/services/firestore_service_sponsor.dart';
import 'package:sgela_services/sgela_util/registration_stream_handler.dart';
import 'package:sgela_shared_widgets/widgets/org_logo_widget.dart';
import 'package:sgela_sponsor_app/ui/branding/branding_images_picker.dart';
import 'package:sgela_sponsor_app/ui/branding/branding_upload_two.dart';
import 'package:sgela_sponsor_app/util/functions.dart';
import 'package:sgela_sponsor_app/util/navigation_util.dart';


class BrandingUploadOne extends StatefulWidget {
  const BrandingUploadOne(
      {super.key, required this.organization, this.branding});

  final Organization organization;
  final Branding? branding;

  @override
  BrandingUploadOneState createState() => BrandingUploadOneState();
}

class BrandingUploadOneState extends State<BrandingUploadOne>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  List<Branding> brandings = [];
  SponsorFirestoreService firestoreService =
      GetIt.instance<SponsorFirestoreService>();

  static const mm = '❤️🧡💛💚💙💜 BrandUpload';
  File? logoFile, splashFile;
  String? logoUrl, splashUrl, tagLine, orgUrl;

  var taglineEditingController = TextEditingController();
  var linkEditingController = TextEditingController();
  CompletionStreamHandler completionHandler =
  GetIt.instance<CompletionStreamHandler>();
  late StreamSubscription<bool> regSubscription;

  @override
  void initState() {
    _controller = AnimationController(vsync: this);
    super.initState();
    _listen();
    _getBranding();
  }

  _listen() {
    regSubscription = completionHandler.registrationStream.listen((completed) {
      ppx('$mm branding upload ... completed: $completed');
      if (completed) {
        if (mounted) {
          Navigator.of(context).pop();
        }
      }
    });
  }

  _getBranding() async {
    brandings =
        await firestoreService.getBranding(widget.organization.id!, true);
    setState(() {});
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }


  _onLogoPicked() async {
    ppx('$mm ... _onLogoPicked: ${logoFile!.path}');
    _checkFiles();
  }

  bool _checkFiles() {
    if (logoFile == null) {
      showToast(
          message: 'Pick the logo file',
          backgroundColor: Colors.black,
          padding: 20,
          context: context);
      return false;
    }
    if (splashFile == null) {
      showToast(
          message: 'Pick the splash file',
          backgroundColor: Colors.black,
          padding: 20,
          context: context);
      return false;
    }

    return false;
  }

  _onSplashPicked() async {
    ppx('$mm ... _onSplashPicked: ${splashFile!.path}');
    _checkFiles();
  }

  _navigateToBrandingUploadTwo() async {
    ppx('$mm ...... _navigateToBrandingUploadTwo ...');
    var msg = 'No new files picked, no problem!';
    if (logoFile == null && splashFile == null) {
      if (brandings.isEmpty) {
        msg = 'Please pick your logo and splash files';
        showToast(
            message: msg,
            backgroundColor: Colors.black,
            padding: 24,
            textStyle: const TextStyle(color: Colors.amber),
            context: context);
        return;
      }
    }

    Branding? branding;
    if (widget.branding != null) {
      branding = widget.branding;
    } else if (brandings.isNotEmpty) {
      branding = brandings.first;
    }
    await NavigationUtils.navigateToPage(
        context: context,
        widget: BrandingUploadTwo(
            organization: widget.organization,
            logoFile: logoFile,
            splashFile: splashFile,
            branding: branding));
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    Branding? branding;
    if (widget.branding != null) {
      branding = widget.branding!;
    } else if (brandings.isNotEmpty) {
      branding = brandings.first;
    }
    return SafeArea(
        child: Scaffold(
      appBar: AppBar(
        title: OrgLogoWidget(
          branding: branding,
          // logoUrl: logoUrl,
          height: 28,
        ),
      ),
      body: ScreenTypeLayout.builder(
        mobile: (_) {
          return Stack(
            children: [
              Column(
                children: [
                  Expanded(
                    child: SizedBox(
                      width: double.infinity,
                      child: BrandingImagesPicker(
                          onLogoPicked: (f) {
                            logoFile = f;
                            setState(() {});
                            _onLogoPicked();
                          },
                          onSplashPicked: (f) {
                            splashFile = f;
                            setState(() {});
                            _onSplashPicked();
                          },
                          organization: widget.organization),
                    ),
                  ),
                  gapH8,
                  SizedBox(
                    width: 300,
                    child: ElevatedButton(
                        style: const ButtonStyle(
                          elevation: MaterialStatePropertyAll(8.0),
                        ),
                        onPressed: () {
                          _navigateToBrandingUploadTwo();
                        },
                        child: const Padding(
                          padding: EdgeInsets.all(20.0),
                          child: Text('Next'),
                        )),
                  ),
                  gapH32,
                ],
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
