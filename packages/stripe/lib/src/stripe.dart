import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:stripe_platform_interface/stripe_platform_interface.dart';

/// [Stripe] is the facade of the library and exposes the operations that can be
/// executed on the Stripe platform.
///
class Stripe {
  // Disables the platform override in order to use a manually registered
  // ignore: comment_references
  // [SharePlatform] for testing purposes.
  // See https://github.com/flutter/flutter/issues/52267 for more details.
  //
  Stripe._();

  /// Sets the publishable key that is used to identify the account on the
  /// Stripe platform.
  static set publishableKey(String value) {
    if (value == instance._publishableKey) {
      return;
    }
    instance._publishableKey = value;
    instance.markNeedsSettings();
  }

  /// Retrieves the publishable API key.
  static String get publishableKey {
    assert(instance._publishableKey != null,
        'A publishableKey is required and missing');
    return instance._publishableKey;
  }

  /// Retrieves the id associate with the Stripe account.
  static String get stripeAccountId => instance._stripeAccountId;

  /// Sets the account id that is generated when creating a Stripe account.
  static set stripeAccountId(String value) {
    if (value == instance._stripeAccountId) {
      return;
    }
    instance._stripeAccountId = value;
    instance.markNeedsSettings();
  }

  /// Retrieves the configuration parameters for 3D secure.
  static ThreeDSecureConfigurationParams get threeDSecureParams =>
      instance._threeDSecureParams;

  /// Sets the configuration parameters for 3D secure.
  static set threeDSecureParams(ThreeDSecureConfigurationParams value) {
    if (value == instance._threeDSecureParams) {
      return;
    }
    instance._threeDSecureParams = value;
    instance.markNeedsSettings();
  }

  /// Sets the custom url scheme
  static set urlScheme(String value) {
    if (value == instance._urlScheme) {
      return;
    }
    instance._urlScheme = value;
    instance.markNeedsSettings();
  }

  /// Retrieves the custom url scheme
  static String get urlScheme {
    return instance._urlScheme;
  }

  /// Retrieves the merchant identifier.
  static String get merchantIdentifier => instance._merchantIdentifier;

  /// Sets the merchant identifier.
  static set merchantIdentifier(String value) {
    if (value == instance._merchantIdentifier) {
      return;
    }
    instance._merchantIdentifier = value;
    instance.markNeedsSettings();
  }



  /// Exposes a [ValueListenable] whether or not Apple pay is supported for this
  /// device.
  ///
  /// Always returns false on non Apple platforms.
  ValueListenable<bool> get isApplePaySupported {
    if (_isApplePaySupported == null) {
      _isApplePaySupported = ValueNotifier(false);
      checkApplePaySupport();
    }
    return _isApplePaySupported;
  }

  ///Checks if Apple pay is supported on this device.
  ///
  /// Always returns false on non Apple devices.
  Future<bool> checkApplePaySupport() async {
    await _awaitForSettings();
    final isSupported = await _platform.isApplePaySupported();
    _isApplePaySupported ??= ValueNotifier(false);
    _isApplePaySupported.value = isSupported;
    return isSupported;
  }

  /// Creates a single-use token that represents an Apple Pay credit card’s details.
  /// 
  /// The [payment] param should be the data response from the `pay` plugin. It can 
  /// be used both with the callback `onPaymentResult` from `pay.ApplePayButton` or 
  /// directly with `Pay.showPaymentSelector`
  ///
  /// Throws an [StripeError] in case createApplePayToken fails.
  Future<TokenData> createApplePayToken(Map<String, dynamic> payment) async {
    await _awaitForSettings();
    try {
      final tokenData = await _platform.createApplePayToken(payment);
      return tokenData;
    } on StripeError catch (error) {
      throw StripeError(message: error.message, code: error.message);
    }
  }

  FutureOr<void> _awaitForSettings() {
    if (_needsSettings) {
      _settingsFuture = applySettings();
    }
    if (_settingsFuture != null) {
      return _settingsFuture;
    }
    return null;
  }

  /// Reconfigures the Stripe platform by applying the current values for
  /// [publishableKey], [merchantIdentifier], [stripeAccountId],
  /// [threeDSecureParams], [urlScheme]
  Future<void> applySettings() => _initialise(
    publishableKey: publishableKey,
    merchantIdentifier: merchantIdentifier,
    stripeAccountId: stripeAccountId,
    threeDSecureParams: threeDSecureParams,
    urlScheme: urlScheme,
  );

  Future<void> _initialise({
    String publishableKey,
    String stripeAccountId,
    ThreeDSecureConfigurationParams threeDSecureParams,
    String merchantIdentifier,
    String urlScheme,
  }) async {
    _needsSettings = false;
    await _platform.initialise(
      publishableKey: publishableKey,
      stripeAccountId: stripeAccountId,
      threeDSecureParams: threeDSecureParams,
      merchantIdentifier: merchantIdentifier,
      urlScheme: urlScheme,
    );
  }

  Future<void> _settingsFuture;

  static final Stripe instance = Stripe._();

  String _publishableKey;
  String _stripeAccountId;
  ThreeDSecureConfigurationParams _threeDSecureParams;
  String _merchantIdentifier;
  String _urlScheme;

  static StripePlatform __platform;

  // This is to manually endorse the Linux plugin until automatic registration
  // of dart plugins is implemented.
  // See https://github.com/flutter/flutter/issues/52267 for more details.
  static StripePlatform get _platform {
    __platform ??= StripePlatform.instance;
    return __platform;
  }

  bool _needsSettings = true;
  void markNeedsSettings() {
    _needsSettings = true;
  }



  ValueNotifier<bool> _isApplePaySupported;
}
