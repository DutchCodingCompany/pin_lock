import 'package:flutter/cupertino.dart';

/// Describes the state of the given pin input field
enum InputFieldState {
  /// The field is in it's initial state
  empty,

  /// The field is about to be filled, but the user hasn't entered the value yet
  focused,

  /// The filed is filled and focus has moved on to the next filed
  filled,

  /// The field is filled and input widget is focused (likely to be the last field)
  filledAndFocused,

  /// The field is cleared right after an unsuccessful attempt to unlock
  error,
}

/// Gives an interface to which pin input widgets should conform
/// You decide what the input widgets should look like, based on the [InputFieldState]
/// and the position ([index]) of the field. Input fields will be drawn in a [Row]
typedef PinInputBuilder = Widget Function(int index, InputFieldState state);
