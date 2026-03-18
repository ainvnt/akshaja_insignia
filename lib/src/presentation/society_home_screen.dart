import 'package:akshaja_insignia/src/presentation/models/society_home_models.dart';
import 'package:akshaja_insignia/src/presentation/camera_capture_screen.dart';
import 'package:akshaja_insignia/src/presentation/home_screen.dart';
import 'package:akshaja_insignia/src/presentation/society_notices_screen.dart';
import 'package:akshaja_insignia/src/presentation/visitors_detail_screen.dart';
import 'package:akshaja_insignia/src/repositories/photo_repository.dart';
import 'package:akshaja_insignia/src/domain/photo_record.dart';
import 'package:flutter/material.dart';

class SocietyHomeScreen extends StatefulWidget {
  const SocietyHomeScreen({super.key, required this.repository});

  final PhotoRepository repository;

  @override
  State<SocietyHomeScreen> createState() => _SocietyHomeScreenState();
}

class _SocietyHomeScreenState extends State<SocietyHomeScreen> {
  static const Color _backgroundColor = Color(0xFFF6F1E8);
  static const Color _surfaceColor = Colors.white;
  static const Color _textPrimary = Color(0xFF312F2B);
  static const Color _textSecondary = Color(0xFF7E776F);
  static const Color _fabColor = Color(0xFFFF3369);

  static const List<_HomeSectionData> _sections = [
    _HomeSectionData(
      label: 'Visitors',
      icon: Icons.cottage_rounded,
      accent: Color(0xFFE98438),
      headline: 'Smooth visitor flow for Tower 206',
      subtitle: 'Track entries, pre-approve guests, and keep security updated.',
      statValue: '08',
      statLabel: 'Expected today',
      quickActions: [
        _HomeActionData(
          label: 'Pre-Approve',
          icon: Icons.person_add_alt_1_rounded,
          kind: _ActionKind.visitors,
        ),
        _HomeActionData(label: 'Daily Help', icon: Icons.support_agent_rounded),
        _HomeActionData(label: 'View All', icon: Icons.north_east_rounded),
      ],
      promoText: 'Open visitor dashboard',
      promoKind: _PromoKind.visitor,
    ),
    _HomeSectionData(
      label: 'My Bills',
      icon: Icons.account_balance_wallet_rounded,
      accent: Color(0xFFEEA72A),
      headline: 'Stay ahead of every due date',
      subtitle: 'Utilities, maintenance, and rent are organised in one place.',
      statValue: '03',
      statLabel: 'Pending bills',
      quickActions: [
        _HomeActionData(
          label: 'Maintenance',
          icon: Icons.handyman_outlined,
          square: true,
        ),
        _HomeActionData(
          label: 'Utility',
          icon: Icons.receipt_long_outlined,
          square: true,
        ),
        _HomeActionData(
          label: 'Pay Rent',
          icon: Icons.home_work_outlined,
          square: true,
        ),
      ],
      promoText: 'Post your property for FREE',
      promoKind: _PromoKind.offer,
    ),
    _HomeSectionData(
      label: 'Society',
      icon: Icons.apartment_rounded,
      accent: Color(0xFFF0A144),
      headline: 'Everything your block needs, close at hand',
      subtitle:
          'Directory, amenities, and society updates are ready to browse.',
      statValue: '12',
      statLabel: 'Fresh updates',
      quickActions: [
        _HomeActionData(
          label: 'Amenities',
          icon: Icons.pool_outlined,
          square: true,
        ),
        _HomeActionData(
          label: 'Directory',
          icon: Icons.contact_page_outlined,
          square: true,
        ),
        _HomeActionData(
          label: 'Security',
          icon: Icons.shield_outlined,
          square: true,
        ),
      ],
      promoText: 'Discover what is active in your tower',
      promoKind: _PromoKind.city,
    ),
    _HomeSectionData(
      label: 'Services',
      icon: Icons.handyman_rounded,
      accent: Color(0xFFE08247),
      headline: 'Book everyday services without the back and forth',
      subtitle: 'Cleaning, repairs, and support are bundled into one workflow.',
      statValue: '15m',
      statLabel: 'Average response',
      quickActions: [
        _HomeActionData(
          label: 'Cleaning',
          icon: Icons.cleaning_services_outlined,
          square: true,
        ),
        _HomeActionData(
          label: 'Repairs',
          icon: Icons.home_repair_service_outlined,
          square: true,
        ),
        _HomeActionData(
          label: 'Notices',
          icon: Icons.campaign_outlined,
          square: true,
        ),
      ],
      promoText: 'Book essential services in minutes',
      promoKind: _PromoKind.service,
    ),
  ];

