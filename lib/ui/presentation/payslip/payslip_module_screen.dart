import 'package:el_race/core/payslip/providers/payslip_providers.dart';
import 'package:el_race/ui/presentation/payslip/employee_payslip_module_screen.dart';
import 'package:el_race/ui/presentation/payslip/hr_payslip_module_screen.dart';
import 'package:flutter/material.dart';

/// Module 4 entry — employees: own payslips; HR supervisor: all employees.
/// Line managers / PMs stay on employee view (SRD §2).
class PayslipModuleScreen extends StatelessWidget {
  const PayslipModuleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final hrAccess = hasPayslipHrAccess();
    if (hrAccess) {
      return const HrPayslipModuleScreen();
    }
    return const EmployeePayslipModuleScreen();
  }
}
