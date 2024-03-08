import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:sgela_services/services/revenue_cat/store_config.dart';
import 'package:sgela_services/sgela_util/functions.dart';


class ConfigureRevenueCat {
  static const mm = '🥬🥬🥬🥬 ConfigureRevenueCat 🥬 ';
  static Future<void> configureRevenueCatSDK() async {
    pp('$mm .... configuration of RevenueCat starting ....');
    // Enable debug logs before calling `configure`.
    await Purchases.setLogLevel(LogLevel.debug);

    /*
    - appUserID is nil, so an anonymous ID will be generated automatically by the Purchases SDK.
    Read more about Identifying Users here: https://docs.revenuecat.com/docs/user-ids
    - observerMode is false, so Purchases will automatically handle finishing transactions.
    Read more about Observer Mode here: https://docs.revenuecat.com/docs/observer-mode
    */
    PurchasesConfiguration configuration;
    if (StoreConfig.isForAmazonAppstore()) {
      configuration = AmazonConfiguration(StoreConfig.instance.apiKey)
        ..appUserID = null
        ..observerMode = false;
    } else {
      configuration = PurchasesConfiguration(StoreConfig.instance.apiKey)
        ..appUserID = null
        ..observerMode = false;
    }
    await Purchases.configure(configuration);
    pp('$mm Purchases has been configured: ${configuration.store}');
  }

}
