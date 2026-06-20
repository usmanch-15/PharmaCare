import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../viewmodels/cart_viewmodel.dart';
import '../widgets/cart_item_tile.dart';
import '../widgets/medicine_search_tile.dart';
import 'cart_screen.dart';
import 'invoice_detail_screen.dart';

class POSScreen extends ConsumerStatefulWidget {
  const POSScreen({super.key});

  @override
  ConsumerState<POSScreen> createState() => _POSScreenState();
}

class _POSScreenState extends ConsumerState<POSScreen> {
  final _searchCtrl = TextEditingController();
  final _searchFocus = FocusNode();

  @override
  void dispose() {
    _searchCtrl.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(cartViewModelProvider);
    final vm    = ref.read(cartViewModelProvider.notifier);

    // Snackbar + invoice redirect on checkout success
    ref.listen(cartViewModelProvider, (_, next) {
      if (next.actionStatus == CartActionStatus.error &&
          next.actionError != null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(next.actionError!),
          backgroundColor: const Color(0xFFE53935),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10)),
        ));
        vm.clearMessages();
      }
      if (next.actionStatus == CartActionStatus.success &&
          next.completedInvoice != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => InvoiceDetailScreen(
              invoiceId: next.completedInvoice!.id,
              fromCheckout: true,
            ),
          ),
        );
      }
    });

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),
      appBar: _buildAppBar(context, state, vm),
      body: Column(
        children: [
          // ── Search bar ──────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: TextField(
              controller: _searchCtrl,
              focusNode: _searchFocus,
              onChanged: (q) {
                vm.searchMedicine(q);
                setState(() {});
              },
              style: const TextStyle(fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Search medicine by name or scan barcode…',
                hintStyle: const TextStyle(
                    fontSize: 13, color: Color(0xFFBBBBBB)),
                prefixIcon: const Icon(Icons.search_rounded,
                    color: Color(0xFF1565C0), size: 20),
                suffixIcon: _searchCtrl.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.close_rounded, size: 18),
                        onPressed: () {
                          _searchCtrl.clear();
                          vm.clearSearch();
                          setState(() {});
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 12),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFE0E0E0))),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                        color: Color(0xFFE8E8E8))),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                        color: Color(0xFF1565C0), width: 1.5)),
              ),
            ),
          ),
          const SizedBox(height: 8),

          // ── Content ─────────────────────────────────────────────────
          Expanded(
            child: state.searchQuery.length >= 2
                ? _SearchResults(state: state, vm: vm)
                : _CartView(state: state, vm: vm),
          ),
        ],
      ),

      // ── Cart FAB ──────────────────────────────────────────────────
      floatingActionButton: state.cart.isEmpty
          ? null
          : FloatingActionButton.extended(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CartScreen()),
              ),
              backgroundColor: const Color(0xFF1565C0),
              icon: const Icon(Icons.shopping_cart_rounded,
                  color: Colors.white),
              label: Text(
                '${state.cart.totalQty} items · '
                'Rs ${state.cart.grandTotal.toStringAsFixed(0)}',
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.w600),
              ),
            ),
    );
  }

  PreferredSizeWidget _buildAppBar(
      BuildContext context, CartState state, CartViewModel vm) {
    return AppBar(
      backgroundColor: const Color(0xFFF7F8FC),
      elevation: 0,
      scrolledUnderElevation: 0,
      automaticallyImplyLeading: false,
      title: const Text('POS — New Sale',
          style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1A1A2E))),
      actions: [
        if (!state.cart.isEmpty)
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded,
                color: Color(0xFFE53935)),
            tooltip: 'Clear cart',
            onPressed: () => _confirmClear(context, vm),
          ),
        const SizedBox(width: 8),
      ],
    );
  }

  void _confirmClear(BuildContext context, CartViewModel vm) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
        title: const Text('Clear cart?',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
        content: const Text(
            'All items in the cart will be removed.',
            style: TextStyle(fontSize: 13)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFF44336)),
            onPressed: () {
              Navigator.pop(context);
              vm.clearCart();
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }
}

// ── Search results panel ──────────────────────────────────────────────────────

class _SearchResults extends StatelessWidget {
  const _SearchResults({required this.state, required this.vm});
  final CartState state;
  final CartViewModel vm;

  @override
  Widget build(BuildContext context) {
    if (state.isSearching) {
      return const Center(
          child: CircularProgressIndicator(color: Color(0xFF1565C0)));
    }
    if (state.searchResults.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.search_off_rounded,
                size: 44, color: Color(0xFFCCCCCC)),
            const SizedBox(height: 10),
            Text(
              'No results for "${state.searchQuery}"',
              style: const TextStyle(
                  fontSize: 14, color: Color(0xFF888888)),
            ),
          ],
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 100),
      itemCount: state.searchResults.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (_, i) => MedicineSearchTile(
        medicine: state.searchResults[i],
        onAddToCart: () => vm.addToCart(state.searchResults[i]),
      ),
    );
  }
}

