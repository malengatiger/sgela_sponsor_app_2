import 'package:flutter/material.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:sgela_sponsor_app/util/functions.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PaymentWebView extends StatefulWidget {
  const PaymentWebView({super.key, required this.url, required this.title});

  final String title;

  final String url;

  @override
  State<PaymentWebView> createState() => _PaymentWebViewState();
}

class _PaymentWebViewState extends State<PaymentWebView> {
  late WebViewController webViewController;
  static const mm = ' 💚💚💚💚 PaymentWebView  💚💚';

  @override
  void initState() {
    super.initState();
    _setController();
  }

  _setController() {
    webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            // Update loading bar.
          },
          onPageStarted: (String url) {
            ppx('$mm ... onPageStarted ... url: $url');
          },
          onPageFinished: (String url) {
            ppx('$mm ... onPageFinished... url: $url');
            //Navigator.of(context).pop(true);
          },
          onWebResourceError: (WebResourceError error) {
            ppx('$mm ... onWebResourceError ... error: ${error.description}');
            Navigator.of(context).pop(false);
          },
          onNavigationRequest: (NavigationRequest request) {
            if (request.url.startsWith('https://www.youtube.com/')) {
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      appBar: AppBar(
        title: Text(widget.title, style: myTextStyleSmall(context),),
      ),
      body: ScreenTypeLayout.builder(
        mobile: (_) {
          return Stack(
            children: [
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'SgelaAI Sponsorship Payment',
                      style: myTextStyle(context,
                          Theme.of(context).primaryColor, 16, FontWeight.w900),
                    ),
                  ),
                  Expanded(child: WebViewWidget(controller: webViewController))
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
