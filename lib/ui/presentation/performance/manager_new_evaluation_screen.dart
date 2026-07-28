import 'package:el_race/core/performance/models/performance_employee_option.dart';
import 'package:el_race/core/performance/bloc/manager_new_evaluation_cubit.dart';
import 'package:el_race/core/performance/bloc/performance_evaluation_list_cubit.dart';
import 'package:el_race/core/theme/hr_module_colors.dart';
import 'package:el_race/core/theme/hr_module_layout.dart';
import 'package:el_race/core/theme/hr_module_typography.dart';
import 'package:el_race/core/widgets/performance/performance_gradient_scaffold.dart';
import 'package:el_race/ui/presentation/performance/manager_evaluation_detail_screen.dart';
import 'package:el_race/ui/presentation/performance/widgets/evaluation_employee_summary_card.dart';
import 'package:el_race/ui/presentation/performance/widgets/evaluation_pipeline_stepper.dart';
import 'package:el_race/ui/presentation/performance/widgets/personal_competencies_section.dart';
import 'package:el_race/ui/presentation/performance/widgets/performance_themed_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Manager creates / scores a personal competencies evaluation.
class ManagerNewEvaluationScreen extends StatefulWidget {
  const ManagerNewEvaluationScreen({super.key});

  @override
  State<ManagerNewEvaluationScreen> createState() =>
      _ManagerNewEvaluationScreenState();
}

