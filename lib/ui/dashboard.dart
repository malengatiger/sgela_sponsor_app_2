import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:sgela_services/data/branding.dart';
import 'package:sgela_services/data/holder.dart';
import 'package:sgela_services/data/org_user.dart';
import 'package:sgela_services/data/organization.dart';
import 'package:sgela_services/data/sponsor_product.dart';
import 'package:sgela_services/services/firestore_service_sponsor.dart';
import 'package:sgela_services/sgela_util/dark_light_control.dart';
import 'package:sgela_services/sgela_util/sponsor_prefs.dart';
import 'package:sgela_services/sgela_util/widget_prefs.dart';
import 'package:sgela_shared_widgets/util/widget_prefs.dart';
import 'package:sgela_shared_widgets/widgets/color_gallery.dart';
import 'package:sgela_shared_widgets/widgets/org_logo_widget.dart';
import 'package:sgela_shared_widgets/widgets/sponsored_by.dart';
import 'package:sgela_sponsor_app/ui/branding/branding_upload_one.dart';
import 'package:sgela_sponsor_app/ui/organization/organisation_user_add.dart';
import 'package:sgela_sponsor_app/ui/purchase_page.dart';
import 'package:sgela_sponsor_app/util/functions.dart';
import 'package:sgela_sponsor_app/util/navigation_util.dart';
import 'package:sgela_services/sgela_util/registration_stream_handler.dart';


class Dashboard extends StatefulWidget {
  const Dashboard({super.key, required this.organization});

  final Organization organization;

  @override
  DashboardState createState() => DashboardState();
}

