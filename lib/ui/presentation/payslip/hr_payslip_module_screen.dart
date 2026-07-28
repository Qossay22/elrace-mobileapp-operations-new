import 'package:el_race/core/utils/responsive_breakpoints.dart';
import 'package:el_race/core/payslip/bloc/payslip_list_cubit.dart';
import 'package:el_race/core/theme/hr_module_colors.dart';
import 'package:el_race/core/theme/hr_module_layout.dart';
import 'package:el_race/core/theme/hr_module_typography.dart';
import 'package:el_race/core/widgets/hr_management/hr_module_glass_header.dart';
import 'package:el_race/core/widgets/hr_management/hr_search_bar.dart';
import 'package:el_race/core/widgets/payslip/payslip_gradient_scaffold.dart';
import 'package:el_race/ui/presentation/payslip/widgets/payslip_detail_sheet.dart';
import 'package:el_race/ui/presentation/payslip/widgets/payslip_record_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// H1 — HR supervisor: all employees' payslips (paginated).
class HrPayslipModuleScreen extends StatefulWidget {
  const HrPayslipModuleScreen({super.key});

  @override
  State<HrPayslipModuleScreen> createState() => _HrPayslipModuleScreenState();
}

class _HrPayslipModuleScreenState extends State<HrPayslipModuleScreen> {
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    final cubit = context.read<PayslipListCubit>();
    Future.microtask(cubit.load);
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    final keyword = query.trim();
    context.read<PayslipListCubit>().setFilters(
          keyword: keyword.isEmpty ? null : keyword,
        );
  }

  @override
  Widget build(BuildContext context) {
    return PayslipGradientScaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const HrModuleGlassHeader(
            title: 'Payslips',
            accentTint: HrModuleHeaderTints.payslip,
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(
              HrModuleLayout.screenPaddingH.tw,
              12.th,
              HrModuleLayout.screenPaddingH.tw,
              8.th,
            ),
            child: HrSearchBar(
              controller: _searchCtrl,
              hintText: 'Search employee or reference',
              onDebouncedChanged: _onSearchChanged,
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              color: HrModuleColors.payslipAccent,
              onRefresh: () => context.read<PayslipListCubit>().refresh(),
              child: BlocBuilder<PayslipListCubit, PayslipListState>(
                builder: (context, state) {
                  if (state.isLoading && state.items.isEmpty) {
                    return ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        Padding(
                          padding: EdgeInsets.only(top: 48.th),
                          child:
                              const Center(child: CircularProgressIndicator()),
                        ),
                      ],
                    );
                  }
                  if (state.error != null && state.items.isEmpty) {
                    return ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: EdgeInsets.fromLTRB(
                        HrModuleLayout.screenPaddingH.tw,
                        48.th,
                        HrModuleLayout.screenPaddingH.tw,
                        32.th,
                      ),
                      children: [
                        Text(
                          'Could not load payslips: ${state.error}',
                          style: HrModuleTypography.body(),
                        ),
                      ],
                    );
                  }

                  final list = state.items;
                  if (list.isEmpty) {
                    return ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: EdgeInsets.fromLTRB(
                        HrModuleLayout.screenPaddingH.tw,
                        48.th,
                        HrModuleLayout.screenPaddingH.tw,
                        32.th,
                      ),
                      children: [
                        Center(
                          child: Text(
                            'No payslips found.',
                            style: HrModuleTypography.body(),
                          ),
                        ),
                      ],
                    );
                  }
                  return ListView.separated(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsets.fromLTRB(
                      HrModuleLayout.screenPaddingH.tw,
                      4.th,
                      HrModuleLayout.screenPaddingH.tw,
                      32.th,
                    ),
                    itemCount: list.length + (state.hasMore ? 1 : 0),
                    separatorBuilder: (_, __) => SizedBox(height: 10.th),
                    itemBuilder: (context, index) {
                      if (index == list.length) {
                        return Center(
                          child: state.isLoadingMore
                              ? const CircularProgressIndicator()
                              : TextButton(
                                  onPressed: () => context
                                      .read<PayslipListCubit>()
                                      .loadMore(),
                                  child: const Text('Load more'),
                                ),
                        );
                      }
                      final s = list[index];
                      return PayslipRecordCard(
                        summary: s,
                        onTap: () => showPayslipDetailSheet(
                          context,
                          payslipId: s.id,
                          title: s.reference.isNotEmpty
                              ? s.reference
                              : s.periodTitle,
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
