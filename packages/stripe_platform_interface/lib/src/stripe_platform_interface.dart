import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'method_channel_stripe.dart';
import 'models/create_token_data.dart';
import 'models/three_d_secure.dart';

abstract class StripePlatform extends PlatformInterface {
  StripePlatform() : super(token: _token);

  static final Object _token = Object();

  static StripePlatform _instance = const MethodChannelStripeFactory().create();

  /// The default instance of [StripePlatform] to use.
  ///
  /// Defaults to [MethodChannelStripe].
  static StripePlatform get instance => _instance;

  /// Platform-specific plugins should set this with their own platform-specific
  /// class that extends [StripePlatform] when they register themselves.
  static set instance(StripePlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<void> initialise({
     String publishableKey,
    String stripeAccountId,
    ThreeDSecureConfigurationParams threeDSecureParams,
    String merchantIdentifier,
    String urlScheme,
  });

  Future<bool> isApplePaySupported() async => false;

  Future<TokenData> createApplePayToken(Map<String, dynamic> payment);
}
