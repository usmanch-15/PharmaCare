import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../domain/usecases/supplier_usecases.dart';
import '../providers/supplier_providers.dart';

class SupplierListScreen extends ConsumerStatefulWidget {
  const SupplierListScreen({super.key});
  @override ConsumerState<SupplierListScreen> createState() => _State();
}

class _State extends ConsumerState<SupplierListScreen> {
  final _searchCtrl = TextEditingController();
  var _suppliers = <dynamic>[];
  bool _loading = true;

  @override void initState() { super.initState(); _load(); }

  Future<void> _load([String? q]) async {
    setState(() => _loading = true);
    final uc = ref.read(getSuppliersUseCaseProvider);
    final result = await uc(GetSuppliersParams(search: q));
    result.fold((_) {}, (list) => setState(() => _suppliers = list));
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),
      appBar: AppBar(
        title: const Text('Suppliers',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
        backgroundColor: const Color(0xFFF7F8FC), elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: TextField(
              controller: _searchCtrl,
              onChanged: (v) => _load(v.isEmpty ? null : v),
              decoration: InputDecoration(
                hintText: 'Search suppliers...',
                prefixIcon: const Icon(Icons.search_rounded, size: 18),
                filled: true, fillColor: Colors.white,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFE0E0E0))),
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddSheet(context),
        backgroundColor: const Color(0xFF1565C0),
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text('Add supplier',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF1565C0)))
          : _suppliers.isEmpty
              ? const Center(child: Text('No suppliers found',
                    style: TextStyle(fontSize: 14, color: Color(0xFF888888))))
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
                  itemCount: _suppliers.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (_, i) {
                    final s = _suppliers[i];
                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: Colors.black.withOpacity(0.06), width: 0.8),
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor:
                              const Color(0xFF2E7D32).withOpacity(0.1),
                          child: Text(s.name[0].toUpperCase(),
                              style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF2E7D32))),
                        ),
                        title: Text(s.name,
                            style: const TextStyle(
                                fontSize: 14, fontWeight: FontWeight.w600)),
                        subtitle: Text(
                          '${s.phone}${s.contactPerson != null ? ' · ${s.contactPerson}' : ''}',
                          style: const TextStyle(
                              fontSize: 12, color: Color(0xFF888888)),
                        ),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              NumberFormat.currency(
                                      symbol: 'Rs ', decimalDigits: 0)
                                  .format(s.totalAmount),
                              style: const TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.w700,
                                  color: Color(0xFF2E7D32)),
                            ),
                            Text('${s.totalOrders} orders',
                                style: const TextStyle(
                                    fontSize: 10, color: Color(0xFF888888))),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }

  void _showAddSheet(BuildContext context) {
    final nameCtrl    = TextEditingController();
    final phoneCtrl   = TextEditingController();
    final contactCtrl = TextEditingController();

    showModalBottomSheet(
      context: context, isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: EdgeInsets.fromLTRB(
            16, 16, 16, MediaQuery.of(context).viewInsets.bottom + 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Add supplier',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            const SizedBox(height: 14),
            _tf(nameCtrl, 'Company name *'),
            const SizedBox(height: 10),
            _tf(phoneCtrl, 'Phone *', type: TextInputType.phone),
            const SizedBox(height: 10),
            _tf(contactCtrl, 'Contact person'),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF1565C0)),
                onPressed: () async {
                  if (nameCtrl.text.isEmpty || phoneCtrl.text.isEmpty) return;
                  final uc = ref.read(addSupplierUseCaseProvider);
                  await uc(SupplierParams(
                    name:          nameCtrl.text.trim(),
                    phone:         phoneCtrl.text.trim(),
                    contactPerson: contactCtrl.text.trim().isEmpty
                        ? null : contactCtrl.text.trim(),
                  ));
                  if (context.mounted) Navigator.pop(context);
                  _load();
                },
                child: const Text('Save'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tf(TextEditingController ctrl, String label,
      {TextInputType type = TextInputType.text}) =>
      TextField(
        controller: ctrl, keyboardType: type,
        decoration: InputDecoration(
          labelText: label, filled: true, fillColor: const Color(0xFFF9FAFB),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFE0E0E0))),
        ),
      );
}