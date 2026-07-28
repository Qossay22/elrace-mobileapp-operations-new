import 'package:el_race/core/utils/responsive_breakpoints.dart';
import 'package:el_race/core/payslip/bloc/pending_payslip_cubit.dart';
import 'package:el_race/core/theme/hr_module_colors.dart';
import 'package:el_race/core/theme/hr_metallic_decorations.dart';
import 'package:el_race/core/theme/hr_service_screen_backdrop.dart';
import 'package:el_race/core/theme/hr_module_layout.dart';
import 'package:el_race/core/theme/hr_module_typography.dart';
import 'package:el_race/ui/presentation/payslip/manager_payslip_pending_full_screen.dart';
import 'package:el_race/ui/presentation/payslip/widgets/payslip_record_card.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Stakeholder: pending queue for managers. Module 4 TASKS reserve team payslips for HR —
// product may restrict this screen to [HrEffectiveView.hrManager] only on release.

/// Manager landing — pending counter tile + last five pending (card list).
class ManagerPayslipHubScreen extends StatefulWidget {
  const ManagerPayslipHubScreen({super.key});

  @override
  State<ManagerPayslipHubScreen> createState() =>
      _ManagerPayslipHubScreenState();
}

class _ManagerPayslipHubScreenState extends State<ManagerPayslipHubScreen> {
  @override
  void initState() {
    super.initState();
    final cubit = context.read<PendingPayslipCubit>();
    Future.microtask(cubit.load);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HrServiceScreenBackdrop.scaffoldBackground(
          HrServiceScreenKind.payslip),
      appBar: AppBar(
        backgroundColor: HrModuleColors.surface,
        foregroundColor: HrModuleColors.text,
        elevation: 0,
        title: Text(
          'Payslips (team)',
          style: HrModuleTypography.pageTitle().copyWith(
            fontSize: 18.tsp,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: HrServiceScreenBackdrop.wrap(
        kind: HrServiceScreenKind.payslip,
        child: ListView(
          padding: EdgeInsets.fromLTRB(
            HrModuleLayout.screenPaddingH.tw,
            16.th,
            HrModuleLayout.screenPaddingH.tw,
            32.th,
          ),
          children: [
            if (kDebugMode)
              Padding(
                padding: EdgeInsets.only(bottom: 12.th),
                child: Text(
                  'Dev: use HR hub role toggle. Pending list is mock data.',
                  style:
                      HrModuleTypography.caption().copyWith(fontSize: 11.tsp),
                ),
              ),
            BlocBuilder<PendingPayslipCubit, PendingPayslipState>(
              builder: (context, state) {
                if (state.isLoading && state.count == 0) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state.error != null && state.count == 0) {
                  return Text('Error: ${state.error}');
                }
                return _PendingCounterTile(
                  count: state.count,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const ManagerPayslipPendingFullScreen(),
                      ),
                    );
                  },
                );
              },
            ),
            SizedBox(height: 24.th),
            Text(
              'Latest pending',
              style: HrModuleTypography.sectionHeading()
                  .copyWith(fontSize: 15.tsp),
            ),
            SizedBox(height: 6.th),
            Text(
              'Last five in queue',
              style: HrModuleTypography.caption().copyWith(fontSize: 12.tsp),
            ),
            SizedBox(height: 12.th),
            BlocBuilder<PendingPayslipCubit, PendingPayslipState>(
              builder: (context, state) {
                if (state.isLoading && state.peek.isEmpty) {
                  return const SizedBox.shrink();
                }
                if (state.error != null && state.peek.isEmpty) {
                  return const SizedBox.shrink();
                }
                if (state.peek.isEmpty) {
                  return Text(
                    'No pending payslips.',
                    style: HrModuleTypography.body(),
                  );
                }
                return Column(
                  children: [
                    for (final s in state.peek) ...[
                      PayslipRecordCard(
                        summary: s,
                        compact: true,
                      ),
                      SizedBox(height: 10.th),
                    ],
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _PendingCounterTile extends StatelessWidget {
  const _PendingCounterTile({
    required this.count,
    required this.onTap,
  });

  final int count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: HrModuleColors.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(18.tw),
          decoration: HrMetallicDecorations.kpiTile(
            statusTint: const Color(0xFF64B5F6),
            borderRadius: 16,
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(12.tw),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8EEF5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.pending_actions_rounded,
                  size: 32.tsp,
                  color: HrModuleColors.primary,
                ),
              ),
              SizedBox(width: 14.tw),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pending payslips',
                      style: HrModuleTypography.sectionHeading().copyWith(
                          fontSize: 16.tsp, fontWeight: FontWeight.w700),
                    ),
                    SizedBox(height: 4.th),
                    Text(
                      'Tap to open full list with pagination',
                      style: HrModuleTypography.caption()
                          .copyWith(fontSize: 12.tsp),
                    ),
                  ],
                ),
              ),
              Text(
                '$count',
                style: HrModuleTypography.sectionHeading().copyWith(
                  fontSize: 32.tsp,
                  fontWeight: FontWeight.w800,
                  color: HrModuleColors.primary,
                ),
              ),
              SizedBox(width: 4.tw),
              const Icon(
                Icons.chevron_right,
                color: HrModuleColors.mutedText,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
