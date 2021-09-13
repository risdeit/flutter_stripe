import 'package:stripe_platform_interface/stripe_platform_interface.dart';

class ResultParser<T> {
  const ResultParser({
     T Function(Map<String, dynamic>) parseJson,
  }) : _parseJson = parseJson;

  T parse(
      { Map<String, dynamic> result,  String successResultKey}) {
    final successResponse = result[successResultKey];

    if (successResponse != null) {
      return _parseJson(successResponse);
    } else {
      throw parseError(result);
    }
  }

  StripeException parseError(Map<String, dynamic> result) {
    return StripeException.fromJson(result);
  }

  final T Function(Map<String, dynamic>) _parseJson;
}

extension UnfoldToNonNull<T> on T {
  T unfoldToNonNull() {
    if (this == null) {
      throw AssertionError('Result should not be null');
    } else {
      return this!;
    }
  }
}
