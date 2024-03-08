import 'package:flutter/material.dart';
import 'package:sgela_sponsor_app/util/Constants.dart';
import 'package:sgela_sponsor_app/util/functions.dart';

class PaymentTypeChooser extends StatelessWidget {
  const PaymentTypeChooser({super.key, required this.onPaymentTypeSelected});

  final Function(int) onPaymentTypeSelected;

  @override
  Widget build(BuildContext context) {
    var mStyle = const ButtonStyle(
      elevation: MaterialStatePropertyAll(8.0),
    );
    return SizedBox(
      height: 360,
      width: 420,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          gapH8,
          Text(
            'Payment Types',
            style: myTextStyleMediumBold(context),
          ),
          gapH32,
          SizedBox(
            width: 320,
            child: ElevatedButton(
                style: mStyle,
                onPressed: () {
                  onPaymentTypeSelected(PaymentConstants.visa);
                },
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/visa1.png',
                        height: 48,
                      ),
                      gapW16,
                      const Text('Visa'),
                    ],
                  ),
                )),
          ),
          gapH16,
          SizedBox(
            width: 320,
            child: ElevatedButton(
                style: mStyle,
                onPressed: () {
                  onPaymentTypeSelected(PaymentConstants.masterCard);
                },
                child:  Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/mastercard2.png',
                        height: 48,
                      ),
                      gapW16,
                      const Text('Mastercard'),
                    ],
                  ),
                )),
          ),
          gapH16,
          SizedBox(
            width: 320,
            child: ElevatedButton(
                style: mStyle,
                onPressed: () {
                  onPaymentTypeSelected(PaymentConstants.bankTransfer);
                },
                child:  Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Row(
                    children: [
                      Image.asset(
                        'assets/bank1.jpg',
                        height: 48, width: 32,
                      ),
                      gapW16,
                      const Text('Bank Transfer (EFT)'),
                    ],
                  ),
                )),
          ),
          // gapH16,
          // SizedBox(width: 320,
          //   child: ElevatedButton(
          //       style: mStyle,
          //       onPressed: () {
          //         onPaymentTypeSelected(Constants.applePay);
          //       },
          //       child: const Padding(
          //         padding: EdgeInsets.all(20.0),
          //         child: Text('Apple Pay'),
          //       )),
          // ),
          // gapH16,
          // SizedBox(width: 320,
          //   child: ElevatedButton(
          //       style: mStyle,
          //       onPressed: () {
          //         onPaymentTypeSelected(Constants.googlePay);
          //       },
          //       child: const Padding(
          //         padding: EdgeInsets.all(20.0),
          //         child: Text('Google Pay'),
          //       )),
          // ),
          // gapH16,
          // SizedBox(
          //   width: 320,
          //   child: ElevatedButton(
          //       style: mStyle,
          //       onPressed: () {
          //         //onPaymentTypeSelected(Constants.payPal);
          //         showToast(
          //             message: 'PayPal is not available yet. Stay tuned!',
          //             backgroundColor: Colors.amber,
          //             textStyle:
          //                 myTextStyleMediumWithColor(context, Colors.black),
          //             context: context);
          //       },
          //       child:  Padding(
          //         padding: const EdgeInsets.all(4.0),
          //         child: Row(
          //           children: [
          //             Image.asset(
          //               'assets/paypal1.png',
          //               height: 48,
          //             ),
          //             gapW32,
          //             const Text('PayPal'),
          //           ],
          //         ),
          //       )),
          // ),
          // gapH16,
          // SizedBox(
          //   width: 320,
          //   child: ElevatedButton(
          //       style: mStyle,
          //       onPressed: () {
          //         onPaymentTypeSelected(Constants.eWallet);
          //       },
          //       child: const Padding(
          //         padding: EdgeInsets.all(20.0),
          //         child: Text('eWallet'),
          //       )),
          // ),
          // gapH16,
        ],
      ),
    );
  }
}
