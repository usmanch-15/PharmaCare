import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/cart_entity.dart';
import '../../domain/entities/invoice_entity.dart';
import '../../domain/entities/invoice_item_entity.dart';
import '../../domain/entities/medicine_search_result.dart';
import '../../domain/usecases/process_sale_usecase.dart';
import '../../domain/usecases/search_medicine_usecase.dart';
import '../providers/sales_providers.dart';

enum CartActionStatus { idle, loading, success, error }

class CartState {
  const CartState({
    this.cart = const CartEntity(),
    this.searchResults = const [],
    this.searchQuery = '',
    this.isSearching = false,
    this.selectedPayments = const [],
    this.actionStatus = CartActionStatus.idle,
    this.actionError,
    this.completedInvoice,
  });

  final CartEntity cart;
  final List<MedicineSearchResult> searchResults;
  final String searchQuery;
  final bool isSearching;
  final List<PaymentEntry> selectedPayments;
  final CartActionStatus actionStatus;
  final String? actionError;
  final InvoiceEntity? completedInvoice;

  double get totalPaid =>
      selectedPayments.fold(0.0, (s, p) => s + p.amount);
  double get changeAmount => totalPaid - cart.grandTotal;
  bool get canCheckout =>
      !cart.isEmpty && totalPaid >= cart.grandTotal - 0.01;

  CartState copyWith({
    CartEntity? cart,
    List<MedicineSearchResult>? searchResults,
    String? searchQuery,
    bool? isSearching,
    List<PaymentEntry>? selectedPayments,
    CartActionStatus? actionStatus,
    String? actionError,
    InvoiceEntity? completedInvoice,
    bool clearError = false,
    bool clearInvoice = false,
  }) {
    return CartState(
      cart:              cart              ?? this.cart,
      searchResults:     searchResults     ?? this.searchResults,
      searchQuery:       searchQuery       ?? this.searchQuery,
      isSearching:       isSearching       ?? this.isSearching,
      selectedPayments:  selectedPayments  ?? this.selectedPayments,
      actionStatus:      actionStatus      ?? this.actionStatus,
      actionError:       clearError  ? null : actionError    ?? this.actionError,
      completedInvoice:  clearInvoice? null : completedInvoice ?? this.completedInvoice,
    );
  }
}

class CartViewModel extends Notifier<CartState> {
  late SearchMedicineUseCase _search;
  late ProcessSaleUseCase _processSale;

  @override
  CartState build() {
    _search      = ref.read(searchMedicineUseCaseProvider);
    _processSale = ref.read(processSaleUseCaseProvider);
    return const CartState();
  }

  // ── SEARCH ───────────────────────────────────────────────────────────────
  Future<void> searchMedicine(String query) async {
    state = state.copyWith(searchQuery: query, searchResults: []);
    if (query.trim().length < 2) return;
    state = state.copyWith(isSearching: true);
    final result = await _search(SearchMedicineParams(query));
    result.fold(
      (f) => state = state.copyWith(isSearching: false, actionError: f.message),
      (list) => state = state.copyWith(isSearching: false, searchResults: list),
    );
  }

  void clearSearch() =>
      state = state.copyWith(searchQuery: '', searchResults: []);

  // ── CART OPERATIONS ──────────────────────────────────────────────────────
  void addToCart(MedicineSearchResult medicine) {
    final batch = medicine.primaryBatch;
    if (batch == null) return;

    // If already in cart → increment qty
    final existingIdx = state.cart.items
        .indexWhere((i) => i.medicineId == medicine.medicineId);

    List<InvoiceItemEntity> updated;
    if (existingIdx >= 0) {
      final existing = state.cart.items[existingIdx];
      final newQty   = existing.qty + 1;
      if (newQty > batch.qtyAvailable) {
        state = state.copyWith(
          actionError: 'Only ${batch.qtyAvailable} units available for ${medicine.tradeName}.',
        );
        return;
      }
      updated = List.from(state.cart.items)
        ..[existingIdx] = existing.copyWith(qty: newQty);
    } else {
      final newItem = InvoiceItemEntity(
        medicineId:  medicine.medicineId,
        tradeName:   medicine.tradeName,
        genericName: medicine.genericName,
        batchId:     batch.batchId,
        batchNo:     batch.batchNo,
        expiryDate:  batch.expiryDate,
        unitPrice:   batch.salePrice,
        qty:         1,
      );
      updated = [...state.cart.items, newItem];
    }

    state = state.copyWith(
      cart: state.cart.copyWith(items: updated),
      clearError: true,
    );
    clearSearch();
  }

