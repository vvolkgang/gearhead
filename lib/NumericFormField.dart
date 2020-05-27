import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class IntFormField extends StatelessWidget {
  final ValueChanged<int> onChanged;
  final InputDecoration decoration;
  final String initialValue;

  const IntFormField({Key key, this.decoration, this.onChanged, this.initialValue}) : super(key: key);

  void onChangedWrapper(String value) => onChanged(int.parse(value));

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      decoration: decoration,
      keyboardType: const TextInputType.numberWithOptions(signed: false, decimal: false),
      onChanged: onChangedWrapper,
      initialValue: initialValue,
      inputFormatters: [
        WhitelistingTextInputFormatter.digitsOnly,
      ],
    );
  }
}

class DoubleFormField extends StatelessWidget {
  final ValueChanged<double> onChanged;
  final InputDecoration decoration;
  final int decimalRange;
  final String initialValue;

  const DoubleFormField({Key key, this.decoration, this.decimalRange = 2, this.onChanged, this.initialValue}) : super(key: key);

  void onChangedWrapper(String value) => onChanged(double.parse(value));

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      decoration: decoration,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      onChanged: onChangedWrapper,
      initialValue: initialValue,
      inputFormatters: [
        WhitelistingTextInputFormatter(RegExp(r'[\d+\-\.]')),
        DecimalTextInputFormatter(decimalRange: this.decimalRange),
      ],
    );
  }
}

class DecimalTextInputFormatter extends TextInputFormatter {
  DecimalTextInputFormatter({this.decimalRange}) : assert(decimalRange == null || decimalRange > 0);

  final int decimalRange;

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    TextEditingValue _newValue = this.sanitize(newValue);
    String text = _newValue.text;

    if (decimalRange == null) {
      return _newValue;
    }

    if (text == '.') {
      return TextEditingValue(
        text: '0.',
        selection: _newValue.selection.copyWith(baseOffset: 2, extentOffset: 2),
        composing: TextRange.empty,
      );
    }

    return this.isValid(text) ? _newValue : oldValue;
  }

  bool isValid(String text) {
    int dots = '.'.allMatches(text).length;

    if (dots == 0) {
      return true;
    }

    if (dots > 1) {
      return false;
    }

    return text.substring(text.indexOf('.') + 1).length <= decimalRange;
  }

  TextEditingValue sanitize(TextEditingValue value) {
    if (false == value.text.contains('-')) {
      return value;
    }

    String text = '-' + value.text.replaceAll('-', '');

    return TextEditingValue(text: text, selection: value.selection, composing: TextRange.empty);
  }
}
