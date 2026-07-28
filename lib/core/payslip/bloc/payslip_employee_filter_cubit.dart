import 'package:flutter_bloc/flutter_bloc.dart';

class PayslipEmployeeFilterCubit extends Cubit<DateTime> {
  PayslipEmployeeFilterCubit() : super(_currentMonth());

  void setMonth(DateTime firstDayOfMonth) {
    emit(DateTime(firstDayOfMonth.year, firstDayOfMonth.month, 1));
  }

  static DateTime _currentMonth() {
    final n = DateTime.now();
    return DateTime(n.year, n.month, 1);
  }
}
