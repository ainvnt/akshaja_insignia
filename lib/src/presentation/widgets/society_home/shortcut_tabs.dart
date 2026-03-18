import 'package:akshaja_insignia/src/presentation/models/society_home_models.dart';
import 'package:akshaja_insignia/src/presentation/visitors_detail_screen.dart';
import 'package:akshaja_insignia/src/presentation/widgets/society_home/society_home_palette.dart';
import 'package:flutter/material.dart';

class SocietyHomeVisitorsSection extends StatelessWidget {
  const SocietyHomeVisitorsSection({
    super.key,
    required this.tabs,
    required this.selectedIndex,
    required this.onTabSelected,
    required this.actions,
    required this.promoText,
    required this.promoLeading,
    required this.promoGradient,
  });

  final List<ShortcutTabData> tabs;
  final int selectedIndex;
  final ValueChanged<int> onTabSelected;
  final List<CircleActionData> actions;
  final String promoText;
  final Widget promoLeading;
  final List<Color> promoGradient;

  @override
  Widget build(BuildContext context) {
    const gap = 10.0;
    const selectedTabHeight = 120.0;
    const panelTop = 88.0;

    return LayoutBuilder(
      builder: (context, constraints) {
        final tabWidth =
            (constraints.maxWidth - (gap * (tabs.length - 1))) / tabs.length;
        final selectedLeft = selectedIndex * (tabWidth + gap);

        return SizedBox(
          height: panelTop + 228,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                top: panelTop,
                left: 0,
                right: 0,
                child: _AttachedPanel(
                  actions: actions,
                  promoText: promoText,
                  promoLeading: promoLeading,
                  promoGradient: promoGradient,
                  onActionTap: (label) {
                    if (label == 'View All') {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => const VisitorsDetailScreen(),
                        ),
                      );
                    }
                  },
                ),
              ),
              Positioned(
                top: panelTop - 18,
                left: selectedLeft - 18,
                child: const _TabCurveCutout(),
              ),
              Positioned(
                top: panelTop - 18,
                left: selectedLeft + tabWidth - 18,
                child: const _TabCurveCutout(),
              ),
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (var i = 0; i < tabs.length; i++) ...[
                      SizedBox(
                        width: tabWidth,
                        child: i == selectedIndex
                            ? const SizedBox(height: selectedTabHeight)
                            : _TopTab(
                                data: tabs[i],
                                selected: false,
                                onTap: () => onTabSelected(i),
                              ),
                      ),
                      if (i < tabs.length - 1) const SizedBox(width: gap),
                    ],
                  ],
                ),
              ),
              Positioned(
                top: 0,
                left: selectedLeft,
                width: tabWidth,
                child: _TopTab(
                  data: tabs[selectedIndex],
                  selected: true,
                  onTap: () => onTabSelected(selectedIndex),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _TabCurveCutout extends StatelessWidget {
  const _TabCurveCutout();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      decoration: const BoxDecoration(
        color: SocietyHomePalette.backgroundColor,
        shape: BoxShape.circle,
      ),
    );
  }
}

class _TopTab extends StatelessWidget {
  const _TopTab({
    required this.data,
    required this.selected,
    required this.onTap,
  });

  final ShortcutTabData data;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final child = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 54,
          height: 54,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFFFEAA7), Color(0xFFFFB85A)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(18),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: Colors.orange.withValues(alpha: 0.14),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Icon(data.icon, size: 30, color: const Color(0xFFC95D0E)),
        ),
        const SizedBox(height: 10),
        Text(
          data.label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: SocietyHomePalette.primaryText,
            fontSize: 15,
            fontWeight: selected ? FontWeight.w800 : FontWeight.w500,
          ),
        ),
      ],
    );

    if (!selected) {
      return InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: Padding(padding: const EdgeInsets.only(top: 12), child: child),
      );
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(34),
          topRight: Radius.circular(34),
          bottomLeft: Radius.circular(22),
          bottomRight: Radius.circular(22),
        ),
        onTap: onTap,
        child: Container(
          height: 120,
          padding: const EdgeInsets.fromLTRB(8, 16, 8, 16),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(34),
              topRight: Radius.circular(34),
              bottomLeft: Radius.circular(22),
              bottomRight: Radius.circular(22),
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}

class _AttachedPanel extends StatelessWidget {
  const _AttachedPanel({
    required this.actions,
    required this.promoText,
    required this.promoLeading,
    required this.promoGradient,
    this.onActionTap,
  });

  final List<CircleActionData> actions;
  final String promoText;
  final Widget promoLeading;
  final List<Color> promoGradient;
  final ValueChanged<String>? onActionTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 22, 18, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: actions
                .map(
                  (action) => _ActionButton(
                    data: action,
                    onTap: () => onActionTap?.call(action.label),
                  ),
                )
                .toList(growable: false),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(colors: promoGradient),
            ),
            child: Row(
              children: [
                promoLeading,
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    promoText,
                    style: const TextStyle(
                      color: Color(0xFF3A3834),
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: Color(0xFF5A564F),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({required this.data, this.onTap});

  final CircleActionData data;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final backgroundShape = data.square ? BoxShape.rectangle : BoxShape.circle;

    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 94,
        child: Column(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 66,
                  height: 66,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF7F7F5),
                    shape: backgroundShape,
                    borderRadius: data.square
                        ? BorderRadius.circular(18)
                        : null,
                  ),
                  child: Icon(
                    data.icon,
                    size: 31,
                    color: const Color(0xFF8B8A88),
                  ),
                ),
                if (data.showAddBadge)
                  Positioned(
                    right: -2,
                    bottom: -2,
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: const BoxDecoration(
                        color: Color(0xFF56A996),
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
            const SizedBox(height: 12),
            Text(
              data.label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: SocietyHomePalette.primaryText,
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
