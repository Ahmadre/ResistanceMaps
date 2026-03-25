import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:i18next/i18next.dart';
import 'package:jwt_decode/jwt_decode.dart';
import 'package:routemaster/routemaster.dart';
import '../../../auth/application/auth_bloc.dart';
import '../../../markers/marker_bloc.dart';
import '../../../markers/marker_model.dart';
import '../../../routes/route_bloc.dart';
import '../../../routes/route_model.dart';
import '../../../groups/group_bloc.dart';
import '../../../groups/group_model.dart';
import '../../../connections/connection_bloc.dart';
import '../../../connections/connection_model.dart';
import '../../../lists/map_list_bloc.dart';
import '../../../lists/map_list_model.dart';

class SidebarContent extends StatefulWidget {
  const SidebarContent({super.key, required this.navIndex});
  final int navIndex;

  @override
  State<SidebarContent> createState() => _SidebarContentState();
}

class _SidebarContentState extends State<SidebarContent> {
  final _searchCtrl = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = I18Next.of(context)!;
    return Column(
      children: [
        _buildHeader(context, t),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: TextField(
            controller: _searchCtrl,
            onChanged: (v) => setState(() => _searchQuery = v.toLowerCase()),
            decoration: InputDecoration(
              hintText: t.t('map.search'),
              prefixIcon: const Icon(Icons.search, size: 18),
              filled: true,
              fillColor: const Color(0xFF232428),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
              contentPadding: const EdgeInsets.symmetric(vertical: 8),
            ),
          ),
        ),
        Expanded(child: _buildList(context)),
      ],
    );
  }

  Widget _buildHeader(BuildContext context, I18Next t) {
    return Container(
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 12, left: 16, right: 8, bottom: 8),
      child: Row(
        children: [
          const Icon(Icons.public, color: Color(0xFF00F5A4), size: 20),
          const SizedBox(width: 8),
          Text(t.t('app.title'), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF48F5C6))),
          const Spacer(),
          BlocBuilder<AuthBloc, AuthState>(
            builder: (ctx, state) {
              if (state.session == null) {
                return TextButton(
                  onPressed: () => ctx.read<AuthBloc>().add(const SignInRequested()),
                  child: Text(t.t('common.login'), style: const TextStyle(color: Color(0xFF00F5A4), fontSize: 12)),
                );
              }
              String initial = '?';
              try {
                final claims = Jwt.parseJwt(state.session!.accessToken);
                final name = (claims['preferred_username'] ?? claims['name'] ?? '').toString();
                if (name.isNotEmpty) initial = name[0];
              } catch (_) {}
              return PopupMenuButton<String>(
                icon: CircleAvatar(
                  radius: 14,
                  backgroundColor: const Color(0xFF00F5A4).withValues(alpha: 0.2),
                  child: Text(
                    initial.toUpperCase(),
                    style: const TextStyle(color: Color(0xFF00F5A4), fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
                onSelected: (val) {
                  if (val == 'account') Routemaster.of(context).push('/account');
                  if (val == 'logout') ctx.read<AuthBloc>().add(const SignOutRequested());
                },
                itemBuilder: (_) => [
                  PopupMenuItem(value: 'account', child: Text(t.t('map.account.menu.settings'))),
                  PopupMenuItem(value: 'logout', child: Text(t.t('map.account.menu.logout'))),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildList(BuildContext context) {
    switch (widget.navIndex) {
      case 1:
        return _buildGroupsList(context);
      case 2:
        return _buildConnectionsList(context);
      case 3:
        return _buildMapListsList(context);
      default:
        return _buildMarkersAndRoutesList(context);
    }
  }

  Widget _buildMarkersAndRoutesList(BuildContext context) {
    return BlocBuilder<MarkerBloc, MarkerState>(
      builder: (ctx, markerState) {
        return BlocBuilder<RouteBloc, RouteState>(
          builder: (ctx, routeState) {
            final markers = markerState.markers.where((m) => _searchQuery.isEmpty || m.title.toLowerCase().contains(_searchQuery)).toList();
            final routes = routeState.routes.where((r) => _searchQuery.isEmpty || r.title.toLowerCase().contains(_searchQuery)).toList();

            if (markerState.loading || routeState.loading) {
              return const Center(child: CircularProgressIndicator(color: Color(0xFF00F5A4)));
            }

            return ListView(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              children: [
                if (routes.isNotEmpty) ...[
                  _sectionHeader('Routes', routes.length),
                  ...routes.map((r) => _routeTile(ctx, r)),
                  const SizedBox(height: 8),
                ],
                _sectionHeader('Markers', markers.length),
                ...markers.map((m) => _markerTile(ctx, m)),
              ],
            );
          },
        );
      },
    );
  }

  Widget _markerTile(BuildContext context, MarkerModel marker) {
    return ListTile(
      dense: true,
      leading: Icon(
        marker.visibility == 'PRIVATE' ? Icons.lock : Icons.location_on,
        color: marker.visibility == 'PRIVATE' ? Colors.orangeAccent : const Color(0xFF00F5A4),
        size: 18,
      ),
      title: Text(marker.title, style: const TextStyle(fontSize: 13), overflow: TextOverflow.ellipsis),
      subtitle: marker.description != null
          ? Text(marker.description!, style: TextStyle(fontSize: 11, color: Colors.grey[500]), maxLines: 1, overflow: TextOverflow.ellipsis)
          : null,
      trailing: marker.hasPassword ? const Icon(Icons.vpn_key, size: 14, color: Colors.orangeAccent) : null,
      onTap: () => context.read<MarkerBloc>().add(SelectMarker(marker.id)),
    );
  }

  Widget _routeTile(BuildContext context, RouteModel route) {
    return ListTile(
      dense: true,
      leading: const Icon(Icons.route, color: Color(0xFF00F5A4), size: 18),
      title: Text(route.title, style: const TextStyle(fontSize: 13), overflow: TextOverflow.ellipsis),
      subtitle: route.description != null
          ? Text(route.description!, style: TextStyle(fontSize: 11, color: Colors.grey[500]), maxLines: 1, overflow: TextOverflow.ellipsis)
          : null,
      onTap: () => context.read<RouteBloc>().add(SelectRoute(route.id)),
    );
  }

  Widget _buildGroupsList(BuildContext context) {
    return BlocBuilder<GroupBloc, GroupState>(
      builder: (ctx, state) {
        final groups = state.groups.where((g) => _searchQuery.isEmpty || g.name.toLowerCase().contains(_searchQuery)).toList();
        if (state.loading) {
          return const Center(child: CircularProgressIndicator(color: Color(0xFF00F5A4)));
        }
        return ListView(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          children: [
            _sectionHeader('Groups', groups.length),
            ...groups.map((g) => _groupTile(ctx, g)),
          ],
        );
      },
    );
  }

  Widget _groupTile(BuildContext context, GroupModel group) {
    return ListTile(
      dense: true,
      leading: const Icon(Icons.group, color: Color(0xFF00F5A4), size: 18),
      title: Text(group.name, style: const TextStyle(fontSize: 13), overflow: TextOverflow.ellipsis),
      subtitle: group.description != null
          ? Text(group.description!, style: TextStyle(fontSize: 11, color: Colors.grey[500]), maxLines: 1, overflow: TextOverflow.ellipsis)
          : null,
      onTap: () => context.read<GroupBloc>().add(SelectGroup(group.id)),
    );
  }

  Widget _buildConnectionsList(BuildContext context) {
    return BlocBuilder<ConnectionBloc, ConnectionBlocState>(
      builder: (ctx, state) {
        if (state.loading) {
          return const Center(child: CircularProgressIndicator(color: Color(0xFF00F5A4)));
        }
        return ListView(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          children: [
            if (state.pending.isNotEmpty) ...[
              _sectionHeader('Pending', state.pending.length),
              ...state.pending.map((c) => _connectionTile(ctx, c, isPending: true)),
            ],
            if (state.sent.isNotEmpty) ...[
              _sectionHeader('Sent', state.sent.length),
              ...state.sent.map((c) => _connectionTile(ctx, c, isSent: true)),
            ],
            _sectionHeader('Connected', state.accepted.length),
            ...state.accepted.map((c) => _connectionTile(ctx, c)),
          ],
        );
      },
    );
  }

  Widget _connectionTile(BuildContext context, ConnectionModel conn, {bool isPending = false, bool isSent = false}) {
    final String label = isPending ? conn.requesterId : (isSent ? conn.targetId : conn.requesterId);
    return ListTile(
      dense: true,
      leading: const Icon(Icons.person, color: Color(0xFF00F5A4), size: 18),
      title: Text(label, style: const TextStyle(fontSize: 13), overflow: TextOverflow.ellipsis),
      trailing: isPending
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.check, color: Colors.greenAccent, size: 18),
                  onPressed: () => context.read<ConnectionBloc>().add(AcceptInvitation(conn.id!)),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.redAccent, size: 18),
                  onPressed: () => context.read<ConnectionBloc>().add(RejectInvitation(conn.id!)),
                ),
              ],
            )
          : null,
    );
  }

  Widget _buildMapListsList(BuildContext context) {
    return BlocBuilder<MapListBloc, MapListState>(
      builder: (ctx, state) {
        final lists = state.lists.where((l) => _searchQuery.isEmpty || l.title.toLowerCase().contains(_searchQuery)).toList();
        if (state.loading) {
          return const Center(child: CircularProgressIndicator(color: Color(0xFF00F5A4)));
        }
        return ListView(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          children: [
            _sectionHeader('Lists', lists.length),
            ...lists.map((l) => _mapListTile(ctx, l)),
          ],
        );
      },
    );
  }

  Widget _mapListTile(BuildContext context, MapListModel list) {
    return ListTile(
      dense: true,
      leading: const Icon(Icons.list_alt, color: Color(0xFF00F5A4), size: 18),
      title: Text(list.title, style: const TextStyle(fontSize: 13), overflow: TextOverflow.ellipsis),
      subtitle: Text(
        '${list.markerIds.length} markers, ${list.routeIds.length} routes',
        style: TextStyle(fontSize: 11, color: Colors.grey[500]),
      ),
      trailing: list.hasPassword ? const Icon(Icons.vpn_key, size: 14, color: Colors.orangeAccent) : null,
      onTap: () => context.read<MapListBloc>().add(SelectMapList(list.id)),
    );
  }

  Widget _sectionHeader(String title, int count) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 12, 8, 4),
      child: Row(
        children: [
          Text(title, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1)),
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
            decoration: BoxDecoration(color: const Color(0xFF00F5A4).withValues(alpha: 0.15), borderRadius: BorderRadius.circular(8)),
            child: Text('$count', style: const TextStyle(fontSize: 10, color: Color(0xFF00F5A4))),
          ),
        ],
      ),
    );
  }
}
