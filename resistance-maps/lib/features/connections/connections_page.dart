import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:i18next/i18next.dart';
import '../../auth/application/auth_bloc.dart';
import '../../connections/connection_bloc.dart';
import '../../connections/connection_model.dart';

class ConnectionsPage extends StatelessWidget {
  const ConnectionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final t = I18Next.of(context)!;
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        if (authState.session == null) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.people, size: 64, color: Color(0xFF00F5A4)),
                const SizedBox(height: 16),
                Text(t.t('connections.loginRequired'), style: TextStyle(color: Colors.grey[400], fontSize: 16)),
              ],
            ),
          );
        }
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(t.t('connections.title'), style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              _InviteForm(t: t),
              const SizedBox(height: 24),
              Expanded(child: _ConnectionTabs(t: t)),
            ],
          ),
        );
      },
    );
  }
}

class _InviteForm extends StatefulWidget {
  const _InviteForm({required this.t});
  final I18Next t;
  @override
  State<_InviteForm> createState() => _InviteFormState();
}

class _InviteFormState extends State<_InviteForm> {
  final _ctrl = TextEditingController();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _ctrl,
            decoration: InputDecoration(
              hintText: widget.t.t('connections.inviteHint'),
              filled: true,
              fillColor: const Color(0xFF232428),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
            ),
          ),
        ),
        const SizedBox(width: 12),
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00F5A4), foregroundColor: Colors.black),
          onPressed: () {
            final value = _ctrl.text.trim();
            if (value.isEmpty) return;
            context.read<ConnectionBloc>().add(SendInvitation(value));
            _ctrl.clear();
          },
          icon: const Icon(Icons.send, size: 18),
          label: Text(widget.t.t('connections.invite')),
        ),
      ],
    );
  }
}

class _ConnectionTabs extends StatelessWidget {
  const _ConnectionTabs({required this.t});
  final I18Next t;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ConnectionBloc, ConnectionBlocState>(
      builder: (context, state) {
        if (state.loading) {
          return const Center(child: CircularProgressIndicator(color: Color(0xFF00F5A4)));
        }

        return DefaultTabController(
          length: 3,
          child: Column(
            children: [
              TabBar(
                indicatorColor: const Color(0xFF00F5A4),
                labelColor: const Color(0xFF00F5A4),
                unselectedLabelColor: Colors.grey,
                tabs: [
                  Tab(text: '${t.t('connections.accepted')} (${state.accepted.length})'),
                  Tab(text: '${t.t('connections.pending')} (${state.pending.length})'),
                  Tab(text: '${t.t('connections.sent')} (${state.sent.length})'),
                ],
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    _buildList(context, state.accepted, _ConnectionTileType.accepted),
                    _buildList(context, state.pending, _ConnectionTileType.pending),
                    _buildList(context, state.sent, _ConnectionTileType.sent),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildList(BuildContext context, List<ConnectionModel> items, _ConnectionTileType type) {
    if (items.isEmpty) {
      return Center(child: Text(t.t('connections.empty'), style: TextStyle(color: Colors.grey[500])));
    }
    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) {
        final conn = items[index];
        final label = type == _ConnectionTileType.pending ? conn.requesterId : conn.targetId;
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: const Color(0xFF00F5A4).withValues(alpha: 0.2),
            child: Text(label.isNotEmpty ? label[0].toUpperCase() : '?', style: const TextStyle(color: Color(0xFF00F5A4))),
          ),
          title: Text(label),
          subtitle: Text(conn.createdAt?.toLocal().toString().split('.').first ?? '', style: TextStyle(fontSize: 11, color: Colors.grey[500])),
          trailing: _buildActions(context, conn, type),
        );
      },
    );
  }

  Widget? _buildActions(BuildContext context, ConnectionModel conn, _ConnectionTileType type) {
    switch (type) {
      case _ConnectionTileType.pending:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.check_circle, color: Colors.greenAccent),
              tooltip: t.t('connections.accept'),
              onPressed: () => context.read<ConnectionBloc>().add(AcceptInvitation(conn.id!)),
            ),
            IconButton(
              icon: const Icon(Icons.cancel, color: Colors.redAccent),
              tooltip: t.t('connections.reject'),
              onPressed: () => context.read<ConnectionBloc>().add(RejectInvitation(conn.id!)),
            ),
          ],
        );
      case _ConnectionTileType.accepted:
        return IconButton(
          icon: const Icon(Icons.person_remove, color: Colors.redAccent),
          tooltip: t.t('connections.remove'),
          onPressed: () => context.read<ConnectionBloc>().add(RemoveConnection(conn.id!)),
        );
      case _ConnectionTileType.sent:
        return null;
    }
  }
}

enum _ConnectionTileType { accepted, pending, sent }
