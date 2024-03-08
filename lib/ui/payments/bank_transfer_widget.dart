import 'package:badges/badges.dart' as bd;
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:sgela_services/data/country.dart';
import 'package:sgela_services/data/holder.dart';
import 'package:sgela_services/data/sponsor_product.dart';
import 'package:sgela_services/services/rapyd_payment_service.dart';
import 'package:sgela_services/sgela_util/sponsor_prefs.dart';
import 'package:sgela_shared_widgets/widgets/busy_indicator.dart';
import 'package:sgela_sponsor_app/ui/payments/payment_web_view.dart';
import 'package:sgela_sponsor_app/ui/payments/sponsor_product_widget.dart';
import 'package:sgela_sponsor_app/util/environment.dart';

import '../../util/functions.dart';
import '../../util/navigation_util.dart';

class BankTransferWidget extends StatefulWidget {
  const BankTransferWidget({super.key, required this.sponsorProduct});

  final SponsorProduct sponsorProduct;

  @override
  BankTransferWidgetState createState() => BankTransferWidgetState();
}

class BankTransferWidgetState extends State<BankTransferWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  static const mm = '🔵🍐🍐🍐🍐 BankTransferWidget 🍎🍎';
  RapydPaymentService rapydPaymentService =
      GetIt.instance<RapydPaymentService>();
  SponsorPrefs prefs = GetIt.instance<SponsorPrefs>();
  List<PaymentMethod> paymentMethods = [];
  List<PaymentMethod> filtered = [];
  PaymentMethod? paymentMethod;
  Country? country;
  Customer? customer;
  bool _busy = false;

  @override
  void initState() {
    _controller = AnimationController(vsync: this);
    super.initState();
    _getPaymentMethods();
  }

  _getPaymentMethods() async {
    ppx('$mm ... _getPaymentMethods ...');
    setState(() {
      _busy = false;
    });
    try {
      country = prefs.getCountry();
      customer = prefs.getCustomer();
      paymentMethods =
          await rapydPaymentService.getCountryPaymentMethods(country!.iso2!);
      _filterPaymentMethods();
    } catch (e) {
      ppx(e);
      if (mounted) {
        showErrorDialog(context, 'Unable to get Payment methods');
      }
    }
    setState(() {
      _busy = false;
    });
  }

  void _handlePaymentResponse(PaymentResponse resp) {
    ppx('$mm ... _handlePaymentResponse ... ${resp.status!.status}');
    if (resp.status!.status!.contains('SUCCESS')) {
      Payment? payment = resp.data;
      if (payment != null) {
        if (mounted) {
          NavigationUtils.navigateToPage(
              context: context,
              widget: PaymentWebView(
                url: payment.redirect_url!,
                title: '${paymentMethod!.name} Payment',
              ));
        }
      }
    } else {
      showErrorDialog(context, "Error occurred handling your payment");
    }
  }

  _filterPaymentMethods() {
    filtered.clear();
    for (var pm in paymentMethods) {
      if (pm.type!.contains('bank')) {
        filtered.add(pm);
      }
    }
  }
  _startCheckout() async {
    ppx('$mm ... _startCheckout ... ${widget.sponsorProduct.title} ');
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
              title: 'Payment',
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

  _startBankTransfer(PaymentMethod paymentMethod) async {
    ppx('$mm ... _startBankTransfer ...');
    this.paymentMethod = paymentMethod;
    var amount = widget.sponsorProduct.studentsSponsored! *
        widget.sponsorProduct.amountPerSponsoree!;
    setState(() {
      _busy = true;
    });
    late PaymentByBankTransferRequest request;
    try {
      if (customer == null) {
        _startCheckout();
      } else {
        request = PaymentByBankTransferRequest(amount,
            widget.sponsorProduct.currency, customer!.id!, paymentMethod);

        var resp =
            await rapydPaymentService.createPaymentByBankTransfer(request);
        ppx('$mm ... _startBankTransfer came back. status: ${resp.status!.toJson()} .');
        ppx('$mm ... _startBankTransfer came back. data(Payment): ${resp.data!.toJson()} .');
        _handlePaymentResponse(resp);
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
        title: const Text('Bank Transfer (EFT)'),
      ),
      body: ScreenTypeLayout.builder(
        mobile: (_) {
          return Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: SponsorProductWidget(
                        sponsorProduct: widget.sponsorProduct,
                        countryEmoji: '${country!.emoji}',
                      ),
                    ),
                    _busy
                        ? Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: BusyIndicator(
                              caption: 'Contacting  ${paymentMethod?.name} ...',
                              showClock: true,
                            ),
                          )
                        : Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: bd.Badge(
                                position:
                                    bd.BadgePosition.topEnd(top: -10, end: 2),
                                badgeContent: Text('${filtered.length}'),
                                child: ListView.builder(
                                    itemCount: filtered.length,
                                    itemBuilder: (_, index) {
                                      var pm = filtered.elementAt(index);
                                      return GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            paymentMethod = pm;
                                          });
                                          _startBankTransfer(pm);
                                        },
                                        child: Card(
                                          elevation: 8,
                                          child: Padding(
                                            padding: const EdgeInsets.all(12.0),
                                            child: Row(
                                              children: [
                                                Text(
                                                  '${index + 1}',
                                                  style: myTextStyle(
                                                      context,
                                                      Theme.of(context)
                                                          .primaryColor,
                                                      20,
                                                      FontWeight.w900),
                                                ),
                                                gapW16,
                                                Text(
                                                  '${pm.name}',
                                                  style: myTextStyleMediumBold(
                                                      context),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                    }),
                              ),
                            ),
                          ),
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