class _ManagerNewEvaluationScreenState
    extends State<ManagerNewEvaluationScreen> {
  List<int> _scores = [];

  @override
  void initState() {
    super.initState();
    final cubit = context.read<ManagerNewEvaluationCubit>();
    Future.microtask(cubit.loadEmployees);
  }

  Future<void> _prepareDraft() async {
    final cubit = context.read<ManagerNewEvaluationCubit>();
    final ok = await cubit.prepareDraft();
    if (!mounted) return;
    if (!ok && cubit.state.error != null) {
      _snack(cubit.state.error!);
    }
  }

  Future<void> _save() async {
    final cubit = context.read<ManagerNewEvaluationCubit>();
    final id = cubit.state.evaluationId;
    final detail = cubit.state.detail;
    if (id == null || detail == null) {
      _snack('Prepare the draft first.');
      return;
    }
    final rows = detail.competencies;
    if (_scores.length != rows.length) {
      _scores = rows.map((r) => r.userScore).toList();
    }
    for (var i = 0; i < rows.length; i++) {
      final max = rows[i].maxScore;
      if (_scores[i] < 0 || _scores[i] > max) {
        _snack('Row ${i + 1}: score must be between 0 and $max.');
        return;
      }
    }
    final listCubit = context.read<PerformanceEvaluationListCubit>();
    final savedId = await cubit.save(_scores);
    if (!mounted) return;
    if (savedId == null) {
      if (cubit.state.error != null) _snack(cubit.state.error!);
      return;
    }
    listCubit.refresh();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Evaluation saved')),
    );
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => ManagerEvaluationDetailScreen(evaluationId: savedId),
      ),
    );
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  void _noopEmployee(PerformanceEmployeeOption? _) {}

  void _noopYear(int? _) {}

  @override
  Widget build(BuildContext context) {
    return PerformanceGradientScaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        foregroundColor: HrModuleColors.text,
        title: Text(
          'New evaluation',
          style: HrModuleTypography.pageTitle().copyWith(fontSize: 18.sp),
        ),
      ),
      body: BlocBuilder<ManagerNewEvaluationCubit, ManagerNewEvaluationState>(
        builder: (context, state) {
          if (state.isLoadingEmployees && state.employees.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.error != null && state.employees.isEmpty) {
            return Center(child: Text(state.error!));
          }
          final employees = state.employees;
          final years = List.generate(5, (i) => DateTime.now().year - i);

          return ListView(
            padding: EdgeInsets.fromLTRB(
              HrModuleLayout.screenPaddingH.w,
              12.h,
              HrModuleLayout.screenPaddingH.w,
              32.h,
            ),
            children: [
              _sectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Employee & period',
                      style: HrModuleTypography.sectionHeading()
                          .copyWith(fontSize: 15.sp),
                    ),
                    SizedBox(height: 12.h),
                    Text(
                      'Employee',
                      style: HrModuleTypography.caption().copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 6.h),
                    PerformanceThemedDropdown<PerformanceEmployeeOption>(
                      value: state.selectedEmployee,
                      items: employees
                          .map(
                            (e) => DropdownMenuItem(
                              value: e,
                              child: Text(
                                '${e.employeeName} · ${e.employeeNumber}',
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: state.evaluationId == null
                          ? context
                              .read<ManagerNewEvaluationCubit>()
                              .selectEmployee
                          : _noopEmployee,
                    ),
                    SizedBox(height: 12.h),
                    Text(
                      'Evaluation year',
                      style: HrModuleTypography.caption().copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 6.h),
                    PerformanceThemedDropdown<int>(
                      value: state.year,
                      items: years
                          .map((y) => DropdownMenuItem(
                                value: y,
                                child: Text('$y'),
                              ))
                          .toList(),
                      onChanged: state.evaluationId == null
                          ? (v) {
                              if (v != null) {
                                context
                                    .read<ManagerNewEvaluationCubit>()
                                    .setYear(v);
                              }
                            }
                          : _noopYear,
                    ),
                    if (state.evaluationId == null) ...[
                      SizedBox(height: 16.h),
                      FilledButton(
                        onPressed: state.isBusy ? null : _prepareDraft,
                        style: FilledButton.styleFrom(
                          backgroundColor: HrModuleColors.primary,
                          padding: EdgeInsets.symmetric(vertical: 14.h),
                        ),
                        child: state.isBusy
                            ? SizedBox(
                                height: 20.h,
                                width: 20.h,
                                child: const CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text('Prepare draft'),
                      ),
                    ],
                  ],
                ),
              ),
              if (state.evaluationId != null) ...[
                SizedBox(height: 14.h),
                if (state.isLoadingDetail)
                  const Padding(
                    padding: EdgeInsets.all(24),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (state.detail == null)
                  Text(state.error ?? 'Evaluation not found.')
                else
                  Builder(builder: (context) {
                    final detail = state.detail!;
                    if (_scores.length != detail.competencies.length) {
                      _scores =
                          detail.competencies.map((r) => r.userScore).toList();
                    }
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _sectionCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                detail.pepReference,
                                style: HrModuleTypography.sectionHeading()
                                    .copyWith(
                                  fontSize: 14.sp,
                                  color: HrModuleColors.danger,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              SizedBox(height: 8.h),
                              EvaluationPipelineStepper(
                                uiStatus: detail.uiStatus,
                              ),
                              SizedBox(height: 14.h),
                              EvaluationEmployeeSummaryCard(
                                profile: detail.profile,
                                detail: detail,
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 16.h),
                        _sectionCard(
                          child: PersonalCompetenciesScoreEditor(
                            key: ValueKey(state.evaluationId),
                            templateRows: detail.competencies,
                            onScoresChanged: (s) => setState(() => _scores = s),
                          ),
                        ),
                        SizedBox(height: 16.h),
                        FilledButton(
                          onPressed: state.isBusy ? null : _save,
                          style: FilledButton.styleFrom(
                            backgroundColor: HrModuleColors.success,
                            padding: EdgeInsets.symmetric(vertical: 14.h),
                          ),
                          child: Text(
                            'Save evaluation',
                            style: HrModuleTypography.sectionHeading().copyWith(
                              fontSize: 15.sp,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    );
                  }),
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _sectionCard({required Widget child}) {
    return Material(
      color: HrModuleColors.surface,
      borderRadius: BorderRadius.circular(16.r),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: HrModuleColors.border),
          boxShadow: HrModuleColors.cardShadow,
        ),
        child: child,
      ),
    );
  }
}
