import 'package:el_race/core/purchase/purchase_access.dart';
import 'package:el_race/core/purchase/purchase_dev_role_provider.dart';
import 'package:el_race/core/utils/shared_pref.dart';
import 'package:el_race/ui/presentation/purchase_management/data/purchase_models.dart';
import 'package:el_race/ui/presentation/purchase_management/data/purchase_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PurchaseManagementHubState {
  const PurchaseManagementHubState({
    this.overview,
    this.latestLpos = const [],
    this.access = PurchaseAccess.none,
    this.testRole,
    this.isLoading = false,
    this.error,
  });

  final PurchaseOverview? overview;
  final List<RfqItem> latestLpos;
  final PurchaseAccess access;
  final PurchaseDevTestRole? testRole;
  final bool isLoading;
  final String? error;

  bool get isAuthorized =>
      access.hasAnyAccess ||
      (overview != null && overview!.isAuthorized && overview!.scope != 'none');

  static const initial = PurchaseManagementHubState();

  PurchaseManagementHubState copyWith({
    PurchaseOverview? overview,
    List<RfqItem>? latestLpos,
    PurchaseAccess? access,
    PurchaseDevTestRole? testRole,
    bool? isLoading,
    String? error,
    bool clearError = false,
    bool clearTestRole = false,
  }) {
    return PurchaseManagementHubState(
      overview: overview ?? this.overview,
      latestLpos: latestLpos ?? this.latestLpos,
      access: access ?? this.access,
      testRole: clearTestRole ? null : testRole ?? this.testRole,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : error ?? this.error,
    );
  }
}

class PurchaseManagementHubCubit extends Cubit<PurchaseManagementHubState> {
  PurchaseManagementHubCubit({PurchaseRepository? repository})
      : _repository = repository ?? PurchaseRepository(),
        super(PurchaseManagementHubState.initial);

  final PurchaseRepository _repository;

  Future<void> load({PurchaseDevTestRole? testRole, bool force = false}) async {
    if (!force &&
        !state.isLoading &&
        state.overview != null &&
        state.testRole == testRole) {
      return;
    }

    emit(
      state.copyWith(
        testRole: testRole,
        access: _resolveAccess(null, testRole),
        isLoading: true,
        clearError: true,
        clearTestRole: testRole == null,
      ),
    );

    try {
      final overview = await _repository.fetchOverview(testRole: testRole);
      final latestLpos = await _fetchLatestLpos(testRole);
      emit(
        state.copyWith(
          overview: overview,
          latestLpos: latestLpos,
          access: _resolveAccess(overview, testRole),
          isLoading: false,
          clearError: true,
          clearTestRole: testRole == null,
        ),
      );
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> refresh() async {
    final testRole = state.testRole;
    try {
      final overview = await _repository.fetchOverview(
        testRole: testRole,
        refresh: true,
      );
      final latestLpos = await _fetchLatestLpos(testRole);
      emit(
        state.copyWith(
          overview: overview,
          latestLpos: latestLpos,
          access: _resolveAccess(overview, testRole),
          clearError: true,
        ),
      );
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  Future<void> setTestRole(PurchaseDevTestRole? role) async {
    await load(testRole: role, force: true);
  }

  PurchaseAccess _resolveAccess(
    PurchaseOverview? overview,
    PurchaseDevTestRole? testRole,
  ) {
    if (kDebugMode && testRole != null) {
      return purchaseAccessForDevRole(testRole);
    }

    final base = purchaseAccessFromData(SharedPref.getLoginData().result?.data);
    if (overview == null) return base;

    if (overview.isAuthorized &&
        overview.scope != 'none' &&
        (!base.hasAnyAccess ||
            (overview.scope == 'all' && !base.isCostControlOrManagement))) {
      return PurchaseAccess(
        isPurchaseRep: base.isPurchaseRep,
        isPurchaseManager: true,
        isCostControlOrManagement:
            overview.scope == 'all' || base.isCostControlOrManagement,
        isDocController: base.isDocController,
        scope: overview.scope,
      );
    }
    return base;
  }

  Future<List<RfqItem>> _fetchLatestLpos(PurchaseDevTestRole? testRole) async {
    final result = await _repository.fetchRfqs(
      page: 1,
      limit: 5,
      status: 'LPOS',
      orderDesc: true,
      testRole: testRole,
    );
    return result.items;
  }
}
