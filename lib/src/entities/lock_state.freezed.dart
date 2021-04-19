// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides

part of 'lock_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more informations: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

/// @nodoc
class _$LockStateTearOff {
  const _$LockStateTearOff();

  Unlocked unlocked() {
    return const Unlocked();
  }

  Locked locked({required bool isBiometricAvailable}) {
    return Locked(
      isBiometricAvailable: isBiometricAvailable,
    );
  }
}

/// @nodoc
const $LockState = _$LockStateTearOff();

/// @nodoc
mixin _$LockState {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() unlocked,
    required TResult Function(bool isBiometricAvailable) locked,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? unlocked,
    TResult Function(bool isBiometricAvailable)? locked,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(Unlocked value) unlocked,
    required TResult Function(Locked value) locked,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(Unlocked value)? unlocked,
    TResult Function(Locked value)? locked,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LockStateCopyWith<$Res> {
  factory $LockStateCopyWith(LockState value, $Res Function(LockState) then) =
      _$LockStateCopyWithImpl<$Res>;
}

/// @nodoc
class _$LockStateCopyWithImpl<$Res> implements $LockStateCopyWith<$Res> {
  _$LockStateCopyWithImpl(this._value, this._then);

  final LockState _value;
  // ignore: unused_field
  final $Res Function(LockState) _then;
}

/// @nodoc
abstract class $UnlockedCopyWith<$Res> {
  factory $UnlockedCopyWith(Unlocked value, $Res Function(Unlocked) then) =
      _$UnlockedCopyWithImpl<$Res>;
}

/// @nodoc
class _$UnlockedCopyWithImpl<$Res> extends _$LockStateCopyWithImpl<$Res>
    implements $UnlockedCopyWith<$Res> {
  _$UnlockedCopyWithImpl(Unlocked _value, $Res Function(Unlocked) _then)
      : super(_value, (v) => _then(v as Unlocked));

  @override
  Unlocked get _value => super._value as Unlocked;
}

/// @nodoc
class _$Unlocked implements Unlocked {
  const _$Unlocked();

  @override
  String toString() {
    return 'LockState.unlocked()';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) || (other is Unlocked);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() unlocked,
    required TResult Function(bool isBiometricAvailable) locked,
  }) {
    return unlocked();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? unlocked,
    TResult Function(bool isBiometricAvailable)? locked,
    required TResult orElse(),
  }) {
    if (unlocked != null) {
      return unlocked();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(Unlocked value) unlocked,
    required TResult Function(Locked value) locked,
  }) {
    return unlocked(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(Unlocked value)? unlocked,
    TResult Function(Locked value)? locked,
    required TResult orElse(),
  }) {
    if (unlocked != null) {
      return unlocked(this);
    }
    return orElse();
  }
}

abstract class Unlocked implements LockState {
  const factory Unlocked() = _$Unlocked;
}

/// @nodoc
abstract class $LockedCopyWith<$Res> {
  factory $LockedCopyWith(Locked value, $Res Function(Locked) then) =
      _$LockedCopyWithImpl<$Res>;
  $Res call({bool isBiometricAvailable});
}

/// @nodoc
class _$LockedCopyWithImpl<$Res> extends _$LockStateCopyWithImpl<$Res>
    implements $LockedCopyWith<$Res> {
  _$LockedCopyWithImpl(Locked _value, $Res Function(Locked) _then)
      : super(_value, (v) => _then(v as Locked));

  @override
  Locked get _value => super._value as Locked;

  @override
  $Res call({
    Object? isBiometricAvailable = freezed,
  }) {
    return _then(Locked(
      isBiometricAvailable: isBiometricAvailable == freezed
          ? _value.isBiometricAvailable
          : isBiometricAvailable // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
class _$Locked implements Locked {
  const _$Locked({required this.isBiometricAvailable});

  @override
  final bool isBiometricAvailable;

  @override
  String toString() {
    return 'LockState.locked(isBiometricAvailable: $isBiometricAvailable)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other is Locked &&
            (identical(other.isBiometricAvailable, isBiometricAvailable) ||
                const DeepCollectionEquality()
                    .equals(other.isBiometricAvailable, isBiometricAvailable)));
  }

  @override
  int get hashCode =>
      runtimeType.hashCode ^
      const DeepCollectionEquality().hash(isBiometricAvailable);

  @JsonKey(ignore: true)
  @override
  $LockedCopyWith<Locked> get copyWith =>
      _$LockedCopyWithImpl<Locked>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() unlocked,
    required TResult Function(bool isBiometricAvailable) locked,
  }) {
    return locked(isBiometricAvailable);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? unlocked,
    TResult Function(bool isBiometricAvailable)? locked,
    required TResult orElse(),
  }) {
    if (locked != null) {
      return locked(isBiometricAvailable);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(Unlocked value) unlocked,
    required TResult Function(Locked value) locked,
  }) {
    return locked(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(Unlocked value)? unlocked,
    TResult Function(Locked value)? locked,
    required TResult orElse(),
  }) {
    if (locked != null) {
      return locked(this);
    }
    return orElse();
  }
}

abstract class Locked implements LockState {
  const factory Locked({required bool isBiometricAvailable}) = _$Locked;

  bool get isBiometricAvailable => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $LockedCopyWith<Locked> get copyWith => throw _privateConstructorUsedError;
}
