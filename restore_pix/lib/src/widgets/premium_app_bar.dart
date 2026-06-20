import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state_provider.dart';
import '../screens/premium_paywall_screen.dart';

class PremiumAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;

  const PremiumAppBar({
    Key? key,
    required this.title,
    this.actions,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final sub = context.watch<AppStateProvider>().subscription;

    return AppBar(
      title: Text(title),
      actions: [
        // Premium or remaining free daily exports badge
        GestureDetector(
          onTap: () {
            if (!sub.isPremium) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PremiumPaywallScreen()),
              );
            }
          },
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              gradient: sub.isPremium
                  ? const LinearGradient(
                      colors: [Color(0xFFFFD700), Color(0xFFFF7A00)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : const LinearGradient(
                      colors: [Color(0xFF7A11FF), Color(0xFFFF1178)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: (sub.isPremium ? const Color(0xFFFFD700) : const Color(0xFF7A11FF))
                      .withOpacity(0.4),
                  blurRadius: 8,
                ),
              ],
            ),
            alignment: Alignment.center,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  sub.isPremium ? Icons.workspace_premium_rounded : Icons.electric_bolt_rounded,
                  color: Colors.white,
                  size: 16,
                ),
                const SizedBox(width: 6),
                Text(
                  sub.isPremium ? 'PRO ACTIVE' : '${sub.freeExportsRemaining} Free Left',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (actions != null) ...actions!,
        const SizedBox(width: 8),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
