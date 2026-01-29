import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:ping/core/monetization/revenue_cat_config.dart';

/// Service to manage RevenueCat SDK interactions
///
/// This service wraps all RevenueCat functionality including:
/// - SDK initialization
/// - Fetching offerings
/// - Making purchases
/// - Restoring purchases
/// - Checking subscription status
class RevenueCatService {
  RevenueCatService._();
  static final RevenueCatService instance = RevenueCatService._();

  bool _isInitialized = false;
  CustomerInfo? _currentCustomerInfo;

  /// Initialize RevenueCat SDK
  ///
  /// Call this once at app startup, after user authentication
  Future<void> initialize({String? userId}) async {
    if (_isInitialized) {
      debugPrint('RevenueCat: Already initialized');
      return;
    }

    try {
      debugPrint('RevenueCat: Initializing...');

      // Configure SDK
      final configuration =
          PurchasesConfiguration(RevenueCatConfig.getApiKey());

      if (userId != null) {
        configuration..appUserID = userId;
      }

      // Initialize
      await Purchases.configure(configuration);

      // Enable debug logs in development
      if (kDebugMode) {
        await Purchases.setLogLevel(LogLevel.debug);
      }

      // Get initial customer info
      _currentCustomerInfo = await Purchases.getCustomerInfo();

      _isInitialized = true;
      debugPrint('RevenueCat: Initialized successfully');
      debugPrint('RevenueCat: User has premium: ${isPremium()}');
    } catch (e) {
      debugPrint('RevenueCat: Initialization error: $e');
      rethrow;
    }
  }

  /// Check if user has premium subscription
  bool isPremium() {
    if (_currentCustomerInfo == null) return false;

    final entitlements = _currentCustomerInfo!.entitlements.all;
    final premiumEntitlement =
        entitlements[RevenueCatConfig.premiumEntitlementId];

    return premiumEntitlement?.isActive ?? false;
  }

  /// Get current customer info
  CustomerInfo? get customerInfo => _currentCustomerInfo;

  /// Fetch available offerings from RevenueCat
  Future<Offerings?> getOfferings() async {
    try {
      debugPrint('RevenueCat: Fetching offerings...');
      final offerings = await Purchases.getOfferings();

      if (offerings.current == null) {
        debugPrint('RevenueCat: No current offering found');
        return null;
      }

      debugPrint(
          'RevenueCat: Found ${offerings.current!.availablePackages.length} packages');
      return offerings;
    } catch (e) {
      debugPrint('RevenueCat: Error fetching offerings: $e');
      return null;
    }
  }

  /// Purchase a package
  Future<CustomerInfo?> purchasePackage(Package package) async {
    try {
      debugPrint('RevenueCat: Purchasing package: ${package.identifier}');

      final purchaseResult = await Purchases.purchasePackage(package);
      _currentCustomerInfo = purchaseResult.customerInfo;

      debugPrint('RevenueCat: Purchase successful');
      debugPrint('RevenueCat: User has premium: ${isPremium()}');

      return _currentCustomerInfo;
    } on PlatformException catch (e) {
      final errorCode = PurchasesErrorHelper.getErrorCode(e);

      if (errorCode == PurchasesErrorCode.purchaseCancelledError) {
        debugPrint('RevenueCat: Purchase cancelled by user');
      } else if (errorCode == PurchasesErrorCode.purchaseNotAllowedError) {
        debugPrint('RevenueCat: Purchase not allowed');
      } else {
        debugPrint('RevenueCat: Purchase error: ${e.message}');
      }

      return null;
    } catch (e) {
      debugPrint('RevenueCat: Unexpected purchase error: $e');
      return null;
    }
  }

  /// Restore previous purchases
  Future<CustomerInfo?> restorePurchases() async {
    try {
      debugPrint('RevenueCat: Restoring purchases...');

      _currentCustomerInfo = await Purchases.restorePurchases();

      debugPrint('RevenueCat: Purchases restored');
      debugPrint('RevenueCat: User has premium: ${isPremium()}');

      return _currentCustomerInfo;
    } catch (e) {
      debugPrint('RevenueCat: Error restoring purchases: $e');
      return null;
    }
  }

  /// Refresh customer info
  Future<void> refreshCustomerInfo() async {
    try {
      _currentCustomerInfo = await Purchases.getCustomerInfo();
      debugPrint('RevenueCat: Customer info refreshed');
    } catch (e) {
      debugPrint('RevenueCat: Error refreshing customer info: $e');
    }
  }

  /// Set user ID (for logged-in users)
  Future<void> setUserId(String userId) async {
    try {
      debugPrint('RevenueCat: Setting user ID: $userId');
      await Purchases.logIn(userId);
      await refreshCustomerInfo();
    } catch (e) {
      debugPrint('RevenueCat: Error setting user ID: $e');
    }
  }

  /// Clear user ID (for logout)
  Future<void> logout() async {
    try {
      debugPrint('RevenueCat: Logging out user');
      await Purchases.logOut();
      _currentCustomerInfo = null;
    } catch (e) {
      debugPrint('RevenueCat: Error logging out: $e');
    }
  }

  /// Get active subscription info
  String? getActiveSubscriptionInfo() {
    if (!isPremium()) return null;

    final entitlements = _currentCustomerInfo!.entitlements.all;
    final premiumEntitlement =
        entitlements[RevenueCatConfig.premiumEntitlementId];

    if (premiumEntitlement == null) return null;

    final expirationDate = premiumEntitlement.expirationDate;
    final willRenew = premiumEntitlement.willRenew;

    if (expirationDate != null) {
      // expirationDate is a String in ISO format, parse it to DateTime first
      final dateTime = DateTime.parse(expirationDate);
      final formattedDate = dateTime.toLocal().toString().split(' ')[0];
      if (willRenew) {
        return 'Renews on $formattedDate';
      } else {
        return 'Expires on $formattedDate';
      }
    }

    return 'Active';
  }
}
