import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:i18next/i18next.dart';
import 'package:routemaster/routemaster.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:flutter_map_animations/flutter_map_animations.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:jwt_decode/jwt_decode.dart';
import '../../../../markers/marker_bloc.dart';
import '../../../../markers/marker_repository.dart';
import '../../../../core/api_client.dart';
import '../../../../auth/application/auth_bloc.dart';
import '../../../../auth/application/oidc_client.dart';
import '../../../../auth/data/session_storage.dart';
import '../../../../auth/application/auth_interceptor.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> with TickerProviderStateMixin {
  final _searchCtrl = TextEditingController();
  bool _sortAsc = true;
  late final AnimatedMapController _mapController = AnimatedMapController(vsync: this);
  late final SessionStorage _sessionStorage;
  late final OidcClientWrapper _oidc;
  late final ApiClient _client;
  late final MarkerRepository _repo;
  late final MarkerBloc _markerBloc;

  @override
  void initState() {
    super.initState();
    _sessionStorage = SessionStorage();
    _oidc = OidcClientWrapper.fromEnv();
    _client = ApiClient(interceptors: [AuthInterceptor(_sessionStorage, _oidc)]);
    _repo = MarkerRepository(_client);
    _markerBloc = MarkerBloc(_repo)..add(const LoadPublicMarkers());
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _mapController.dispose();
    _markerBloc.close();
    super.dispose();
  }

  List<T> _sortedFiltered<T>(List<T> items, bool Function(T) matches, int Function(T a, T b) compare) {
    final filtered = items.where(matches).toList();
    filtered.sort(compare);
    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocProvider.value(
        value: _markerBloc,
        child: Row(
          children: [
            Container(
              width: 320,
              color: const Color(0xFF0E0F12),
              child: Column(
                children: [
                  const SizedBox(height: 40),
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: TextField(
                      controller: _searchCtrl,
                      onChanged: (_) => setState(() {}),
                      decoration: InputDecoration(
                        hintText: I18Next.of(context)!.t('map.search'),
                        prefixIcon: const Icon(Icons.search),
                        filled: true,
                        fillColor: const Color(0xFF232428),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Row(
                      children: [
                        FilterChip(
                          label: Text(_sortAsc ? 'A → Z' : 'Z → A'),
                          selected: true,
                          onSelected: (_) => setState(() => _sortAsc = !_sortAsc),
                        ),
                        const SizedBox(width: 8),
                        if (_searchCtrl.text.isNotEmpty)
                          TextButton.icon(
                            onPressed: () {
                              _searchCtrl.clear();
                              setState(() {});
                            },
                            icon: const Icon(Icons.clear, size: 18),
                            label: const Text('Filter zurücksetzen'),
                          ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: BlocBuilder<MarkerBloc, MarkerState>(
                      builder: (context, state) {
                        if (state.loading) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        final lower = _searchCtrl.text.toLowerCase();
                        final items = _sortedFiltered(
                          state.markers,
                          (m) => m.title.toLowerCase().contains(lower),
                          (a, b) => _sortAsc ? a.title.compareTo(b.title) : b.title.compareTo(a.title),
                        );
                        return NotificationListener<ScrollNotification>(
                          onNotification: (notification) {
                            final metrics = notification.metrics;
                            if (metrics.pixels >= metrics.maxScrollExtent - 200) {
                              if (state.hasMore && !state.paging) {
                                context.read<MarkerBloc>().add(const LoadNextPage());
                              }
                            }
                            return false;
                          },
                          child: ListView.separated(
                            padding: const EdgeInsets.all(8),
                            itemCount: state.paging ? items.length + 1 : items.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 8),
                            itemBuilder: (context, index) {
                              if (index >= items.length) {
                                return const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 12),
                                  child: Center(
                                    child: SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    ),
                                  ),
                                );
                              }
                              final m = items[index];
                              final selected = state.selectedMarkerId == m.id;
                              return ListTile(
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                tileColor: selected ? const Color(0xFF2A2B30) : const Color(0xFF1A1B1F),
                                title: Text(m.title),
                                subtitle: Text('(${m.lat.toStringAsFixed(5)}, ${m.lng.toStringAsFixed(5)})'),
                                trailing: m.iconUrl != null && m.iconUrl!.isNotEmpty
                                    ? SizedBox(
                                        width: 28,
                                        height: 28,
                                        child: ClipOval(
                                          child: m.iconUrl!.toLowerCase().endsWith('.svg')
                                              ? SvgPicture.network(m.iconUrl!, fit: BoxFit.cover)
                                              : Image.network(m.iconUrl!, fit: BoxFit.cover),
                                        ),
                                      )
                                    : null,
                                onTap: () => context.read<MarkerBloc>().add(SelectMarker(m.id)),
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Stack(
                children: [
                  BlocListener<MarkerBloc, MarkerState>(
                    listenWhen: (prev, curr) => prev.selectedMarkerId != curr.selectedMarkerId,
                    listener: (context, state) {
                      final sel = state.selected;
                      if (sel != null) {
                        _mapController.animateTo(
                          dest: LatLng(sel.lat, sel.lng),
                          zoom: 15,
                          curve: Curves.easeInOutCubic,
                          duration: const Duration(milliseconds: 650),
                        );
                      }
                    },
                    child: BlocBuilder<MarkerBloc, MarkerState>(
                      builder: (context, state) {
                        final lower = _searchCtrl.text.toLowerCase();
                        final visibleMarkers = state.markers
                            .where((m) => m.title.toLowerCase().contains(lower))
                            .map(
                              (m) => Marker(
                                point: LatLng(m.lat, m.lng),
                                width: 36,
                                height: 36,
                                child: GestureDetector(
                                  onTap: () => context.read<MarkerBloc>().add(SelectMarker(m.id)),
                                  child: _MarkerIcon(iconUrl: m.iconUrl, selected: state.selectedMarkerId == m.id),
                                ),
                              ),
                            )
                            .toList();

                        return FlutterMap(
                          mapController: _mapController.mapController,
                          options: MapOptions(
                            initialZoom: 12,
                            initialCenter: visibleMarkers.isEmpty
                                ? const LatLng(52.52, 13.405)
                                : LatLng(visibleMarkers.first.point.latitude, visibleMarkers.first.point.longitude),
                            initialCameraFit: visibleMarkers.isNotEmpty
                                ? CameraFit.bounds(
                                    bounds: LatLngBounds.fromPoints(visibleMarkers.map((m) => m.point).toList()),
                                    padding: const EdgeInsets.all(48),
                                  )
                                : null,
                            onMapEvent: (evt) {
                              if (evt is MapEventMoveEnd ||
                                  evt is MapEventFlingAnimationEnd ||
                                  evt is MapEventRotateEnd ||
                                  evt is MapEventDoubleTapZoomEnd) {
                                final b = _mapController.mapController.camera.visibleBounds;
                                final z = _mapController.mapController.camera.zoom;
                                context.read<MarkerBloc>().add(
                                  ViewportChanged(south: b.south, west: b.west, north: b.north, east: b.east, zoom: z),
                                );
                              }
                            },
                          ),
                          children: [
                            TileLayer(
                              // Empfehlung von flutter_map: keine Subdomains mehr für OSM nutzen
                              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                              userAgentPackageName: 'dev.resistance.maps',
                            ),
                            MarkerClusterLayerWidget(
                              options: MarkerClusterLayerOptions(
                                maxClusterRadius: 45,
                                size: const Size(36, 36),
                                markers: visibleMarkers,
                                builder: (context, markers) {
                                  return Container(
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF2A2B30),
                                      shape: BoxShape.circle,
                                      boxShadow: const [BoxShadow(color: Colors.black45, blurRadius: 6)],
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      markers.length.toString(),
                                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  // Detail card overlay
                  Positioned(
                    left: 16,
                    top: 16,
                    child: BlocBuilder<AuthBloc, AuthState>(
                      builder: (context, state) {
                        final isAuthed = state.session != null;
                        if (!isAuthed) {
                          return ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              backgroundColor: const Color(0xFF1A1B1F),
                              foregroundColor: Colors.white,
                            ),
                            onPressed: () => context.read<AuthBloc>().add(const SignInRequested()),
                            icon: const Icon(Icons.login, size: 18),
                            label: const Text('Login'),
                          );
                        }
                        // Build avatar from token claims: prefer image URL, fallback to initials from name/username/email
                        final session = state.session!;
                        final token = session.idToken ?? session.accessToken;
                        Map<String, dynamic> claims = const {};
                        try {
                          claims = Jwt.parseJwt(token);
                        } catch (_) {}

                        String displayName = '';
                        final name = claims['name']?.toString();
                        final preferred = claims['preferred_username']?.toString();
                        final email = claims['email']?.toString();
                        if (name != null && name.isNotEmpty) {
                          displayName = name;
                        } else if (preferred != null && preferred.isNotEmpty) {
                          displayName = preferred;
                        } else if (email != null && email.isNotEmpty) {
                          displayName = email.split('@').first;
                        }

                        final pictureUrl =
                            (claims['picture'] ?? claims['avatar_url'] ?? claims['profilePicture'] ?? claims['image'])
                                ?.toString();

                        Widget avatar;
                        if (pictureUrl != null && pictureUrl.isNotEmpty) {
                          avatar = CircleAvatar(
                            radius: 16,
                            backgroundColor: const Color(0xFF2A2B30),
                            backgroundImage: NetworkImage(pictureUrl),
                          );
                        } else if (displayName.trim().isNotEmpty) {
                          final parts = displayName.trim().split(RegExp(r"\s+"));
                          String initials = parts.take(2).map((p) => p.isNotEmpty ? p[0] : '').join();
                          if (initials.isEmpty && displayName.isNotEmpty) {
                            initials = displayName[0];
                          }
                          avatar = CircleAvatar(
                            radius: 16,
                            backgroundColor: const Color(0xFF2A2B30),
                            child: Text(initials.toUpperCase(), style: const TextStyle(color: Colors.white)),
                          );
                        } else {
                          avatar = const Icon(Icons.account_circle, color: Colors.white);
                        }
                        return PopupMenuButton<String>(
                          tooltip: 'Account',
                          icon: avatar,
                          color: const Color(0xFF1A1B1F),
                          padding: EdgeInsets.zero,
                          onSelected: (value) {
                            switch (value) {
                              case 'settings':
                                Routemaster.of(context).push('/account');
                                break;
                              case 'logout':
                                context.read<AuthBloc>().add(const SignOutRequested());
                                break;
                            }
                          },
                          itemBuilder: (context) => [
                            PopupMenuItem<String>(
                              value: 'settings',
                              child: ListTile(
                                contentPadding: EdgeInsets.zero,
                                leading: const Icon(Icons.settings, color: Colors.white),
                                title: Text(
                                  I18Next.of(context)!.t('map.account.menu.settings'),
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                            const PopupMenuDivider(height: 8),
                            PopupMenuItem<String>(
                              value: 'logout',
                              child: ListTile(
                                contentPadding: EdgeInsets.zero,
                                leading: const Icon(Icons.logout, color: Colors.white),
                                title: Text(
                                  I18Next.of(context)!.t('map.account.menu.logout'),
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  // Detail card overlay
                  Positioned(
                    right: 16,
                    top: 16,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        BlocBuilder<MarkerBloc, MarkerState>(
                          builder: (context, state) {
                            return ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                backgroundColor: const Color(0xFF1A1B1F),
                                foregroundColor: Colors.white,
                              ),
                              onPressed: () {
                                final lower = _searchCtrl.text.toLowerCase();
                                final points = state.markers
                                    .where((m) => m.title.toLowerCase().contains(lower))
                                    .map((m) => LatLng(m.lat, m.lng))
                                    .toList();
                                if (points.isEmpty) return;
                                final bounds = LatLngBounds.fromPoints(points);
                                // Zoom out leicht für einen angenehmen Puffer
                                _mapController.animateTo(
                                  dest: LatLng((bounds.north + bounds.south) / 2, (bounds.east + bounds.west) / 2),
                                  zoom: 11,
                                  curve: Curves.easeInOut,
                                  duration: const Duration(milliseconds: 500),
                                );
                              },
                              icon: const Icon(Icons.fit_screen, size: 18),
                              label: const Text('Alle anzeigen'),
                            );
                          },
                        ),
                        const SizedBox(height: 8),
                        BlocBuilder<MarkerBloc, MarkerState>(
                          builder: (context, state) {
                            final sel = state.selected;
                            return OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                foregroundColor: Colors.white,
                              ),
                              onPressed: sel == null
                                  ? null
                                  : () => _mapController.animateTo(
                                      dest: LatLng(sel.lat, sel.lng),
                                      zoom: 15,
                                      curve: Curves.easeInOutCubic,
                                      duration: const Duration(milliseconds: 500),
                                    ),
                              icon: const Icon(Icons.my_location, size: 18),
                              label: const Text('Auswahl zentrieren'),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  // Detail card overlay
                  Positioned(
                    right: 16,
                    bottom: 16,
                    child: BlocBuilder<MarkerBloc, MarkerState>(
                      builder: (context, state) {
                        final sel = state.selected;
                        if (sel == null) return const SizedBox.shrink();
                        return _DetailCard(
                          title: sel.title,
                          lat: sel.lat,
                          lng: sel.lng,
                          onClose: () => context.read<MarkerBloc>().add(const SelectMarker(null)),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailCard extends StatelessWidget {
  const _DetailCard({required this.title, required this.lat, required this.lng, required this.onClose});
  final String title;
  final double lat;
  final double lng;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1B1F),
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 12, spreadRadius: 2)],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              ),
              IconButton(onPressed: onClose, icon: const Icon(Icons.close)),
            ],
          ),
          const SizedBox(height: 8),
          Text('Lat: ${lat.toStringAsFixed(5)}'),
          Text('Lng: ${lng.toStringAsFixed(5)}'),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.place, size: 16, color: Color(0xFF90CAF9)),
              const SizedBox(width: 6),
              Text('Öffentlicher Marker', style: TextStyle(color: Colors.grey[300])),
            ],
          ),
        ],
      ),
    );
  }
}

class _MarkerIcon extends StatelessWidget {
  const _MarkerIcon({required this.iconUrl, required this.selected});
  final String? iconUrl;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final double size = selected ? 30 : 24;
    if (iconUrl == null || iconUrl!.isEmpty) {
      return Icon(Icons.location_on, color: selected ? const Color(0xFFE53935) : const Color(0xFF90CAF9), size: size);
    }
    final isSvg = iconUrl!.toLowerCase().endsWith('.svg');
    final border = BoxDecoration(
      shape: BoxShape.circle,
      boxShadow: const [BoxShadow(color: Colors.black45, blurRadius: 6, spreadRadius: 1)],
    );
    return Container(
      decoration: border,
      padding: const EdgeInsets.all(2),
      child: ClipOval(
        child: isSvg
            ? SvgPicture.network(iconUrl!, width: size, height: size, fit: BoxFit.cover)
            : Image.network(iconUrl!, width: size, height: size, fit: BoxFit.cover),
      ),
    );
  }
}
