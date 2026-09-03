import 'package:flutter/services.dart';

/// Formatter that automatically formats input into Callyzer Biz Device Connect Code format:
/// [3-LETTERS]-[4-DIGITS]-[4-DIGITS], e.g. KAS-4257-4648 or ROH-3453-2342
class ConnectCodeInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // If user is deleting/backspacing, allow deletion smoothly
    if (newValue.text.length < oldValue.text.length) {
      return newValue;
    }

    // Strip everything except alphanumeric characters
    final raw = newValue.text.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '').toUpperCase();
    
    final StringBuffer buffer = StringBuffer();
    for (int i = 0; i < raw.length && i < 11; i++) {
      // First 3 are letters, rest digits
      buffer.write(raw[i]);
      if ((i == 2 || i == 6) && i < raw.length - 1) {
        buffer.write('-');
      }
    }

    var result = buffer.toString();
    
    // Auto append '-' right after completing 3 chars or 7 chars
    if (raw.length == 3 && !result.endsWith('-')) {
      result = '$result-';
    } else if (raw.length == 7 && !result.endsWith('-')) {
      result = '$result-';
    }

    return TextEditingValue(
      text: result,
      selection: TextSelection.collapsed(offset: result.length),
    );
  }
}
