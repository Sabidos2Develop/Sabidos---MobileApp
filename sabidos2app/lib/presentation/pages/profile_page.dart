import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sabidos2app/core/theme/app_colors.dart';
import 'package:sabidos2app/core/theme/theme_extensions.dart';
import 'package:sabidos2app/presentation/pages/widgets/dashboard_grid.dart';
import 'package:sabidos2app/presentation/pages/widgets/achievements_tab.dart';
import 'package:sabidos2app/presentation/controllers/authController.dart';
import 'package:sabidos2app/data/datasources/gamefication_service.dart';
import 'package:sabidos2app/core/theme/theme_controller.dart';
import 'package:sabidos2app/data/core/models/user_stats.dart';
import 'package:sabidos2app/presentation/controllers/gamification_controller.dart';

class ProfileScreen extends StatefulWidget {
  final Function(int)? onNavigate;
  final int initialTabIndex;

  const ProfileScreen({super.key, this.onNavigate, this.initialTabIndex = 0});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with SingleTickerProviderStateMixin {
  // Controle da animação do menu
  late AnimationController _menuController;
  late Animation<double> _menuAnimation;
  OverlayEntry? _overlayEntry;
  bool _isMenuOpen = false;

  @override
  void initState() {
    super.initState();
    
    // Dispara a atualização dos dados em background ao entrar na tela
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GamificationController>().fetchStats();
    });