  static const List<_ActionRailData> _actionRailItems = [
    _ActionRailData(
      'Home Cleaning',
      Icons.cleaning_services_rounded,
      featured: true,
    ),
    _ActionRailData('Directory', Icons.contact_page_outlined),
    _ActionRailData('Security', Icons.local_police_outlined),
    _ActionRailData('Notices', Icons.notifications_active_outlined),
    _ActionRailData('SOS', Icons.sos_rounded),
  ];

  static const List<_PromoCardData> _promotions = [
    _PromoCardData(
      title: 'Drive home innovation.',
      subtitle: 'Mercedes-Benz privileges for residents.',
      colors: [Color(0xFF0B4E7B), Color(0xFF2A7CB6)],
      icon: Icons.directions_car_filled_rounded,
    ),
    _PromoCardData(
      title: 'Limited units. Valid till 31st March.',
      subtitle: 'Premium residences in Kondapur.',
      colors: [Color(0xFF67D1F5), Color(0xFF2E74D2)],
      icon: Icons.location_city_rounded,
    ),
  ];

  static const List<SocietyNoticeData> _notices = [
    SocietyNoticeData(
      title: 'Rule the Roads',
      body: 'Live the Awesome Beat - the true king of SUVs.',
      timeLabel: '1d ago',
      fullBody:
          'Live the Awesome Beat - the true king of SUVs. This notice highlights the latest showcase campaign currently visible in the community feed. Residents are encouraged to review the promotional information carefully before responding to any external contact numbers or offers. If you are interested in the campaign, verify details directly with the official event or brand representative.\n\nPlease note that society management only provides display space for approved campaigns and does not guarantee pricing, inventory, or commercial terms. For questions related to permissions, display rules, or future advertising requests inside the community, contact the administration desk during office hours.',
    ),
    SocietyNoticeData(
      title: 'Clubhouse renewal',
      body: 'Annual facility access renewals start this Friday.',
      timeLabel: '2d ago',
      fullBody:
          'Annual facility access renewals start this Friday. Residents who use the clubhouse, gym, indoor games room, or multipurpose hall are requested to complete their renewal at the front office or through the society helpdesk once the billing link goes live.\n\nRenewals completed before the due date will ensure uninterrupted access. Please carry your flat details and registered mobile number when visiting the office. If your household details have changed, update them before submitting the renewal request so that access rights are mapped correctly. A detailed fee circular and schedule will be shared separately through the notice board and resident communication group.',
    ),
  ];

  static const List<_BottomNavData> _bottomNavItems = [
    _BottomNavData('My Hood', Icons.all_inclusive_rounded),
    _BottomNavData('Society', Icons.groups_outlined),
    _BottomNavData('Forum', Icons.chat_bubble_outline_rounded),
    _BottomNavData('Services', Icons.handyman_outlined),
    _BottomNavData('Homes', Icons.house_outlined),
  ];

  static const List<_ForumPostData> _forumPosts = [
    _ForumPostData(
      author: 'Block A Residents',
      title: 'Weekend farmers market near clubhouse',
      body:
          'Fresh produce stalls and local bakers will be available from 8 AM to 1 PM this Saturday.',
      replies: '18 replies',
    ),
    _ForumPostData(
      author: 'Security Desk',
      title: 'Late night delivery guidelines',
      body:
          'Please pre-approve deliveries after 10 PM so the gate team can clear them faster.',
      replies: '7 replies',
    ),
    _ForumPostData(
      author: 'Tower 2 Committee',
      title: 'Looking for badminton partners',
      body:
          'Residents interested in weekday evening games can reply to coordinate a regular slot.',
      replies: '24 replies',
    ),
  ];

  static const List<_ServiceItemData> _serviceItems = [
    _ServiceItemData(
      'Home Cleaning',
      Icons.cleaning_services_outlined,
      'Starts at Rs 499',
    ),
    _ServiceItemData(
      'Electrician',
      Icons.electrical_services_outlined,
      'Available in 20 min',
    ),
    _ServiceItemData(
      'Plumbing',
      Icons.plumbing_outlined,
      'Verified professionals',
    ),
    _ServiceItemData(
      'Appliance Repair',
      Icons.kitchen_outlined,
      'Doorstep support',
    ),
  ];

  static const List<_HomeListingData> _homeListings = [
    _HomeListingData(
      title: '2 BHK for Rent',
      subtitle: 'Tower C, 14th Floor',
      tag: 'Ready to move',
      price: 'Rs 32,000/mo',
    ),
    _HomeListingData(
      title: '3 BHK Resale',
      subtitle: 'Corner unit with lake view',
      tag: 'Owner listed',
      price: 'Rs 1.28 Cr',
    ),
  ];

