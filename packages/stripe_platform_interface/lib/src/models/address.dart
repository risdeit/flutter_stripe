import 'package:freezed_annotation/freezed_annotation.dart';

part 'address.freezed.dart';
part 'address.g.dart';

@freezed

/// Address information
class Address with _$Address {
  @JsonSerializable(explicitToJson: true)
  const factory Address({
    /// City, town or district.
     String city,

    /// Country
     String country,

    /// Address line1 (e.g. Street, C/O , PO Box).
     String line1,

    /// Address line2 (e.g. building, appartment or unit).
     String line2,

    /// ZIP or postal code.
     String postalCode,

    /// State or province.
     String state,
  }) = _Address;

  factory Address.fromJson(Map<String, dynamic> json) =>
      _$AddressFromJson(json);
}
