import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../utils/extensions/buildcontext.dart';

class UserRateNumberField extends StatefulWidget {
  final int initial;
  final int? maxValue;
  final String label;
  final void Function(int) onChanged;

  const UserRateNumberField({
    super.key,
    required this.onChanged,
    required this.label,
    this.initial = 0,
    this.maxValue,
  });

  @override
  State<UserRateNumberField> createState() => _UserRateNumberFieldState();
}

class _UserRateNumberFieldState extends State<UserRateNumberField> {
  late final TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.initial.toString());
  }

  @override
  void didUpdateWidget(covariant UserRateNumberField oldWidget) {
    super.didUpdateWidget(oldWidget);
    final text = widget.initial.toString();
    if (text != _ctrl.text) {
      _ctrl.value = TextEditingValue(
        text: text,
        selection: TextSelection(
          baseOffset: text.length,
          extentOffset: text.length,
        ),
      );
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(0),
      elevation: 0,
      color: Colors.transparent,
      //color: context.colorScheme.surfaceVariant,
      shape: RoundedRectangleBorder(
        side: BorderSide(
          color: context.colorScheme.outline, //  outline  surfaceVariant
        ),
        borderRadius: const BorderRadius.all(
          Radius.circular(12),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.label,
              style: context.textTheme.labelLarge,
            ),
            TextField(
              scrollPadding: const EdgeInsets.all(0),
              maxLines: 1,
              minLines: 1,
              controller: _ctrl,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
              ],
              textAlign: TextAlign.start,
              style: context.textTheme.headlineSmall,
              decoration: const InputDecoration(
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.all(0),
              ),
              onChanged: _validateInput,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton.filledTonal(
                  onPressed: _ctrl.text == '0'
                      ? null
                      : () => _validateInput(_ctrl.text, -1),
                  icon: const Icon(
                    Icons.remove_rounded,
                  ),
                  style: ButtonStyle(
                    padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                      const EdgeInsets.all(0),
                    ),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  visualDensity: VisualDensity.compact,
                ),
                const SizedBox(
                  width: 8.0,
                ),
                IconButton.filledTonal(
                  onPressed: (widget.maxValue != null &&
                          _ctrl.text == '${widget.maxValue}')
                      ? null
                      : () => _validateInput(_ctrl.text, 1),
                  icon: const Icon(
                    Icons.add_rounded,
                  ),
                  style: ButtonStyle(
                    padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                      const EdgeInsets.all(0),
                    ),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _validateInput(String value, [int add = 0]) {
    int result;
    bool needCursorReset = true;

    if (value.isEmpty) {
      result = 0;
    } else {
      final number = int.parse(value) + add;

      if (widget.maxValue != null && number > widget.maxValue!) {
        result = widget.maxValue!;
      } else if (number < 0) {
        result = 0;
      } else {
        result = number;
        if (add == 0 && int.tryParse(value) == null) needCursorReset = false;
      }
    }

    widget.onChanged(result);
    if (!needCursorReset) return;

    final text = result.toString();
    _ctrl.value = _ctrl.value.copyWith(
      text: text,
      selection: TextSelection(
        baseOffset: text.length,
        extentOffset: text.length,
      ),
      composing: TextRange.empty,
    );
  }
}

class NumberField extends StatefulWidget {
  const NumberField({
    super.key,
    required this.onChanged,
    required this.label,
    this.initial = 0,
    this.maxValue,
  });

  final int initial;
  final int? maxValue;
  final String label;
  final void Function(int) onChanged;

  @override
  NumberFieldState createState() => NumberFieldState();
}

class NumberFieldState extends State<NumberField> {
  late final TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.initial.toString());
  }

  @override
  void didUpdateWidget(covariant NumberField oldWidget) {
    super.didUpdateWidget(oldWidget);
    final text = widget.initial.toString();
    if (text != _ctrl.text) {
      _ctrl.value = TextEditingValue(
        text: text,
        selection: TextSelection(
          baseOffset: text.length,
          extentOffset: text.length,
        ),
      );
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(widget.label),
        const SizedBox(
          width: 4,
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                maxLines: 1,
                minLines: 1,
                controller: _ctrl,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                textAlign: TextAlign.start,
                style: Theme.of(context).textTheme.bodyMedium,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(0),
                ),
                onChanged: _validateInput,
              ),
              const SizedBox(
                height: 2,
              ),
            ],
          ),
        ),
        const Spacer(),
        Wrap(
          children: [
            IconButton(
              onPressed: _ctrl.text == '0'
                  ? null
                  : () => _validateInput(_ctrl.text, -1),
              icon: const Icon(Icons.remove),
            ),
            const SizedBox(
              width: 4,
            ),
            IconButton(
              onPressed: (widget.maxValue != null &&
                      _ctrl.text == '${widget.maxValue}')
                  ? null
                  : () => _validateInput(_ctrl.text, 1),
              icon: const Icon(Icons.add),
            ),
          ],
        ),
      ],
    );
  }

  void _validateInput(String value, [int add = 0]) {
    int result;
    bool needCursorReset = true;

    if (value.isEmpty) {
      result = 0;
    } else {
      final number = int.parse(value) + add;

      if (widget.maxValue != null && number > widget.maxValue!) {
        result = widget.maxValue!;
      } else if (number < 0) {
        result = 0;
      } else {
        result = number;
        if (add == 0 && int.tryParse(value) == null) needCursorReset = false;
      }
    }

    widget.onChanged(result);
    if (!needCursorReset) return;

    final text = result.toString();
    _ctrl.value = _ctrl.value.copyWith(
      text: text,
      selection: TextSelection(
        baseOffset: text.length,
        extentOffset: text.length,
      ),
      composing: TextRange.empty,
    );
  }
}
