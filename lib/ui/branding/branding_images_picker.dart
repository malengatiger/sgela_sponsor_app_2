import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:image_picker/image_picker.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:sgela_services/data/branding.dart';
import 'package:sgela_services/data/organization.dart';
import 'package:sgela_services/services/firestore_service_sponsor.dart';
import 'package:sgela_services/sgela_util/sponsor_prefs.dart';
import 'package:sgela_sponsor_app/util/environment.dart';
import 'package:sgela_sponsor_app/util/functions.dart';


class BrandingImagesPicker extends StatefulWidget {
  final Function(File) onLogoPicked;
  final Function(File) onSplashPicked;
  final Organization organization;

  const BrandingImagesPicker({
    super.key,
    required this.onLogoPicked,
    required this.onSplashPicked,
    required this.organization,
  });

  @override
  BrandingImagesPickerState createState() => BrandingImagesPickerState();
}

class BrandingImagesPickerState extends State<BrandingImagesPicker> {
  File? _logoFile;
  File? _splashFile;
  List<Branding> brandings = [];
  SponsorFirestoreService firestoreService = GetIt.instance<SponsorFirestoreService>();
  SponsorPrefs prefs = GetIt.instance<SponsorPrefs>();

  String? logoUrl;

  @override
  void initState() {
    super.initState();
    _getBranding();
  }

  _getBranding() async {
    logoUrl = prefs.getLogoUrl();
    brandings = await firestoreService.getBranding(widget.organization.id!, false);
    brandings.sort((a,b) => b.date!.compareTo(a.date!));
    setState(() {});
  }

  Future<void> _pickLogoImage() async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );

    if (pickedFile != null) {
      final file = File(pickedFile.path);
      final fileSize = await file.length();

      if (fileSize <= 1024 * 1024) {
        setState(() {
          _logoFile = file;
        });
        widget.onLogoPicked(file);
      } else {
        // File size exceeds 1MB
        // Handle the error or show a message to the user
      }
    }
  }

  Future<void> _pickSplashImage() async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );

    if (pickedFile != null) {
      final file = File(pickedFile.path);
      final fileSize = await file.length();

      if (fileSize <= 4 * 1024 * 1024) {
        setState(() {
          _splashFile = file;
        });
        widget.onSplashPicked(file);
      } else {
        if (mounted) {
          showErrorDialog(context, 'The image you picked is too big');
        }
      }
    }
  }

  Widget _getExistingLogo() {
    if (_logoFile != null) {
      return Image.file(_logoFile!, height: 48, width: 96,);
    }
    if (logoUrl != null) {
      return CachedNetworkImage(
        imageUrl: logoUrl!,
        fit: BoxFit.fill,
      );
    }
    Branding? branding;
    if (brandings.isNotEmpty) {
      branding = brandings.first;
      return CachedNetworkImage(
        imageUrl: branding.logoUrl!,
        fit: BoxFit.fill,
      );
    }

    return CachedNetworkImage(
      imageUrl: SponsorsEnvironment.sgelaLogoUrl,
      fit: BoxFit.fill,
    );
  }
  double containerHeight = 0.0, containerWidth = 0.0;
  Widget _getExistingSplash() {

    if (_splashFile != null) {
      Image image = Image.file(_splashFile!);
      image.image
          .resolve(const ImageConfiguration())
          .addListener(
        ImageStreamListener(
                (ImageInfo info, bool _) {
              double imageWidth =
              info.image.width.toDouble();
              double imageHeight =
              info.image.height.toDouble();

              double aspectRatio =
                  imageWidth / imageHeight;
              if (aspectRatio > 1) {
                // Landscape image
                containerHeight =
                    containerWidth / aspectRatio;
              } else {
                // Portrait image
                containerWidth =
                    containerHeight * aspectRatio;
              }
            }),
      );
      return image;
    }
    Branding? branding;
    if (brandings.isNotEmpty) {
      branding = brandings.first;
      return CachedNetworkImage(
        imageUrl: branding.splashUrl!,
        fit: BoxFit.cover,
      );
    }

    return CachedNetworkImage(
      imageUrl: SponsorsEnvironment.sgelaSplashUrl,
      fit: BoxFit.cover,
    );
  }

  @override
  Widget build(BuildContext context) {

    return SafeArea(
      child: Scaffold(

        body: ScreenTypeLayout.builder(
          mobile: (context) {
            return Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SizedBox(
                    width: double.infinity,
                    child: Card(
                      // color: Colors.red,
                      elevation: 8,
                      child: Column(
                        children: [
                          gapH16,
                          SizedBox(
                            height: 64,
                            child: _getExistingLogo()
                          ),
                          SizedBox(
                            width: 300,
                            child: ElevatedButton(
                              style: const ButtonStyle(
                                elevation: MaterialStatePropertyAll(8.0),
                              ),
                              onPressed: _pickLogoImage,
                              child: const Text('Pick Logo'),
                            ),
                          ),
                          gapH8,
                          Expanded(
                            child: Card(
                              child: LayoutBuilder(
                                builder: (BuildContext context,
                                    BoxConstraints constraints) {
                                  containerWidth = constraints.maxWidth;
                                  containerHeight =
                                      constraints.maxHeight;
                                  return SizedBox(
                                    width: containerWidth,
                                    height: containerHeight,
                                    child: _getExistingSplash(),
                                  );
                                },
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 300,
                            child: ElevatedButton(
                              style: const ButtonStyle(
                                elevation: MaterialStatePropertyAll(8.0),
                              ),
                              onPressed: _pickSplashImage,
                              child: const Text('Pick Splash Image'),
                            ),
                          ),
                          gapH8,
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
          tablet: (context) {
            return const Stack();
          },
          desktop: (context) {
            return const Stack();
          },
        ),
      ),
    );
  }
}
