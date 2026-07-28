import 'package:el_race/core/utils/responsive_breakpoints.dart';
import 'package:el_race/core/recruitment/bloc/recruitment_candidates_cubit.dart';
import 'package:el_race/core/recruitment/models/recruitment_entities.dart';
import 'package:el_race/core/theme/hr_module_layout.dart';
import 'package:el_race/core/theme/hr_module_typography.dart';
import 'package:el_race/core/widgets/hr_management/hr_module_glass_header.dart';
import 'package:el_race/core/widgets/hr_management/hr_search_bar.dart';
import 'package:el_race/core/widgets/recruitment/recruitment_candidate_tile.dart';
import 'package:el_race/core/widgets/recruitment/recruitment_gradient_scaffold.dart';
import 'package:el_race/ui/presentation/recruitment/c2_candidate_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// C1 — Candidates list (SRD §4.1).
class C1CandidatesListScreen extends StatefulWidget {
  const C1CandidatesListScreen({
    super.key,
    this.requisitionIdFilter,
    this.initialStage,
  });

  final String? requisitionIdFilter;
  final String? initialStage;

  @override
  State<C1CandidatesListScreen> createState() => _C1CandidatesListScreenState();
}

class _C1CandidatesListScreenState extends State<C1CandidatesListScreen> {
  String _search = '';
  String? _stage;
  _Sort _sort = _Sort.newest;

  @override
  void initState() {
    super.initState();
    _stage = widget.initialStage;
    final cubit = context.read<RecruitmentCandidatesCubit>();
    Future.microtask(cubit.load);
  }

  List<RecruitmentCandidate> _apply(
    List<RecruitmentCandidate> all,
  ) {
    var list = all;
    if (widget.requisitionIdFilter != null) {
      list = list
          .where((c) => c.requisitionId == widget.requisitionIdFilter)
          .toList();
    }
    if (_stage != null) {
      list = list.where((c) => c.stage == _stage).toList();
    }
    if (_search.trim().isNotEmpty) {
      final q = _search.toLowerCase();
      list = list
          .where(
            (c) =>
                c.fullName.toLowerCase().contains(q) ||
                c.email.toLowerCase().contains(q),
          )
          .toList();
    }
    switch (_sort) {
      case _Sort.newest:
        list = [...list]..sort((a, b) => b.appliedAt.compareTo(a.appliedAt));
      case _Sort.oldest:
        list = [...list]..sort((a, b) => a.appliedAt.compareTo(b.appliedAt));
      case _Sort.scoreHigh:
        list = [...list]..sort((a, b) {
            final av = a.avgScore ?? -1;
            final bv = b.avgScore ?? -1;
            return bv.compareTo(av);
          });
      case _Sort.scoreLow:
        list = [...list]..sort((a, b) {
            final av = a.avgScore ?? 999;
            final bv = b.avgScore ?? 999;
            return av.compareTo(bv);
          });
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final global = widget.requisitionIdFilter == null;

    return RecruitmentGradientScaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const HrModuleGlassHeader(
            title: 'Candidates',
            accentTint: HrModuleHeaderTints.recruitment,
          ),
          Expanded(
            child: BlocBuilder<RecruitmentCandidatesCubit,
                RecruitmentCandidatesState>(
              builder: (context, state) {
                if (state.isLoading && state.items.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state.error != null && state.items.isEmpty) {
                  return Center(child: Text(state.error!));
                }
                final rows = _apply(state.items);
                const stages = [
                  'APPLIED',
                  'SCREENING',
                  'INTERVIEW',
                  'OFFER',
                  'HIRED',
                  'REJECTED',
                  'WITHDRAWN',
                ];
                return ListView(
                  padding: EdgeInsets.all(HrModuleLayout.screenPaddingH.tw),
                  children: [
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          ChoiceChip(
                            label: const Text('All stages'),
                            selected: _stage == null,
                            onSelected: (_) => setState(() => _stage = null),
                          ),
                          ...stages.map(
                            (s) => Padding(
                              padding: EdgeInsets.only(left: 8.tw),
                              child: ChoiceChip(
                                label: Text(s),
                                selected: _stage == s,
                                onSelected: (_) => setState(() => _stage = s),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 12.th),
                    HrSearchBar(
                      hintText: 'Name or email',
                      onDebouncedChanged: (q) => setState(() => _search = q),
                    ),
                    SizedBox(height: 8.th),
                    Row(
                      children: [
                        Text('Sort: ', style: HrModuleTypography.caption()),
                        DropdownButton<_Sort>(
                          value: _sort,
                          items: const [
                            DropdownMenuItem(
                              value: _Sort.newest,
                              child: Text('Newest'),
                            ),
                            DropdownMenuItem(
                              value: _Sort.oldest,
                              child: Text('Oldest'),
                            ),
                            DropdownMenuItem(
                              value: _Sort.scoreHigh,
                              child: Text('Highest score'),
                            ),
                            DropdownMenuItem(
                              value: _Sort.scoreLow,
                              child: Text('Lowest score'),
                            ),
                          ],
                          onChanged: (v) {
                            if (v != null) setState(() => _sort = v);
                          },
                        ),
                      ],
                    ),
                    SizedBox(height: 12.th),
                    if (rows.isEmpty)
                      Padding(
                        padding: EdgeInsets.only(top: 32.th),
                        child: Center(
                          child: Text(
                            'No candidates match.',
                            style: HrModuleTypography.body(),
                          ),
                        ),
                      )
                    else
                      ...rows.map(
                        (c) => Padding(
                          padding: EdgeInsets.only(bottom: 10.th),
                          child: RecruitmentCandidateTile(
                            candidate: c,
                            showRequisitionLink: global,
                            onTap: () {
                              Navigator.of(context).push<void>(
                                MaterialPageRoute<void>(
                                  builder: (_) => C2CandidateDetailScreen(
                                      candidateId: c.id),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
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

enum _Sort { newest, oldest, scoreHigh, scoreLow }