  int _selectedSectionIndex = 0;
  int _selectedBottomIndex = 0;
  List<PhotoRecord> _incidentPhotos = const <PhotoRecord>[];
  Offset? _cameraButtonOffset;

  @override
  void initState() {
    super.initState();
    _loadIncidentPhotos();
  }

  @override
  Widget build(BuildContext context) {
    final section = _sections[_selectedSectionIndex];

    return Scaffold(
      backgroundColor: _backgroundColor,
      bottomNavigationBar: _BottomNavigationBar(
        items: _bottomNavItems,
        currentIndex: _selectedBottomIndex,
        onTap: (index) {
          setState(() {
            _selectedBottomIndex = index;
          });
        },
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final buttonOffset = _effectiveCameraButtonOffset(constraints);

            return Stack(
              children: [
                Positioned.fill(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(18, 12, 18, 140),
                    child: _buildCurrentPage(section),
                  ),
                ),
                Positioned(
                  left: buttonOffset.dx,
                  top: buttonOffset.dy,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onPanUpdate: (details) {
                      setState(() {
                        _cameraButtonOffset = _clampCameraOffset(
                          buttonOffset + details.delta,
                          constraints,
                        );
                      });
                    },
                    onTap: _openCameraCapture,
                    child: Container(
                      width: 56,
                      height: 56,
                      decoration: const BoxDecoration(
                        color: _fabColor,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Color(0x33000000),
                            blurRadius: 12,
                            offset: Offset(0, 6),
                          ),
                        ],
                      ),
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.camera_alt_rounded,
                        size: 34,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _handleSectionAction(_HomeActionData action) {
    if (action.kind == _ActionKind.visitors) {
      Navigator.of(context).push(
        MaterialPageRoute<void>(builder: (_) => const VisitorsDetailScreen()),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${action.label} is not wired yet.')),
    );
  }

  void _openNotices() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => SocietyNoticesScreen(notices: _notices),
      ),
    );
  }

  Widget _buildCurrentPage(_HomeSectionData section) {
    switch (_selectedBottomIndex) {
      case 0:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _TopHeader(),
            const SizedBox(height: 18),
            _HeroCard(data: section),
            const SizedBox(height: 18),
            _SectionSwitcher(
              sections: _sections,
              selectedIndex: _selectedSectionIndex,
              onSelect: (index) {
                setState(() {
                  _selectedSectionIndex = index;
                });
              },
            ),
            const SizedBox(height: 18),
            _ContextBoard(section: section, onActionTap: _handleSectionAction),
            const SizedBox(height: 18),
            const _InfoStrip(),
            const SizedBox(height: 18),
            const _SectionCard(
              title: 'Your actions',
              trailing: 'See all',
              badge: 'Fresh',
              child: _ActionRail(items: _actionRailItems),
            ),
            const SizedBox(height: 18),
            _IncidentSection(
              photos: _incidentPhotos,
              onOpen: _openIncidentScreen,
            ),
            const SizedBox(height: 18),
            _PromoGallery(cards: _promotions),
            const SizedBox(height: 18),
            _NoticeSection(notices: _notices, onOpenAll: _openNotices),
          ],
        );
      case 1:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _TopHeader(),
            const SizedBox(height: 18),
            const _PageBanner(
              title: 'Society',
              subtitle:
                  'Community essentials, updates, and management access in one place.',
              colors: [Color(0xFF1F3A49), Color(0xFF3D6882)],
            ),
            const SizedBox(height: 18),
            const _InfoStrip(),
            const SizedBox(height: 18),
            const _SectionCard(
              title: 'Community Desk',
              trailing: 'Open',
              child: _SocietyFeatureGrid(),
            ),
            const SizedBox(height: 18),
            _NoticeSection(notices: _notices, onOpenAll: _openNotices),
          ],
        );
      case 2:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _TopHeader(),
            const SizedBox(height: 18),
            const _PageBanner(
              title: 'Forum',
              subtitle:
                  'Resident conversations, coordination, and quick community threads.',
              colors: [Color(0xFF32244F), Color(0xFF6756A4)],
            ),
            const SizedBox(height: 18),
            const _SectionCard(
              title: 'Trending Discussions',
              trailing: 'Latest',
              child: _ForumList(items: _forumPosts),
            ),
          ],
        );
      case 3:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _TopHeader(),
            const SizedBox(height: 18),
            const _PageBanner(
              title: 'Services',
              subtitle:
                  'Book trusted home services with faster resident turnaround times.',
              colors: [Color(0xFF4E321D), Color(0xFFB46A34)],
            ),
            const SizedBox(height: 18),
            const _SectionCard(
              title: 'Available Services',
              trailing: 'Book now',
              child: _ServicesGrid(items: _serviceItems),
            ),
            const SizedBox(height: 18),
            _PromoGallery(cards: _promotions),
          ],
        );
      case 4:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _TopHeader(),
            const SizedBox(height: 18),
            const _PageBanner(
              title: 'Homes',
              subtitle:
                  'Explore listings, rentals, and owner-posted opportunities in your community.',
              colors: [Color(0xFF1E4C3E), Color(0xFF4F8C72)],
            ),
            const SizedBox(height: 18),
            const _SectionCard(
              title: 'Featured Listings',
              trailing: 'Browse',
              child: _HomesList(items: _homeListings),
            ),
          ],
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Future<void> _openCameraCapture() async {
    final saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => CameraCaptureScreen(repository: widget.repository),
      ),
    );

    if (saved == true) {
      await _loadIncidentPhotos();
    }
  }

  Future<void> _openIncidentScreen() async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => HomeScreen(repository: widget.repository),
      ),
    );

    await _loadIncidentPhotos();
  }

  Future<void> _loadIncidentPhotos() async {
    final records = await widget.repository.getAllPhotos();
    if (!mounted) {
      return;
    }
    setState(() {
      _incidentPhotos = records;
    });
  }

  Offset _effectiveCameraButtonOffset(BoxConstraints constraints) {
    final fallback = Offset(
      constraints.maxWidth - 72 - 18,
      constraints.maxHeight - 72 - 28,
    );

    return _clampCameraOffset(_cameraButtonOffset ?? fallback, constraints);
  }

  Offset _clampCameraOffset(Offset candidate, BoxConstraints constraints) {
    const minInset = 8.0;
    const buttonSize = 56.0;
    final maxX = constraints.maxWidth - buttonSize - minInset;
    final maxY = constraints.maxHeight - buttonSize - minInset;

    return Offset(
      candidate.dx.clamp(minInset, maxX),
      candidate.dy.clamp(minInset, maxY),
    );
  }
}

