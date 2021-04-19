import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:equatable/equatable.dart';

enum BiometricMethod { fingerprint, face, iris }

class HashedValue extends Equatable {
  final String value;

  HashedValue(String text) : value = sha256.convert(utf8.encode(text)).toString();

  @override
  List<Object?> get props => [value];

  @override
  String toString() => value;
}

class Pin extends HashedValue {
  Pin(String pinText) : super(pinText);
}

class PinHash extends Equatable {
  final String value;

  const PinHash(this.value);

  @override
  List<Object?> get props => [value];
}

class UserId extends HashedValue {
  UserId(String id) : super(id);
}

class SPKey extends HashedValue {
  SPKey(String key) : super(key);
}
