/// RevenueCat Configuration
///
/// This file contains all RevenueCat-related constants and configuration.
/// For hackathon/development, API keys are included here.
/// For production, move these to environment variables or secure storage.

import 'dart:io' show Platform;

class RevenueCatConfig {
  // API Keys
  // Test API key from RevenueCat
  static const String androidApiKey = 'test_QGZBgRMXhqAqGyYFHehfCnSUUPd';
  static const String iosApiKey = 'test_QGZBgRMXhqAqGyYFHehfCnSUUPd';

  // Entitlement IDs (configured in RevenueCat dashboard)
  static const String premiumEntitlementId = 'premium';

  // Product IDs (must match App Store/Play Store product IDs)
  static const String monthlyProductId = 'ping_premium_monthly';
  static const String yearlyProductId = 'ping_premium_yearly';
  static const String lifetimeProductId = 'ping_premium_lifetime';

  // Free tier limits
  static const int freeReminderLimit = 2; // Changed to 2 for easy testing

  // Feature flags
  static const bool enableCloudSyncForFree = false;
  static const bool enableCustomSoundsForFree = false;

  // Pricing display (for UI only, actual prices come from stores)
  static const String monthlyPrice = '\$4.99'; // Updated to match RevenueCat
  static const String yearlyPrice = '\$19.99';
  static const String lifetimePrice = '\$49.99';
  static const String yearlySavings = '44%';

  /// Get the appropriate API key for the current platform
  static String getApiKey() {
    // Detect platform and return appropriate key
    try {
      if (Platform.isAndroid) {
        return androidApiKey;
      } else if (Platform.isIOS) {
        return iosApiKey;
      } else {
        // For web or other platforms, use Android key as fallback
        return androidApiKey;
      }
    } catch (e) {
      // If Platform is not available (web), use Android key
      return androidApiKey;
    }
  }
}