class _TopHeader extends StatelessWidget {
  const _TopHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(
            Icons.person_outline_rounded,
            color: Color(0xFFC6C1B8),
          ),
        ),
        const SizedBox(width: 12),
        const Text(
          '...206',
          style: TextStyle(
            color: _SocietyHomeScreenState._textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(width: 4),
        const Icon(
          Icons.keyboard_arrow_down_rounded,
          color: _SocietyHomeScreenState._textPrimary,
        ),
        const SizedBox(width: 12),
        const Expanded(child: _LocationPill()),
        const SizedBox(width: 10),
        const Icon(
          Icons.search_rounded,
          size: 34,
          color: _SocietyHomeScreenState._textPrimary,
        ),
        const SizedBox(width: 10),
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [Color(0xFFFFD63A), Color(0xFFFF8D14)],
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.orange.withValues(alpha: 0.2),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Center(
            child: Text(
              'N',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _LocationPill extends StatelessWidget {
  const _LocationPill();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 46,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE6DFD4)),
      ),
      child: const Row(
        children: [
          CircleAvatar(
            radius: 15,
            backgroundColor: Color(0xFFE8F0FF),
            child: Icon(
              Icons.location_on_rounded,
              size: 22,
              color: Color(0xFF286EEB),
            ),
          ),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'ifting Horizon',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Color(0xFF726A60),
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFFB5AE9F)),
        ],
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({required this.data});

  final _HomeSectionData data;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(34),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1C2035), Color(0xFF28334F), Color(0xFF4A536F)],
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x220A0A10),
            blurRadius: 30,
            offset: Offset(0, 16),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _StatusChip(
                color: data.accent,
                icon: data.icon,
                label: data.label,
              ),
              const Spacer(),
              const _WeatherBadge(),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            data.headline,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.w900,
              height: 1.02,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            data.subtitle,
            style: const TextStyle(
              color: Color(0xFFD2D6E4),
              fontSize: 15,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _MetricTile(
                  title: data.statValue,
                  subtitle: data.statLabel,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: _MetricTile(title: '27°', subtitle: 'Cloudy evening'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PageBanner extends StatelessWidget {
  const _PageBanner({
    required this.title,
    required this.subtitle,
    required this.colors,
  });

  final String title;
  final String subtitle;
  final List<Color> colors;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        gradient: LinearGradient(colors: colors),
        boxShadow: const [
          BoxShadow(
            color: Color(0x220A0A10),
            blurRadius: 26,
            offset: Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            subtitle,
            style: const TextStyle(
              color: Color(0xFFE3E6EF),
              fontSize: 15,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionSwitcher extends StatelessWidget {
  const _SectionSwitcher({
    required this.sections,
    required this.selectedIndex,
    required this.onSelect,
  });

  final List<_HomeSectionData> sections;
  final int selectedIndex;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 108,
      child: Row(
        children: [
          for (var i = 0; i < sections.length; i++) ...[
            Expanded(
              child: _SectionTab(
                data: sections[i],
                selected: i == selectedIndex,
                onTap: () => onSelect(i),
              ),
            ),
            if (i < sections.length - 1) const SizedBox(width: 10),
          ],
        ],
      ),
    );
  }
}

class _ContextBoard extends StatelessWidget {
  const _ContextBoard({required this.section, required this.onActionTap});

  final _HomeSectionData section;
  final ValueChanged<_HomeActionData> onActionTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 14),
      decoration: BoxDecoration(
        color: _SocietyHomeScreenState._surfaceColor,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '${section.label} hub',
                style: const TextStyle(
                  color: _SocietyHomeScreenState._textPrimary,
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const Spacer(),
              Text(
                'See all',
                style: TextStyle(
                  color: _SocietyHomeScreenState._textSecondary,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: section.quickActions
                .map(
                  (action) => _ActionCard(
                    data: action,
                    accent: section.accent,
                    onTap: () => onActionTap(action),
                  ),
                )
                .toList(growable: false),
          ),
          const SizedBox(height: 16),
          _PromoBanner(text: section.promoText, kind: section.promoKind),
        ],
      ),
    );
  }
}

class _InfoStrip extends StatelessWidget {
  const _InfoStrip();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: const [
        Expanded(
          child: _SmallInfoCard(
            title: 'Today in your block',
            subtitle: '3 notices, 8 deliveries, 2 events',
            color: Color(0xFFFDF7E5),
            icon: Icons.light_mode_outlined,
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: _SmallInfoCard(
            title: 'Community pulse',
            subtitle: 'Water 100%, Power stable, Lift OK',
            color: Color(0xFFEFF7F0),
            icon: Icons.favorite_border_rounded,
          ),
        ),
      ],
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.trailing,
    required this.child,
    this.badge,
  });

  final String title;
  final String trailing;
  final Widget child;
  final String? badge;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 20),
      decoration: BoxDecoration(
        color: _SocietyHomeScreenState._surfaceColor,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: _SocietyHomeScreenState._textPrimary,
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                ),
              ),
              if (badge != null) ...[
                const SizedBox(width: 10),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE74747),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    badge!,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
              const Spacer(),
              Text(
                trailing,
                style: const TextStyle(
                  color: _SocietyHomeScreenState._textSecondary,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _ActionRail extends StatelessWidget {
  const _ActionRail({required this.items});

  final List<_ActionRailData> items;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 154,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (_, _) => const SizedBox(width: 14),
        itemBuilder: (context, index) => _ActionRailCard(data: items[index]),
      ),
    );
  }
}

