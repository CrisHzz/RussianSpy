import 'package:flutter/material.dart';

//barra de la app header
class SpyAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback? onAllIdentities;

  const SpyAppBar({super.key, this.onAllIdentities});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  static const _red = Color(0xFFFF4D4D);
  static const _surface = Color(0xFF161B22);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: _surface,
      elevation: 0,
      title: const Row(
        children: [
          Icon(Icons.shield, color: _red, size: 20),
          SizedBox(width: 8),
          Text(
            'RUSSIAN SPY',
            style: TextStyle(
              fontFamily: 'monospace',
              fontSize: 16,
              fontWeight: FontWeight.w600,
              letterSpacing: 2,
              color: _red,
            ),
          ),
        ],
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent.withValues(alpha: 0.12),
              foregroundColor: Colors.redAccent,
              elevation: 0,
              side: BorderSide(color: Colors.redAccent.withValues(alpha: 0.4)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            icon: const Icon(Icons.people, size: 16),
            label: const Text(
              "ALL IDENTITIES",
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 1,
              ),
            ),
            onPressed:
                onAllIdentities ?? () => debugPrint("All identities pressed"),
          ),
        ),
      ],
    );
  }
}
