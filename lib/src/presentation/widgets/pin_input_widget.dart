import 'package:flutter/material.dart';
import 'package:pin_lock/src/presentation/builders.dart';

class PinInputWidget extends StatefulWidget {
  final String value;
  final int pinLength;
  final FocusNode? focusNode;
  final FocusNode? nextFocusNode;
  final Function(String) onInput;
  final bool autofocus;

  final PinInputBuilder? inputNodeBuilder;

  const PinInputWidget({
    Key? key,
    required this.value,
    required this.pinLength,
    required this.onInput,
    this.focusNode,
    this.inputNodeBuilder,
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

  static const double _nodeSize = 32;

  @override
  Widget build(BuildContext context) {
    if (controller.text != widget.value) {
      controller.text = widget.value;
    }
    final selectedIndex = widget.value.length;
    return Stack(
      alignment: Alignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            widget.pinLength,
            (index) {
              if (index == selectedIndex && focusNode.hasFocus == true) {
                return widget.inputNodeBuilder?.call(index, InputFieldState.focused) ??
                    const Card(
                      elevation: 24,
                      shape: CircleBorder(),
                      child: SizedBox(width: _nodeSize, height: _nodeSize),
                    );
              }
              if (index < selectedIndex) {
                return widget.inputNodeBuilder?.call(index, InputFieldState.filled) ??
                    const Card(
                      elevation: 4,
                      color: Colors.blue,
                      shape: CircleBorder(),
                      child: SizedBox(width: _nodeSize, height: _nodeSize),
                    );
              }
              return widget.inputNodeBuilder?.call(index, InputFieldState.empty) ??
                  const Card(
                    elevation: 4,
                    shape: CircleBorder(),
                    child: SizedBox(width: _nodeSize, height: _nodeSize),
                  );
            },
          ),
        ),
        Opacity(
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
      ],
    );
  }
}
