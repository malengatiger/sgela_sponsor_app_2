import 'dart:async';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:sgela_services/data/branding.dart';
import 'package:sgela_services/data/organization.dart';
import 'package:sgela_services/services/firestore_service_sponsor.dart';
import 'package:sgela_services/sgela_util/dark_light_control.dart';
import 'package:sgela_services/sgela_util/sponsor_prefs.dart';
import 'package:sgela_services/sgela_util/widget_prefs.dart';
import 'package:sgela_shared_widgets/widgets/busy_indicator.dart';
import 'package:sgela_shared_widgets/widgets/color_gallery.dart';
import 'package:sgela_shared_widgets/widgets/org_logo_widget.dart';
import 'package:sgela_services/services/repository.dart';
import 'package:sgela_sponsor_app/util/navigation_util.dart';
import 'package:sgela_services/sgela_util/registration_stream_handler.dart';

import '../../util/functions.dart';

class BrandingUploadTwo extends StatefulWidget {
  const BrandingUploadTwo(
      {super.key,
      required this.organization,
      this.logoFile,
      this.splashFile,
      this.branding});

  final Organization organization;
  final File? logoFile;
  final File? splashFile;
  final Branding? branding;

  @override
  State<BrandingUploadTwo> createState() => _BrandingUploadTwoState();
}

class _BrandingUploadTwoState extends State<BrandingUploadTwo> {
  TextEditingController taglineController = TextEditingController();
  TextEditingController splashUrlController = TextEditingController();

  TextEditingController splashTimeController = TextEditingController(text: '5');

  static const mm = '🥦🥦🥦🥦🥦🥦 BrandingUploadTwo 🔵🔵';
  SponsorFirestoreService firestoreService =
      GetIt.instance<SponsorFirestoreService>();

  RepositoryService repositoryService = GetIt.instance<RepositoryService>();
  SponsorPrefs prefs = GetIt.instance<SponsorPrefs>();
  WidgetPrefs widgetPrefs = GetIt.instance<WidgetPrefs>();

  CompletionStreamHandler handler =
      GetIt.instance<CompletionStreamHandler>();
  late StreamSubscription<bool> regSubscription;

  bool _busy = false;
  Branding? branding;
  List<Branding> brandings = [];
  String? logoUrl;

  void _dismissKeyboard(BuildContext context) {
    final currentFocus = FocusScope.of(context);
    if (!currentFocus.hasPrimaryFocus && currentFocus.hasFocus) {
      FocusManager.instance.primaryFocus?.unfocus();
    }
  }

  @override
  void initState() {
    super.initState();
    _getLogoAndBrandings(true);
  }

  _getLogoAndBrandings(bool refresh) async {
    ppx('$mm ... _getLogoAndBrandings starting ... refresh: $refresh');

    brandings =
        await firestoreService.getBranding(widget.organization.id!, refresh);
    if ((widget.branding != null)) {
      branding = widget.branding;
      _setControllers();
    } else if (brandings.isNotEmpty) {
      branding = brandings.first;
      _setControllers();
    } else {
      branding = Branding(organizationId: widget.organization.id!, id: DateTime.now().millisecondsSinceEpoch,
          date: DateTime.now().toUtc().toIso8601String(),
          logoUrl: logoUrl,
          splashUrl: null,
          tagLine: null, organizationName: widget.organization.name,
          organizationUrl: null,
          splashTimeInSeconds: 10,
          colorIndex: colorIndex, boxFit: 0, activeFlag: true);
    }
    setState(() {});
  }

  void _setControllers() {
    splashUrlController = TextEditingController(text: branding?.splashUrl!);
    taglineController = TextEditingController(text: branding?.tagLine!);
    splashTimeController =
        TextEditingController(text: '${branding?.splashTimeInSeconds!}');
    logoUrl = branding!.logoUrl;

    colorIndex =
        branding!.colorIndex == null ? colorIndex : branding!.colorIndex!;
    logoUrl = branding?.logoUrl!;

  }

  _onSubmitBranding() async {
    ppx('$mm ... _onSubmitBranding ...');
    _dismissKeyboard(context);

    setState(() {
      _busy = true;
    });

    var prefix = 'https://';
    try {
      if (widget.logoFile == null && widget.splashFile == null) {
        if (brandings.isEmpty && branding == null) {
          throw Exception('Brandings not available');
        }

        branding!.splashTimeInSeconds = splashTimeController.text.isNotEmpty
            ? int.parse(splashTimeController.text)
            : branding!.splashTimeInSeconds == null
                ? 10
                : branding!.splashTimeInSeconds!;
        branding!.tagLine = taglineController.text.isEmpty
            ? branding!.tagLine
            : taglineController.text;
        branding!.organizationUrl = splashUrlController.text.isEmpty
            ? branding!.organizationUrl
            : '$prefix${splashUrlController.text}';
        branding!.colorIndex = colorIndex;

        branding = await repositoryService.uploadBrandingWithNoFiles(branding!);
      } else {
        branding = await repositoryService.uploadBranding(
            organizationId: branding!.id!,
            organizationName: branding!.organizationName!,
            tagLine:
                taglineController.text.isEmpty ? '' : taglineController.text,
            orgUrl: splashUrlController.text.isEmpty
                ? ''
                : '$prefix${splashUrlController.text}',
            logoFile: widget.logoFile,
            splashFile: widget.splashFile,
            colorIndex: colorIndex,
            splashTimeInSeconds: splashTimeController.text.isNotEmpty
                ? int.parse(splashTimeController.text)
                : branding!.splashTimeInSeconds == null
                ? 10
                : branding!.splashTimeInSeconds!);
      }
      ppx('$mm ... _onSubmitBranding completed! ${branding!.toJson()}...');
      // if (widget.branding) {
      //
      // }
      // await _getLogoAndBrandings(true);
      // handler.setCompleted();
      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      ppx(e);
      if (mounted) {
        showErrorDialog(context, '$e');
      }
    }
    brandings =
        await firestoreService.getBranding(widget.organization.id!, false);

    setState(() {
      _busy = false;
    });
  }

