import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controllers/auth_provider.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/app_routes.dart';
import '../../widgets/rounded_card.dart';

/// Basic placeholder home page for the dashboard module.
class HomeView extends StatelessWidget {
  const HomeView({super.key});

  Future<void> _confirmLogout(BuildContext context) async {
    final theme = Theme.of(context);
    final authProvider = context.read<AuthProvider>();
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: Row(
            children: [
              Icon(Icons.logout, color: theme.colorScheme.primary),
              const SizedBox(width: 12),
              Text(
                'Logout',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          content: Text(
            'Apakah Anda yakin ingin keluar dari akun ini? Anda akan dialihkan ke halaman login.',
            style: theme.textTheme.bodyMedium,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Batal'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Keluar'),
            ),
          ],
        );
      },
    );

    if (result == true) {
      await _logout(
        authProvider: authProvider,
        messenger: messenger,
        navigator: navigator,
      );
    }
  }

  Future<void> _logout({
    required AuthProvider authProvider,
    required ScaffoldMessengerState messenger,
    required NavigatorState navigator,
  }) async {
    try {
      await authProvider.logout();
      if (!navigator.mounted) return;
      messenger.showSnackBar(
        SnackBar(
          content: const Text('Berhasil logout.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      navigator.pushReplacementNamed(AppRoutes.authLogin);
    } catch (error) {
      if (!navigator.mounted) return;
      messenger.showSnackBar(
        SnackBar(
          content: Text(error.toString()),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppConstants.appName),
        actions: [
          IconButton(
            onPressed: authProvider.isLoading
                ? null
                : () => _confirmLogout(context),
            icon: authProvider.isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2.5),
                  )
                : const Icon(Icons.logout),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Selamat datang di Itinetary',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 12),
            Text(
              'Rencana perjalanan Anda akan tersedia di sini setelah setup selesai.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            const RoundedCard(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Dashboard siap dikembangkan'),
                    Icon(Icons.travel_explore),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
