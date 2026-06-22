import 'dart:async';
import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharma_care/core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/customer_entity.dart';
import '../../domain/usecases/customer_usecases.dart';
import '../providers/customer_providers.dart';

enum CustomerStatus { idle, loading, success, error }

class CustomerState {
  const CustomerState({
    this.customers = const [],
    this.filtered = const [],
    this.status = CustomerStatus.idle,
    this.searchQuery = '',
    this.errorMessage,
  });

  final List<CustomerEntity> customers;
  final List<CustomerEntity> filtered;
  final CustomerStatus status;
  final String searchQuery;
  final String? errorMessage;

  bool get isLoading => status == CustomerStatus.loading;

  CustomerState copyWith({
    List<CustomerEntity>? customers,
    List<CustomerEntity>? filtered,
    CustomerStatus? status,
    String? searchQuery,
    String? errorMessage,
    bool clearError = false,
  }) =>
      CustomerState(
        customers: customers ?? this.customers,
        filtered: filtered ?? this.filtered,
        status: status ?? this.status,
        searchQuery: searchQuery ?? this.searchQuery,
        errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      );
}

class CustomerViewModel extends Notifier<CustomerState> {
  StreamSubscription<Either<Failure, List<CustomerEntity>>>? _subscription;

  @override
  CustomerState build() {
    _initializeWatch();
    ref.onDispose(() {
      _subscription?.cancel();
    });
    return const CustomerState();
  }

  void _initializeWatch() {
    final watchUC = ref.read(watchCustomersUseCaseProvider);

    final stream =
    watchUC(const GetCustomersParams()) as Stream<Either<Failure, List<CustomerEntity>>>;

    _subscription = stream.listen(
          (either) {
        either.fold(
              (f) => state = state.copyWith(
            status: CustomerStatus.error,
            errorMessage: f.message,
          ),
              (list) => state = state.copyWith(
            status: CustomerStatus.success,
            customers: list,
            filtered: _filter(list, state.searchQuery),
          ),
        );
      },
      onError: (e) {
        state = state.copyWith(
          status: CustomerStatus.error,
          errorMessage: e.toString(),
        );
      },
    );
  }

  List<CustomerEntity> _filter(List<CustomerEntity> all, String q) {
    if (q.isEmpty) return all;
    final lower = q.toLowerCase();
    return all
        .where((c) =>
    c.name.toLowerCase().contains(lower) ||
        c.phone.contains(lower))
        .toList();
  }

  void search(String q) => state = state.copyWith(
    searchQuery: q,
    filtered: _filter(state.customers, q),
  );

  Future<bool> addCustomer(CustomerParams params) async {
    state = state.copyWith(
      status: CustomerStatus.loading,
      clearError: true,
    );
    final result = await ref.read(addCustomerUseCaseProvider)(params);
    return result.fold(
          (f) {
        state = state.copyWith(
          status: CustomerStatus.error,
          errorMessage: f.message,
        );
        return false;
      },
          (_) {
        state = state.copyWith(status: CustomerStatus.success);
        return true;
      },
    );
  }

  Future<bool> deleteCustomer(String id) async {
    final result = await ref.read(deleteCustomerUseCaseProvider)(id);
    return result.fold(
          (f) {
        state = state.copyWith(errorMessage: f.message);
        return false;
      },
          (_) => true,
    );
  }
}

final customerViewModelProvider =
NotifierProvider<CustomerViewModel, CustomerState>(
    CustomerViewModel.new);

final watchCustomersUseCaseProvider = Provider(
      (ref) => GetCustomersUseCase(ref.read(customerRepositoryProvider)),
);