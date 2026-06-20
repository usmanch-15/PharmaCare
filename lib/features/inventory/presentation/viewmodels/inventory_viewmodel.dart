import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/batch_entity.dart';
import '../../domain/entities/purchase_order_entity.dart';
import '../../domain/usecases/adjust_stock_usecase.dart';
import '../../domain/usecases/get_expiring_medicines_usecase.dart';
import '../../domain/usecases/get_low_stock_medicines_usecase.dart';
import '../../domain/usecases/receive_stock_usecase.dart';
import '../../../../core/usecases/usecase.dart';
import '../providers/inventory_providers.dart';

// ── State ─────────────────────────────────────────────────────────────────────

enum InventoryActionStatus { idle, loading, success, error }

class InventoryState {
  const InventoryState({
    this.lowStockItems = const [],
    this.expiringBatches = const [],
    this.selectedMedicineBatches = const [],
    this.actionStatus = InventoryActionStatus.idle,
    this.actionError,
    this.successMessage,
    this.expiryDaysFilter = 30,
  });

  final List<StockSummary> lowStockItems;
  final List<BatchEntity> expiringBatches;
  final List<BatchEntity> selectedMedicineBatches;
  final InventoryActionStatus actionStatus;
  final String? actionError;
  final String? successMessage;
  final int expiryDaysFilter;

  bool get isLoading => actionStatus == InventoryActionStatus.loading;

  InventoryState copyWith({
    List<StockSummary>? lowStockItems,
    List<BatchEntity>? expiringBatches,
    List<BatchEntity>? selectedMedicineBatches,
    InventoryActionStatus? actionStatus,
    String? actionError,
    String? successMessage,
    int? expiryDaysFilter,
    bool clearMessages = false,
  }) {
    return InventoryState(
      lowStockItems: lowStockItems ?? this.lowStockItems,
      expiringBatches: expiringBatches ?? this.expiringBatches,
      selectedMedicineBatches:
          selectedMedicineBatches ?? this.selectedMedicineBatches,
      actionStatus: actionStatus ?? this.actionStatus,
      actionError: clearMessages ? null : actionError ?? this.actionError,
      successMessage:
          clearMessages ? null : successMessage ?? this.successMessage,
      expiryDaysFilter: expiryDaysFilter ?? this.expiryDaysFilter,
    );
  }
}

// ── ViewModel ─────────────────────────────────────────────────────────────────

class InventoryViewModel extends Notifier<InventoryState> {
  late ReceiveStockUseCase _receive;
  late AdjustStockUseCase _adjust;
  late GetLowStockMedicinesUseCase _getLowStock;
  late GetExpiringMedicinesUseCase _getExpiring;

  @override
  InventoryState build() {
    _receive = ref.read(receiveStockUseCaseProvider);
    _adjust = ref.read(adjustStockUseCaseProvider);
    _getLowStock = ref.read(getLowStockUseCaseProvider);
    _getExpiring = ref.read(getExpiringUseCaseProvider);
    Future.microtask(loadAlerts);
    return const InventoryState();
  }

  // ── Load all alerts ──────────────────────────────────────────────────────
  Future<void> loadAlerts() async {
    state = state.copyWith(actionStatus: InventoryActionStatus.loading);

    final results = await Future.wait([
      _getLowStock(const NoParams()),
      _getExpiring(ExpiryParams(withinDays: state.expiryDaysFilter)),
    ]);

    results[0].fold(
      (f) => state = state.copyWith(
          actionStatus: InventoryActionStatus.error, actionError: f.message),
      (list) => state = state.copyWith(lowStockItems: list as List<StockSummary>),
    );

    results[1].fold(
      (f) => state = state.copyWith(actionError: f.message),
      (list) => state = state.copyWith(
          expiringBatches: list as List<BatchEntity>,
          actionStatus: InventoryActionStatus.idle),
    );
  }

  // ── Change expiry filter ─────────────────────────────────────────────────
  Future<void> setExpiryDaysFilter(int days) async {
    state = state.copyWith(expiryDaysFilter: days);
    final result = await _getExpiring(ExpiryParams(withinDays: days));
    result.fold(
      (f) => state = state.copyWith(actionError: f.message),
      (list) => state = state.copyWith(expiringBatches: list),
    );
  }

  // ── Receive stock ────────────────────────────────────────────────────────
  Future<bool> receiveStock(ReceiveStockParams params) async {
    state = state.copyWith(
        actionStatus: InventoryActionStatus.loading, clearMessages: true);
    final result = await _receive(params);
    return result.fold(
      (f) {
        state = state.copyWith(
            actionStatus: InventoryActionStatus.error, actionError: f.message);
        return false;
      },
      (batch) {
        state = state.copyWith(
          actionStatus: InventoryActionStatus.success,
          successMessage:
              'Stock received: ${batch.tradeName} — ${batch.qtyReceived} units (Batch ${batch.batchNo}).',
        );
        loadAlerts();   // refresh low stock list
        return true;
      },
    );
  }

  // ── Adjust stock ─────────────────────────────────────────────────────────
  Future<bool> adjustStock(AdjustStockParams params) async {
    state = state.copyWith(
        actionStatus: InventoryActionStatus.loading, clearMessages: true);
    final result = await _adjust(params);
    return result.fold(
      (f) {
        state = state.copyWith(
            actionStatus: InventoryActionStatus.error, actionError: f.message);
        return false;
      },
      (_) {
        state = state.copyWith(
          actionStatus: InventoryActionStatus.success,
          successMessage:
              'Stock adjusted for ${params.tradeName} (${params.qty > 0 ? '+' : ''}${params.qty} units).',
        );
        loadAlerts();
        return true;
      },
    );
  }

  void clearMessages() {
    state = state.copyWith(
        clearMessages: true, actionStatus: InventoryActionStatus.idle);
  }
}

final inventoryViewModelProvider =
    NotifierProvider<InventoryViewModel, InventoryState>(
        InventoryViewModel.new);