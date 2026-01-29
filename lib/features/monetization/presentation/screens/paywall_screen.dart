import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:ping/app/theme/ping_theme.dart';
import 'package:ping/core/monetization/entitlement_provider.dart';
import 'package:ping/features/monetization/presentation/widgets/subscription_card.dart';

/// Paywall screen showing subscription options
class PaywallScreen extends ConsumerStatefulWidget {
  const PaywallScreen({super.key});

  @override
  ConsumerState<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends ConsumerState<PaywallScreen> {
  Package? _selectedPackage;
  bool _isPurchasing = false;

  @override
  Widget build(BuildContext context) {
    final offeringsAsync = ref.watch(offeringsProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Upgrade to Premium'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: offeringsAsync.when(
        data: (offerings) {
          if (offerings == null || offerings.current == null) {
            return _buildErrorState();
          }

          final packages = offerings.current!.availablePackages;

          // Sort packages: yearly, monthly, lifetime
          packages.sort((a, b) {
            if (a.packageType == PackageType.annual) return -1;
            if (b.packageType == PackageType.annual) return 1;
            if (a.packageType == PackageType.monthly) return -1;
            if (b.packageType == PackageType.monthly) return 1;
            return 0;
          });

          // Select yearly by default
          _selectedPackage ??= packages.firstWhere(
            (p) => p.packageType == PackageType.annual,
            orElse: () => packages.first,
          );

          return _buildPaywallContent(packages);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => _buildErrorState(),
      ),
    );
  }

  Widget _buildPaywallContent(List<Package> packages) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Premium features list
          _buildFeaturesList(),

          const SizedBox(height: 32),

          // Subscription options
          ...packages.map((package) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: SubscriptionCard(
                  package: package,
                  isSelected: _selectedPackage == package,
                  onTap: () {
                    setState(() {
                      _selectedPackage = package;
                    });
                  },
                ),
              )),

          const SizedBox(height: 24),

          // Purchase button
          _buildPurchaseButton(),

          const SizedBox(height: 16),

          // Restore purchases button
          _buildRestoreButton(),

          const SizedBox(height: 16),

          // Terms and privacy
          _buildLegalLinks(),
        ],
      ),
    );
  }

  Widget _buildFeaturesList() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            PingTheme.primaryRed.withOpacity(0.1),
            PingTheme.primaryRed.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.workspace_premium,
                color: PingTheme.primaryRed,
                size: 32,
              ),
              const SizedBox(width: 12),
              Text(
                'Premium Features',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildFeatureItem(Icons.all_inclusive, 'Unlimited Reminders'),
          _buildFeatureItem(Icons.cloud_sync, 'Cloud Sync Across Devices'),
          _buildFeatureItem(Icons.music_note, 'Custom Notification Sounds'),
          _buildFeatureItem(Icons.palette, 'Premium Themes'),
          _buildFeatureItem(Icons.priority_high, 'Priority Notifications'),
          _buildFeatureItem(Icons.support, 'Priority Support'),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(
            icon,
            color: PingTheme.primaryRed,
            size: 24,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPurchaseButton() {
    return ElevatedButton(
      onPressed: _isPurchasing ? null : _handlePurchase,
      style: ElevatedButton.styleFrom(
        backgroundColor: PingTheme.primaryRed,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: _isPurchasing
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : Text(
              'Start Premium',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
            ),
    );
  }

  Widget _buildRestoreButton() {
    return TextButton(
      onPressed: _isPurchasing ? null : _handleRestore,
      child: Text(
        'Restore Purchases',
        style: TextStyle(
          color: PingTheme.primaryRed,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildLegalLinks() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TextButton(
          onPressed: () {
            // TODO: Open terms of service
          },
          child: Text(
            'Terms',
            style: TextStyle(
              color: Theme.of(context).textTheme.bodySmall?.color,
              fontSize: 12,
            ),
          ),
        ),
        Text(
          '•',
          style: TextStyle(
            color: Theme.of(context).textTheme.bodySmall?.color,
          ),
        ),
        TextButton(
          onPressed: () {
            // TODO: Open privacy policy
          },
          child: Text(
            'Privacy',
            style: TextStyle(
              color: Theme.of(context).textTheme.bodySmall?.color,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Theme.of(context).textTheme.bodySmall?.color,
          ),
          const SizedBox(height: 16),
          Text(
            'Unable to load subscription options',
            style: Theme.of(context).textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Please check your internet connection',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              ref.invalidate(offeringsProvider);
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Future<void> _handlePurchase() async {
    if (_selectedPackage == null) return;

    setState(() {
      _isPurchasing = true;
    });

    final success =
        await ref.read(purchaseProvider.notifier).purchase(_selectedPackage!);

    setState(() {
      _isPurchasing = false;
    });

    if (mounted) {
      if (success) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('🎉 Welcome to Premium!'),
            backgroundColor: Colors.green,
          ),
        );

        // Close paywall
        context.pop();
      } else {
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Purchase failed. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _handleRestore() async {
    setState(() {
      _isPurchasing = true;
    });

    final hasPremium = await ref.read(purchaseProvider.notifier).restore();

    setState(() {
      _isPurchasing = false;
    });

    if (mounted) {
      if (hasPremium) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Purchases restored successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        context.pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No previous purchases found'),
          ),
        );
      }
    }
  }
}
