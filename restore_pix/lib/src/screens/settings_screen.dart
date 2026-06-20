import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/app_state_provider.dart';
import 'premium_paywall_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final TextEditingController _apiKeyController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final provider = context.read<AppStateProvider>();
    _apiKeyController.text = provider.cloudApiKey;
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppStateProvider>();
    final sub = provider.subscription;
    final useCloud = provider.useCloudEngine;

    return Scaffold(
      backgroundColor: const Color(0xFF0D0E15),
      appBar: AppBar(
        title: const Text('Settings & API Manager'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Pro status card
              _buildProStatusCard(context, sub, provider),
              const SizedBox(height: 24),

              const Text('Tech Stack & AI Backend Architecture', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text('Configure exactly how image enhancements and restorations are computed.', style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 13)),
              const SizedBox(height: 16),

              // Switcher card
              _buildEngineSwitcherCard(context, useCloud, provider),
              const SizedBox(height: 24),

              // Developer API Keys Input Box (If Cloud is toggled)
              if (useCloud) ...[
                _buildApiKeyConfigBox(context, provider),
                const SizedBox(height: 24),
              ],

              const Text('Developer Inspection & Test Utilities', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              _buildTestUtilitiesBox(context, provider),
              const SizedBox(height: 24),

              const Text('Support & Documentation', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              _buildSupportBox(context),
              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProStatusCard(BuildContext context, subscription, AppStateProvider provider) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: subscription.isPremium
            ? const LinearGradient(colors: [Color(0xFFFFD700), Color(0xFFFF7A00)])
            : const LinearGradient(colors: [Color(0xFF7A11FF), Color(0xFFFF1178)]),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: (subscription.isPremium ? const Color(0xFFFFD700) : const Color(0xFF7A11FF)).withOpacity(0.4), blurRadius: 15),
        ],
      ),
      child: Row(
        children: [
          Icon(subscription.isPremium ? Icons.workspace_premium_rounded : Icons.star_rounded, color: Colors.white, size: 36),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(subscription.isPremium ? 'ReviveAI Pro Active' : 'Free Monetization Tier', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 2),
                Text(
                  subscription.isPremium ? 'Unlimited 4K batch processing enabled.' : '${subscription.freeExportsRemaining} Free Exports remaining today.',
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PremiumPaywallScreen())),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: Text(subscription.isPremium ? 'MANAGE' : 'UPGRADE', style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildEngineSwitcherCard(BuildContext context, bool useCloud, AppStateProvider provider) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF161824),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white12),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Active Image Restoration Engine:', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w600, fontSize: 14)),
          const SizedBox(height: 16),

          // Option 1: On-Device Algorithmic Filter Engine
          RadioListTile<bool>(
            value: false,
            groupValue: useCloud,
            activeColor: const Color(0xFF00F0FF),
            tileColor: const Color(0xFF1F2232),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: const Text('100% Free On-Device AI Simulation', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
            subtitle: const Text('Works offline, zero cost, completely stable on all Android phones.', style: TextStyle(color: Color(0xFFA0A3B5), fontSize: 12)),
            onChanged: (val) {
              if (val != null) provider.toggleEngine(val);
            },
          ),
          const SizedBox(height: 12),

          // Option 2: Cloud REST API Engine
          RadioListTile<bool>(
            value: true,
            groupValue: useCloud,
            activeColor: const Color(0xFFFF1178),
            tileColor: const Color(0xFF1F2232),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: const Text('Cloud GPU REST APIs (Paid Engine)', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
            subtitle: const Text('Requires your personal API keys (Stability / Replicate / Fal.ai)', style: TextStyle(color: Color(0xFFA0A3B5), fontSize: 12)),
            onChanged: (val) {
              if (val != null) provider.toggleEngine(val);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildApiKeyConfigBox(BuildContext context, AppStateProvider provider) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF161824),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFFF1178).withOpacity(0.5)),
        boxShadow: [
          BoxShadow(color: const Color(0xFFFF1178).withOpacity(0.15), blurRadius: 10),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.key_rounded, color: Color(0xFFFF1178), size: 22),
              SizedBox(width: 10),
              Text('Cloud REST API Key Integration', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 8),
          const Text('Provide your bearer token for Replicate / Stability AI. If empty or invalid, the app gracefully falls back to the Free On-Device Engine.', style: TextStyle(color: Color(0xFFA0A3B5), fontSize: 12)),
          const SizedBox(height: 16),
          TextField(
            controller: _apiKeyController,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color(0xFF1F2232),
              hintText: 'Paste your Bearer Token (e.g. sk-MY_KEY...)',
              hintStyle: const TextStyle(color: Colors.white24),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFFFF1178))),
            ),
            obscureText: true,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () async {
              await provider.setCloudApiKey(_apiKeyController.text);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('🔑 Saved Cloud API Key successfully!'), backgroundColor: Colors.green),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF1178),
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            icon: const Icon(Icons.save_rounded, size: 20),
            label: const Text('Save API Key', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildTestUtilitiesBox(BuildContext context, AppStateProvider provider) {
    final sub = provider.subscription;

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF161824),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white12),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.refresh_rounded, color: Color(0xFF00F0FF)),
            title: const Text('Reset Free Tier Daily Export Limit'),
            subtitle: const Text('Restores remaining free exports to 3'),
            trailing: ElevatedButton(
              onPressed: () async {
                await provider.resetFreeExportsLimit();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('🔄 Daily free export counter reset to 3!'), backgroundColor: Colors.green),
                  );
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00F0FF), foregroundColor: Colors.black),
              child: const Text('RESET'),
            ),
          ),
          const Divider(color: Colors.white12),
          ListTile(
            leading: const Icon(Icons.developer_mode_rounded, color: Color(0xFFFFD700)),
            title: const Text('Simulate Play Store Pro Unlock'),
            subtitle: Text(sub.isPremium ? 'Currently Pro' : 'Currently Free'),
            trailing: Switch(
              value: sub.isPremium,
              activeColor: const Color(0xFFFFD700),
              onChanged: (val) => provider.unlockPremium(val),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSupportBox(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF161824),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white12),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.help_outline_rounded, color: Colors.white),
            title: const Text('Senior App Developer Integration Guide'),
            subtitle: const Text('How to publish this app on Google Play Store'),
            trailing: const Icon(Icons.open_in_new_rounded, color: Colors.white54, size: 18),
            onTap: () {
              // Show guide dialog
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  backgroundColor: const Color(0xFF1F2232),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                  title: const Text('Play Store Publish Guide 🚀', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  content: const SingleChildScrollView(
                    child: Text(
                      '1. Build App Bundle: Run `flutter build appbundle` in your terminal.\n\n'
                      '2. Play Store KeyStore: Sign the app with your Google Play Upload Key.\n\n'
                      '3. Positioning: Remember the PDF strategy. Emotion sells! Use the exact titles "Restore Old Memories", "Bring Old Photos Back to Life".\n\n'
                      '4. Viral Marketing: Post Before/After sample videos on TikTok, Instagram Reels, and YouTube Shorts as mentioned in the PRD.\n\n'
                      '5. Permissions: The app has full Android 21-34 Scoped Storage support pre-configured.',
                      style: TextStyle(color: Colors.white70, height: 1.4),
                    ),
                  ),
                  actions: [
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF7A11FF)),
                      child: const Text('Understood'),
                    ),
                  ],
                ),
              );
            },
          ),
          const Divider(color: Colors.white12),
          ListTile(
            leading: const Icon(Icons.privacy_tip_outlined, color: Colors.greenAccent),
            title: const Text('Privacy Policy & Play Store Compliance'),
            trailing: const Icon(Icons.open_in_new_rounded, color: Colors.white54, size: 18),
            onTap: () {
              launchUrl(Uri.parse('https://policies.google.com/privacy'));
            },
          ),
        ],
      ),
    );
  }
}
