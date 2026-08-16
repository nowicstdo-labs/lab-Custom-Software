/// Safe Formula Evaluator for Diagnostic Formula Engine.
/// Parses arithmetic expressions containing constants, variables, +, -, *, /, and parentheses.
class FormulaEvaluator {
  FormulaEvaluator._();

  static double evaluate(String expression, Map<String, double> variableValues) {
    String expr = expression.replaceAll(' ', '');
    // Replace variable names with their double string values
    // Sort keys by length descending to prevent substring mismatch (e.g. VAR1 vs VAR10)
    final sortedKeys = variableValues.keys.toList()
      ..sort((a, b) => b.length.compareTo(a.length));

    for (final varName in sortedKeys) {
      final val = variableValues[varName] ?? 0.0;
      expr = expr.replaceAll(varName, val.toString());
    }

    try {
      final parser = _Parser(expr);
      return parser.parse();
    } catch (e) {
      return 0.0;
    }
  }
}

class _Parser {
  final String text;
  int pos = 0;

  _Parser(this.text);

  int get ch => pos < text.length ? text.codeUnitAt(pos) : -1;

  double parse() {
    final v = _parseExpression();
    if (pos < text.length) {
      throw FormatException('Unexpected character at position $pos: ${text[pos]}');
    }
    return v;
  }

  double _parseExpression() {
    double v = _parseTerm();
    while (true) {
      if (ch == 43) { // '+'
        pos++;
        v += _parseTerm();
      } else if (ch == 45) { // '-'
        pos++;
        v -= _parseTerm();
      } else {
        break;
      }
    }
    return v;
  }

  double _parseTerm() {
    double v = _parseFactor();
    while (true) {
      if (ch == 42) { // '*'
        pos++;
        v *= _parseFactor();
      } else if (ch == 47) { // '/'
        pos++;
        final denominator = _parseFactor();
        if (denominator == 0.0) return 0.0;
        v /= denominator;
      } else {
        break;
      }
    }
    return v;
  }

  double _parseFactor() {
    if (ch == 45) { // Unary '-'
      pos++;
      return -_parseFactor();
    }
    if (ch == 43) { // Unary '+'
      pos++;
      return _parseFactor();
    }
    if (ch == 40) { // '('
      pos++;
      final v = _parseExpression();
      if (ch == 41) { // ')'
        pos++;
      }
      return v;
    }

    final start = pos;
    while ((ch >= 48 && ch <= 57) || ch == 46) { // Digits or '.'
      pos++;
    }
    if (start == pos) {
      return 0.0;
    }
    return double.tryParse(text.substring(start, pos)) ?? 0.0;
  }
}
