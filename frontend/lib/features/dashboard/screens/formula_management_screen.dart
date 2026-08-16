import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../../models/formula_item.dart';
import '../../../services/shared_data_repository.dart';

class FormulaManagementScreen extends ConsumerStatefulWidget {
  const FormulaManagementScreen({super.key});

  @override
  ConsumerState<FormulaManagementScreen> createState() => _FormulaManagementScreenState();
}

class _FormulaManagementScreenState extends ConsumerState<FormulaManagementScreen> {
  final _nameController = TextEditingController();
  final _exprController = TextEditingController();
  final _varsController = TextEditingController();
  final _unitController = TextEditingController();
  final _refController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _exprController.dispose();
    _varsController.dispose();
    _unitController.dispose();
    _refController.dispose();
    super.dispose();
  }

  void _showAddFormulaModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          left: 20,
          right: 20,
          top: 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 16),
            const Text('Create Admin Diagnostic Formula', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            const Text('Define automated calculation logic for lab parameters.', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
            const SizedBox(height: 16),

            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Formula Name *', hintText: 'e.g. Globulin'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _exprController,
              decoration: const InputDecoration(labelText: 'Expression *', hintText: 'e.g. TOTAL_PROTEIN - ALBUMIN'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _varsController,
              decoration: const InputDecoration(labelText: 'Variables (comma separated) *', hintText: 'TOTAL_PROTEIN, ALBUMIN'),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _unitController,
                    decoration: const InputDecoration(labelText: 'Unit', hintText: 'g/dL'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _refController,
                    decoration: const InputDecoration(labelText: 'Reference Range', hintText: '2.0 - 3.5'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  final name = _nameController.text.trim();
                  final expr = _exprController.text.trim();
                  if (name.isEmpty || expr.isEmpty) return;

                  final vars = _varsController.text.split(',').map((v) => v.trim()).where((v) => v.isNotEmpty).toList();

                  final newFormula = FormulaItem(
                    formulaId: 'f-${DateTime.now().millisecondsSinceEpoch}',
                    formulaName: name,
                    formulaExpression: expr,
                    variables: vars.isEmpty ? ['A', 'B'] : vars,
                    targetTestId: 't2',
                    targetTestName: 'Biochemistry Test',
                    unit: _unitController.text.trim().isEmpty ? 'g/dL' : _unitController.text.trim(),
                    referenceRange: _refController.text.trim().isEmpty ? 'Normal' : _refController.text.trim(),
                    isActive: true,
                  );

                  ref.read(sharedDataProvider.notifier).addFormula(newFormula);

                  _nameController.clear();
                  _exprController.clear();
                  _varsController.clear();
                  _unitController.clear();
                  _refController.clear();

                  Navigator.pop(context);

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Formula "$name" created successfully!')),
                  );
                },
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                child: const Text('Save Formula'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sharedData = ref.watch(sharedDataProvider);
    final formulas = sharedData.formulas;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Formula Management Engine'),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline, color: AppColors.primary),
            onPressed: () => _showAddFormulaModal(context),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Admin-Managed Formulas', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              const Text('Receptionists and Lab Technicians can use these formulas to calculate test results automatically.', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              const SizedBox(height: 16),

              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: formulas.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final formula = formulas[index];
                  return Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(formula.formulaName, style: AppTextStyles.headline3.copyWith(fontSize: 16, fontWeight: FontWeight.bold)),
                            Switch(
                              value: formula.isActive,
                              activeThumbColor: const Color(0xFF14B8A6),
                              onChanged: (val) {
                                ref.read(sharedDataProvider.notifier).toggleFormulaActive(formula.formulaId);
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.functions, size: 18, color: AppColors.primary),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  formula.formulaExpression,
                                  style: const TextStyle(fontFamily: 'monospace', fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.primary),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Variables: ${formula.variables.join(', ')}', style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                            Text('Ref Range: ${formula.referenceRange} ${formula.unit}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddFormulaModal(context),
        icon: const Icon(Icons.add),
        label: const Text('New Formula'),
        backgroundColor: const Color(0xFF14B8A6),
      ),
    );
  }
}
