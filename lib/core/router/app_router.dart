import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// Import your screens here:
// import '../../features/auth/presentation/screens/login_screen.dart';
// import '../../features/auth/presentation/screens/register_screen.dart';
// import '../../features/auth/presentation/providers/auth_providers.dart';
// ... etc

/// App-wide GoRouter configuration.
///
/// Routes:
///   /login            → LoginScreen
///   /register         → RegisterScreen
///   /                 → DashboardScreen
///   /medicines        → MedicineListScreen
///   /medicines/add    → AddMedicineScreen
///   /inventory        → InventoryScreen
///   /inventory/receive → ReceiveStockScreen
///   /inventory/adjust → AdjustStockScreen
///   /inventory/orders → PurchaseOrdersScreen
///   /pos              → POSScreen (Cart)
///   /sales            → SalesHistoryScreen
///   /invoices/:id     → InvoiceDetailScreen
///   /invoices/:id/pdf → PdfViewerScreen
///   /reports          → ReportsScreen
///   /customers        → CustomerListScreen
///   /customers/add    → AddCustomerScreen
///   /suppliers        → SupplierListScreen
///   /notifications    → NotificationListScreen
///   /backup           → BackupRestoreScreen
///   /stores           → StoreManagementScreen
///   /settings         → SettingsScreen

final appRouterProvider = Provider<GoRouter>((ref) {
  // Watch auth state for redirect
  // final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/login',
    // redirect: (context, state) {
    //   final isLoggedIn = authState.value != null;
    //   final isOnLogin  = state.matchedLocation == '/login' ||
    //                      state.matchedLocation == '/register';
    //   if (!isLoggedIn && !isOnLogin) return '/login';
    //   if (isLoggedIn  && isOnLogin)  return '/';
    //   return null;
    // },
    routes: [
      GoRoute(path: '/login',    builder: (_, __) => const _Placeholder('LoginScreen')),
      GoRoute(path: '/register', builder: (_, __) => const _Placeholder('RegisterScreen')),
      GoRoute(path: '/',         builder: (_, __) => const _Placeholder('DashboardScreen')),
      GoRoute(path: '/medicines', builder: (_, __) => const _Placeholder('MedicineListScreen'),
        routes: [
          GoRoute(path: 'add',  builder: (_, __) => const _Placeholder('AddMedicineScreen')),
          GoRoute(path: ':id',  builder: (_, s)  => _Placeholder('EditMedicineScreen ${s.pathParameters['id']}')),
        ]),
      GoRoute(path: '/inventory', builder: (_, __) => const _Placeholder('InventoryScreen'),
        routes: [
          GoRoute(path: 'receive', builder: (_, __) => const _Placeholder('ReceiveStockScreen')),
          GoRoute(path: 'adjust',  builder: (_, __) => const _Placeholder('AdjustStockScreen')),
          GoRoute(path: 'orders',  builder: (_, __) => const _Placeholder('PurchaseOrdersScreen')),
          GoRoute(path: 'orders/new', builder: (_, __) => const _Placeholder('CreatePurchaseOrderScreen')),
        ]),
      GoRoute(path: '/pos',     builder: (_, __) => const _Placeholder('POSScreen')),
      GoRoute(path: '/sales',   builder: (_, __) => const _Placeholder('SalesHistoryScreen')),
      GoRoute(path: '/invoices/:id', builder: (_, s) => _Placeholder('InvoiceDetailScreen ${s.pathParameters['id']}'),
        routes: [
          GoRoute(path: 'pdf', builder: (_, s) => _Placeholder('PdfViewerScreen ${s.pathParameters['id']}')),
        ]),
      GoRoute(path: '/reports',       builder: (_, __) => const _Placeholder('ReportsScreen')),
      GoRoute(path: '/customers',     builder: (_, __) => const _Placeholder('CustomerListScreen'),
        routes: [
          GoRoute(path: 'add', builder: (_, __) => const _Placeholder('AddCustomerScreen')),
        ]),
      GoRoute(path: '/suppliers',     builder: (_, __) => const _Placeholder('SupplierListScreen')),
      GoRoute(path: '/notifications', builder: (_, __) => const _Placeholder('NotificationListScreen')),
      GoRoute(path: '/backup',        builder: (_, __) => const _Placeholder('BackupRestoreScreen')),
      GoRoute(path: '/stores',        builder: (_, __) => const _Placeholder('StoreManagementScreen')),
      GoRoute(path: '/settings',      builder: (_, __) => const _Placeholder('SettingsScreen')),
    ],
    errorBuilder: (_, state) => Scaffold(
      body: Center(child: Text('Page not found: ${state.error}')),
    ),
  );
});

/// Placeholder widget — replace with real screen imports.
class _Placeholder extends StatelessWidget {
  const _Placeholder(this.name);
  final String name;
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text(name)),
        body: Center(
          child: Text(name,
              style: const TextStyle(
                  fontSize: 16, color: Color(0xFF888888))),
        ),
      );
}