import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../app/app_shell.dart';
import '../../auth/application/auth_bloc.dart';
import '../../markers/marker_bloc.dart';
import '../../routes/route_bloc.dart';
import '../../groups/group_bloc.dart';
import '../../connections/connection_bloc.dart';
import '../../lists/map_list_bloc.dart';
import '../map/presentation/pages/map_page.dart';
import '../groups/groups_page.dart';
import '../connections/connections_page.dart';
import '../lists/lists_page.dart';
import 'sidebar/sidebar_content.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _navIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    final authState = context.read<AuthBloc>().state;
    if (authState.session != null) {
      context.read<MarkerBloc>().add(const LoadAccessibleMarkers());
      context.read<RouteBloc>().add(const LoadAccessibleRoutes());
      context.read<GroupBloc>().add(const LoadMyGroups());
      context.read<ConnectionBloc>().add(const LoadConnections());
      context.read<MapListBloc>().add(const LoadAccessibleLists());
    } else {
      context.read<MarkerBloc>().add(const LoadPublicMarkers());
      context.read<RouteBloc>().add(const LoadPublicRoutes());
      context.read<MapListBloc>().add(const LoadPublicLists());
    }
  }

  Widget get _mainContent {
    switch (_navIndex) {
      case 1:
        return const GroupsPage();
      case 2:
        return const ConnectionsPage();
      case 3:
        return const ListsPage();
      default:
        return const MapPageContent();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listenWhen: (prev, curr) => prev.session != curr.session,
      listener: (context, state) => _loadData(),
      child: AppShell(
        selectedNavIndex: _navIndex,
        onNavChanged: (i) => setState(() => _navIndex = i),
        sidebarContent: SidebarContent(navIndex: _navIndex),
        mainContent: _mainContent,
      ),
    );
  }
}
