import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/dashboard_stats.dart';

/// Data-layer model that maps raw Firestore aggregation results
/// into [DashboardStats] domain entity.
///
/// This is NOT stored as a single Firestore document.
/// It is assembled from multiple collection queries in [DashboardRemoteDataSource].
class DashboardModel extends DashboardStats {
  const DashboardModel({
    required super.totalMedicines,
    required super.totalCustomers,
    required super.totalSuppliers,
    required super.lowStockCount,
    required super.expiringCount,
    required super.todaySalesAmount,
    required super.todaySalesCount,
    required super.monthlySalesAmount,
    required super.monthlySalesCount,
    required super.recentActivities,
    required super.fetchedAt,
  });

  /// Constructs a [DashboardModel] from pre-computed values.
  /// Called by [DashboardRemoteDataSource] after running all queries.
  factory DashboardModel.fromAggregated({
    required int totalMedicines,
    required int totalCustomers,
    required int totalSuppliers,
    required int lowStockCount,
    required int expiringCount,
    required QuerySnapshot todayInvoicesSnap,
    required QuerySnapshot monthlyInvoicesSnap,
    required QuerySnapshot recentActivitySnap,
  }) {
    // ── Compute today's sales totals ─────────────────────────────────────
    double todaySalesAmount = 0;
    for (final doc in todayInvoicesSnap.docs) {
      final data = doc.data() as Map<String, dynamic>;
      todaySalesAmount += (data['grandTotal'] ?? 0).toDouble();
    }

    // ── Compute monthly sales totals ─────────────────────────────────────
    double monthlySalesAmount = 0;
    for (final doc in monthlyInvoicesSnap.docs) {
      final data = doc.data() as Map<String, dynamic>;
      monthlySalesAmount += (data['grandTotal'] ?? 0).toDouble();
    }

    // ── Map recent activity docs ─────────────────────────────────────────
    final activities = recentActivitySnap.docs
        .map((doc) => RecentActivityModel.fromFirestore(doc))
        .toList();

    return DashboardModel(
      totalMedicines: totalMedicines,
      totalCustomers: totalCustomers,
      totalSuppliers: totalSuppliers,
      lowStockCount: lowStockCount,
      expiringCount: expiringCount,
      todaySalesAmount: todaySalesAmount,
      todaySalesCount: todayInvoicesSnap.docs.length,
      monthlySalesAmount: monthlySalesAmount,
      monthlySalesCount: monthlyInvoicesSnap.docs.length,
      recentActivities: activities,
      fetchedAt: DateTime.now(),
    );
  }
}

/// Maps a Firestore activityLogs document to [RecentActivity].
class RecentActivityModel extends RecentActivity {
  const RecentActivityModel({
    required super.id,
    required super.type,
    required super.description,
    required super.performedBy,
    required super.timestamp,
    super.amount,
  });

  factory RecentActivityModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return RecentActivityModel(
      id: doc.id,
      type: _parseType(data['action'] as String?),
      description: _buildDescription(data),
      performedBy: data['performedByName'] as String? ?? 'System',
      timestamp: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      amount: data['amount'] != null
          ? (data['amount'] as num).toDouble()
          : null,
    );
  }

  static ActivityType _parseType(String? action) {
    return switch (action) {
      'CREATE_INVOICE' => ActivityType.sale,
      'CREATE_PURCHASE_ORDER' => ActivityType.purchase,
      'STOCK_ADJUSTMENT' => ActivityType.stockAdjustment,
      'ADD_MEDICINE' => ActivityType.newMedicine,
      'ADD_CUSTOMER' => ActivityType.newCustomer,
      'ADD_PRESCRIPTION' => ActivityType.prescriptionAdded,
      'LOW_STOCK_ALERT' => ActivityType.lowStockAlert,
      'EXPIRY_ALERT' => ActivityType.expiryAlert,
      _ => ActivityType.sale,
    };
  }

  static String _buildDescription(Map<String, dynamic> data) {
    final action = data['action'] as String? ?? '';
    final target = data['targetId'] as String? ?? '';
    return switch (action) {
      'CREATE_INVOICE' => 'Invoice $target created',
      'CREATE_PURCHASE_ORDER' => 'Purchase order $target placed',
      'STOCK_ADJUSTMENT' => 'Stock adjusted for $target',
      'ADD_MEDICINE' => 'Medicine $target added',
      'ADD_CUSTOMER' => 'Customer $target registered',
      _ => data['description'] as String? ?? action,
    };
  }
}
