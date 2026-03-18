import 'package:flutter/material.dart';

class VisitorsDetailScreen extends StatefulWidget {
  const VisitorsDetailScreen({super.key});

  @override
  State<VisitorsDetailScreen> createState() => _VisitorsDetailScreenState();
}

class _VisitorsDetailScreenState extends State<VisitorsDetailScreen> {
  static const List<String> _tabs = [
    'Current',
    'Expected',
    'Past',
    'Packages',
    'Denied',
    'Group',
  ];

  int _selectedTabIndex = 0;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const Text('My Visitors'),
        elevation: 0,
        backgroundColor: colorScheme.surface,
      ),
      body: Column(
        children: [
          // Tab bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: colorScheme.outlineVariant, width: 1),
              ),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  for (int i = 0; i < _tabs.length; i++)
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedTabIndex = i;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: i == _selectedTabIndex
                                  ? colorScheme.primary
                                  : Colors.transparent,
                              width: 3,
                            ),
                          ),
                        ),
                        child: Text(
                          _tabs[i],
                          style: TextStyle(
                            color: i == _selectedTabIndex
                                ? colorScheme.primary
                                : colorScheme.onSurfaceVariant,
                            fontWeight: i == _selectedTabIndex
                                ? FontWeight.w700
                                : FontWeight.w500,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          // Tab content
          Expanded(child: _buildTabContent(_selectedTabIndex)),
        ],
      ),
    );
  }

  Widget _buildTabContent(int index) {
    final emptyState = _EmptyVisitorsState(tabName: _tabs[index]);
    return emptyState;
  }
}

class _EmptyVisitorsState extends StatelessWidget {
  const _EmptyVisitorsState({required this.tabName});

  final String tabName;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer.withValues(alpha: 0.3),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.person_outline,
                size: 100,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No Visitors',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              'No $tabName visitors found in your records.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: colorScheme.onSurfaceVariant,
                fontSize: 14,
              ),
            ),
            if (tabName == 'Current') ...[
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.person_add),
                label: const Text('Invite Visitors'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
