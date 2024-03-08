import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:sgela_services/data/branding.dart';
import 'package:sgela_services/data/country.dart';
import 'package:sgela_services/data/organization.dart';
import 'package:sgela_services/data/sponsor_product.dart' as sp;
import 'package:sgela_services/services/firestore_service_sponsor.dart';
import 'package:sgela_services/sgela_util/sponsor_prefs.dart';
import 'package:sgela_shared_widgets/widgets/org_logo_widget.dart';
import 'package:sgela_sponsor_app/ui/payments/bank_transfer_widget.dart';
import 'package:sgela_sponsor_app/ui/payments/credit_card_widget.dart';
import 'package:sgela_sponsor_app/ui/payments/e_wallet_widget.dart';
import 'package:sgela_sponsor_app/ui/payments/google-apple_pay_widget.dart';
import 'package:sgela_sponsor_app/ui/payments/pay_pal_widget.dart';
import 'package:sgela_sponsor_app/ui/payments/payment_type_chooser.dart';
import 'package:sgela_sponsor_app/util/functions.dart';
import 'package:sgela_sponsor_app/util/navigation_util.dart';

import '../../util/Constants.dart';

class SponsorProductSelector extends StatefulWidget {
  const SponsorProductSelector({super.key});

  @override
  SponsorProductSelectorState createState() => SponsorProductSelectorState();
}

