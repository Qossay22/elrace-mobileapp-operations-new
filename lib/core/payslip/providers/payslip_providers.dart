import 'package:el_race/core/hr_management/hr_effective_view.dart';
import 'package:el_race/core/hr_management/hr_module_manager_access.dart';
import 'package:el_race/core/utils/shared_pref.dart';

/// HR payslip team access — login `hr_module_manager.payslip` (supervisor / management).
bool hasPayslipHrAccess() {
  final data = SharedPref.getLoginData().result?.data;
  if (data == null) return false;
  return hrServerManagerForModule(data, HrManagedModule.payslip);
}

/// Last 24 months for employee month filter dropdown.
List<DateTime> payslipMonthFilterOptions() {
  final now = DateTime.now();
  return List.generate(24, (i) {
    final m = DateTime(now.year, now.month - i, 1);
    return DateTime(m.year, m.month, 1);
  });
}
