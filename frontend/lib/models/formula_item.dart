class FormulaItem {
  final String formulaId;
  final String formulaName;
  final String formulaExpression; // e.g. "(A + B) / 2" or "A * 0.2"
  final List<String> variables; // e.g. ["A", "B"]
  final String targetTestId;
  final String targetTestName;
  final String unit;
  final String referenceRange;
  final bool isActive;

  const FormulaItem({
    required this.formulaId,
    required this.formulaName,
    required this.formulaExpression,
    required this.variables,
    required this.targetTestId,
    required this.targetTestName,
    required this.unit,
    required this.referenceRange,
    this.isActive = true,
  });

  FormulaItem copyWith({
    String? formulaId,
    String? formulaName,
    String? formulaExpression,
    List<String>? variables,
    String? targetTestId,
    String? targetTestName,
    String? unit,
    String? referenceRange,
    bool? isActive,
  }) {
    return FormulaItem(
      formulaId: formulaId ?? this.formulaId,
      formulaName: formulaName ?? this.formulaName,
      formulaExpression: formulaExpression ?? this.formulaExpression,
      variables: variables ?? this.variables,
      targetTestId: targetTestId ?? this.targetTestId,
      targetTestName: targetTestName ?? this.targetTestName,
      unit: unit ?? this.unit,
      referenceRange: referenceRange ?? this.referenceRange,
      isActive: isActive ?? this.isActive,
    );
  }
}