class SponsorProductSelectorState extends State<SponsorProductSelector>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  List<sp.SponsorProduct> sponsorProducts = [];
  SponsorFirestoreService firestoreService = GetIt.instance<SponsorFirestoreService>();
  SponsorPrefs prefs = GetIt.instance<SponsorPrefs>();
  static const mm = '🔵🔵🔵🔵🔵🔵🔵🔵 SponsorProductSelector 🔵🔵';

  Country? country;
  Organization? organization;
  Branding? branding;

  @override
  void initState() {
    _controller = AnimationController(vsync: this);
    super.initState();
    _getSponsorProducts();
  }

  _getSponsorProducts() async {
    sponsorProducts = await firestoreService.getSponsorProducts(true);
    sponsorProducts
        .sort((a, b) => b.studentsSponsored!.compareTo(a.studentsSponsored!));
    _filterTypes();
    country = prefs.getCountry();
    organization = prefs.getOrganization();
    var brandings = prefs.getBrandings();
    if (brandings.isNotEmpty) {
      branding = brandings.first;
    }
    setState(() {});
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool isIndividual = false;
  List<sp.SponsorProduct> filtered = [];

  int selectedPaymentType = 0;

  _showPaymentTypeDialog(sp.SponsorProduct sponsorProduct) {
    showDialog(
        context: context,
        builder: (_) {
          return AlertDialog(
            content: PaymentTypeChooser(onPaymentTypeSelected: (type) {
              ppx('$mm .... onPaymentTypeSelected: $type');
              setState(() {
                selectedPaymentType = type;
              });
              Navigator.of(context).pop();
              _navigateToPaymentTypeWidget(sponsorProduct);
            }),
          );
        });
  }

  _navigateToPaymentTypeWidget(sp.SponsorProduct sponsorProduct) {
    ppx('$mm ... _navigateToPaymentTypeWidget ...');

    switch (selectedPaymentType) {
      case PaymentConstants.googlePay:
        NavigationUtils.navigateToPage(
            context: context,
            widget: ApplePayWidget(
              sponsorProduct: sponsorProduct,
            ));
        break;
      case PaymentConstants.applePay:
        NavigationUtils.navigateToPage(
            context: context,
            widget: ApplePayWidget(
              sponsorProduct: sponsorProduct,
            ));
        break;
      case PaymentConstants.visa:
        NavigationUtils.navigateToPage(
            context: context,
            widget: CreditCardWidget(
              cardType: PaymentConstants.visa,
              sponsorProduct: sponsorProduct,
            ));
        break;
      case PaymentConstants.masterCard:
        NavigationUtils.navigateToPage(
            context: context,
            widget: CreditCardWidget(
              cardType: PaymentConstants.masterCard,
              sponsorProduct: sponsorProduct,
            ));
        break;
      case PaymentConstants.bankTransfer:
        NavigationUtils.navigateToPage(
            context: context,
            widget: BankTransferWidget(
              sponsorProduct: sponsorProduct,
            ));
        break;
      case PaymentConstants.payPal:
        NavigationUtils.navigateToPage(
            context: context, widget: const PayPalWidget());
        break;
      case PaymentConstants.eWallet:
        NavigationUtils.navigateToPage(
            context: context,
            widget: EWalletWidget(
              sponsorProduct: sponsorProduct,
            ));
        break;
    }
  }

  sp.SponsorProduct? sponsorProduct;

  _filterTypes() {
    filtered.clear();
    if (isIndividual) {
      for (var value in sponsorProducts) {
        if (value.title!.contains("Individual")) {
          filtered.add(value);
        }
      }
    } else {
      for (var value in sponsorProducts) {
        if (value.title!.contains("Corp")) {
          filtered.add(value);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      appBar: AppBar(
        title: organization == null
            ? const Text('Sponsorships')
            : OrgLogoWidget(
                branding: branding,
              ),
      ),
      body: ScreenTypeLayout.builder(
        mobile: (_) {
          return Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 16.0, right: 16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            isIndividual
                                ? 'Individual Sponsorships'
                                : 'Corporate Sponsorships',
                            style: myTextStyleMediumLarge(context, 20),
                          ),
                          Switch(
                              value: isIndividual,
                              onChanged: (change) {
                                setState(() {
                                  isIndividual = !isIndividual;
                                });
                                _filterTypes();
                              }),
                        ],
                      ),
                    ),
                    gapH16,
                    country == null
                        ? gapW4
                        : Expanded(
                            child: SponsorProductGrid(
                            sponsorProducts: filtered,
                            country: country!,
                            onSponsorProduct: (sponsorProduct) {
                              _showPaymentTypeDialog(sponsorProduct);
                            },
                          ))
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

class SponsorProductGrid extends StatelessWidget {
  const SponsorProductGrid({
    super.key,
    required this.sponsorProducts,
    required this.country,
    required this.onSponsorProduct,
  });

  final List<sp.SponsorProduct> sponsorProducts;
  final Country country;
  final Function(sp.SponsorProduct) onSponsorProduct;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
        gridDelegate:
            const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
        itemCount: sponsorProducts.length,
        itemBuilder: (ctx, index) {
          var type = sponsorProducts.elementAt(index);
          return GestureDetector(
              onTap: () {
                onSponsorProduct(type);
              },
              child: SponsorProductCard(
                sponsorProduct: type,
                elevation: 8,
                country: country,
              ));
        });
  }
}

class SponsorProductCard extends StatelessWidget {
  const SponsorProductCard(
      {super.key,
      required this.elevation,
      required this.sponsorProduct,
      required this.country});

  final sp.SponsorProduct sponsorProduct;
  final double elevation;
  final Country country;

  @override
  Widget build(BuildContext context) {
    var fmt = NumberFormat('###,###.##');
    var fmt2 = NumberFormat('###,###,###,###');
    var amountPerSponsoree =
        sponsorProduct.amountPerSponsoree!.toStringAsFixed(2);
    var total =
        sponsorProduct.amountPerSponsoree! * sponsorProduct.studentsSponsored!;
    var totalFmt = fmt.format(total);
    var students = fmt2.format(sponsorProduct.studentsSponsored);

    return Card(
      elevation: elevation,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          gapH16,
          Text(
            students,
            style: myTextStyle(
                context, Theme.of(context).primaryColor, 24, FontWeight.w200),
          ),
          Text(
            "Students Sponsored",
            style: myTextStyleSmall(context),
          ),
          gapH8,
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Per Student",
                style: myTextStyleSmall(context),
              ),
              gapW4,
              Text(
                amountPerSponsoree,
                style: myTextStyle(context, Theme.of(context).primaryColor, 14,
                    FontWeight.normal),
              ),
            ],
          ),
          gapH16, gapH8,
          // Text("Total Amount", style: myTextStyleSmall(context),),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                country.emoji!,
                style: const TextStyle(fontSize: 28),
              ),
              gapW4,
              Text(
                totalFmt,
                style: myTextStyle(context, Theme.of(context).primaryColorLight,
                    18, FontWeight.w900),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
