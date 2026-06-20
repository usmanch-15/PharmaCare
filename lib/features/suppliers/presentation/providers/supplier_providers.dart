import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/supplier_datasource.dart';
import '../../data/repositories/supplier_repository_impl.dart';
import '../../domain/repositories/supplier_repository.dart';
import '../../domain/usecases/supplier_usecases.dart';

final firestoreProvider =
    Provider<FirebaseFirestore>((_) => FirebaseFirestore.instance);
final supplierDataSourceProvider =
    Provider((ref) => SupplierRemoteDataSource(ref.read(firestoreProvider)));
final supplierRepositoryProvider = Provider<SupplierRepository>(
    (ref) => SupplierRepositoryImpl(ref.read(supplierDataSourceProvider)));
final getSuppliersUseCaseProvider =
    Provider((ref) => GetSuppliersUseCase(ref.read(supplierRepositoryProvider)));
final addSupplierUseCaseProvider =
    Provider((ref) => AddSupplierUseCase(ref.read(supplierRepositoryProvider)));
final updateSupplierUseCaseProvider =
    Provider((ref) => UpdateSupplierUseCase(ref.read(supplierRepositoryProvider)));
final deleteSupplierUseCaseProvider =
    Provider((ref) => DeleteSupplierUseCase(ref.read(supplierRepositoryProvider)));