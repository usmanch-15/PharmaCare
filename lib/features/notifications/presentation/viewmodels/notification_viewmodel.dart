import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/notification_entity.dart';
import '../../domain/usecases/notification_usecases.dart';
import '../providers/notification_providers.dart';

enum NotifStatus { idle, loading, success, error }

class NotificationState {
  const NotificationState({
    this.notifications = const [],
    this.status = NotifStatus.idle,
    this.errorMessage,
  });
  final List<NotificationEntity> notifications;
  final NotifStatus status;
  final String? errorMessage;
  int get unreadCount => notifications.where((n) => !n.isRead).length;
  NotificationState copyWith({
    List<NotificationEntity>? notifications,
    NotifStatus? status,
    String? errorMessage,
    bool clearError = false,
  }) => NotificationState(
    notifications: notifications ?? this.notifications,
    status: status ?? this.status,
    errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
  );
}

class NotificationViewModel extends Notifier<NotificationState> {
  @override
  NotificationState build() {
    // Watch real-time stream
    final watchUC = ref.read(watchNotificationsUseCaseProvider);
    final sub = watchUC(const NoParams()).listen((either) {
      either.fold(
        (f) => state = state.copyWith(errorMessage: f.message),
        (list) => state = state.copyWith(notifications: list),
      );
    });
    ref.onDispose(sub.cancel);
    // Init on startup
    Future.microtask(_init);
    return const NotificationState();
  }

  Future<void> _init() async {
    final uc = ref.read(initNotificationsUseCaseProvider);
    await uc(const NoParams());
  }

  Future<void> checkAlerts() async {
    state = state.copyWith(status: NotifStatus.loading);
    final e1 = await ref.read(scheduleExpiryUseCaseProvider)(const NoParams());
    final e2 = await ref.read(scheduleLowStockUseCaseProvider)(const NoParams());
    final hasError = e1.isLeft() || e2.isLeft();
    state = state.copyWith(
      status: hasError ? NotifStatus.error : NotifStatus.success,
      errorMessage: hasError ? 'Some alerts failed.' : null,
    );
  }

  Future<void> markAsRead(String id) async {
    await ref.read(markAsReadUseCaseProvider)(MarkAsReadParams(id));
  }

  Future<void> markAllAsRead() async {
    await ref.read(markAllAsReadUseCaseProvider)(const NoParams());
  }
}

final notificationViewModelProvider =
    NotifierProvider<NotificationViewModel, NotificationState>(
        NotificationViewModel.new);