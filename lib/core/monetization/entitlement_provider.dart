import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:ping/core/monetization/revenue_cat_service.dart';
import 'package:ping/core/monetization/revenue_cat_config.dart';

/// Provider for RevenueCat service instance
final revenueCatServiceProvider = Provider<RevenueCatService>((ref) {
  return RevenueCatService.instance;
});

/// Provider for premium subscription status
///
/// Returns true if user has active premium subscription
final isPremiumProvider = StateProvider<bool>((ref) {
  final service = ref.watch(revenueCatServiceProvider);
  return service.isPremium();
});

/// Provider for customer info
final customerInfoProvider = StateProvider<CustomerInfo?>((ref) {
  final service = ref.watch(revenueCatServiceProvider);
  return service.customerInfo;
});

/// Provider for available offerings
final offeringsProvider = FutureProvider<Offerings?>((ref) async {
  final service = ref.watch(revenueCatServiceProvider);
  return await service.getOfferings();
});

/// Provider to check if user can create more reminders
///
/// Free users are limited to 10 reminders
final canCreateReminderProvider =
    Provider.family<bool, int>((ref, currentCount) {
  final isPremium = ref.watch(isPremiumProvider);

  if (isPremium) {
    return true; // Premium users have unlimited reminders
  }

  return currentCount < RevenueCatConfig.freeReminderLimit;
});

/// Provider for remaining free reminders
final remainingFreeRemindersProvider =
    Provider.family<int, int>((ref, currentCount) {
  final isPremium = ref.watch(isPremiumProvider);

  if (isPremium) {
    return -1; // -1 indicates unlimited
  }

  final remaining = RevenueCatConfig.freeReminderLimit - currentCount;
  return remaining > 0 ? remaining : 0;
});

/// Notifier for managing purchases
class PurchaseNotifier extends StateNotifier<AsyncValue<CustomerInfo?>> {
  final Ref ref;

  PurchaseNotifier(this.ref) : super(const AsyncValue.data(null));

  /// Purchase a package
  Future<bool> purchase(Package package) async {
    state = const AsyncValue.loading();

    try {
      final service = ref.read(revenueCatServiceProvider);
      final customerInfo = await service.purchasePackage(package);

      if (customerInfo != null) {
        // Update premium status
        ref.read(isPremiumProvider.notifier).state = service.isPremium();
        ref.read(customerInfoProvider.notifier).state = customerInfo;

        state = AsyncValue.data(customerInfo);
        return true;
      } else {
        state = const AsyncValue.data(null);
        return false;
      }
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      return false;
    }
  }

  /// Restore purchases
  Future<bool> restore() async {
    state = const AsyncValue.loading();

    try {
      final service = ref.read(revenueCatServiceProvider);
      final customerInfo = await service.restorePurchases();

      if (customerInfo != null) {
        // Update premium status
        ref.read(isPremiumProvider.notifier).state = service.isPremium();
        ref.read(customerInfoProvider.notifier).state = customerInfo;

        state = AsyncValue.data(customerInfo);
        return service.isPremium();
      } else {
        state = const AsyncValue.data(null);
        return false;
      }
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      return false;
    }
  }
}

/// Provider for purchase operations
final purchaseProvider =
    StateNotifierProvider<PurchaseNotifier, AsyncValue<CustomerInfo?>>((ref) {
  return PurchaseNotifier(ref);
});
