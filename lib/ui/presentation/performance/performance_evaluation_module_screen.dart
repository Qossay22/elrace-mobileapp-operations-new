import 'package:el_race/core/performance/models/performance_evaluation.dart';
import 'package:el_race/core/performance/bloc/employee_performance_cubit.dart';
import 'package:el_race/core/performance/bloc/performance_evaluation_list_cubit.dart';
import 'package:el_race/core/performance/providers/performance_providers.dart';
import 'package:el_race/core/theme/hr_badge_kind.dart';
import 'package:el_race/core/theme/hr_module_colors.dart';
import 'package:el_race/core/theme/hr_module_layout.dart';
import 'package:el_race/core/theme/hr_module_typography.dart';
import 'package:el_race/core/widgets/hr_management/hr_status_badge.dart';
import 'package:el_race/core/widgets/hr_management/hr_module_glass_header.dart';
import 'package:el_race/core/widgets/performance/performance_gradient_scaffold.dart';
import 'package:el_race/ui/presentation/performance/manager_evaluation_detail_screen.dart';
import 'package:el_race/ui/presentation/performance/widgets/personal_competencies_section.dart';
import 'package:el_race/ui/presentation/performance/widgets/performance_themed_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

List<int> _evaluationYears() =>
    List.generate(6, (i) => DateTime.now().year - i);

/// Module 3 entry — employee competencies; manager/HR team list.
class PerformanceEvaluationModuleScreen extends StatelessWidget {
  const PerformanceEvaluationModuleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isManager = hasPerformanceManagerMode();

    if (!isManager) {
      return const _EmployeeCompetenciesOnlyScaffold();
    }
    return const _ManagerEvaluationListScaffold();
  }
}

class _EmployeeCompetenciesOnlyScaffold extends StatefulWidget {
  const _EmployeeCompetenciesOnlyScaffold();

  @override
  State<_EmployeeCompetenciesOnlyScaffold> createState() =>
      _EmployeeCompetenciesOnlyScaffoldState();
}

