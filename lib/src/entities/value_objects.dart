import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:equatable/equatable.dart';

/// Stores given [text] as a sha256 hash
class HashedValue extends Equatable {
  final String value;

  HashedValue(String text)
      : value = sha256.convert(utf8.encode(text)).toString();

  @override
  List<Object?> get props => [value];

  @override
  String toString() => value;
}

/// A [HashedValue] of [pinText]
class Pin extends HashedValue {
  Pin(String pinText) : super(pinText);
}

/// A [HashedValue] of the [userId]
class UserId extends HashedValue {
  UserId(String id) : super(id);
}

/// A helper class that makes a sha256 hash of the key
/// used to store pin and userId values
class SPKey extends HashedValue {
  SPKey(String key) : super(key);
}

/// A hash of the pin. Unlike [Pin], [PinHash] is retrieved from
/// local storage and has no direct contact with the plaintext version
/// of the pin. It's used to compare hash values of newly entered [Pin]
/// and the one from local storage.
class PinHash extends Equatable {
  final String value;

  const PinHash(this.value);

  @override
  List<Object?> get props => [value];
}
