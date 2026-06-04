import 'package:flutter/material.dart';

import 'add_trip_view.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SafeArea(
      child: Container(
        width: double.infinity,
        color: colorScheme.primary.withAlpha(12),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 24,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: colorScheme.primary.withAlpha(20),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          'DEBUG: HomeView is rendering',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: colorScheme.primary,
                          ),
                        ),
                      ),
                      // Greeting Header
                      _GreetingHeader(theme: theme, colorScheme: colorScheme),
                      const SizedBox(height: 32),

                      // Hero Card - Upcoming Trip
                      _HeroCard(theme: theme, colorScheme: colorScheme),
                      const SizedBox(height: 32),

                      // Quick Actions Grid
                      _QuickActionsGrid(theme: theme, colorScheme: colorScheme),
                      const SizedBox(height: 32),

                      // Statistics Section
                      _StatisticsSection(
                        theme: theme,
                        colorScheme: colorScheme,
                      ),
                      const SizedBox(height: 32),

                      // Recent Activity
                      _RecentActivitySection(
                        theme: theme,
                        colorScheme: colorScheme,
                      ),
                      const SizedBox(height: 32),

                      // Empty State / CTA
                      _EmptyStateSection(
                        theme: theme,
                        colorScheme: colorScheme,
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Greeting section dengan nama user dan welcome message
class _GreetingHeader extends StatelessWidget {
  final ThemeData theme;
  final ColorScheme colorScheme;

  const _GreetingHeader({required this.theme, required this.colorScheme});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome back, Traveler',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Ready for your next adventure?',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurface.withAlpha(191),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        CircleAvatar(
          radius: 28,
          backgroundColor: colorScheme.primary.withAlpha(31),
          child: Icon(Icons.person, color: colorScheme.primary, size: 32),
        ),
      ],
    );
  }
}

/// Hero card untuk upcoming trip dengan ilustrasi
class _HeroCard extends StatelessWidget {
  final ThemeData theme;
  final ColorScheme colorScheme;

  const _HeroCard({required this.theme, required this.colorScheme});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [colorScheme.primary, colorScheme.primary.withAlpha(220)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withAlpha(51),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Your Next Adventure',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: Colors.white.withAlpha(204),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Plan your dream getaway',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.flight_takeoff_rounded,
                color: Colors.white.withAlpha(191),
                size: 48,
              ),
            ],
          ),
          const SizedBox(height: 20),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Colors.white.withAlpha(242),
              foregroundColor: colorScheme.primary,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const AddTripView()),
              );
            },
            child: Text(
              'Start Planning',
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Grid untuk quick actions
class _QuickActionsGrid extends StatelessWidget {
  final ThemeData theme;
  final ColorScheme colorScheme;

  const _QuickActionsGrid({required this.theme, required this.colorScheme});

  @override
  Widget build(BuildContext context) {
    final actions = [
      ('Add Trip', Icons.add_location_alt_rounded),
      ('My Schedule', Icons.calendar_today_rounded),
      ('Budget', Icons.wallet_rounded),
      ('Notes', Icons.note_rounded),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 16),
        GridView.count(
          primary: false,
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 1.1,
          children: actions.map((action) {
            return _QuickActionCard(
              label: action.$1,
              icon: action.$2,
              theme: theme,
              colorScheme: colorScheme,
            );
          }).toList(),
        ),
      ],
    );
  }
}

/// Individual quick action card
class _QuickActionCard extends StatelessWidget {
  final String label;
  final IconData icon;
  final ThemeData theme;
  final ColorScheme colorScheme;

  const _QuickActionCard({
    required this.label,
    required this.icon,
    required this.theme,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          if (label == 'Add Trip') {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const AddTripView()),
            );
          }
        },
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: BoxDecoration(
            color: colorScheme.primary.withAlpha(20),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: colorScheme.primary.withAlpha(41),
              width: 1,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: colorScheme.primary, size: 36),
              const SizedBox(height: 10),
              Text(
                label,
                textAlign: TextAlign.center,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Statistics section menampilkan trip overview
class _StatisticsSection extends StatelessWidget {
  final ThemeData theme;
  final ColorScheme colorScheme;

  const _StatisticsSection({required this.theme, required this.colorScheme});

  @override
  Widget build(BuildContext context) {
    final stats = [
      ('0', 'Total Trips', Icons.card_travel_rounded),
      ('0', 'Upcoming', Icons.upcoming_rounded),
      ('0', 'Completed', Icons.check_circle_rounded),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Your Statistics',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 16),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: stats.asMap().entries.map((entry) {
              final isLast = entry.key == stats.length - 1;
              return Padding(
                padding: EdgeInsets.only(right: isLast ? 0 : 12),
                child: _StatisticCard(
                  value: entry.value.$1,
                  label: entry.value.$2,
                  icon: entry.value.$3,
                  theme: theme,
                  colorScheme: colorScheme,
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

/// Individual statistic card
class _StatisticCard extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final ThemeData theme;
  final ColorScheme colorScheme;

  const _StatisticCard({
    required this.value,
    required this.label,
    required this.icon,
    required this.theme,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: colorScheme.outlineVariant.withAlpha(76),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(8),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: colorScheme.primary, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: colorScheme.onSurface.withAlpha(166),
            ),
          ),
        ],
      ),
    );
  }
}

/// Recent activity section dengan placeholder
class _RecentActivitySection extends StatelessWidget {
  final ThemeData theme;
  final ColorScheme colorScheme;

  const _RecentActivitySection({
    required this.theme,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Activity',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: colorScheme.onSurface,
              ),
            ),
            Text(
              'See all',
              style: theme.textTheme.labelMedium?.copyWith(
                color: colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: colorScheme.outlineVariant.withAlpha(76)),
          ),
          child: Column(
            children: [
              Icon(
                Icons.history_rounded,
                color: colorScheme.primary.withAlpha(127),
                size: 40,
              ),
              const SizedBox(height: 12),
              Text(
                'No recent activity',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface.withAlpha(166),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Empty state CTA untuk membuat trip pertama
class _EmptyStateSection extends StatelessWidget {
  final ThemeData theme;
  final ColorScheme colorScheme;

  const _EmptyStateSection({required this.theme, required this.colorScheme});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colorScheme.secondary.withAlpha(20),
            colorScheme.secondary.withAlpha(31),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: colorScheme.secondary.withAlpha(51),
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          Icon(Icons.explore_rounded, color: colorScheme.secondary, size: 52),
          const SizedBox(height: 16),
          Text(
            'Start Your First Journey',
            textAlign: TextAlign.center,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Create your first trip and start planning your dream vacation today.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurface.withAlpha(166),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: colorScheme.secondary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onPressed: () {},
              child: Text(
                'Create Your First Trip',
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