class _EmployeeCompetenciesOnlyScaffoldState
    extends State<_EmployeeCompetenciesOnlyScaffold> {
  @override
  void initState() {
    super.initState();
    final cubit = context.read<EmployeePerformanceCubit>();
    Future.microtask(cubit.load);
  }

  @override
  Widget build(BuildContext context) {
    final years = _evaluationYears();

    return PerformanceGradientScaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const HrModuleGlassHeader(
            title: 'Performance',
            accentTint: HrModuleHeaderTints.performance,
          ),
          Expanded(
            child:
                BlocBuilder<EmployeePerformanceCubit, EmployeePerformanceState>(
              builder: (context, state) {
                final year = state.year;
                if (state.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state.error != null) {
                  return Center(
                    child: Padding(
                      padding: EdgeInsets.all(24.w),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Could not load evaluation',
                            style: HrModuleTypography.sectionHeading(),
                          ),
                          SizedBox(height: 8.h),
                          Text(state.error!, textAlign: TextAlign.center),
                          SizedBox(height: 16.h),
                          FilledButton(
                            onPressed: () => context
                                .read<EmployeePerformanceCubit>()
                                .load(force: true),
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                final detail = state.detail;
                return ListView(
                  padding: EdgeInsets.fromLTRB(
                    HrModuleLayout.screenPaddingH.w,
                    16.h,
                    HrModuleLayout.screenPaddingH.w,
                    32.h,
                  ),
                  children: [
                    Text(
                      'Evaluation year',
                      style: HrModuleTypography.caption().copyWith(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 6.h),
                    PerformanceThemedDropdown<int>(
                      value: year,
                      items: years
                          .map((y) =>
                              DropdownMenuItem(value: y, child: Text('$y')))
                          .toList(),
                      onChanged: (y) {
                        if (y != null) {
                          context.read<EmployeePerformanceCubit>().setYear(y);
                        }
                      },
                    ),
                    SizedBox(height: 20.h),
                    if (detail == null)
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 32.h),
                        child: Center(
                          child: Text(
                            'No evaluation on file for $year.',
                            textAlign: TextAlign.center,
                            style: HrModuleTypography.body()
                                .copyWith(fontSize: 14.sp),
                          ),
                        ),
                      )
                    else ...[
                      if (detail.finalScorePercent > 0) ...[
                        Text(
                          'Total Score',
                          style: HrModuleTypography.caption().copyWith(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 6.h),
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(
                            horizontal: 14.w,
                            vertical: 14.h,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: HrModuleColors.surface,
                            border: Border.all(color: HrModuleColors.border),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  'Overall evaluation score',
                                  style: HrModuleTypography.body()
                                      .copyWith(fontSize: 13.sp),
                                ),
                              ),
                              Text(
                                '${detail.finalScorePercent}%',
                                style: HrModuleTypography.sectionHeading()
                                    .copyWith(
                                  fontSize: 22.sp,
                                  fontWeight: FontWeight.w800,
                                  color: HrModuleColors.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 20.h),
                      ],
                      PersonalCompetenciesSection(rows: detail.competencies),
                    ],
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ManagerEvaluationListScaffold extends StatefulWidget {
  const _ManagerEvaluationListScaffold();

  @override
  State<_ManagerEvaluationListScaffold> createState() =>
      _ManagerEvaluationListScaffoldState();
}

class _ManagerEvaluationListScaffoldState
    extends State<_ManagerEvaluationListScaffold> {
  @override
  void initState() {
    super.initState();
    final cubit = context.read<PerformanceEvaluationListCubit>();
    Future.microtask(cubit.load);
  }

  @override
  Widget build(BuildContext context) {
    return PerformanceGradientScaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const HrModuleGlassHeader(
            title: 'Performance',
            accentTint: HrModuleHeaderTints.performance,
          ),
          Expanded(
            child: BlocBuilder<PerformanceEvaluationListCubit,
                PerformanceEvaluationListState>(
              builder: (context, state) {
                if (state.isLoading && state.items.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state.error != null && state.items.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: EdgeInsets.all(24.w),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Could not load list',
                            style: HrModuleTypography.sectionHeading(),
                          ),
                          SizedBox(height: 8.h),
                          Text(state.error!, textAlign: TextAlign.center),
                          SizedBox(height: 16.h),
                          FilledButton(
                            onPressed: () => context
                                .read<PerformanceEvaluationListCubit>()
                                .refresh(),
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                final list = state.items;
                if (list.isEmpty) {
                  return Center(
                    child: Text(
                      'No evaluations yet.',
                      style: HrModuleTypography.body(),
                    ),
                  );
                }
                return RefreshIndicator(
                  onRefresh: () async {
                    await context
                        .read<PerformanceEvaluationListCubit>()
                        .refresh();
                  },
                  child: ListView.separated(
                    padding: EdgeInsets.fromLTRB(
                      HrModuleLayout.screenPaddingH.w,
                      12.h,
                      HrModuleLayout.screenPaddingH.w,
                      100.h,
                    ),
                    itemCount: list.length,
                    separatorBuilder: (_, __) => SizedBox(height: 10.h),
                    itemBuilder: (context, i) {
                      final s = list[i];
                      return _EvaluationListTile(
                        summary: s,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => ManagerEvaluationDetailScreen(
                                evaluationId: s.id,
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _EvaluationListTile extends StatelessWidget {
  const _EvaluationListTile({
    required this.summary,
    required this.onTap,
  });

  final PerformanceEvaluationSummary summary;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: HrModuleColors.surface,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: EdgeInsets.all(14.w),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: HrModuleColors.border),
            boxShadow: HrModuleColors.cardShadow,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      summary.pepReference,
                      style: HrModuleTypography.sectionHeading().copyWith(
                        fontSize: 13.sp,
                        color: HrModuleColors.danger,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE9ECEF),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${summary.evaluationYear}',
                      style: HrModuleTypography.caption().copyWith(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  HrStatusBadge(
                    uiStatus: summary.uiStatus,
                    kind: HrBadgeKind.performanceEvaluation,
                    labelOverride: summary.uiStatusLabel,
                  ),
                ],
              ),
              SizedBox(height: 8.h),
              Text(
                summary.employeeName,
                style: HrModuleTypography.body().copyWith(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                '${summary.jobPosition} · ID ${summary.employeeId}',
                style: HrModuleTypography.caption().copyWith(fontSize: 12.sp),
              ),
              if (summary.finalScorePercent > 0) ...[
                SizedBox(height: 8.h),
                Text(
                  '${summary.finalScorePercent}%',
                  style: HrModuleTypography.sectionHeading().copyWith(
                    fontSize: 22.sp,
                    color: HrModuleColors.success,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
