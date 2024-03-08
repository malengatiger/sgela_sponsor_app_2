import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:sgela_services/data/branding.dart';
import 'package:sgela_services/data/country.dart';
import 'package:sgela_services/data/organization.dart';
import 'package:sgela_services/services/revenue_cat/constants.dart';
import 'package:sgela_services/sgela_util/functions.dart';
import 'package:sgela_services/sgela_util/sponsor_prefs.dart';
import 'package:sgela_shared_widgets/util/dialogs.dart';
import 'package:sgela_shared_widgets/widgets/org_logo_widget.dart';


class RevenueCat extends StatefulWidget {
  const RevenueCat({super.key});

  @override
  RevenueCatState createState() => RevenueCatState();
}

class RevenueCatState extends State<RevenueCat>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  Country? country;
  Organization? organization;
  SponsorPrefs prefs = GetIt.instance<SponsorPrefs>();
  static const mm = '🔵🔵🔵🔵 RevenueCat  🔵🔵';

  @override
  void initState() {
    _controller = AnimationController(vsync: this);
    super.initState();
    _getData();
  }

  List<Branding> brandings = [];
  bool _busy = false;

  _getData() async {
    pp('$mm ... getting data ...');
    setState(() {
      _busy = false;
    });
    try {
      organization = prefs.getOrganization();
      country = prefs.getCountry();
      brandings = prefs.getBrandings();
      pp('$mm brandings available ${brandings.length}');
    } catch (e, s) {
      pp('$e $s');
      showErrorDialog(context, '$e');
    }
    setState(() {
      _busy = false;
    });
  }

  bool entitlementIsActive = false;
  CustomerInfo? mCustomerInfo;
  EntitlementInfo? entitlement;

  Future<void> initPlatformState() async {
    var appUserId = await Purchases.appUserID;
    pp('$mm ... initPlatformState: appUserId: $appUserId');
    Purchases.addCustomerInfoUpdateListener((customerInfo) async {
      pp('$mm addCustomerInfoUpdateListener: ${customerInfo.toJson()}');
      mCustomerInfo = customerInfo;
      entitlement = customerInfo.entitlements.all[Constants.entitlementId];
      entitlementIsActive = entitlement?.isActive ?? false;

      setState(() {});
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Branding? branding;
    if (brandings.isNotEmpty) {
      branding = brandings.first;
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
                return const Stack();
              },
              tablet: (_) {
                return const Stack();
              },
              desktop: (_) {
                return const Stack();
              },
            )));
  }
}
