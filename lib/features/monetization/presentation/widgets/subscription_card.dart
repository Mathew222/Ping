import 'package:flutter/material.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:ping/app/theme/ping_theme.dart';

/// Subscription card widget for displaying package options
class SubscriptionCard extends StatelessWidget {
  final Package package;
  final bool isSelected;
  final VoidCallback onTap;

  const SubscriptionCard({
    super.key,
    required this.package,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isBestValue = package.packageType == PackageType.annual;

    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isSelected
                  ? PingTheme.primaryRed.withOpacity(0.1)
                  : Theme.of(context).cardColor,
              border: Border.all(
                color: isSelected
                    ? PingTheme.primaryRed
                    : Theme.of(context).dividerColor,
                width: isSelected ? 2 : 1,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                // Radio button
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected
                          ? PingTheme.primaryRed
                          : Theme.of(context).dividerColor,
                      width: 2,
                    ),
                    color:
                        isSelected ? PingTheme.primaryRed : Colors.transparent,
                  ),
                  child: isSelected
                      ? const Icon(
                          Icons.check,
                          size: 16,
                          color: Colors.white,
                        )
                      : null,
                ),

                const SizedBox(width: 16),

                // Package info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getPackageTitle(),
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _getPackageDescription(),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),

                // Price
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      package.storeProduct.priceString,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: PingTheme.primaryRed,
                          ),
                    ),
                    if (_getPerMonthPrice() != null)
                      Text(
                        _getPerMonthPrice()!,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                  ],
                ),
              ],
            ),
          ),

          // Best value badge
          if (isBestValue)
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: PingTheme.primaryRed,
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(12),
                    bottomLeft: Radius.circular(12),
                  ),
                ),
                child: const Text(
                  'BEST VALUE',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _getPackageTitle() {
    switch (package.packageType) {
      case PackageType.monthly:
        return 'Monthly';
      case PackageType.annual:
        return 'Yearly';
      case PackageType.lifetime:
        return 'Lifetime';
      default:
        return package.storeProduct.title;
    }
  }

  String _getPackageDescription() {
    switch (package.packageType) {
      case PackageType.monthly:
        return 'Billed monthly';
      case PackageType.annual:
        return 'Billed annually • Save 44%';
      case PackageType.lifetime:
        return 'One-time payment';
      default:
        return '';
    }
  }

  String? _getPerMonthPrice() {
    if (package.packageType == PackageType.annual) {
      // Calculate per month price for annual subscription
      final price = package.storeProduct.price;
      final perMonth = price / 12;
      return '\$${perMonth.toStringAsFixed(2)}/month';
    }
    return null;
  }
}
