import 'package:flutter/material.dart';

enum ThreeDAssetType {
  receptionist,
  labTechnician,
  doctor,
  patientHealth,
  testTubes,
  microscope,
  sample,
  report,
  appointment,
}

extension ThreeDAssetTypeExtension on ThreeDAssetType {
  String get assetPath {
    switch (this) {
      case ThreeDAssetType.receptionist:
        return 'assets/images/3d/receptionist_3d.png';
      case ThreeDAssetType.labTechnician:
        return 'assets/images/3d/lab_technician_3d.png';
      case ThreeDAssetType.doctor:
        return 'assets/images/3d/doctor_3d.png';
      case ThreeDAssetType.patientHealth:
        return 'assets/images/3d/patient_health_3d.png';
      case ThreeDAssetType.testTubes:
        return 'assets/images/3d/test_tubes_3d.png';
      case ThreeDAssetType.microscope:
        return 'assets/images/3d/microscope_3d.png';
      case ThreeDAssetType.sample:
        return 'assets/images/3d/sample_3d.png';
      case ThreeDAssetType.report:
        return 'assets/images/3d/report_3d.png';
      case ThreeDAssetType.appointment:
        return 'assets/images/3d/appointment_3d.png';
    }
  }

  IconData get fallbackIcon {
    switch (this) {
      case ThreeDAssetType.receptionist:
        return Icons.support_agent;
      case ThreeDAssetType.labTechnician:
        return Icons.biotech;
      case ThreeDAssetType.doctor:
        return Icons.medical_services;
      case ThreeDAssetType.patientHealth:
        return Icons.health_and_safety;
      case ThreeDAssetType.testTubes:
        return Icons.science;
      case ThreeDAssetType.microscope:
        return Icons.coronavirus;
      case ThreeDAssetType.sample:
        return Icons.water_drop;
      case ThreeDAssetType.report:
        return Icons.assignment_turned_in;
      case ThreeDAssetType.appointment:
        return Icons.calendar_month;
    }
  }

  Color get primaryColor {
    switch (this) {
      case ThreeDAssetType.receptionist:
        return const Color(0xFF2563EB);
      case ThreeDAssetType.labTechnician:
        return const Color(0xFF14B8A6);
      case ThreeDAssetType.doctor:
        return const Color(0xFF0284C7);
      case ThreeDAssetType.patientHealth:
        return const Color(0xFF3B82F6);
      case ThreeDAssetType.testTubes:
        return const Color(0xFFEC4899);
      case ThreeDAssetType.microscope:
        return const Color(0xFF8B5CF6);
      case ThreeDAssetType.sample:
        return const Color(0xFFEF4444);
      case ThreeDAssetType.report:
        return const Color(0xFF10B981);
      case ThreeDAssetType.appointment:
        return const Color(0xFFF59E0B);
    }
  }
}

class ThreeDIllustration extends StatelessWidget {
  final ThreeDAssetType type;
  final double size;
  final BoxFit fit;

  const ThreeDIllustration({
    super.key,
    required this.type,
    this.size = 120,
    this.fit = BoxFit.contain,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          center: const Alignment(-0.3, -0.4),
          radius: 0.8,
          colors: [
            Colors.white.withValues(alpha: 0.9),
            type.primaryColor.withValues(alpha: 0.25),
            type.primaryColor,
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
        boxShadow: [
          BoxShadow(
            color: type.primaryColor.withValues(alpha: 0.35),
            blurRadius: size * 0.2,
            offset: Offset(0, size * 0.1),
          ),
        ],
      ),
      child: Icon(
        type.fallbackIcon,
        size: size * 0.48,
        color: Colors.white,
      ),
    );
  }

}
