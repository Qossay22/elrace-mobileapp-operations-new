import 'package:el_race/core/hr_management/hr_effective_view.dart';
import 'package:el_race/core/hr_management/hr_module_manager_access.dart';
import 'package:el_race/core/utils/shared_pref.dart';

/// True when login role has x_is_management or x_evaluation.
bool hasPerformanceManagerMode() {
  final data = SharedPref.getLoginData().result?.data;
  if (data == null) return false;
  if (hrServerManagerForModule(data, HrManagedModule.evaluation)) {
    return true;
  }
  final caps = data.roleCapabilities;
  if (caps != null) {
    final mgmt = caps['x_is_management'] == true;
    final eval = caps['x_evaluation'] == true;
    if (mgmt || eval) return true;
  }
  return data.isManagement == true;
}
