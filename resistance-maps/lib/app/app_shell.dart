import 'package:flutter/material.dart';

/// Responsive breakpoints
class Breakpoints {
  static const double mobile = 600;
  static const double tablet = 1024;
}

/// Determines the current layout mode based on width
enum LayoutMode { mobile, tablet, desktop }

LayoutMode layoutModeOf(BuildContext context) {
  final width = MediaQuery.of(context).size.width;
  if (width < Breakpoints.mobile) return LayoutMode.mobile;
  if (width < Breakpoints.tablet) return LayoutMode.tablet;
  return LayoutMode.desktop;
}

/// App shell with golden-ratio sidebar (38.2% sidebar / 61.8% main).
/// On mobile, the sidebar is behind a drawer.
class AppShell extends StatefulWidget {
  const AppShell({super.key, required this.mainContent, required this.sidebarContent, this.selectedNavIndex = 0, this.onNavChanged});
  final Widget mainContent;
  final Widget sidebarContent;
  final int selectedNavIndex;
  final ValueChanged<int>? onNavChanged;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  static const _navItems = [
    _NavItem(icon: Icons.map, label: 'Map'),
    _NavItem(icon: Icons.group, label: 'Groups'),
    _NavItem(icon: Icons.people, label: 'Connections'),
    _NavItem(icon: Icons.list_alt, label: 'Lists'),
  ];

  @override
  Widget build(BuildContext context) {
    final mode = layoutModeOf(context);

    if (mode == LayoutMode.mobile) {
      return Scaffold(
        key: _scaffoldKey,
        backgroundColor: const Color(0xFF191A1D),
        drawer: Drawer(
          backgroundColor: const Color(0xFF0E0F12),
          child: widget.sidebarContent,
        ),
        body: Stack(
          children: [
            widget.mainContent,
            Positioned(
              top: MediaQuery.of(context).padding.top + 8,
              left: 8,
              child: IconButton(
                icon: const Icon(Icons.menu, color: Colors.white),
                onPressed: () => _scaffoldKey.currentState?.openDrawer(),
              ),
            ),
          ],
        ),
        bottomNavigationBar: _buildBottomNav(),
      );
    }

    // Tablet & Desktop: persistent sidebar with golden ratio
    return Scaffold(
      backgroundColor: const Color(0xFF191A1D),
      body: Row(
        children: [
          // Navigation rail
          _buildNavRail(mode),
          // Sidebar (38.2% on desktop, narrower on tablet)
          Container(
            width: mode == LayoutMode.desktop
                ? MediaQuery.of(context).size.width * 0.382 - 72
                : 280,
            color: const Color(0xFF0E0F12),
            child: widget.sidebarContent,
          ),
          // Main content (61.8%)
          Expanded(child: widget.mainContent),
        ],
      ),
    );
  }

  Widget _buildNavRail(LayoutMode mode) {
    return NavigationRail(
      backgroundColor: const Color(0xFF0E0F12),
      selectedIndex: widget.selectedNavIndex,
      onDestinationSelected: widget.onNavChanged,
      labelType: NavigationRailLabelType.all,
      indicatorColor: const Color(0xFF00F5A4).withValues(alpha: 0.15),
      destinations: _navItems
          .map((item) => NavigationRailDestination(
                icon: Icon(item.icon, color: Colors.grey),
                selectedIcon: Icon(item.icon, color: const Color(0xFF00F5A4)),
                label: Text(item.label, style: const TextStyle(fontSize: 10)),
              ))
          .toList(),
    );
  }

  Widget _buildBottomNav() {
    return BottomNavigationBar(
      currentIndex: widget.selectedNavIndex,
      onTap: widget.onNavChanged,
      backgroundColor: const Color(0xFF0E0F12),
      selectedItemColor: const Color(0xFF00F5A4),
      unselectedItemColor: Colors.grey,
      type: BottomNavigationBarType.fixed,
      items: _navItems
          .map((item) => BottomNavigationBarItem(icon: Icon(item.icon), label: item.label))
          .toList(),
    );
  }
}

class _NavItem {
  const _NavItem({required this.icon, required this.label});
  final IconData icon;
  final String label;
}