// ── Cart view (when no search) ────────────────────────────────────────────────

class _CartView extends StatelessWidget {
  const _CartView({required this.state, required this.vm});
  final CartState state;
  final CartViewModel vm;

  @override
  Widget build(BuildContext context) {
    if (state.cart.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72, height: 72,
              decoration: BoxDecoration(
                color: const Color(0xFFE8F0FE),
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Icon(Icons.point_of_sale_rounded,
                  size: 36, color: Color(0xFF1565C0)),
            ),
            const SizedBox(height: 16),
            const Text('Cart is empty',
                style: TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            const Text(
              'Search for a medicine above\nor scan its barcode.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Color(0xFF888888)),
            ),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 120),
      children: [
        // Customer chip
        if (state.cart.customerName != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _CustomerChip(
              name: state.cart.customerName!,
              onRemove: vm.clearCustomer,
            ),
          ),

        // Cart items
        ...state.cart.items.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: CartItemTile(
                item: item,
                onQtyChanged: (qty) =>
                    vm.updateQty(item.medicineId, qty),
                onRemove: () =>
                    vm.removeFromCart(item.medicineId),
                onDiscountChanged: (pct) =>
                    vm.updateItemDiscount(item.medicineId, pct),
              ),
            )),

        // Cart totals summary
        const SizedBox(height: 4),
        _CartTotals(cart: state.cart, vm: vm),
      ],
    );
  }
}

class _CustomerChip extends StatelessWidget {
  const _CustomerChip({required this.name, required this.onRemove});
  final String name;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFE8F0FE),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
              color: const Color(0xFF1565C0).withOpacity(0.2)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.person_rounded,
                size: 16, color: Color(0xFF1565C0)),
            const SizedBox(width: 6),
            Text(name,
                style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF1565C0))),
            const SizedBox(width: 6),
            GestureDetector(
              onTap: onRemove,
              child: const Icon(Icons.close_rounded,
                  size: 16, color: Color(0xFF1565C0)),
            ),
          ],
        ),
      );
}

class _CartTotals extends StatelessWidget {
  const _CartTotals({required this.cart, required this.vm});
  final dynamic cart;
  final CartViewModel vm;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: Colors.black.withOpacity(0.06), width: 0.8),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        children: [
          _Row('Subtotal', 'Rs ${cart.subtotal.toStringAsFixed(0)}'),
          if (cart.totalDiscount > 0)
            _Row('Discount',
                '- Rs ${cart.totalDiscount.toStringAsFixed(0)}',
                valueColor: const Color(0xFF2E7D32)),
          if (cart.totalTax > 0)
            _Row('Tax', '+ Rs ${cart.totalTax.toStringAsFixed(0)}'),
          const Divider(height: 16),
          _Row('Total', 'Rs ${cart.grandTotal.toStringAsFixed(0)}',
              bold: true, valueColor: const Color(0xFF1565C0)),
          const SizedBox(height: 10),
          // Global discount stepper
          Row(
            children: [
              const Text('Global discount:',
                  style: TextStyle(
                      fontSize: 12, color: Color(0xFF888888))),
              const SizedBox(width: 8),
              Expanded(
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    trackHeight: 2,
                    thumbShape: const RoundSliderThumbShape(
                        enabledThumbRadius: 7),
                    overlayShape: const RoundSliderOverlayShape(
                        overlayRadius: 14),
                    activeTrackColor: const Color(0xFF1565C0),
                    thumbColor: const Color(0xFF1565C0),
                  ),
                  child: Slider(
                    value: cart.globalDiscountPct,
                    min: 0, max: 30,
                    divisions: 30,
                    onChanged: vm.setGlobalDiscount,
                  ),
                ),
              ),
              Text('${cart.globalDiscountPct.toStringAsFixed(0)}%',
                  style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1565C0))),
            ],
          ),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row(this.label, this.value,
      {this.bold = false, this.valueColor = const Color(0xFF1A1A2E)});
  final String label;
  final String value;
  final bool bold;
  final Color valueColor;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label,
                style: TextStyle(
                    fontSize: 13,
                    color: bold
                        ? const Color(0xFF1A1A2E)
                        : const Color(0xFF888888),
                    fontWeight: bold
                        ? FontWeight.w700
                        : FontWeight.w400)),
            Text(value,
                style: TextStyle(
                    fontSize: bold ? 15 : 13,
                    fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
                    color: valueColor)),
          ],
        ),
      );
}