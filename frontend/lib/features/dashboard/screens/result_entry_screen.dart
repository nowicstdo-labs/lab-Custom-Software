import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../../models/lab_report.dart';
import '../../../models/test_result.dart';
import '../../../services/shared_data_repository.dart';
import '../../../services/api_service.dart';
import '../../../utils/formula_evaluator.dart';

class ResultEntryScreen extends ConsumerStatefulWidget {
  final String? sampleId;

  const ResultEntryScreen({super.key, this.sampleId});

  @override
  ConsumerState<ResultEntryScreen> createState() => _ResultEntryScreenState();
}

class _ResultEntryScreenState extends ConsumerState<ResultEntryScreen> {
  late List<_ParamInput> _paramInputs;
  final _remarksController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _paramInputs = [
      _ParamInput(name: 'SGOT (AST)', value: '28', unit: 'U/L', refRange: '10 - 40', flag: ParameterFlag.normal),
      _ParamInput(name: 'SGPT (ALT)', value: '32', unit: 'U/L', refRange: '7 - 56', flag: ParameterFlag.normal),
      _ParamInput(name: 'Total Bilirubin', value: '1.2', unit: 'mg/dL', refRange: '0.2 - 1.2', flag: ParameterFlag.normal),
      _ParamInput(name: 'Direct Bilirubin', value: '0.3', unit: 'mg/dL', refRange: '0.0 - 0.3', flag: ParameterFlag.normal),
      _ParamInput(name: 'Indirect Bilirubin (Formula)', value: '0.9', unit: 'mg/dL', refRange: '0.2 - 0.8', flag: ParameterFlag.high, isCalculated: true),
    ];
  }

  @override
  void dispose() {
    _remarksController.dispose();
    super.dispose();
  }

  void _runFormulaEngine() {
    final sharedData = ref.read(sharedDataProvider);
    final activeFormulas = sharedData.formulas.where((f) => f.isActive).toList();

    Map<String, double> variableValues = {};
    for (final p in _paramInputs) {
      final nameUpper = p.name.toUpperCase().replaceAll(' ', '_');
      final val = double.tryParse(p.value.text) ?? 0.0;
      variableValues[nameUpper] = val;
      if (p.name.contains('Total Bilirubin')) variableValues['TOTAL_BIL'] = val;
      if (p.name.contains('Direct Bilirubin')) variableValues['DIRECT_BIL'] = val;
    }

    for (final formula in activeFormulas) {
      final calculatedVal = FormulaEvaluator.evaluate(formula.formulaExpression, variableValues);
      final calcString = calculatedVal.toStringAsFixed(2);

      // Update or add parameter
      final existingIdx = _paramInputs.indexWhere((p) => p.name.contains(formula.formulaName));
      if (existingIdx >= 0) {
        setState(() {
          _paramInputs[existingIdx].value.text = calcString;
        });
      } else {
        setState(() {
          _paramInputs.add(
            _ParamInput(
              name: '${formula.formulaName} (Calculated)',
              value: calcString,
              unit: formula.unit,
              refRange: formula.referenceRange,
              flag: ParameterFlag.normal,
              isCalculated: true,
            ),
          );
        });
      }
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Formula Engine: Calculated values evaluated automatically!'),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  void _addParameter() {
    setState(() {
      _paramInputs.add(_ParamInput(name: '', value: '', unit: '', refRange: ''));
    });
  }

  Future<void> _saveDraftOrSubmit({required bool isSubmit}) async {
    final sharedData = ref.read(sharedDataProvider);
    final targetSample = sharedData.samples.firstWhere(
      (s) => s.sampleId == widget.sampleId,
      orElse: () => sharedData.samples.first,
    );

    final parameters = _paramInputs.map((p) {
      return TestResultParameter(
        parameterName: p.name,
        resultValue: p.value.text.trim(),
        unit: p.unit,
        referenceRange: p.refRange,
        flag: p.flag,
        remark: p.remark.text.trim(),
      );
    }).toList();

    try {
      await ApiService.post('/results', {
        'sampleId': targetSample.sampleId,
        'results': _paramInputs.map((p) => {
          'parameterId': p.name,
          'resultValue': p.value.text.trim(),
        }).toList(),
      });
      await ApiService.post('/reports', {
        'bookingId': targetSample.bookingId,
        'parameters': _paramInputs.map((p) => {
          'parameterName': p.name,
          'resultValue': p.value.text.trim(),
          'unit': p.unit,
          'referenceRange': p.refRange,
        }).toList(),
      });
    } catch (_) {}

    final reportId = 'ASTH-RPT-2026-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';

    final draftReport = LabReport(
      reportId: reportId,
      bookingId: targetSample.bookingId,
      sampleId: targetSample.sampleId,
      patientId: targetSample.patientId,
      patientName: targetSample.patientId,
      patientAgeGender: '28 Yrs / Male',
      testName: targetSample.testName,
      sampleType: targetSample.sampleType,
      collectionDate: '${targetSample.collectionDate} ${targetSample.collectionTime}',
      reportDate: '${targetSample.collectionDate} 04:30 PM',
      parameters: parameters,
      status: isSubmit ? ReportStatus.readyForVerification : ReportStatus.draft,
      doctorPathologistName: 'Dr. Priya Mehta, MD (Pathology)',
      doctorQualifications: 'Senior Pathologist • KMC Reg #48291',
      qrToken: 'ASTH-RPT-TOKEN-$reportId',
    );

    ref.read(sharedDataProvider.notifier).submitReportDraft(draftReport);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isSubmit
                ? 'Results submitted! Report $reportId sent to Admin for Verification.'
                : 'Draft report saved successfully.',
          ),
          backgroundColor: const Color(0xFF00796B),
        ),
      );

      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final sharedData = ref.watch(sharedDataProvider);
    final sample = sharedData.samples.firstWhere(
      (s) => s.sampleId == widget.sampleId,
      orElse: () => sharedData.samples.first,
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text('Test Result Entry — ${sample.sampleId}'),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: () => context.pop(),
        ),
        actions: [
          ElevatedButton.icon(
            onPressed: _runFormulaEngine,
            icon: const Icon(Icons.calculate, size: 16),
            label: const Text('Run Formula Engine'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF14B8A6),
              elevation: 0,
            ),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Test & Patient Banner
              Container(
                padding: const EdgeInsets.all(16),
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
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE0F2F1),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(Icons.science, color: Color(0xFF00796B), size: 28),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(sample.testName, style: AppTextStyles.headline3.copyWith(fontSize: 16)),
                          const SizedBox(height: 2),
                          Text('Patient ID: ${sample.patientId} • Sample: ${sample.sampleId}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Test Parameters & Measurements', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  TextButton.icon(
                    onPressed: _addParameter,
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text('Add Parameter'),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _paramInputs.length,
                itemBuilder: (context, index) {
                  final param = _paramInputs[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: param.isCalculated ? const Color(0xFF14B8A6) : Colors.grey.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                param.name,
                                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                              ),
                            ),
                            if (param.isCalculated)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFCCFBF1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Text(
                                  'Formula Engine',
                                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF0F766E)),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: TextField(
                                controller: param.value,
                                decoration: const InputDecoration(
                                  labelText: 'Result Value',
                                  border: OutlineInputBorder(),
                                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              flex: 1,
                              child: Text('Unit:\n${param.unit}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text('Ref Range:\n${param.refRange}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                            ),
                            DropdownButton<ParameterFlag>(
                              value: param.flag,
                              items: ParameterFlag.values
                                  .map((f) => DropdownMenuItem(
                                        value: f,
                                        child: Text(f.displayName),
                                      ))
                                  .toList(),
                              onChanged: (v) {
                                if (v != null) setState(() => param.flag = v);
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),

              const SizedBox(height: 20),

              const Text('Overall Technician Remarks', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              TextField(
                controller: _remarksController,
                maxLines: 2,
                decoration: InputDecoration(
                  hintText: 'Enter clinical observations or remarks...',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                  fillColor: Colors.white,
                  filled: true,
                ),
              ),

              const SizedBox(height: 24),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _saveDraftOrSubmit(isSubmit: false),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                      ),
                      child: const Text('Save Draft'),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _saveDraftOrSubmit(isSubmit: true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2563EB),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                      ),
                      child: const Text('Submit for Verification'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ParamInput {
  String name;
  TextEditingController value;
  String unit;
  String refRange;
  ParameterFlag flag;
  TextEditingController remark;
  bool isCalculated;

  _ParamInput({
    required this.name,
    required String value,
    required this.unit,
    required this.refRange,
    this.flag = ParameterFlag.normal,
    this.isCalculated = false,
  })  : value = TextEditingController(text: value),
        remark = TextEditingController();
}
