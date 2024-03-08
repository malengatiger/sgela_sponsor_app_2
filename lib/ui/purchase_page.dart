import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:sgela_services/data/organization.dart';
import 'package:sgela_services/data/sgela_product_details.dart';
import 'package:sgela_services/services/firestore_service_sponsor.dart';
import 'package:sgela_services/services/in_app_purchase_service.dart';
import 'package:sgela_services/sgela_util/functions.dart';
import 'package:sgela_services/sgela_util/prefs.dart';
import 'package:sgela_shared_widgets/widgets/busy_indicator.dart';
import 'package:sgela_sponsor_app/in_app/paywall_widget.dart';

import '../util/functions.dart';

class PurchasePage extends StatefulWidget {
  const PurchasePage({super.key});

  @override
  PurchasePageState createState() => PurchasePageState();
}

class PurchasePageState extends State<PurchasePage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  InAppPurchaseService inAppPurchaseService =
      GetIt.instance<InAppPurchaseService>();

  static const mm = '🔵🔵🔵🔵 PurchasePage  🔵🔵';
  List<SgelaProductDetails> sgelaProductDetails = [];
  List<ProductDetails> productDetails = [];
  List<ProductDetails> subscriptionDetails = [];
  List<SgelaProductDetails> allDetails = [];
  SponsorFirestoreService firestoreService =
      GetIt.instance<SponsorFirestoreService>();
  Prefs prefs = GetIt.instance<Prefs>();

  Organization? organization;

  @override
  void initState() {
    _controller = AnimationController(vsync: this);
    super.initState();
    _getData();
  }

  bool _busy = false;

  _getData() async {
    pp('$mm ....................... getting data ...');
    setState(() {
      _busy = true;
    });
    try {
      organization = prefs.getOrganization();
      productDetails = inAppPurchaseService.oneTimeProductDetails;
      subscriptionDetails = inAppPurchaseService.subscriptionDetails;
      sgelaProductDetails =
          await firestoreService.getSgelaProductDetails(organization!.id!);

      for (var element in subscriptionDetails) {
        allDetails.add(_buildDetails(element, false));
      }
      for (var element in productDetails) {
        allDetails.add(_buildDetails(element, true));
      }

      pp('$mm ... 🍎productDetails: ${productDetails.length} '
          '🍎subscriptionDetails: ${subscriptionDetails.length} '
          '🍎sgelaProductDetails: ${sgelaProductDetails.length}');
    } catch (e) {
      pp(e);
      if (mounted) {
        showErrorDialog(context, '$e');
      }
    }
    setState(() {
      _busy = false;
    });
  }

  SgelaProductDetails _buildDetails(ProductDetails pd, bool isOneTime) {
    var sg = SgelaProductDetails(
        id: DateTime.now().millisecondsSinceEpoch,
        title: pd.title,
        description: pd.description,
        price: pd.price,
        rawPrice: pd.rawPrice,
        currencyCode: pd.currencyCode,
        currencySymbol: pd.currencySymbol,
        organizationId: organization!.id,
        organizationName: organization!.name,
        productId: pd.id,
        isOneTime: isOneTime,
        isAppleStore: Platform.isIOS,
        date: DateTime.now().toUtc().toIso8601String());

    return sg;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var h = MediaQuery.of(context).size.height;
    return SafeArea(
        child: Scaffold(
            appBar: AppBar(
              title: const Text('SgelaAI Sponsorships'),
            ),
            body: _busy
                ? const BusyIndicator()
                : ScreenTypeLayout.builder(
                    mobile: (_) {
                      return Stack(
                        children: [
                          PayWallWidget(sgelaProductDetails: allDetails),
                        ],
                      );
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