class _IncidentSection extends StatelessWidget {
  const _IncidentSection({required this.photos, required this.onOpen});

  final List<PhotoRecord> photos;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final uploadedCount = photos
        .where((photo) => photo.uploadStatus == UploadStatus.uploaded)
        .length;
    final pendingCount = photos
        .where((photo) => photo.uploadStatus == UploadStatus.pending)
        .length;
    final latestPhoto = photos.isEmpty
        ? null
        : (photos.toList()
                ..sort((a, b) => b.capturedAt.compareTo(a.capturedAt)))
              .first;
    final latestLabel = latestPhoto == null
        ? 'No incidents captured yet'
        : 'Latest capture ${_formatCapturedAt(latestPhoto.capturedAt)}';

    return _SectionCard(
      title: 'Incident Capture',
      trailing: 'Open',
      badge: photos.isEmpty ? 'New' : null,
      child: Material(
        color: const Color(0xFFF8F5EF),
        borderRadius: BorderRadius.circular(28),
        child: InkWell(
          borderRadius: BorderRadius.circular(28),
          onTap: onOpen,
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFE9DE),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: const Icon(
                        Icons.camera_outdoor_rounded,
                        color: Color(0xFFE96B4C),
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Incident gallery',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: _SocietyHomeScreenState._textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            latestLabel,
                            style: const TextStyle(
                              color: _SocietyHomeScreenState._textSecondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.arrow_forward_rounded,
                      color: _SocietyHomeScreenState._textSecondary,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text(
                  'Open the dedicated incident screen for folders, uploads, and camera capture.',
                  style: TextStyle(
                    color: _SocietyHomeScreenState._textSecondary,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _IncidentMetricChip(
                        value: photos.length.toString(),
                        label: 'Total',
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _IncidentMetricChip(
                        value: uploadedCount.toString(),
                        label: 'Uploaded',
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _IncidentMetricChip(
                        value: pendingCount.toString(),
                        label: 'Pending',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static String _formatCapturedAt(DateTime capturedAt) {
    final local = capturedAt.toLocal();
    final hour = local.hour % 12 == 0 ? 12 : local.hour % 12;
    final minute = local.minute.toString().padLeft(2, '0');
    final suffix = local.hour >= 12 ? 'PM' : 'AM';
    return '${local.day}/${local.month}/${local.year} at $hour:$minute $suffix';
  }
}

class _IncidentMetricChip extends StatelessWidget {
  const _IncidentMetricChip({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: _SocietyHomeScreenState._textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: _SocietyHomeScreenState._textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _PromoGallery extends StatelessWidget {
  const _PromoGallery({required this.cards});

  final List<_PromoCardData> cards;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 188,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: cards.length,
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemBuilder: (context, index) => _PromoCard(data: cards[index]),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            _Dot(active: true, wide: true),
            _Dot(active: false),
            _Dot(active: false),
            _Dot(active: false),
          ],
        ),
      ],
    );
  }
}

class _NoticeSection extends StatelessWidget {
  const _NoticeSection({required this.notices, required this.onOpenAll});

  final List<SocietyNoticeData> notices;
  final VoidCallback onOpenAll;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 20),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7D7),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Text(
                'Society Notices',
                style: TextStyle(
                  color: _SocietyHomeScreenState._textPrimary,
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const Spacer(),
              InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: onOpenAll,
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  child: Text(
                    'See all',
                    style: TextStyle(
                      color: _SocietyHomeScreenState._textSecondary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          for (var i = 0; i < notices.length; i++) ...[
            _NoticeCard(data: notices[i], onTap: onOpenAll),
            if (i < notices.length - 1) const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }
}

class _SocietyFeatureGrid extends StatelessWidget {
  const _SocietyFeatureGrid();

  @override
  Widget build(BuildContext context) {
    const items = [
      _MiniTileData('Amenities', Icons.pool_outlined),
      _MiniTileData('Directory', Icons.contact_page_outlined),
      _MiniTileData('Security', Icons.shield_outlined),
      _MiniTileData('Payments', Icons.receipt_long_outlined),
    ];

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: items
          .map((item) => SizedBox(width: 140, child: _MiniTile(data: item)))
          .toList(growable: false),
    );
  }
}

class _ForumList extends StatelessWidget {
  const _ForumList({required this.items});

  final List<_ForumPostData> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < items.length; i++) ...[
          _ForumCard(data: items[i]),
          if (i < items.length - 1) const SizedBox(height: 12),
        ],
      ],
    );
  }
}

class _ServicesGrid extends StatelessWidget {
  const _ServicesGrid({required this.items});

  final List<_ServiceItemData> items;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: items
          .map((item) => SizedBox(width: 140, child: _ServiceTile(data: item)))
          .toList(growable: false),
    );
  }
}

class _HomesList extends StatelessWidget {
  const _HomesList({required this.items});

  final List<_HomeListingData> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < items.length; i++) ...[
          _HomeListingCard(data: items[i]),
          if (i < items.length - 1) const SizedBox(height: 12),
        ],
      ],
    );
  }
}