  void updateQty(String medicineId, int qty) {
    if (qty <= 0) { removeFromCart(medicineId); return; }
    final updated = state.cart.items
        .map((i) => i.medicineId == medicineId ? i.copyWith(qty: qty) : i)
        .toList();
    state = state.copyWith(cart: state.cart.copyWith(items: updated));
  }

  void updateItemDiscount(String medicineId, double pct) {
    final updated = state.cart.items
        .map((i) => i.medicineId == medicineId
            ? i.copyWith(discountPct: pct.clamp(0, 100))
            : i)
        .toList();
    state = state.copyWith(cart: state.cart.copyWith(items: updated));
  }

  void removeFromCart(String medicineId) {
    final updated = state.cart.items
        .where((i) => i.medicineId != medicineId)
        .toList();
    state = state.copyWith(cart: state.cart.copyWith(items: updated));
  }

  void setGlobalDiscount(double pct) =>
      state = state.copyWith(
          cart: state.cart.copyWith(
              globalDiscountPct: pct.clamp(0, 100)));

  void setCustomer({
    required String id,
    required String name,
    required String phone,
  }) =>
      state = state.copyWith(
          cart: state.cart.copyWith(
              customerId: id, customerName: name, customerPhone: phone));

  void clearCustomer() =>
      state = state.copyWith(cart: state.cart.copyWith(clearCustomer: true));

  void setPrescription(String? rxId) =>
      state = state.copyWith(
          cart: state.cart.copyWith(prescriptionId: rxId));

  void redeemLoyaltyPoints(int pts) =>
      state = state.copyWith(
          cart: state.cart.copyWith(loyaltyPointsRedeemed: pts));

  // ── PAYMENT ──────────────────────────────────────────────────────────────
  void setPayment(PaymentMethod method, double amount) {
    final updated = state.selectedPayments
        .where((p) => p.method != method)
        .toList();
    if (amount > 0) updated.add(PaymentEntry(method: method, amount: amount));
    state = state.copyWith(selectedPayments: updated);
  }

  void clearPayments() => state = state.copyWith(selectedPayments: []);

  // ── CHECKOUT ─────────────────────────────────────────────────────────────
  Future<bool> checkout({required String soldBy}) async {
    state = state.copyWith(
        actionStatus: CartActionStatus.loading, clearError: true);

    final result = await _processSale(ProcessSaleParams(
      cart:     state.cart,
      payments: state.selectedPayments,
      soldBy:   soldBy,
    ));

    return result.fold(
      (f) {
        state = state.copyWith(
            actionStatus: CartActionStatus.error, actionError: f.message);
        return false;
      },
      (invoice) {
        state = state.copyWith(
          actionStatus:     CartActionStatus.success,
          completedInvoice: invoice,
          cart:             const CartEntity(),
          selectedPayments: [],
        );
        return true;
      },
    );
  }

  void clearCart() =>
      state = state.copyWith(
          cart: const CartEntity(),
          selectedPayments: [],
          clearError: true,
          clearInvoice: true);

  void clearMessages() =>
      state = state.copyWith(
          clearError: true, actionStatus: CartActionStatus.idle);
}

final cartViewModelProvider =
    NotifierProvider<CartViewModel, CartState>(CartViewModel.new);