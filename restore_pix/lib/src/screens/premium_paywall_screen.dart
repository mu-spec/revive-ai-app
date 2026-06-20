import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state_provider.dart';

class PremiumPaywallScreen extends StatelessWidget {
  const PremiumPaywallScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final sub = context.watch<AppStateProvider>().subscription;

    return Scaffold(
      backgroundColor: const Color(0xFF0D0E15),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              // Dismiss button
              Align(
                alignment: Alignment.topRight,
                child: IconButton(
                  icon: const Icon(Icons.close_rounded, color: Colors.white70, size: 28),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              const SizedBox(height: 10),

              // Pro Gold Badge Banner
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFFD700), Color(0xFFFF7A00)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(32),
                  boxShadow: [
                    BoxShadow(color: const Color(0xFFFFD700).withOpacity(0.4), blurRadius: 24, spreadRadius: 4),
                  ],
                ),
                child: const Icon(Icons.workspace_premium_rounded, size: 56, color: Colors.black),
              ),
              const SizedBox(height: 24),

              const Text(
                'ReviveAI Pro',
                style: TextStyle(fontSize: 36, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 1),
              ),
              const SizedBox(height: 8),
              Text(
                'Bring all your precious old memories back to life with premium AI processing power.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 15, color: Colors.white.withOpacity(0.8), height: 1.3),
              ),
              const SizedBox(height: 36),

              // Feature comparison Table
              _buildFeatureComparisonBox(context),
              const SizedBox(height: 36),

              // Plan Chooser Cards (Weekly / Lifetime)
              Row(
                children: [
                  Expanded(
                    child: _buildPlanCard(
                      label: 'Weekly Pro',
                      price: '\$3.99',
                      subtitle: 'Cancel anytime',
                      isPopular: false,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildPlanCard(
                      label: 'Lifetime Pro',
                      price: '\$29.99',
                      subtitle: 'Pay once, own forever',
                      isPopular: true,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 36),

              // Actual Unlock Button
              ElevatedButton.icon(
                onPressed: () async {
                  await context.read<AppStateProvider>().unlockPremium(!sub.isPremium);
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(sub.isPremium ? 'Pro Subscription Cancelled.' : '🎉 Successfully unlocked ReviveAI Premium Suite!'),
                        backgroundColor: sub.isPremium ? Colors.orange : Colors.green,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: sub.isPremium ? Colors.redAccent : const Color(0xFFFFD700),
                  foregroundColor: Colors.black,
                  minimumSize: const Size(double.infinity, 60),
                  elevation: 10,
                  shadowColor: const Color(0xFFFFD700).withOpacity(0.5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
                icon: Icon(sub.isPremium ? Icons.lock_open_rounded : Icons.star_rounded, size: 24),
                label: Text(
                  sub.isPremium ? 'Disable Pro (For Testing)' : 'Unlock Unlimited Pro Now',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: 0.5),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Secure Play Store Android Billing • Instant Activation',
                style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 11),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureComparisonBox(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF161824),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFFFFD700).withOpacity(0.3)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 15),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          _buildComparisonRow(title: 'Export Resolution', free: 'Standard / 1080p', pro: 'Ultra HD 4K', isHighlight: true),
          const Divider(color: Colors.white12, height: 24),
          _buildComparisonRow(title: 'Daily Limit', free: '3 Exports / Day', pro: 'Unlimited Exports', isHighlight: true),
          const Divider(color: Colors.white12, height: 24),
          _buildComparisonRow(title: 'Watermark', free: 'ReviveAI Overlay', pro: 'No Watermark', isHighlight: false),
          const Divider(color: Colors.white12, height: 24),
          _buildComparisonRow(title: 'Batch Enhance 10+', free: 'Locked', pro: 'Unlocked', isHighlight: true),
          const Divider(color: Colors.white12, height: 24),
          _buildComparisonRow(title: 'Processing Speed', free: 'Standard Wait', pro: '2x Priority AI', isHighlight: false),
        ],
      ),
    );
  }

  Widget _buildComparisonRow({
    required String title,
    required String free,
    required String pro,
    required bool isHighlight,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          flex: 3,
          child: Text(title, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
        ),
        Expanded(
          flex: 2,
          child: Text(free, style: const TextStyle(color: Color(0xFFA0A3B5), fontSize: 13)),
        ),
        Expanded(
          flex: 2,
          child: Text(pro, textAlign: TextAlign.right, style: TextStyle(color: isHighlight ? const Color(0xFFFFD700) : const Color(0xFF00F0FF), fontSize: 13, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }

  Widget _buildPlanCard({
    required String label,
    required String price,
    required String subtitle,
    required bool isPopular,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isPopular ? const Color(0xFFFFD700).withOpacity(0.1) : const Color(0xFF1F2232),
        border: Border.all(color: isPopular ? const Color(0xFFFFD700) : Colors.white12, width: isPopular ? 2 : 1),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          if (isPopular)
            Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(color: const Color(0xFFFFD700), borderRadius: BorderRadius.circular(10)),
              child: const Text('BEST VALUE', style: TextStyle(color: Colors.black, fontSize: 10, fontWeight: FontWeight.bold)),
            ),
          Text(label, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(price, style: TextStyle(color: isPopular ? const Color(0xFFFFD700) : Colors.white, fontSize: 28, fontWeight: FontWeight.w900)),
          const SizedBox(height: 6),
          Text(subtitle, style: const TextStyle(color: Color(0xFFA0A3B5), fontSize: 12)),
        ],
      ),
    );
  }
}
