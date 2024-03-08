import 'package:flutter/material.dart';

class PayPalWidget extends StatefulWidget {
  const PayPalWidget({super.key});

  @override
  PayPalWidgetState createState() => PayPalWidgetState();
}

class PayPalWidgetState extends State<PayPalWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  static const mm = '🔵🔵🔵🔵🔵🔵🔵🔵 PayPalWidget 🍎🍎';

  @override
  void initState() {
    _controller = AnimationController(vsync: this);
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
