import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:sgela_services/data/country.dart';
import 'package:sgela_services/data/holder.dart';
import 'package:sgela_services/data/organization.dart';
import 'package:sgela_services/data/sponsor_product.dart';
import 'package:sgela_services/sgela_util/sponsor_prefs.dart';
import 'package:sgela_services/services/rapyd_payment_service.dart';
import 'package:sgela_sponsor_app/ui/payments/payment_web_view.dart';
import 'package:sgela_sponsor_app/util/functions.dart';
import 'package:sgela_sponsor_app/util/navigation_util.dart';


class PaymentController extends StatefulWidget {
  const PaymentController({super.key, required this.sponsorPaymentType});

  final SponsorProduct sponsorPaymentType;

  @override
  PaymentControllerState createState() => PaymentControllerState();
}

class PaymentControllerState extends State<PaymentController>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  RapydPaymentService paymentService = GetIt.instance<RapydPaymentService>();
  SponsorPrefs prefs = GetIt.instance<SponsorPrefs>();
  Country? country;
  int _showPaymentType = payByCard;

  @override
  void initState() {
    _controller = AnimationController(vsync: this);
    super.initState();
    _getPaymentMethods();
  }

  List<PaymentMethod> paymentMethods = [];
  List<PaymentMethod> filtered = [];

  _getPaymentMethods() async {
    country = prefs.getCountry();
    customer = prefs.getCustomer();
    paymentMethods =
    await paymentService.getCountryPaymentMethods(country!.iso2!);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  PaymentMethod? paymentMethod;
  Customer? customer;

  _startCard() async{
    var amount = widget.sponsorPaymentType.studentsSponsored! *
        widget.sponsorPaymentType.amountPerSponsoree!;
    try {
      var request =
          PaymentByCardRequest(amount, widget.sponsorPaymentType.currency,
              customer!.id!, paymentMethod, true, false);
      var resp = await paymentService.createPaymentByCard(request);
      _handlePaymentResponse(resp);
    } catch (e) {
      ppx(e);
      if (mounted) {
        showErrorDialog(context, '$e');
      }
    }
  }

  _startBank() async{
    var amount = widget.sponsorPaymentType.studentsSponsored! *
        widget.sponsorPaymentType.amountPerSponsoree!;
    try {
      var request =
          PaymentByBankTransferRequest(amount, widget.sponsorPaymentType.currency,
              customer!.id!, paymentMethod);
      var resp =  await paymentService.createPaymentByBankTransfer(request);
      _handlePaymentResponse(resp);
    } catch (e) {
      ppx(e);
      if (mounted) {
        showErrorDialog(context, '$e');
      }
    }
  }

  void _handlePaymentResponse(PaymentResponse resp) {
     if (resp.status!.status!.contains('SUCCESS')) {
      Payment? payment = resp.data;
      if (payment != null) {
        if (mounted) {
          NavigationUtils.navigateToPage(context: context, widget: PaymentWebView(url: payment.redirect_url!, title: '',));
        }
      }
    } else {
       showErrorDialog(context, "Error occurred handling your payment");
     }
  }

  _startWallet() async {
    var amount = widget.sponsorPaymentType.studentsSponsored! *
        widget.sponsorPaymentType.amountPerSponsoree!;
    try {
      var request =
          PaymentByWalletRequest(amount, widget.sponsorPaymentType.currency,
              customer!.id!, paymentMethod);
      var resp =  await paymentService.createPaymentByWallet(request);
      _handlePaymentResponse(resp);
    } catch (e) {
      ppx(e);
      if (mounted) {
        showErrorDialog(context, '$e');
      }
    }
  }

  List<Widget> _displayCards() {
    filtered.clear();
    for (var pm in paymentMethods) {
      if (pm.type!.contains('card')) {
        filtered.add(pm);
      }
    }
    List<Widget> widgets = [];
    int cnt = 0;
    for (var pm in filtered) {
      // var img = CachedNetworkImage(imageUrl: pm.image!,);
      var name = pm.name!;
      var card = GestureDetector(
        onTap: () {
          setState(() {
            paymentMethod = pm;
          });
          _startCard();
        },
        child: SizedBox(width: 400,
          child: Card(
            elevation: 8,
            child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                    children: [
                    Text('$cnt', style: myTextStyle(context, Theme
                    .of(context)
                    .primaryColor, 18, FontWeight.bold)),
                gapW16,
                Text(name, style: myTextStyleMediumLarge(context, 18),),
          ],
        ),
      )
    ,),
    ),
    );
    widgets.add(card);
    cnt++;
    }
    return widgets;
    }

  List<Widget> _displayBanks() {
    filtered.clear();
    for (var pm in paymentMethods) {
      if (pm.type!.contains('bank')) {
        filtered.add(pm);
      }
    }
    List<Widget> widgets = [];
    int cnt = 1;
    for (var pm in filtered) {
      //var img = CachedNetworkImage(imageUrl: pm.image!,);
      var name = pm.name!;
      var card = GestureDetector(
        onTap: () {
          setState(() {
            paymentMethod = pm;
          });
          _startBank();
        },
        child: SizedBox(width: 400,
          child: Card(
            elevation: 8,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Text('$cnt', style: myTextStyle(context, Theme
                      .of(context)
                      .primaryColor, 18, FontWeight.bold)),
                  gapW8,
                  Text(name, style: myTextStyleMediumLarge(context, 18)),
                ],
              ),
            ),
          ),
        ),
      );
      widgets.add(card);
      cnt++;
    }
    return widgets;
  }

  List<Widget> _displayWallets() {
    filtered.clear();
    for (var pm in paymentMethods) {
      if (pm.type!.contains('wallet')) {
        filtered.add(pm);
      }
    }
    List<Widget> widgets = [];
    int cnt = 1;
    for (var pm in filtered) {
      // var img = CachedNetworkImage(imageUrl: pm.image!,);
      var name = pm.name!;
      var card = GestureDetector(
        onTap: () {
          setState(() {
            paymentMethod = pm;
          });
          _startWallet();
        },
        child: SizedBox(width: 400,
          child: Card(
            elevation: 8,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Text('$cnt', style: myTextStyle(context, Theme
                      .of(context)
                      .primaryColor, 18, FontWeight.bold)),
                  gapW16,
                  Text(name, style: myTextStyleMediumLarge(context, 18)),
                ],
              ),
            ),
          ),
        ),
      );
      widgets.add(card);
      cnt++;
    }
    return widgets;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Sponsorship Payment'),
          ),
          body: ScreenTypeLayout.builder(
            mobile: (_) {
              return Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TypeChooser(
                            onTypeChosen: (mType) {
                              setState(() {
                                _showPaymentType = mType;
                              });
                            },
                            selectedPaymentMethod: 8),
                        gapH16,
                        if (_showPaymentType == payByCard) Expanded(
                          child: SingleChildScrollView(
                            child: Column(
                              children: _displayCards(),
                            ),
                          ),
                        ),
                        if (_showPaymentType == payByBankTransfer) Expanded(
                          child: SingleChildScrollView(
                            child: Column(
                              children: _displayBanks(),
                            ),
                          ),

                        ),
                        if (_showPaymentType == payByWallet) Expanded(
                          child: Column(
                            children: _displayWallets(),
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

class StartPaymentProcess extends StatefulWidget {
  const StartPaymentProcess({super.key,
    required this.organization,
    required this.sponsorPaymentType,
    required this.onPaymentSucceeded,
    required this.onPaymentFailed});

  final Organization organization;
  final SponsorProduct sponsorPaymentType;
  final Function() onPaymentSucceeded;
  final Function() onPaymentFailed;

  @override
  State<StartPaymentProcess> createState() => _StartPaymentProcessState();
}

class _StartPaymentProcessState extends State<StartPaymentProcess> {
  RapydPaymentService paymentService = GetIt.instance<RapydPaymentService>();
  SponsorPrefs prefs = GetIt.instance<SponsorPrefs>();
  Country? country;

  @override
  void initState() {
    super.initState();
    customer = prefs.getCustomer();
    country = prefs.getCountry();
    _getPaymentMethods();
  }

  List<PaymentMethod> paymentMethods = [];
  List<PaymentMethod> filtered = [];

  _filter() {
    filtered.clear();
  }

  _getPaymentMethods() async {
    paymentMethods =
    await paymentService.getCountryPaymentMethods(country!.iso2!);
  }

  _startPayment() async {
    var amount = widget.sponsorPaymentType.studentsSponsored! *
        widget.sponsorPaymentType.amountPerSponsoree!;
    var request =
    PaymentByCardRequest(
        amount, widget.sponsorPaymentType.currency, customer!.id!,
        paymentMethod, true, false);
    paymentService.createPaymentByCard(request);
  }

  PaymentMethod? paymentMethod;
  Customer? customer;

  @override
  Widget build(BuildContext context) {
    var amount = widget.sponsorPaymentType.studentsSponsored! *
        widget.sponsorPaymentType.amountPerSponsoree!;
    var mNumber = amount.toStringAsFixed(2);
    return SafeArea(
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Payment Process'),
          ),
          body: ScreenTypeLayout.builder(
            mobile: (_) {
              return Stack(
                children: [
                  Column(
                    children: [
                      Text('${widget.sponsorPaymentType.title}'),
                      Text('${widget.sponsorPaymentType.studentsSponsored}'),
                      Text(mNumber),
                      Expanded(child: ListView.builder(
                          itemCount: filtered.length,
                          itemBuilder: (context, index) {
                            var method = filtered.elementAt(index);
                            return const Card(
                              child: Column(
                                children: [
                                ],
                              ),
                            );
                          })),
                    ],
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

const payByCard = 1;
const payByBankTransfer = 2;
const payByWallet = 3;

class TypeChooser extends StatelessWidget {
  const TypeChooser({super.key,
    required this.onTypeChosen,
    required this.selectedPaymentMethod});

  final Function(int) onTypeChosen;
  final int selectedPaymentMethod;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 8,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Radio<int>(
              value: 1,
              groupValue: selectedPaymentMethod,
              onChanged: (value) {
                if (value != null) {
                  onTypeChosen(value);
                }
              },
            ),
            const Text('Card'),
            Radio<int>(
              value: 2,
              groupValue: selectedPaymentMethod,
              onChanged: (value) {
                if (value != null) {
                  onTypeChosen(value);
                }
              },
            ),
            const Text('Bank'),
            Radio<int>(
              value: 3,
              groupValue: selectedPaymentMethod,
              onChanged: (value) {
                if (value != null) {
                  onTypeChosen(value);
                }
              },
            ),
            const Text('Wallet'),
          ],
        ),
      ),
    );
  }
}
