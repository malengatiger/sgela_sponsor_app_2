import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:sgela_services/data/country.dart';
import 'package:sgela_services/data/holder.dart';
import 'package:sgela_services/data/sponsor_product.dart';
import 'package:sgela_services/services/firestore_service_sponsor.dart';
import 'package:sgela_services/sgela_util/sponsor_prefs.dart';
import 'package:sgela_services/services/rapyd_payment_service.dart';
import 'package:sgela_sponsor_app/ui/payments/payment_web_view.dart';
import 'package:sgela_sponsor_app/ui/payments/sponsor_product_widget.dart';
import 'package:sgela_sponsor_app/util/Constants.dart';
import 'package:sgela_sponsor_app/util/environment.dart';
import 'package:sgela_sponsor_app/util/functions.dart';
import 'package:sgela_sponsor_app/util/navigation_util.dart';

class CreditCardWidget extends StatefulWidget {
  const CreditCardWidget(
      {super.key, required this.cardType, required this.sponsorProduct});

  final int cardType;
  final SponsorProduct sponsorProduct;

  @override
  CreditCardWidgetState createState() => CreditCardWidgetState();
}

class CreditCardWidgetState extends State<CreditCardWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  static const mm = '🔵🔵🔵🔵🔵🔵🔵🔵 CreditCardWidget 🍎🍎';
  RapydPaymentService rapydPaymentService =
      GetIt.instance<RapydPaymentService>();
  SponsorFirestoreService firestoreService = GetIt.instance<SponsorFirestoreService>();
  SponsorPrefs prefs = GetIt.instance<SponsorPrefs>();
  List<PaymentMethod> paymentMethods = [];
  List<PaymentMethod> filtered = [];
  PaymentMethod? paymentMethod;
  Country? country;
  Customer? customer;
  final bool _busy = false;

  String cardName = '';
  String assetPath = 'assets/mastercard2.png';

  @override
  void initState() {
    _controller = AnimationController(vsync: this);
    super.initState();
    if (widget.cardType == PaymentConstants.visa) {
      cardName = 'Visa';
      assetPath = 'assets/visa1.png';
    }
    if (widget.cardType == PaymentConstants.masterCard) {
      cardName = 'MasterCard';
      assetPath = 'assets/mastercard2.png';
    }
    _getData();
  }

  _getData() async {
    country = prefs.getCountry();
    customer = prefs.getCustomer();
    paymentMethods =
        await rapydPaymentService.getCountryPaymentMethods(country!.iso2!);

    if (widget.cardType == PaymentConstants.visa) {
      for (var value in paymentMethods) {
        if (value.type!.contains('visa')) {
          paymentMethod = value;
        }
      }
    }
    if (widget.cardType == PaymentConstants.masterCard) {
      for (var value in paymentMethods) {
        if (value.type!.contains('master')) {
          paymentMethod = value;
        }
      }
    }
    setState(() {});
  }

  _startCheckout() async {
    ppx('$mm ... _startCheckout ... ${widget.sponsorProduct.title} with card: $cardName');
    var amount = widget.sponsorProduct.studentsSponsored! *
        widget.sponsorProduct.amountPerSponsoree!;
    String ref = 'sgelaAI_${DateTime.now().millisecondsSinceEpoch}';

    try {
      var now = DateTime.now().millisecondsSinceEpoch ~/ 1000 + (60 * 20);
      var checkOutRequest = CheckoutRequest(
          amount.toInt(),
          SponsorsEnvironment.getPaymentCompleteUrl(),
          country!.iso2!,
          paymentMethod!.currencies.first,
          null,
          SponsorsEnvironment.getPaymentErrorUrl(),
          ref,
          true,
          'en',
          null,
          [paymentMethod!.type!],
          now,
          SponsorsEnvironment.getCheckoutCancelUrl(),
          SponsorsEnvironment.getCheckoutCompleteUrl(),
          []);

      ppx('$mm ... sending checkOut request: ${checkOutRequest.toJson()}');
      var gr = await rapydPaymentService.createCheckOut(checkOutRequest);
      ppx('$mm ... _startCheckout returned with checkout, should redirect');
      if (mounted) {
        NavigationUtils.navigateToPage(
            context: context,
            widget: PaymentWebView(
              url: gr.redirect_url!,
              title: '$cardName Payment',
            ));
      }

      // _handlePaymentResponse(resp);
    } catch (e, s) {
      ppx(e);
      ppx(s);
      if (mounted) {
        showErrorDialog(context, '$e');
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      appBar: AppBar(
        title: Text(cardName),
      ),
      body: ScreenTypeLayout.builder(
        mobile: (_) {
          return Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: SponsorProductWidget(
                          sponsorProduct: widget.sponsorProduct,
                          countryEmoji:
                              country == null ? '' : '${country!.emoji}'),
                    ),
                    gapH16,
                    Expanded(
                        child:
                            Card(elevation: 8, child: Image.asset(assetPath))),
                    gapH16,
                    ElevatedButton(
                        style: const ButtonStyle(
                          elevation: MaterialStatePropertyAll(8),
                        ),
                        onPressed: () {
                          _startCheckout();
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Text(
                            'Pay with $cardName',
                            style: myTextStyle(
                                context,
                                Theme.of(context).primaryColor,
                                24,
                                FontWeight.w900),
                          ),
                        )),
                    gapH32,
                  ],
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
