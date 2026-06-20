import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/dashboard_model.dart';

/// Abstract contract for the remote data source.
abstract class DashboardRemoteDataSource {
  Future<DashboardModel> getDashboardStats();
  Stream<DashboardModel> watchDashboardStats();
  Future<int> getLowStockCount();
  Future<int> getExpiringCount({int withinDays = 30});
}

/// Firestore implementation of [DashboardRemoteDataSource].
///
/// Uses [Future.wait] to fire all count queries in parallel —
/// total fetch time = slowest single query, not sum of all queries.
class DashboardRemoteDataSourceImpl implements DashboardRemoteDataSource {
  const DashboardRemoteDataSourceImpl(this._firestore);

  final FirebaseFirestore _firestore;

  // ── Collection references ────────────────────────────────────────────────
  CollectionReference get _medicines => _firestore.collection('medicines');
  CollectionReference get _customers => _firestore.collection('customers');
  CollectionReference get _suppliers => _firestore.collection('suppliers');
  CollectionReference get _invoices => _firestore.collection('invoices');
  CollectionReference get _activityLogs =>
      _firestore.collection('activityLogs');
  CollectionReference get _batches => _firestore.collection('batches');

  @override
  Future<DashboardModel> getDashboardStats() async {
    try {
      final now = DateTime.now();
      final todayStart =
          DateTime(now.year, now.month, now.day);
      final monthStart =
          DateTime(now.year, now.month, 1);
      final expiryThreshold =
          DateTime(now.year, now.month, now.day + 30);

      // Fire all queries in parallel
      final results = await Future.wait([
        // [0] Total active medicines
        _medicines
            .where('isActive', isEqualTo: true)
            .count()
            .get(),
        // [1] Total customers
        _customers.count().get(),
        // [2] Total active suppliers
        _suppliers
            .where('isActive', isEqualTo: true)
            .count()
            .get(),
        // [3] Low stock — qtyAvailable <= reorderLevel (done via batch collection)
        _getLowStockCountQuery(),
        // [4] Expiring within 30 days
        _batches
            .where('status', isEqualTo: 'active')
            .where('expiryDate',
                isLessThanOrEqualTo: Timestamp.fromDate(expiryThreshold))
            .where('expiryDate',
                isGreaterThan: Timestamp.fromDate(now))
            .count()
            .get(),
        // [5] Today's invoices
        _invoices
            .where('createdAt',
                isGreaterThanOrEqualTo: Timestamp.fromDate(todayStart))
            .where('status', whereIn: ['paid', 'credit'])
            .get(),
        // [6] Monthly invoices
        _invoices
            .where('createdAt',
                isGreaterThanOrEqualTo: Timestamp.fromDate(monthStart))
            .where('status', whereIn: ['paid', 'credit'])
            .get(),
        // [7] Recent 5 activity logs
        _activityLogs
            .orderBy('createdAt', descending: true)
            .limit(5)
            .get(),
      ]);

      return DashboardModel.fromAggregated(
        totalMedicines:
            (results[0] as AggregateQuerySnapshot).count ?? 0,
        totalCustomers:
            (results[1] as AggregateQuerySnapshot).count ?? 0,
        totalSuppliers:
            (results[2] as AggregateQuerySnapshot).count ?? 0,
        lowStockCount:
            (results[3] as AggregateQuerySnapshot).count ?? 0,
        expiringCount:
            (results[4] as AggregateQuerySnapshot).count ?? 0,
        todayInvoicesSnap: results[5] as QuerySnapshot,
        monthlyInvoicesSnap: results[6] as QuerySnapshot,
        recentActivitySnap: results[7] as QuerySnapshot,
      );
    } on FirebaseException catch (e) {
      throw ServerException(e.message);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Stream<DashboardModel> watchDashboardStats() {
    // Re-fetch full stats whenever the invoices collection changes.
    // For production, consider a Cloud Function that maintains a
    // /stats/dashboard document and listen to that single doc instead.
    return _invoices
        .orderBy('createdAt', descending: true)
        .limit(1)
        .snapshots()
        .asyncMap((_) => getDashboardStats());
  }

  @override
  Future<int> getLowStockCount() async {
    try {
      final snap = await _getLowStockCountQuery();
      return snap.count ?? 0;
    } on FirebaseException catch (e) {
      throw ServerException(e.message);
    }
  }

  @override
  Future<int> getExpiringCount({int withinDays = 30}) async {
    try {
      final threshold =
          DateTime.now().add(Duration(days: withinDays));
      final snap = await _batches
          .where('status', isEqualTo: 'active')
          .where('expiryDate',
              isLessThanOrEqualTo: Timestamp.fromDate(threshold))
          .where('expiryDate',
              isGreaterThan: Timestamp.fromDate(DateTime.now()))
          .count()
          .get();
      return snap.count ?? 0;
    } on FirebaseException catch (e) {
      throw ServerException(e.message);
    }
  }

  // ── Private helpers ──────────────────────────────────────────────────────

  /// Low stock: batches where qtyAvailable > 0 but medicine's
  /// qtyAvailable <= reorderLevel. We store a denormalized
  /// `isLowStock` boolean on each medicine document (updated by
  /// Cloud Function on every sale) to avoid a collection-group query.
  Future<AggregateQuerySnapshot> _getLowStockCountQuery() {
    return _medicines
        .where('isActive', isEqualTo: true)
        .where('isLowStock', isEqualTo: true)
        .count()
        .get();
  }
}
