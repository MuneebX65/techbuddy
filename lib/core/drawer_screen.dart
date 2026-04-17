import 'package:flutter/material.dart';
import 'package:techbuddy/core/constants.dart';
import 'package:techbuddy/services/app_preferences.dart';
import 'package:techbuddy/screens/ChatScreen/chat_screen.dart';
import 'package:techbuddy/screens/HomeScreen/home_screen.dart';
import 'package:techbuddy/screens/LessonScreen/lessons_screen.dart';
import 'package:techbuddy/screens/Scam_Screen/scam_screen.dart';

class DrawerScreen extends StatefulWidget {
  const DrawerScreen({super.key});

  @override
  State<DrawerScreen> createState() => _DrawerScreenState();
}

class _DrawerScreenState extends State<DrawerScreen>
    with SingleTickerProviderStateMixin {
  static const double _collapsedWidth = 84;
  static const double _expandedWidth = 220;

  int _selectedIndex = 0;
  int? _hoveredIndex;

  late final AnimationController _menuController;
  late final Animation<double> _widthAnimation;

  late final List<_NavItem> _navItems;

  @override
  void initState() {
    super.initState();
    _menuController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 260),
    );
    _widthAnimation = Tween<double>(begin: _collapsedWidth, end: _expandedWidth)
        .animate(
          CurvedAnimation(
            parent: _menuController,
            curve: Curves.easeOutCubic,
            reverseCurve: Curves.easeInCubic,
          ),
        );
    // Start with drawer expanded by default
    _menuController.forward();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkFirstTimeSetup();
    });

    _navItems = [
      _NavItem(icon: Icons.home, label: 'Home', screen: const HomeScreen()),
      _NavItem(
        icon: Icons.menu_book,
        label: 'Lessons',
        screen: LessonsScreen(onBackRequested: _goToHome),
      ),
      _NavItem(
        icon: Icons.chat_bubble_outline,
        label: 'Chat',
        screen: const ChatScreen(),
      ),
      _NavItem(
        icon: Icons.warning_amber_rounded,
        label: 'Scam Identifier',
        screen: ScamScreen(onBackRequested: _goToHome),
      ),
    ];

    _restoreSelectedPage();
  }

  @override
  void dispose() {
    _menuController.dispose();
    super.dispose();
  }

  void _goToHome() {
    setState(() {
      _selectedIndex = 0;
    });
    AppPreferences.saveSelectedPageIndex(0);
  }

  Future<void> _restoreSelectedPage() async {
    final savedIndex = await AppPreferences.getSelectedPageIndex();
    if (!mounted || savedIndex >= _navItems.length) {
      return;
    }
    setState(() {
      _selectedIndex = savedIndex;
    });
  }

  Future<void> _checkFirstTimeSetup() async {
    final firstTime = await AppPreferences.isFirstTimeOpening();
    if (!mounted || !firstTime) {
      return;
    }
    await _showFirstTimeProfileDialog();
  }

  Future<void> _showFirstTimeProfileDialog() async {
    final nameController = TextEditingController();
    final ageController = TextEditingController();

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return PopScope(
          canPop: false,
          child: AlertDialog(
            backgroundColor: AppColors.cardBg,
            surfaceTintColor: AppColors.cardBg,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(22),
            ),
            titlePadding: const EdgeInsets.fromLTRB(24, 22, 24, 4),
            contentPadding: const EdgeInsets.fromLTRB(24, 6, 24, 10),
            actionsPadding: const EdgeInsets.fromLTRB(24, 4, 24, 22),
            title: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF1B6B4A), Color(0xFF5DD49A)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.auto_awesome_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Let us personalize TechBuddy',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark,
                    ),
                  ),
                ),
              ],
            ),
            content: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Share your details once so your assistant feels truly yours.',
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.45,
                        color: AppColors.textMuted,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: nameController,
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                        labelText: 'Your name',
                        hintText: 'e.g. Muneeb',
                        prefixIcon: const Icon(
                          Icons.person_outline,
                          color: AppColors.primary,
                        ),
                        filled: true,
                        fillColor: const Color(0xFFF8FCFA),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(
                            color: AppColors.primary.withOpacity(0.18),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(
                            color: AppColors.primary.withOpacity(0.18),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(
                            color: AppColors.primary,
                            width: 1.6,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: ageController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Your age',
                        hintText: 'e.g. 65',
                        prefixIcon: const Icon(
                          Icons.cake_outlined,
                          color: AppColors.primary,
                        ),
                        filled: true,
                        fillColor: const Color(0xFFF8FCFA),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(
                            color: AppColors.primary.withOpacity(0.18),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(
                            color: AppColors.primary.withOpacity(0.18),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(
                            color: AppColors.primary,
                            width: 1.6,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final name = nameController.text.trim();
                    final age = int.tryParse(ageController.text.trim());
                    if (name.isEmpty || age == null || age <= 0) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please enter a valid name and age.'),
                        ),
                      );
                      return;
                    }

                    await AppPreferences.saveUserProfile(name: name, age: age);
                    if (!mounted) return;
                    Navigator.of(dialogContext).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  icon: const Icon(Icons.rocket_launch_outlined, size: 20),
                  label: const Text(
                    'Continue to TechBuddy',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );

    nameController.dispose();
    ageController.dispose();
  }

  Widget _sidebarItem({
    required IconData icon,
    required String label,
    required int index,
    required bool isExpanded,
    required VoidCallback onTap,
  }) {
    final isSelected = _selectedIndex == index;
    final isHovered = _hoveredIndex == index;
    final selectedSurface =
        Color.lerp(AppColors.cardBg, AppColors.light, 0.42) ??
        AppColors.successBg;
    final hoverSurface =
        Color.lerp(AppColors.cardBg, AppColors.light, 0.26) ??
        AppColors.successBg;
    final itemColor = isSelected || isHovered
        ? AppColors.primary
        : AppColors.textMuted;
    final backgroundColor = isSelected
        ? selectedSurface
        : isHovered
        ? hoverSurface
        : Colors.transparent;
    final elevation = isSelected
        ? 6.0
        : isHovered
        ? 4.0
        : 0.0;
    final translateY = isSelected
        ? -2.0
        : isHovered
        ? -1.0
        : 0.0;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) {
        setState(() {
          _hoveredIndex = index;
        });
      },
      onExit: (_) {
        if (_hoveredIndex == index) {
          setState(() {
            _hoveredIndex = null;
          });
        }
      },
      child: AnimatedScale(
        scale: isSelected
            ? 1.0
            : isHovered
            ? 1.02
            : 1.0,
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          transform: Matrix4.translationValues(0, translateY, 0),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected || isHovered
                  ? Colors.black12
                  : Colors.transparent,
            ),
            boxShadow: elevation > 0
                ? [
                    BoxShadow(
                      color: AppColors.light.withOpacity(0.28),
                      blurRadius: elevation * 2.0,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : const [],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: onTap,
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isExpanded ? 12 : 8,
                  vertical: isExpanded ? 10 : 12,
                ),
                child: isExpanded
                    ? Row(
                        children: [
                          Icon(icon, color: itemColor),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              label,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: itemColor,
                              ),
                            ),
                          ),
                        ],
                      )
                    : Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(icon, color: itemColor, size: 28),
                          const SizedBox(height: 4),
                          Text(
                            label,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w600,
                              color: itemColor,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _sidebarToggleItem({required bool isExpanded}) {
    final color = Colors.black54;

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () {
        if (_menuController.status == AnimationStatus.completed) {
          _menuController.reverse();
        } else {
          _menuController.forward();
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        child: isExpanded
            ? Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.menu, color: color),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Menu',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: color,
                        ),
                      ),
                    ),
                  ],
                ),
              )
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.menu, color: Colors.black54, size: 28),
                  SizedBox(height: 4),
                  Text(
                    'Menu',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w500,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _drawerHeader({required bool isExpanded}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      child: isExpanded
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
              child: Row(
                children: [
                  Icon(
                    Icons.smart_toy_outlined,
                    color: AppColors.primary,
                    size: 36,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Text(
                          AppStrings.appName,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          AppStrings.tagline,
                          style: TextStyle(fontSize: 11, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )
          : Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.smart_toy_outlined,
                  color: AppColors.primary,
                  size: 28,
                ),
                const SizedBox(height: 4),
              ],
            ),
    );
  }

  Widget _sidebarFooter({required bool isExpanded}) {
    if (!isExpanded) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 8),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.successBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.primary.withOpacity(0.16)),
        ),
        child: const Icon(
          Icons.support_agent_outlined,
          color: AppColors.primary,
          size: 22,
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.successBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withOpacity(0.16)),
      ),
      child: const Row(
        children: [
          Icon(
            Icons.support_agent_outlined,
            color: AppColors.primary,
            size: 20,
          ),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Need help? Open Chat for quick support.',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textDark,
                height: 1.25,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          AnimatedBuilder(
            animation: _menuController,
            builder: (context, _) {
              final isExpanded = _menuController.value > 0.6;
              return SizedBox(
                width: _widthAnimation.value,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border(
                      right: BorderSide(
                        color: Colors.grey.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                  ),
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 12, bottom: 12),
                      child: Column(
                        children: [
                          _drawerHeader(isExpanded: isExpanded),
                          const SizedBox(height: 8),
                          _sidebarToggleItem(isExpanded: isExpanded),
                          const SizedBox(height: 4),
                          ...List.generate(
                            _navItems.length,
                            (index) => _sidebarItem(
                              icon: _navItems[index].icon,
                              label: _navItems[index].label,
                              index: index,
                              isExpanded: isExpanded,
                              onTap: () {
                                setState(() {
                                  _selectedIndex = index;
                                });
                                AppPreferences.saveSelectedPageIndex(index);
                              },
                            ),
                          ),
                          const Spacer(),
                          _sidebarFooter(isExpanded: isExpanded),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          Expanded(
            child: RepaintBoundary(child: _navItems[_selectedIndex].screen),
          ),
        ],
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  final Widget screen;

  _NavItem({required this.icon, required this.label, required this.screen});
}
