import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/test_booking.dart';

final testBookingsProvider =
    StateNotifierProvider<TestBookingsNotifier, List<TestBooking>>((ref) {
  return TestBookingsNotifier();
});

class TestBookingsNotifier extends StateNotifier<List<TestBooking>> {
  TestBookingsNotifier() : super(_initialMockBookings);

  static const List<TestBooking> _initialMockBookings = [];

  void addBooking(TestBooking booking) {
    state = [booking, ...state];
  }
}