  int colorIndex = 0;
  ColorWatcher colorWatcher = GetIt.instance<ColorWatcher>();

  _navigateToColorGallery() async {
    _dismissKeyboard(context);
    var res = await NavigationUtils.navigateToPage(
        context: context,
        widget: ColorGallery(colorWatcher: colorWatcher));
    if (res is int) {
      setState(() {
        colorIndex = res;
      });
    } else {
      colorIndex = prefs.getColorIndex();
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    bool isRemote = false;
    if (widget.logoFile == null &&
        widget.splashFile == null &&
        brandings.isNotEmpty) {
      isRemote = true;
    }
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
        ),
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  isRemote
                      ? ThumbnailsRemote(
                          logoUrl: branding!.logoUrl!,
                          splashUrl: branding!.splashUrl!,
                        )
                      : Thumbnails(
                          logoFile: widget.logoFile,
                          splashFile: widget.splashFile),
                  gapH32,
                  Text(
                    'This data is optional',
                    style: myTextStyleMediumWithColor(context, Colors.grey),
                  ),
                  gapH8,
                  TextField(
                    controller: taglineController,
                    minLines: 1,
                    maxLines: 2,
                    decoration: InputDecoration(
                        // border: const OutlineInputBorder(),
                        label: Text(
                          'Marketing Tagline',
                          style: myTextStyleSmall(context),
                        ),
                        hintText: 'Enter your marketing tagline'),
                  ),
                  gapH16,
                  TextField(
                    controller: splashUrlController,
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                        // border: const OutlineInputBorder(),
                        label: Text('Organization Information Link',
                            style: myTextStyleSmall(context)),
                        hintText: 'Enter your organization info link'),
                  ),
                  gapH16,
                  TextField(
                    controller: splashTimeController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                        // border: const OutlineInputBorder(),
                        label: Text('Splash time in seconds',
                            style: myTextStyleSmall(context)),
                        hintText:
                            'Enter the seconds your splash image will show'),
                  ),
                  gapH32,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        color: getColors().elementAt(colorIndex),
                        width: 28,
                        height: 28,
                      ),
                      gapW16,
                      ElevatedButton(
                          style: const ButtonStyle(
                            elevation: MaterialStatePropertyAll(8.0),
                          ),
                          onPressed: () {
                            _navigateToColorGallery();
                          },
                          child: const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text('Pick Default Colour'),
                          )),
                    ],
                  ),
                  gapH32,
                  _busy
                      ? const BusyIndicator(
                          caption: 'Uploading your branding elements',
                        )
                      : ElevatedButton(
                          style: const ButtonStyle(
                            elevation: MaterialStatePropertyAll(8.0),
                          ),
                          onPressed: () {
                            _onSubmitBranding();
                          },
                          child: const Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Text('Upload Branding Materials'),
                          )),
                  gapH32,
                ],
              ),
            ),
          )
        ],
      ),
    ));
  }
}

class ThumbnailsRemote extends StatelessWidget {
  const ThumbnailsRemote(
      {super.key,
      this.logoHeight,
      this.splashHeight,
      required this.logoUrl,
      required this.splashUrl});

  final String splashUrl;
  final String logoUrl;

  final double? logoHeight, splashHeight;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: logoHeight == null ? 32 : logoHeight!,
          child: CachedNetworkImage(imageUrl: logoUrl),
        ),
        gapH16,
        SizedBox(
            height: splashHeight == null ? 160 : splashHeight!,
            width: 400,
            child: CachedNetworkImage(
              imageUrl: splashUrl,
              fit: BoxFit.fitHeight,
            )),
      ],
    );
  }
}

class Thumbnails extends StatelessWidget {
  const Thumbnails(
      {super.key,
      this.logoFile,
      required this.splashFile,
      this.logoHeight,
      this.splashHeight,
      this.logoUrl});

  final File? logoFile;
  final File? splashFile;
  final String? logoUrl;

  final double? logoHeight, splashHeight;

  @override
  Widget build(BuildContext context) {
    Widget? logoImage;
    Widget? splashImage;
    if (logoUrl != null) {
      logoImage = CachedNetworkImage(imageUrl: logoUrl!);
    }
    if (logoFile != null) {
      logoImage = Image.file(logoFile!);
    }
    if (splashFile != null) {
      splashImage = Image.file(splashFile!);
    }
    return Column(
      children: [
        SizedBox(
          height: logoHeight == null ? 32 : logoHeight!,
          child: logoImage ?? gapW32,
        ),
        gapH8,
        SizedBox(
          height: splashHeight == null ? 240 : splashHeight!,
          width: 320,
          child: splashImage,
        ),
      ],
    );
  }
}
