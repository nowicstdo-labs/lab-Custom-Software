import 'package:flutter/widgets.dart';

class Responsive {
  static bool isMobile(BuildContext context) => MediaQuery.of(context).size.width < 760;
  static bool isTablet(BuildContext context) => MediaQuery.of(context).size.width >= 760 && MediaQuery.of(context).size.width < 1100;
  static bool isDesktop(BuildContext context) => MediaQuery.of(context).size.width >= 1100;
}
