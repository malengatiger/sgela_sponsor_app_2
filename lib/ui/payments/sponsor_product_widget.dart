import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sgela_services/data/sponsor_product.dart';

import '../../util/functions.dart';

class SponsorProductWidget extends StatelessWidget {
  const SponsorProductWidget({super.key, required this.sponsorProduct, required this.countryEmoji});

  final SponsorProduct sponsorProduct;
  final String countryEmoji;

  @override
  Widget build(BuildContext context) {
    var total =
        sponsorProduct.amountPerSponsoree! * sponsorProduct.studentsSponsored!;
    var intTotal = total.toInt();
    var fmt = NumberFormat('###,###,###.00');
    var mTotal = fmt.format(intTotal);
    var fmt2 = NumberFormat('###,###,###,###');

    var mSponsored = fmt2.format(sponsorProduct.studentsSponsored);
    return Card(
      child: SizedBox(
        height:200,
        child: Column(mainAxisAlignment: MainAxisAlignment.center,
          children: [
            gapH16,
            Row(mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(countryEmoji, style: const TextStyle(fontSize: 24),),
                gapW16,
                Text('${sponsorProduct.title}', style: myTextStyleMediumBold(context),),
              ],
            ),
            gapH16,
            Padding(
              padding: const EdgeInsets.only(left:20.0,right: 20.0),
              child: Row(
                children: [
                  const Text('Per Sponsoree'),
                  gapW8,
                  Text(sponsorProduct.amountPerSponsoree!.toStringAsFixed(2),
                    style: myTextStyleMediumBold(context),),
                ],
              ),
            ),
            gapH16,
            Padding(
              padding: const EdgeInsets.only(left:20.0,right: 20.0),
              child: Row(
                children: [
                  const Text('Students Sponsored'),
                  gapW8,
                  Text(mSponsored,
                    style: myTextStyleMediumBold(context),),
                ],
              ),
            ),
            gapH16,
            Padding(
              padding: const EdgeInsets.only(left:20.0,right: 20.0),
              child: Row(
                children: [
                  const Text('Total Amount'),
                  gapW8,
                  Text(
                    mTotal,
                    style: myTextStyle(context, Theme.of(context).primaryColor,
                        24, FontWeight.w900),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
