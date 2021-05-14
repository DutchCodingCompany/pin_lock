import 'package:flutter/material.dart';
import 'package:pin_lock/src/presentation/builders.dart';

class PinInputWidget extends StatefulWidget {
  final String value;
  final int pinLength;
  final FocusNode? focusNode;
  final FocusNode? nextFocusNode;
  final Function(String) onInput;
  final bool autofocus;

  final PinInputBuilder inputNodeBuilder;

  const PinInputWidget({
    Key? key,
    required this.value,
    required this.pinLength,
    required this.onInput,
    required this.inputNodeBuilder,
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
  }

  @override
  Widget build(BuildContext context) {
    if (controller.text != widget.value) {
      controller.text = widget.value;
    }
    final selectedIndex = widget.value.length;
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
                  if (index == selectedIndex && focusNode.hasFocus == true) {
                    return widget.inputNodeBuilder(index, InputFieldState.focused);
                  }
                  if (index < selectedIndex) {
                    return widget.inputNodeBuilder(index, InputFieldState.filled);
                  }
                  return widget.inputNodeBuilder(index, InputFieldState.empty);
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
                    if (text.length == widget.pinLength && focusNode.hasFocus == true) {
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
}
