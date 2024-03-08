import 'package:badges/badges.dart' as bd;
import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:sgela_services/data/country.dart';
import 'package:sgela_services/data/organization.dart';
import 'package:sgela_services/data/sgela_product_details.dart';
import 'package:sgela_services/services/firestore_service.dart';
import 'package:sgela_services/services/in_app_purchase_service.dart';
import 'package:sgela_services/sgela_util/functions.dart';
import 'package:sgela_services/sgela_util/prefs.dart';
import 'package:sgela_shared_widgets/widgets/busy_indicator.dart';

import '../util/functions.dart';

class PayWallWidget extends StatefulWidget {
  const PayWallWidget({super.key, required this.sgelaProductDetails});

  @override
  PayWallWidgetState createState() => PayWallWidgetState();
  final List<SgelaProductDetails> sgelaProductDetails;
}

class PayWallWidgetState extends State<PayWallWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  Country? country;
  Organization? organization;
  Prefs prefs = GetIt.instance<Prefs>();
  static const mm = '🔵🔵🔵🔵 PayWallWidget  🔵🔵';
  FirestoreService firestoreService = GetIt.instance<FirestoreService>();
  InAppPurchaseService inAppPurchaseService =
      GetIt.instance<InAppPurchaseService>();

  @override
  void initState() {
    _controller = AnimationController(vsync: this);
    super.initState();
    _getData();
  }

  bool _busy = false;

  _getData() async {
    pp('$mm ... getting data ...');
    setState(() {
      _busy = false;
    });
    try {
      organization = prefs.getOrganization();
      country = prefs.getCountry();
    } catch (e) {
      pp(e);
      showErrorDialog(context, '$e');
    }
    setState(() {
      _busy = false;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  _submit(SgelaProductDetails spd) async {
    pp('$mm ... submit purchase, check product id: .... ${spd.toJson()}');
    setState(() {
      _busy = true;
    });
    try {
      var prod = ProductDetails(
              id: spd.productId!,
              title: spd.title!,
              description: spd.description!,
              price: spd.price!,
              rawPrice: spd.rawPrice!,
              currencyCode: spd.currencyCode!);
      //
      var res = await inAppPurchaseService
          .purchaseProduct(prod, !spd.isOneTime!);
      pp('$mm ... submit purchase done .... $res ... will wait for completion');
    } catch (e,s) {
      pp('$mm ERROR: $e - $s');
    }
    setState(() {
      _busy = false;
    });
  }

  PageController pageController = PageController();
  int _pageNumber = 0;

  @override
  Widget build(BuildContext context) {
    return ScreenTypeLayout.builder(
      mobile: (_) {
        return Stack(
          children: [
            Column(
              children: [
                gapH32,
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Swipe to see all sponsorship levels'),
                    gapW16,
                    bd.Badge(
                      badgeContent:
                          Text('${widget.sgelaProductDetails.length}'),
                      badgeStyle: const bd.BadgeStyle(
                        padding: EdgeInsets.all(8),
                      ),
                    ),
                  ],
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: PageView.builder(
                        itemCount: widget.sgelaProductDetails.length,
                        controller: pageController,
                        onPageChanged: (m) {
                          setState(() {
                            _pageNumber = m;
                          });
                        },
                        itemBuilder: (_, index) {
                          var prod =
                              widget.sgelaProductDetails.elementAt(index);

                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: _busy? const BusyIndicator(
                              caption: 'Purchasing sponsorship ...',
                            ): PayWallView(
                              productDetails: prod,
                              onSubmit: (prod) {
                                _submit(prod);
                              },
                            ),
                          );
                        }),
                  ),
                ),
                gapH32,
                DotsIndicator(
                  onTap: (p) {
                    setState(() {
                      pageController.animateToPage(p,
                          duration: const Duration(milliseconds: 1000),
                          curve: Curves.bounceIn);
                    });
                  },
                  position: _pageNumber,
                  dotsCount: widget.sgelaProductDetails.length,
                  decorator: DotsDecorator(
                      activeSize: const Size.square(18.0),
                      activeShape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24.0),
                      ),
                      activeColor: Colors.teal),
                ),
                gapH32
              ],
            ),
          ],
        );
      },
      tablet: (_) {
        return const Stack();
      },
      desktop: (_) {
        return const Stack();
      },
    );
  }
}

class PayWallView extends StatelessWidget {
  const PayWallView(
      {super.key, required this.productDetails, required this.onSubmit});

  final SgelaProductDetails productDetails;
  final Function(SgelaProductDetails) onSubmit;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 8,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            gapH32,
            Text(
              productDetails.title!,
              style: myTextStyleMediumLarge(context, 24),
            ),
            gapH32,
            Text(productDetails.description!),
            gapH16,
            Text(productDetails.price!,
                style: myTextStyleMediumLarge(context, 32)),
            gapH32,
            gapH32,
            SizedBox(
              width: 300,
              height: 64,
              child: ElevatedButton(
                  style: const ButtonStyle(
                    elevation: MaterialStatePropertyAll(12.0),
                    backgroundColor: MaterialStatePropertyAll(Colors.blue),
                  ),
                  onPressed: () {
                    onSubmit(productDetails);
                  },
                  child: Text(
                    'Buy',
                    style: myTextStyle(context, Colors.white,
                        36, FontWeight.w900),
                  )),
            ),
          ],
        ),
      ),
    );
  }
}
