import 'dart:io';

import 'package:flutter/services.dart';
import 'package:stripe_platform_interface/src/models/create_token_data.dart';
import 'package:stripe_platform_interface/src/result_parser.dart';

import 'models/app_info.dart';
import 'models/errors.dart';
import 'models/three_d_secure.dart';
import 'stripe_platform_interface.dart';

const _appInfo = AppInfo(
    name: 'flutter_stripe',
    version: '0.0.0',
    url: 'https://github.com/fluttercommunity/flutter_stripe/');

/// An implementation of [StripePlatform] that uses method channels.
class MethodChannelStripe extends StripePlatform {
  MethodChannelStripe({
     MethodChannel methodChannel,
     bool platformIsIos,
  })  : _methodChannel = methodChannel,
        _platformIsIos = platformIsIos;

  final MethodChannel _methodChannel;
  final bool _platformIsIos;

  @override
  Future<void> initialise({
     String publishableKey,
    String stripeAccountId,
    ThreeDSecureConfigurationParams threeDSecureParams,
    String merchantIdentifier,
    String urlScheme,
  }) async {
    await _methodChannel.invokeMethod('initialise', {
      'publishableKey': publishableKey,
      'stripeAccountId': stripeAccountId,
      'merchantIdentifier': merchantIdentifier,
      'appInfo': _appInfo.toJson(),
      'threeDSecureParams': threeDSecureParams,
      'urlScheme': urlScheme,
    });
  }

  @override
  Future<bool> isApplePaySupported() async {
    if (!_platformIsIos) {
      return false;
    }
    final isSupported =
        await _methodChannel.invokeMethod('isApplePaySupported');
    return isSupported ?? false;
  }

  @override
  Future<TokenData> createApplePayToken(Map<String, dynamic> payment) async {
      final result = await _methodChannel.invokeMapMethod<String, dynamic>(
        'createApplePayToken', {'payment': payment});

    return ResultParser<TokenData>(
            parseJson: (json) => TokenData.fromJson(json))
        .parse(result: result, successResultKey: 'token');
  }
}

class MethodChannelStripeFactory {
  const MethodChannelStripeFactory();

  StripePlatform create() => MethodChannelStripe(
      methodChannel: const MethodChannel(
        'flutter.stripe/payments',
        JSONMethodCodec(),
      ),
      platformIsIos: Platform.isIOS);
}