    _menuController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _menuAnimation = CurvedAnimation(
      parent: _menuController,
      curve: Curves.easeOutBack,
    );
  }

  @override
  void dispose() {
    _menuController.dispose();
    _overlayEntry?.remove();
    super.dispose();
  }

  void _toggleMenu(BuildContext context, AuthController auth) {
    if (!mounted) return;
    if (_isMenuOpen) {
      _closeMenu();
    } else {
      _openMenu(context, auth);
    }
  }

  void _openMenu(BuildContext context, AuthController auth) {
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final offset = renderBox.localToGlobal(Offset.zero);
    final colors = context.colors;

    _overlayEntry = OverlayEntry(
      builder: (context) => GestureDetector(
        onTap: _closeMenu,
        behavior: HitTestBehavior.opaque,
        child: Stack(
          children: [
            Positioned.fill(
              child: Container(color: Colors.transparent),
            ),
            Positioned(
              top: offset.dy + 60,
              right: 16,
              child: ScaleTransition(
                scale: _menuAnimation,
                alignment: Alignment.topRight,
                child: FadeTransition(
                  opacity: _menuAnimation,
                  child: Material(
                    color: Colors.transparent,
                    child: Container(
                      width: 220,
                      decoration: BoxDecoration(
                        color: colors.boxBackground.withOpacity(0.95),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: colors.boxBorder, width: 1.5),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 15,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildMenuItem(
                              icon: Icons.person_outline,
                              label: 'Editar Perfil',
                              onTap: () {
                                _closeMenu();
                                // Lógica de editar
                              },
                              colors: colors,
                            ),
                            Divider(color: colors.boxBorder, height: 1),
                            _buildMenuItem(
                              icon: Icons.dark_mode_outlined,
                              label: 'Modo Escuro',
                              onTap: () {
                                context.read<ThemeController>().toggleTheme();
                              },
                              colors: colors,
                              trailing: Transform.scale(
                                scale: 0.7,
                                child: Switch(
                                  value: Theme.of(context).brightness == Brightness.dark,
                                  onChanged: (val) {
                                    context.read<ThemeController>().toggleTheme();
                                  },
                                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  activeColor: colors.accentBlue,
                                  activeTrackColor: colors.accentBlue.withOpacity(0.3),
                                  inactiveThumbColor: colors.accentYellow,
                                  inactiveTrackColor: colors.accentYellow.withOpacity(0.3),
                                ),
                              ),
                            ),
                            Divider(color: colors.boxBorder, height: 1),
                            _buildMenuItem(
                              icon: Icons.logout,
                              label: 'Sair da Conta',
                              onTap: () async {
                                _closeMenu();
                                await auth.logout();
                              },
                              colors: colors,
                              isDestructive: true,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
    _menuController.forward();
    setState(() => _isMenuOpen = true);
  }

  void _closeMenu() async {
    if (!_isMenuOpen) return;
    await _menuController.reverse();
    _overlayEntry?.remove();
    _overlayEntry = null;
    if (mounted) setState(() => _isMenuOpen = false);
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required AppColors colors,
    bool isDestructive = false,
    Widget? trailing,
  }) {
    return SizedBox(
      height: 48, // Altura fixa para todos os itens
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    icon,
                    size: 20,
                    color: isDestructive ? Color.fromARGB(255, 239, 103, 101) : colors.text,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    label,
                    style: TextStyle(
                      color: isDestructive ? Color.fromARGB(255, 239, 103, 101) : colors.text,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              if (trailing != null) 
                SizedBox(
                  height: 30, // Limita a altura do switch
                  child: trailing
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final auth = context.watch<AuthController>();
    final gami = context.watch<GamificationController>();
    final user = auth.user;
    
    final displayName = user?.displayName ?? "Estudante";
    final photoUrl = user?.photoURL ?? "https://ui-avatars.com/api/?name=$displayName&background=0D8ABC&color=fff&size=200";

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: DefaultTabController(
          length: 2,
          initialIndex: widget.initialTabIndex,
          child: NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return [
                SliverToBoxAdapter(
                  child: Column(
                    children: [
                      _buildTopHeader(context, auth),
                      const SizedBox(height: 10),
                      _buildProfileInfo(context, displayName, photoUrl, gami.userLevel),
                      const SizedBox(height: 16),
                      Text(
                        displayName,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: colors.text,
                        ),
                      ),
                      const SizedBox(height: 24),
                      _buildAchievementsCard(context, gami.unlockedCount),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _SliverAppBarDelegate(
                    context,
                    TabBar(
                      indicatorColor: colors.accentYellow,
                      labelColor: colors.accentYellow,
                      unselectedLabelColor: colors.grayText,
                      dividerColor: colors.grayText.withOpacity(0.3),
                      indicatorWeight: 3,
                      indicatorSize: TabBarIndicatorSize.tab,
                      tabs: [
                        const Tab(text: 'Dashboard'),
                        Tab(
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              const Text('Conquistas'),
                              if (context.watch<GamificationController>().hasPendingRewards)
                                Positioned(
                                  right: -10,
                                  top: -2,
                                  child: Container(
                                    width: 8,
                                    height: 8,
                                    decoration: const BoxDecoration(
                                      color: Colors.orange,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ];
            },
            body: TabBarView(
              children: [
                SingleChildScrollView(
                  child: DashboardGrid(
                    stats: gami.stats,
                    onCardTap: widget.onNavigate,
                  ),
                ),
                const SingleChildScrollView(child: AchievementsTab()),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopHeader(BuildContext context, AuthController auth) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Builder(builder: (btnContext) {
            return _buildIconButton(
              context,
              Icons.settings,
              onTap: () => _toggleMenu(btnContext, auth),
              iconAnimation: _menuAnimation,
            );
          }),
        ],
      ),
    );
  }

  Widget _buildIconButton(
    BuildContext context, 
    IconData icon, {
    VoidCallback? onTap, 
    Animation<double>? iconAnimation
  }) {
    final colors = context.colors;
    
    Widget iconWidget = Icon(icon, color: colors.text, size: 20);
    
    if (iconAnimation != null) {
      iconWidget = RotationTransition(
        turns: Tween<double>(begin: 0, end: 0.25).animate(iconAnimation),
        child: iconWidget,
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: colors.boxBackground,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: colors.boxBorder, width: 1),
      ),
      child: IconButton(
        constraints: const BoxConstraints(),
        padding: const EdgeInsets.all(8),
        icon: iconWidget,
        onPressed: onTap,
      ),
    );
  }

  Widget _buildProfileInfo(BuildContext context, String name, String photoUrl, int level) {
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Align(
              alignment: Alignment.centerLeft,
              child: _buildStatBadge(
                context,
                'Rank',
                '---',
                gradient: LinearGradient(
                  colors: colors.rankGradient.colors
                      .map((cor) => cor.withOpacity(0.5))
                      .toList(),
                  begin: colors.rankGradient.begin,
                  end: colors.rankGradient.end,
                  stops: colors.rankGradient.stops,
                ),
                borderColor: colors.accentBlue,
              ),
            ),
          ),
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              color: colors.accentBlue,
              image: DecorationImage(
                image: NetworkImage(photoUrl),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Expanded(
            child: Align(
              alignment: Alignment.centerRight,
              child: _buildStatBadge(
                context,
                'Nivel',
                level.toString(),
                gradient: LinearGradient(
                  colors: colors.levelGradient.colors
                      .map((cor) => cor.withOpacity(0.5))
                      .toList(),
                  begin: colors.levelGradient.begin,
                  end: colors.levelGradient.end,
                  stops: colors.levelGradient.stops,
                ),
                borderColor: colors.accentYellow,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatBadge(
    BuildContext context,
    String label,
    String value, {
    Color? bgColor,
    Gradient? gradient,
    Color? borderColor,
  }) {
    final colors = context.colors;
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(color: colors.grayText, fontSize: 12),
        ),
        const SizedBox(height: 6),
        SizedBox(
          width: 44,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            decoration: BoxDecoration(
              color: bgColor,
              gradient: gradient,
              borderRadius: BorderRadius.circular(8),
              border: borderColor != null
                  ? Border.all(color: borderColor, width: 1.5)
                  : null,
            ),
            child: Center(
              child: Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAchievementsCard(BuildContext context, int count) {
    final colors = context.colors;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.boxBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.boxBorder, width: 1),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Conquistas',
                style: TextStyle(color: colors.grayText, fontSize: 14),
              ),
              Text(
                '$count/10',
                style: TextStyle(color: colors.grayText, fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildAchievementIcon(context, Icons.list_alt, isUnlocked: count >= 1),
              _buildAchievementIcon(context, Icons.timer, isUnlocked: count >= 2),
              _buildAchievementIcon(context, Icons.lock_outline, isUnlocked: false),
              _buildAchievementIcon(context, Icons.lock_outline, isUnlocked: false),
              _buildAchievementIcon(context, Icons.lock_outline, isUnlocked: false),
              _buildAchievementIcon(context, Icons.lock_outline, isUnlocked: false),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementIcon(BuildContext context, IconData icon, {required bool isUnlocked}) {
    final colors = context.colors;
    final greyMaskColor = Colors.black.withOpacity(0.6);

    Widget achievementWidget = Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: colors.sabidosGradient,
      ),
      child: Icon(icon, color: Colors.white, size: 24),
    );

    if (!isUnlocked) {
      achievementWidget = ColorFiltered(
        colorFilter: ColorFilter.mode(greyMaskColor, BlendMode.srcATop),
        child: achievementWidget,
      );
    }

    return Stack(
      clipBehavior: Clip.none,
      children: [
        achievementWidget,
        if (isUnlocked)
          Positioned(
            top: -2,
            right: -2,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: colors.accentYellow,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check,
                color: colors.background,
                size: 16,
              ),
            ),
          ),
      ],
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this.context, this._tabBar);

  final BuildContext context;
  final TabBar _tabBar;

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(color: context.colors.background, child: _tabBar);
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}