class _SectionTab extends StatelessWidget {
  const _SectionTab({
    required this.data,
    required this.selected,
    required this.onTap,
  });

  final _HomeSectionData data;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(26),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          padding: EdgeInsets.fromLTRB(8, selected ? 12 : 8, 8, 12),
          decoration: BoxDecoration(
            color: selected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(26),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ]
                : null,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: data.accent.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Icon(data.icon, color: data.accent, size: 28),
              ),
              const SizedBox(height: 8),
              Text(
                data.label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _SocietyHomeScreenState._textPrimary,
                  fontSize: 15,
                  fontWeight: selected ? FontWeight.w800 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.data,
    required this.accent,
    required this.onTap,
  });

  final _HomeActionData data;
  final Color accent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 92,
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: Column(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 66,
                  height: 66,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F5F3),
                    shape: data.square ? BoxShape.rectangle : BoxShape.circle,
                    borderRadius: data.square
                        ? BorderRadius.circular(20)
                        : null,
                  ),
                  child: Icon(data.icon, color: accent, size: 30),
                ),
                if (!data.square)
                  Positioned(
                    right: -2,
                    bottom: -2,
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: accent.withValues(alpha: 0.9),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.add,
                        size: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              data.label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: _SocietyHomeScreenState._textPrimary,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniTile extends StatelessWidget {
  const _MiniTile({required this.data});

  final _MiniTileData data;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F5EF),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(data.icon, color: const Color(0xFF5B554B)),
          ),
          const SizedBox(height: 12),
          Text(
            data.label,
            style: const TextStyle(
              color: _SocietyHomeScreenState._textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _ForumCard extends StatelessWidget {
  const _ForumCard({required this.data});

  final _ForumPostData data;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F5EF),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            data.author,
            style: const TextStyle(
              color: _SocietyHomeScreenState._textSecondary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            data.title,
            style: const TextStyle(
              color: _SocietyHomeScreenState._textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            data.body,
            style: const TextStyle(
              color: _SocietyHomeScreenState._textSecondary,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            data.replies,
            style: const TextStyle(
              color: Color(0xFF5B4EA2),
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _ServiceTile extends StatelessWidget {
  const _ServiceTile({required this.data});

  final _ServiceItemData data;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F5EF),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(data.icon, color: const Color(0xFF8C5A1F)),
          ),
          const SizedBox(height: 12),
          Text(
            data.label,
            style: const TextStyle(
              color: _SocietyHomeScreenState._textPrimary,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            data.meta,
            style: const TextStyle(
              color: _SocietyHomeScreenState._textSecondary,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

class _HomeListingCard extends StatelessWidget {
  const _HomeListingCard({required this.data});

  final _HomeListingData data;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F5EF),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(
              Icons.home_work_rounded,
              color: Color(0xFF4A8A72),
              size: 34,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.title,
                  style: const TextStyle(
                    color: _SocietyHomeScreenState._textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  data.subtitle,
                  style: const TextStyle(
                    color: _SocietyHomeScreenState._textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    data.tag,
                    style: const TextStyle(
                      color: Color(0xFF4A8A72),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            data.price,
            style: const TextStyle(
              color: _SocietyHomeScreenState._textPrimary,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _PromoBanner extends StatelessWidget {
  const _PromoBanner({required this.text, required this.kind});

  final String text;
  final _PromoKind kind;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: LinearGradient(colors: kind.colors),
      ),
      child: Row(
        children: [
          _PromoLead(kind: kind),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: _SocietyHomeScreenState._textPrimary,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: Color(0xFF5A564F)),
        ],
      ),
    );
  }
}

class _PromoLead extends StatelessWidget {
  const _PromoLead({required this.kind});

  final _PromoKind kind;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 72,
      height: 34,
      decoration: BoxDecoration(
        color: kind.leadBackground,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Center(child: Icon(kind.icon, color: kind.iconColor, size: 22)),
    );
  }
}

class _SmallInfoCard extends StatelessWidget {
  const _SmallInfoCard({
    required this.title,
    required this.subtitle,
    required this.color,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _SocietyHomeScreenState._surfaceColor,
        borderRadius: BorderRadius.circular(26),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: _SocietyHomeScreenState._textPrimary),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              color: _SocietyHomeScreenState._textPrimary,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(
              color: _SocietyHomeScreenState._textSecondary,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionRailCard extends StatelessWidget {
  const _ActionRailCard({required this.data});

  final _ActionRailData data;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: data.featured ? 190 : 108,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 96,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              gradient: data.featured
                  ? const LinearGradient(
                      colors: [Color(0xFF57C6F1), Color(0xFF254E8C)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    )
                  : const LinearGradient(
                      colors: [Color(0xFFFFFEFD), Color(0xFFF4F1EC)],
                    ),
              border: data.featured
                  ? null
                  : Border.all(color: const Color(0xFFEDE8E0)),
            ),
            child: Center(
              child: Icon(
                data.icon,
                color: data.featured ? Colors.white : const Color(0xFF6A6760),
                size: data.featured ? 42 : 34,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            data.label,
            style: const TextStyle(
              color: _SocietyHomeScreenState._textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _PromoCard extends StatelessWidget {
  const _PromoCard({required this.data});

  final _PromoCardData data;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 292,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(colors: data.colors),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            data.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w900,
              height: 1.02,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            data.subtitle,
            style: const TextStyle(color: Color(0xFFD9E6F4), fontSize: 14),
          ),
          const Spacer(),
          Align(
            alignment: Alignment.bottomRight,
            child: Icon(data.icon, size: 44, color: Colors.white),
          ),
        ],
      ),
    );
  }
}

class _NoticeCard extends StatelessWidget {
  const _NoticeCard({required this.data, required this.onTap});

  final SocietyNoticeData data;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Ink(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Row(
            children: [
              Container(
                width: 92,
                height: 76,
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF1FF),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Icon(
                  Icons.directions_car_filled_rounded,
                  color: Color(0xFF4067B3),
                  size: 34,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.circle,
                          color: Color(0xFFFF4862),
                          size: 10,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            data.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: _SocietyHomeScreenState._textPrimary,
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          data.timeLabel,
                          style: const TextStyle(
                            color: _SocietyHomeScreenState._textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      data.body,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: _SocietyHomeScreenState._textSecondary,
                        fontSize: 15,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({
    required this.color,
    required this.icon,
    required this.label,
  });

  final Color color;
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 26,
            height: 26,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            child: Icon(icon, size: 16, color: Colors.white),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _WeatherBadge extends StatelessWidget {
  const _WeatherBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(18),
      ),
      child: const Text(
        'Windy 27°',
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(color: Color(0xFFD3D9E7), fontSize: 13),
          ),
        ],
      ),
    );
  }
}

class _BottomNavigationBar extends StatelessWidget {
  const _BottomNavigationBar({
    required this.items,
    required this.currentIndex,
    required this.onTap,
  });

  final List<_BottomNavData> items;
  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      padding: const EdgeInsets.fromLTRB(10, 12, 10, 18),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            for (var i = 0; i < items.length; i++)
              InkWell(
                borderRadius: BorderRadius.circular(18),
                onTap: () => onTap(i),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        items[i].icon,
                        color: i == currentIndex
                            ? _SocietyHomeScreenState._fabColor
                            : Colors.black,
                        size: 30,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        items[i].label,
                        style: TextStyle(
                          color: i == currentIndex
                              ? _SocietyHomeScreenState._fabColor
                              : Colors.black,
                          fontSize: 13,
                          fontWeight: i == currentIndex
                              ? FontWeight.w800
                              : FontWeight.w500,
                        ),
                      ),
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

class _Dot extends StatelessWidget {
  const _Dot({required this.active, this.wide = false});

  final bool active;
  final bool wide;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: wide ? 34 : 8,
      height: 8,
      margin: const EdgeInsets.symmetric(horizontal: 3),
      decoration: BoxDecoration(
        color: active ? const Color(0xFF8A7E65) : const Color(0xFFD9D1C6),
        borderRadius: BorderRadius.circular(99),
      ),
    );
  }
}

class _HomeSectionData {
  const _HomeSectionData({
    required this.label,
    required this.icon,
    required this.accent,
    required this.headline,
    required this.subtitle,
    required this.statValue,
    required this.statLabel,
    required this.quickActions,
    required this.promoText,
    required this.promoKind,
  });

  final String label;
  final IconData icon;
  final Color accent;
  final String headline;
  final String subtitle;
  final String statValue;
  final String statLabel;
  final List<_HomeActionData> quickActions;
  final String promoText;
  final _PromoKind promoKind;
}

class _HomeActionData {
  const _HomeActionData({
    required this.label,
    required this.icon,
    this.kind = _ActionKind.none,
    this.square = false,
  });

  final String label;
  final IconData icon;
  final _ActionKind kind;
  final bool square;
}

class _ActionRailData {
  const _ActionRailData(this.label, this.icon, {this.featured = false});

  final String label;
  final IconData icon;
  final bool featured;
}

class _MiniTileData {
  const _MiniTileData(this.label, this.icon);

  final String label;
  final IconData icon;
}

class _ForumPostData {
  const _ForumPostData({
    required this.author,
    required this.title,
    required this.body,
    required this.replies,
  });

  final String author;
  final String title;
  final String body;
  final String replies;
}

class _ServiceItemData {
  const _ServiceItemData(this.label, this.icon, this.meta);

  final String label;
  final IconData icon;
  final String meta;
}

class _HomeListingData {
  const _HomeListingData({
    required this.title,
    required this.subtitle,
    required this.tag,
    required this.price,
  });

  final String title;
  final String subtitle;
  final String tag;
  final String price;
}

class _PromoCardData {
  const _PromoCardData({
    required this.title,
    required this.subtitle,
    required this.colors,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final List<Color> colors;
  final IconData icon;
}

class _BottomNavData {
  const _BottomNavData(this.label, this.icon);

  final String label;
  final IconData icon;
}

enum _ActionKind { none, visitors }

enum _PromoKind {
  visitor(
    [Color(0xFFFDFDFD), Color(0xFFEAE7E1)],
    Color(0xFF3B3B43),
    Icons.directions_car_filled_rounded,
    Colors.white,
  ),
  offer(
    [Color(0xFFFFF6F6), Color(0xFFFBE0E3)],
    Color(0xFFFFF0F0),
    Icons.percent_rounded,
    Color(0xFFFF5470),
  ),
  city(
    [Color(0xFFF9FBFF), Color(0xFFE8F0FF)],
    Color(0xFFEAF1FF),
    Icons.location_city_rounded,
    Color(0xFF4F78D6),
  ),
  service(
    [Color(0xFFFFFBF2), Color(0xFFF8E9D1)],
    Color(0xFFFFF3E3),
    Icons.home_repair_service_rounded,
    Color(0xFFD1801F),
  );

  const _PromoKind(this.colors, this.leadBackground, this.icon, this.iconColor);

  final List<Color> colors;
  final Color leadBackground;
  final IconData icon;
  final Color iconColor;
}
