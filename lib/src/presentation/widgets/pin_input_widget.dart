import 'package:flutter/material.dart';

typedef PinInputBuilder = Widget Function(int index);
typedef FilledPinInputBuilder = Widget Function(int index, String text);

class PinInputWidget extends StatefulWidget {
  final String value;
  final int pinLength;
  final FocusNode focusNode;
  final FocusNode? nextFocusNode;
  final Function(String) onInput;

  final PinInputBuilder? emptyNodeBuilder;
  final PinInputBuilder? focusedNodeBuilder;
  final FilledPinInputBuilder? filledPinInputBuilder;

  const PinInputWidget({
    Key? key,
    required this.value,
    required this.pinLength,
    required this.focusNode,
    required this.onInput,
    this.emptyNodeBuilder,
    this.focusedNodeBuilder,
    this.filledPinInputBuilder,
    this.nextFocusNode,
  }) : super(key: key);

  @override
  _PinInputWidgetState createState() => _PinInputWidgetState();
}

class _PinInputWidgetState extends State<PinInputWidget> {
  late final TextEditingController controller;
  @override
  void initState() {
    super.initState();
    controller = TextEditingController(text: widget.value);
  }

  static const double _nodeSize = 32;
  @override
  Widget build(BuildContext context) {
    if (controller.text != widget.value) {
      controller.text = widget.value;
    }
    final selectedIndex = widget.value.length;
    return GestureDetector(
      onTap: () {
        widget.focusNode.requestFocus();
      },
      child: Stack(
        alignment: Alignment.center,
        children: [
          TextField(
            controller: controller,
            focusNode: widget.focusNode,
            keyboardType: TextInputType.number,
            onChanged: (text) async {
              widget.onInput(text);
              if (text.length == widget.pinLength && widget.focusNode.hasFocus) {
                widget.nextFocusNode?.requestFocus();
              }
            },
            decoration: const InputDecoration(
              contentPadding: EdgeInsets.all(0),
              border: InputBorder.none,
              fillColor: Colors.transparent,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              disabledBorder: InputBorder.none,
            ),
            style: const TextStyle(
              color: Colors.transparent,
              height: .01,
              fontSize: 0.01,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              widget.pinLength,
              (index) {
                if (index == selectedIndex && widget.focusNode.hasFocus) {
                  return widget.focusedNodeBuilder != null
                      ? widget.focusedNodeBuilder!.call(index)
                      : const Card(
                          elevation: 24,
                          shape: CircleBorder(),
                          child: SizedBox(width: _nodeSize, height: _nodeSize),
                        );
                }
                if (index < selectedIndex) {
                  return widget.filledPinInputBuilder != null
                      ? widget.filledPinInputBuilder!(index, widget.value[index])
                      : const Card(
                          elevation: 4,
                          color: Colors.blue,
                          shape: CircleBorder(),
                          child: SizedBox(width: _nodeSize, height: _nodeSize),
                        );
                }
                return widget.emptyNodeBuilder != null
                    ? widget.emptyNodeBuilder!(index)
                    : const Card(
                        elevation: 4,
                        shape: CircleBorder(),
                        child: SizedBox(width: _nodeSize, height: _nodeSize),
                      );
              },
            ),
          ),
        ],
      ),
    );
  }
}
