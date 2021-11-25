import 'package:flutter/material.dart';
import 'package:pin_lock/src/presentation/pin_input.dart';

class PinInputWidget extends StatefulWidget {
  final String value;
  final int pinLength;
  final FocusNode? focusNode;
  final FocusNode? nextFocusNode;
  final Function(String) onInput;
  final bool autofocus;
  final bool hasError;

  final PinInputBuilder inputNodeBuilder;

  const PinInputWidget({
    Key? key,
    required this.value,
    required this.pinLength,
    required this.onInput,
    required this.inputNodeBuilder,
    required this.hasError,
    this.focusNode,
    this.nextFocusNode,
    this.autofocus = false,
  }) : super(key: key);

  @override
  _PinInputWidgetState createState() => _PinInputWidgetState();
}

class _PinInputWidgetState extends State<PinInputWidget> {
  late final TextEditingController controller;
  late final FocusNode focusNode;
  @override
  void initState() {
    super.initState();
    controller = TextEditingController(text: widget.value);
    focusNode = widget.focusNode ?? FocusNode();
    if (widget.autofocus) {
      focusNode.requestFocus();
    }
    focusNode.addListener(() => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    if (controller.text != widget.value) {
      controller.text = widget.value;
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: List.generate(
                widget.pinLength,
                (index) {
                  if (widget.hasError) {
                    return widget.inputNodeBuilder(
                        index, InputFieldState.error);
                  }
                  return widget.inputNodeBuilder(index, _determineState(index));
                },
              ),
            ),
            Positioned.fill(
              child: Opacity(
                opacity: 0,
                child: TextField(
                  controller: controller,
                  focusNode: focusNode,
                  keyboardType: TextInputType.number,
                  maxLength: widget.pinLength,
                  onChanged: (text) async {
                    widget.onInput(text);
                    if (text.length == widget.pinLength &&
                        focusNode.hasFocus == true) {
                      widget.nextFocusNode?.requestFocus();
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  InputFieldState _determineState(int position) {
    final nextFocusPosition = widget.value.length;

    // already filled input fields
    if (position < nextFocusPosition) {
      // if the last field is filled and the input still has focus
      if (position == widget.pinLength - 1 && focusNode.hasFocus) {
        return InputFieldState.filledAndFocused;
      }
      return InputFieldState.filled;
    } else if (position == nextFocusPosition && focusNode.hasFocus) {
      // represents next value to be entered
      return InputFieldState.focused;
    } else {
      // fields not yet filled
      return InputFieldState.empty;
    }
  }
}
