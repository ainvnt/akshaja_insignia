import 'package:akshaja_insignia/src/presentation/models/society_home_models.dart';
import 'package:akshaja_insignia/src/presentation/widgets/society_home/bottom_navigation_bar.dart';
import 'package:akshaja_insignia/src/presentation/widgets/society_home/mini_suggestion_row.dart';
import 'package:akshaja_insignia/src/presentation/widgets/society_home/notice_strip.dart';
import 'package:akshaja_insignia/src/presentation/widgets/society_home/promo_carousel.dart';
import 'package:akshaja_insignia/src/presentation/widgets/society_home/section_shell.dart';
import 'package:akshaja_insignia/src/presentation/widgets/society_home/shortcut_tabs.dart';
import 'package:akshaja_insignia/src/presentation/widgets/society_home/society_home_palette.dart';
import 'package:akshaja_insignia/src/presentation/widgets/society_home/top_header.dart';
import 'package:akshaja_insignia/src/presentation/widgets/society_home/visitors_panel.dart';
import 'package:akshaja_insignia/src/presentation/widgets/society_home/your_actions_strip.dart';
import 'package:flutter/material.dart';

class SocietyHomeScreen extends StatefulWidget {
  const SocietyHomeScreen({super.key});

  @override
  State<SocietyHomeScreen> createState() => _SocietyHomeScreenState();
}

class _SocietyHomeScreenState extends State<SocietyHomeScreen> {
  static const List<ShortcutTabData> _tabs = [
    ShortcutTabData('Visitors', Icons.cottage_rounded, true),
    ShortcutTabData('My Bills', Icons.account_balance_wallet_rounded, false),
    ShortcutTabData('Society', Icons.apartment_rounded, false),
    ShortcutTabData('Services', Icons.handyman_rounded, false),
  ];

  static const List<CircleActionData> _visitorActions = [
    CircleActionData('Pre-Approve', Icons.person_add_alt_1_rounded),
    CircleActionData('Daily Help', Icons.support_agent_rounded),
    CircleActionData('View All', Icons.north_east_rounded),
  ];

  static const List<QuickActionData> _quickActions = [
    QuickActionData(
      label: 'Home Cleaning',
      icon: Icons.cleaning_services_rounded,
      highlight: true,
    ),
    QuickActionData(label: 'Helpdesk', icon: Icons.support_agent_rounded),
    QuickActionData(label: 'Marketplace', icon: Icons.storefront_rounded),
    QuickActionData(label: 'Visit Pass', icon: Icons.badge_outlined),
  ];

  static const List<PromoCardData> _promos = [
    PromoCardData(
      title: 'Drive home 140 years of innovation.',
      subtitle: 'Own the Mercedes-Benz GLE today.',
      primary: Color(0xFF0B3459),
      secondary: Color(0xFF6F92B4),
      icon: Icons.directions_car_filled_rounded,
    ),
    PromoCardData(
      title: 'Zero pre-EMI for limited units.',
      subtitle: 'Hallmark living moments in Kondapur.',
      primary: Color(0xFF61C8F4),
      secondary: Color(0xFF2569D1),
      icon: Icons.location_city_rounded,
    ),
  ];

  static const List<BottomNavData> _bottomItems = [
    BottomNavData('My Hood', Icons.all_inclusive_rounded),
    BottomNavData('Society', Icons.groups_outlined),
    BottomNavData('Forum', Icons.chat_bubble_outline_rounded),
    BottomNavData('Services', Icons.handyman_outlined),
    BottomNavData('Homes', Icons.house_outlined),
  ];

  int _selectedBottomIndex = 0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: SocietyHomePalette.backgroundColor,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 18),
        child: SizedBox(
          width: 74,
          height: 74,
          child: FloatingActionButton(
            elevation: 4,
            backgroundColor: SocietyHomePalette.accentPink,
            foregroundColor: Colors.white,
            shape: const CircleBorder(),
            onPressed: () {},
            child: const Icon(Icons.add, size: 38),
          ),
        ),
      ),
      bottomNavigationBar: SocietyHomeBottomNavigationBar(
        items: _bottomItems,
        currentIndex: _selectedBottomIndex,
        onTap: (index) {
          setState(() {
            _selectedBottomIndex = index;
          });
        },
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(18, 12, 18, 140),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SocietyHomeTopHeader(),
              const SizedBox(height: 18),
              const SocietyHomeShortcutTabs(tabs: _tabs),
              const SizedBox(height: 16),
              const SocietyHomeVisitorsPanel(actions: _visitorActions),
              const SizedBox(height: 18),
              const SocietyHomeSectionShell(
                title: 'Your actions',
                titleSuffix: SocietyHomeEditBadge(),
                trailing: 'See all',
                child: SocietyHomeYourActionsStrip(actions: _quickActions),
              ),
              const SizedBox(height: 18),
              const SocietyHomePromoCarousel(promos: _promos),
              const SizedBox(height: 18),
              const SocietyHomeSectionShell(
                backgroundColor: SocietyHomePalette.softYellow,
                title: 'Society Notices',
                trailing: 'See all',
                child: SocietyHomeNoticeStrip(),
              ),
              const SizedBox(height: 12),
              Text(
                'Suggested for your block',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: SocietyHomePalette.primaryText,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 10),
              const SocietyHomeMiniSuggestionRow(),
            ],
          ),
        ),
      ),
    );
  }
}
