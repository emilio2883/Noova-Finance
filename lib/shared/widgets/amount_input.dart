import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Numeric amount input with decimal support.
/// Returns the raw string; caller parses with DecimalUtils.
class AmountInput extends StatefulWidget {
  final ValueChanged<String> onChanged;

  const AmountInput({super.key, required this.onChanged});

  @override
  State<AmountInput> createState() => _AmountInputState();
}

class _AmountInputState extends State<AmountInput> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.requestFocus();
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      focusNode: _focusNode,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^[\d]*[\.,]?[\d]{0,4}')),
      ],
      style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
      textAlign: TextAlign.center,
      decoration: const InputDecoration(
        prefixText: '\$ ',
        hintText: '0.00',
        border: InputBorder.none,
      ),
      onChanged: widget.onChanged,
    );
  }
}