class DashboardState extends State<Dashboard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  static const mm = '🍔🍔🍔🍔 Dashboard 🍔🍔';

  SponsorPrefs prefs = GetIt.instance<SponsorPrefs>();
  WidgetPrefs widgetPrefs = GetIt.instance<WidgetPrefs>();

  ColorWatcher colorWatcher = GetIt.instance<ColorWatcher>();
  SponsorFirestoreService firestoreService = GetIt.instance<SponsorFirestoreService>();

  CompletionStreamHandler completionHandler =
  GetIt.instance<CompletionStreamHandler>();
  late StreamSubscription<Branding> brandingSubscription;

  List<Branding> brandings = [];
  List<OrgUser> users = [];
  List<PaymentMethod> paymentMethods = [];
  List<SponsorProduct> sponsorProducts = [];

  int transactions = 0;

  double averageRating = 0.0;
  Organization? organization;
  OrgUser? user;
  bool _busy = false;
  String? logoUrl;
  Branding? branding;
  late StreamSubscription<bool> regSubscription;

  @override
  void initState() {
    _controller = AnimationController(vsync: this);
    super.initState();
    _listen();
    _getData();
  }

  _listen() {
    brandingSubscription = completionHandler.brandingStream.listen((brand) {
      if (mounted) {
        setState(() {
          branding = brand;
          brandings.insert(0,brand,);
        });
      }
    });
    regSubscription = completionHandler.registrationStream.listen((completed) {
      ppx('$mm registrationStream ... completed: $completed');

      if (completed) {
        showToast(
            message: 'Branding items uploaded OK',
            backgroundColor: Colors.green,
            padding: 24,
            duration: const Duration(seconds: 6),
            context: context);
        _getData();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  _getData() async {
    setState(() {
      _busy = true;
    });
    try {
      logoUrl = prefs.getLogoUrl();
      organization = prefs.getOrganization();
      user = prefs.getUser();
      //sponsorProducts = await firestoreService.getSponsorProducts(false);
      if ((organization != null)) {
        brandings =
            await firestoreService.getBranding(organization!.id!, true);
        users = await firestoreService.getUsers(organization!.id!, true);
      } else {
        ppx('$mm org is NULL!! - FIND OUT WHY?');
      }
    } catch (e) {
      ppx(e);
      if (mounted) {
        showErrorDialog(context, '$e');
      }
    }

    if (mounted) {
      setState(() {
        _busy = false;
      });
    }
  }

  _navigateToColorPicker() {
    NavigationUtils.navigateToPage(
        context: context,
        widget: ColorGallery(colorWatcher: colorWatcher));
  }

  _navigateToAddPerson() async {
    ppx('$mm ... navigation to user add ...');
    await NavigationUtils.navigateToPage(
        context: context, widget: const OrganisationUserAdd());
    _getData();
  }

  _navigateToBrandUpload() {
    NavigationUtils.navigateToPage(
        context: context,
        widget: BrandingUploadOne(
          organization: widget.organization,
        ));
  }

  _navigateToSponsorProductSelector() {
    NavigationUtils.navigateToPage(
        context: context, widget: const PurchasePage());
  }

  @override
  Widget build(BuildContext context) {
    var tag = '';
    var name = '';
    if ((organization != null)) {
      name = organization!.name!;
      if (organization!.tagLine != null) {
        tag = organization!.tagLine!;
      }
    }
    Branding? branding;
    if (brandings.isNotEmpty) {
      branding = brandings.first;
      logoUrl = branding.logoUrl;
    }
    return SafeArea(
        child: Scaffold(
      appBar: AppBar(
        leading: gapW4,
        title: OrgLogoWidget(
          branding: branding,
        ),
        actions: [
          IconButton(
              onPressed: () {
                _navigateToColorPicker();
              },
              icon: Icon(
                Icons.color_lens_outlined,
                color: Theme.of(context).primaryColor,
              )),
          organization == null
              ? gapW4
              : IconButton(
                  onPressed: () {
                    _navigateToAddPerson();
                  },
                  icon: Icon(
                    Icons.person_add,
                    color: Theme.of(context).primaryColor,
                  )),
        ],
        bottom: PreferredSize(
            preferredSize: const Size.fromHeight(24),
            child: Column(
              children: [
                Text(tag),
                gapH4,
              ],
            )),
      ),
      body: ScreenTypeLayout.builder(
        mobile: (_) {
          return Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Card(
                  elevation: 8,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        gapH32,
                        Text(
                          "Dashboard",
                          style: myTextStyle(
                              context,
                              Theme.of(context).primaryColorLight,
                              18,
                              FontWeight.normal),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: GridView(
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 2),
                              children: [
                                TotalCard(
                                    caption: 'Users',
                                    total: users.length.toDouble()),
                                TotalCard(
                                  caption: 'Branding',
                                  total: brandings.length.toDouble(),
                                  fontSize: 48,
                                ),
                                TotalCard(
                                    caption: 'Average Rating',
                                    total: averageRating),
                                TotalCard(
                                    caption: 'Students Subscribed',
                                    total: averageRating),
                                TotalCard(
                                  caption: 'AI Requests',
                                  total: transactions.toDouble(),
                                  fontSize: 20,
                                ),
                              ],
                            ),
                          ),
                        ),
                        gapH32,
                        SizedBox(
                          height: 160,
                          child: Column(
                            children: [
                              SizedBox(
                                width: 300,
                                child: ElevatedButton.icon(
                                  style: const ButtonStyle(
                                    elevation: MaterialStatePropertyAll(4.0),
                                  ),
                                  onPressed: () {
                                    _navigateToBrandUpload();
                                  },
                                  icon: Icon(Icons.art_track,
                                      color: Theme.of(context).primaryColor),
                                  label: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Text(
                                      'Organization Branding',
                                      style: myTextStyle(
                                          context,
                                          Theme.of(context).primaryColorLight,
                                          16,
                                          FontWeight.normal),
                                    ),
                                  ),
                                ),
                              ),
                              gapH16,
                              SizedBox(
                                width: 300,
                                child: ElevatedButton.icon(
                                  style: const ButtonStyle(
                                    elevation: MaterialStatePropertyAll(8.0),
                                  ),
                                  onPressed: () {
                                    _navigateToSponsorProductSelector();
                                  },
                                  icon: Icon(
                                    Icons.back_hand_sharp,
                                    size: 20,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                  label: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Text(
                                      'Sgela AI Sponsorships',
                                      style: myTextStyle(
                                          context,
                                          Theme.of(context).primaryColorLight,
                                          16,
                                          FontWeight.normal),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 8,
                        ),
                        const SponsoredBy(
                          height: 36,
                        ),
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

class TotalCard extends StatelessWidget {
  const TotalCard(
      {super.key, required this.caption, required this.total, this.fontSize});

  final String caption;
  final double total;
  final double? fontSize;

  @override
  Widget build(BuildContext context) {
    var fmt = NumberFormat('###,###,###,###,###');
    var num = fmt.format(total);
    return Card(
      elevation: 12,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            num,
            style: myTextStyle(context, Theme.of(context).primaryColor,
                fontSize == null ? 28 : fontSize!, FontWeight.w900),
          ),
          gapH16,
          Text(
            caption,
            style: myTextStyleSmall(context),
          )
        ],
      ),
    );
  }
}
