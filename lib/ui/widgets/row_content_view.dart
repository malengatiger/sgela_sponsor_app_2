import 'package:flutter/material.dart';

import '../../util/functions.dart';

class RowContentView extends StatelessWidget {
  const RowContentView(
      {super.key,
        required this.leftWidget,
        required this.rightWidget
      });

  final Widget leftWidget, rightWidget;

  @override
  Widget build(BuildContext context) {
    var mWidth = 100.0;
    var totalWidth = MediaQuery.of(context).size.width;

    var dWidth = (totalWidth/2) - 8;
    return SizedBox(width: totalWidth,
      child: Row(
        children: [
          SizedBox(width: dWidth, child: leftWidget),
          gapW4,
          SizedBox(width: dWidth, child: rightWidget)
        ],
      ),
    );
  }
}
