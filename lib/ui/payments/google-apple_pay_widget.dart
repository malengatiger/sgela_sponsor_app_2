import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:pay/pay.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:sgela_services/data/country.dart';
import 'package:sgela_services/data/holder.dart';
import 'package:sgela_services/data/sponsor_product.dart';
import 'package:sgela_services/services/firestore_service_sponsor.dart';
import 'package:sgela_services/sgela_util/sponsor_prefs.dart';
import 'package:sgela_sponsor_app/util/functions.dart';


class ApplePayWidget extends StatefulWidget {
  const ApplePayWidget({super.key, required this.sponsorProduct});

  final SponsorProduct sponsorProduct;

  @override
  ApplePayWidgetState createState() => ApplePayWidgetState();
}

class ApplePayWidgetState extends State<ApplePayWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  PaymentConfiguration? _paymentConfiguration;
  List<SponsorProduct> sponsorProducts = [];
  SponsorFirestoreService firestoreService = GetIt.instance<SponsorFirestoreService>();
  bool _busy = false;
  static const mm = '🍎🍎🍎🍎🍎🍎 ApplePayWidget 🔵🔵';
  Country? country;
  Customer? customer;
  SponsorPrefs prefs = GetIt.instance<SponsorPrefs>();

  @override
  void initState() {
    _controller = AnimationController(vsync: this);
    super.initState();
    _setConfiguration();
    _setPaymentItem();
  }

  _setConfiguration() async {
    ppx('$mm ... _setConfiguration .....');
    _paymentConfiguration =
        await PaymentConfiguration.fromAsset('default_apple_pay_config.json');
    ppx('$mm ... _setConfiguration ..... ${await _paymentConfiguration?.parameterMap()}');
    _getData();
  }

  _getData() async {
    ppx('$mm ... _getData.. we are processing: isApplePay');
    setState(() {
      _busy = true;
    });
    try {
      country = prefs.getCountry();
      customer = prefs.getCustomer();
      _setPaymentItem();
      ppx('$mm ... _getData.. we are processing: country: ${country!.name}');
    } catch (e) {
      ppx(e);
      if (mounted) {
        showErrorDialog(context, 'Unable to get data');
      }
    }
    setState(() {
      _busy = false;
    });
  }

  void onApplePayResult(paymentResult) {
    ppx('$mm onApplePayResult: paymentResult: ${paymentResult.toString()}');
  }

  final List<PaymentItem> _paymentItems = [];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  _setPaymentItem() {
    int amount = (widget.sponsorProduct.studentsSponsored! *
            widget.sponsorProduct.amountPerSponsoree!)
        .toInt();
    _paymentItems.add(PaymentItem(
        amount: '$amount',
        label: widget.sponsorProduct.title!,
        status: PaymentItemStatus.final_price));
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      appBar: AppBar(
        title: const Text("Apple Pay"),
      ),
      body: ScreenTypeLayout.builder(
        mobile: (_) {
          return Stack(
            children: [
              Column(
                children: [
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Sponsorship Message'),
                    ],
                  ),
                  gapH16,
                  Card(
                    elevation: 8,
                    color: Colors.purple,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          Text('Top of the Card ${widget.sponsorProduct.title}'),
                          _paymentConfiguration == null? gapW16: Card(
                            elevation: 12,
                            color: Colors.amber,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Container(height: 300, color: Colors.teal,
                                child: ApplePayButton(
                                    paymentConfiguration: _paymentConfiguration!,
                                    paymentItems: _paymentItems,
                                    margin: const EdgeInsets.all(64),
                                    type: ApplePayButtonType.order,
                                    onPaymentResult: onApplePayResult),
                              ),
                            ),
                          ),
                          const Text('Bottom of the Card'),
                        ],
                      ),
                    ),
                  )
                ],
              )
            ],
          );
        },
        tablet: (_) {
          return const Stack();
        },
      ),
    ));
  }
}
