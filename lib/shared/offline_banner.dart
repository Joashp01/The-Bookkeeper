import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/network/connectivity_view_model.dart';

/// Wraps every route with a persistent bar that slides in whenever the device
/// is offline, so the offline state is evident on any screen (search, detail,
/// favourites). Installed via `MaterialApp.builder`.
class OfflineBanner extends StatelessWidget {
  const OfflineBanner({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final isOffline = context.watch<ConnectivityViewModel>().isOffline;

    return Column(
      children: [
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: isOffline
              ? const _OfflineBar()
              : const SizedBox(width: double.infinity),
        ),
        Expanded(child: child),
      ],
    );
  }
}

class _OfflineBar extends StatelessWidget {
  const _OfflineBar();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: scheme.errorContainer,
      child: SafeArea(
        bottom: false,
        child: Semantics(
          liveRegion: true,
          label: 'No internet connection. You are offline.',
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.wifi_off,
                  size: 18,
                  color: scheme.onErrorContainer,
                ),
                const SizedBox(width: 8),
                Text(
                  'No internet connection',
                  style: TextStyle(
                    color: scheme.onErrorContainer,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
