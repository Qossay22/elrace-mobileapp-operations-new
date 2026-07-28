import 'package:el_race/core/hr_management/hr_effective_view.dart';
import 'package:el_race/core/hr_management/bloc/hr_effective_view_cubit.dart';
import 'package:el_race/ui/presentation/hr_management/hr_employee_landing_screen.dart';
import 'package:el_race/ui/presentation/hr_management/hr_manager_landing_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Module 1 — HR Requests & approvals (E1 / M1). Opened from [HrManagementHubScreen].
class HrRequestsModuleScreen extends StatelessWidget {
  const HrRequestsModuleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HrEffectiveViewCubit, HrEffectiveViewState>(
      builder: (context, state) {
        if (state.view == HrEffectiveView.employee) {
          return const HrEmployeeLandingScreen();
        }
        return const HrManagerLandingScreen();
      },
    );
  }
}
