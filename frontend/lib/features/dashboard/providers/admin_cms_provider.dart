import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/doctor.dart';
import '../../../utils/dummy_data.dart';
import '../../../services/api_service.dart';

class CmsState {
  final String heroTitle;
  final String heroSubtitle;
  final String heroButtonText;
  final String promoTitle;
  final bool showPromoBanner;
  final String labName;
  final String labPhone;
  final String labEmail;
  final String labAddress;
  final String reportHeader;
  final String reportFooter;
  final List<Doctor> doctors;
  final List<DiagnosticTestModel> tests;
  final Map<String, bool> features;

  CmsState({
    this.heroTitle = 'Your Health, Our Priority',
    this.heroSubtitle = 'Accurate diagnostics with trusted care across modern operations.',
    this.heroButtonText = 'Book a Test',
    this.promoTitle = 'Full Body Checkup Package @ 40% OFF',
    this.showPromoBanner = true,
    this.labName = 'Astha Diagnostic Laboratory',
    this.labPhone = '+91 98765 43210',
    this.labEmail = 'contact@asthadiagnostic.com',
    this.labAddress = '102 Healthcare Avenue, Medical District',
    this.reportHeader = 'ASTHA DIAGNOSTIC LABORATORY — ISO 9001:2015 CERTIFIED',
    this.reportFooter = 'This is an electronically verified digital diagnostic report.',
    List<Doctor>? doctors,
    this.tests = const [
      DiagnosticTestModel(id: 'TEST-CBC', name: 'Complete Blood Count (CBC)', category: 'Blood Tests', price: 500, description: 'Measures RBC, WBC, Hemoglobin & Platelets.', tat: '24 Hours'),
      DiagnosticTestModel(id: 'TEST-LFT', name: 'Liver Function Test (LFT)', category: 'Biochemistry', price: 850, description: 'Bilirubin, SGOT, SGPT, Alkaline Phosphatase.', tat: '24 Hours'),
      DiagnosticTestModel(id: 'TEST-KFT', name: 'Kidney Function Test (KFT)', category: 'Biochemistry', price: 750, description: 'Urea, Creatinine, Uric Acid, Electrolytes.', tat: '24 Hours'),
      DiagnosticTestModel(id: 'TEST-LIPID', name: 'Lipid Profile', category: 'Biochemistry', price: 900, description: 'Cholesterol, Triglycerides, HDL, LDL.', tat: '24 Hours'),
      DiagnosticTestModel(id: 'TEST-THYROID', name: 'Thyroid Panel (T3, T4, TSH)', category: 'Hormones', price: 650, description: 'Total T3, Total T4, TSH Ultra-Sensitive.', tat: '24 Hours'),
    ],
    this.features = const {
      'patientRegistration': true,
      'testBooking': true,
      'doctorConsultation': true,
      'onlineReports': true,
      'homeCollection': true,
    },
  }) : doctors = doctors ?? mockDoctors;

  CmsState copyWith({
    String? heroTitle,
    String? heroSubtitle,
    String? heroButtonText,
    String? promoTitle,
    bool? showPromoBanner,
    String? labName,
    String? labPhone,
    String? labEmail,
    String? labAddress,
    String? reportHeader,
    String? reportFooter,
    List<Doctor>? doctors,
    List<DiagnosticTestModel>? tests,
    Map<String, bool>? features,
  }) {
    return CmsState(
      heroTitle: heroTitle ?? this.heroTitle,
      heroSubtitle: heroSubtitle ?? this.heroSubtitle,
      heroButtonText: heroButtonText ?? this.heroButtonText,
      promoTitle: promoTitle ?? this.promoTitle,
      showPromoBanner: showPromoBanner ?? this.showPromoBanner,
      labName: labName ?? this.labName,
      labPhone: labPhone ?? this.labPhone,
      labEmail: labEmail ?? this.labEmail,
      labAddress: labAddress ?? this.labAddress,
      reportHeader: reportHeader ?? this.reportHeader,
      reportFooter: reportFooter ?? this.reportFooter,
      doctors: doctors ?? this.doctors,
      tests: tests ?? this.tests,
      features: features ?? this.features,
    );
  }
}

class DiagnosticTestModel {
  final String id;
  final String name;
  final String category;
  final double price;
  final String description;
  final String tat;

  const DiagnosticTestModel({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.description,
    required this.tat,
  });
}

class AdminCmsNotifier extends StateNotifier<CmsState> {
  AdminCmsNotifier() : super(CmsState());

  void updateHomeCms({required String title, required String subtitle, required String buttonText, required String promoTitle}) {
    state = state.copyWith(
      heroTitle: title,
      heroSubtitle: subtitle,
      heroButtonText: buttonText,
      promoTitle: promoTitle,
    );
    ApiService.patch('/admin/cms/home', {
      'heroTitle': title,
      'heroSubtitle': subtitle,
      'heroButtonText': buttonText,
      'promoTitle': promoTitle,
    });
  }

  void updateLabProfile({required String name, required String phone, required String email, required String address, required String header, required String footer}) {
    state = state.copyWith(
      labName: name,
      labPhone: phone,
      labEmail: email,
      labAddress: address,
      reportHeader: header,
      reportFooter: footer,
    );
    ApiService.patch('/admin/cms/lab-profile', {
      'labName': name,
      'phone': phone,
      'email': email,
      'address': address,
      'headerText': header,
      'footerText': footer,
    });
  }

  void updateDoctor(Doctor updatedDoc) {
    final list = [...state.doctors];
    final idx = list.indexWhere((d) => d.id == updatedDoc.id);
    if (idx != -1) {
      list[idx] = updatedDoc;
    } else {
      list.insert(0, updatedDoc);
    }
    state = state.copyWith(doctors: list);
    ApiService.patch('/doctors/${updatedDoc.id}', {
      'specialization': updatedDoc.specialization,
      'qualification': updatedDoc.qualification,
      'experience': updatedDoc.experience,
      'consultationFee': updatedDoc.consultationFee,
      'availability': updatedDoc.availability,
    });
  }

  void updateTest(DiagnosticTestModel updatedTest) {
    final list = [...state.tests];
    final idx = list.indexWhere((t) => t.id == updatedTest.id);
    if (idx != -1) {
      list[idx] = updatedTest;
    } else {
      list.insert(0, updatedTest);
    }
    state = state.copyWith(tests: list);
    ApiService.patch('/tests/${updatedTest.id}', {
      'testName': updatedTest.name,
      'category': updatedTest.category,
      'price': updatedTest.price,
      'description': updatedTest.description,
      'tat': updatedTest.tat,
    });
  }

  void toggleFeature(String featureKey, bool enabled) {
    final newMap = Map<String, bool>.from(state.features);
    newMap[featureKey] = enabled;
    state = state.copyWith(features: newMap);
    ApiService.patch('/admin/cms/features', newMap);
  }
}

final adminCmsProvider = StateNotifierProvider<AdminCmsNotifier, CmsState>((ref) {
  return AdminCmsNotifier();
});
