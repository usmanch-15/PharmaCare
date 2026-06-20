import 'package:equatable/equatable.dart';

class AppUser extends Equatable {
  const AppUser({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
    this.isActive = true,
    this.photoUrl,
    this.branchId,
  });

  final String    uid;
  final String    name;
  final String    email;
  final UserRole  role;
  final bool      isActive;
  final String?   photoUrl;
  final String?   branchId;

  bool get isAdmin    => role == UserRole.admin;
  bool get isManager  => role == UserRole.admin || role == UserRole.manager;
  bool get isCashier  => role == UserRole.cashier;

  @override
  List<Object?> get props => [uid, email, role];
}

enum UserRole {
  admin('Admin'),
  manager('Manager'),
  cashier('Cashier'),
  pharmacist('Pharmacist');

  const UserRole(this.label);
  final String label;

  static UserRole fromString(String? v) => UserRole.values.firstWhere(
      (e) => e.name == v, orElse: () => UserRole.cashier);
}