import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:i18next/i18next.dart';
import '../../auth/application/auth_bloc.dart';
import '../../lists/map_list_bloc.dart';
import '../../lists/map_list_model.dart';

class ListsPage extends StatelessWidget {
  const ListsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final t = I18Next.of(context)!;
    return BlocBuilder<MapListBloc, MapListState>(
      builder: (context, state) {
        final selected = state.selectedList;
        if (selected == null) {
          return _ListEmptyState(onCreateList: () => _showCreateListDialog(context, t));
        }
        return _ListDetailView(
          list: selected,
          onEdit: () => _showEditListDialog(context, t, selected),
          onDelete: () => _confirmDeleteList(context, t, selected.id!),
        );
      },
    );
  }

  void _showCreateListDialog(BuildContext context, I18Next t) {
    final authState = context.read<AuthBloc>().state;
    if (authState.session == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t.t('lists.loginRequired'))));
      return;
    }
    final titleCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1B1F),
        title: Text(t.t('lists.createTitle')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: titleCtrl, decoration: InputDecoration(labelText: t.t('common.title'))),
            const SizedBox(height: 12),
            TextField(controller: descCtrl, decoration: InputDecoration(labelText: t.t('common.description')), maxLines: 3),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: Text(t.t('common.cancel'))),
          TextButton(
            onPressed: () {
              final title = titleCtrl.text.trim();
              if (title.isEmpty) return;
              context.read<MapListBloc>().add(CreateMapList(title: title, description: descCtrl.text.trim().isNotEmpty ? descCtrl.text.trim() : null));
              Navigator.of(ctx).pop();
            },
            child: Text(t.t('common.create'), style: const TextStyle(color: Color(0xFF00F5A4))),
          ),
        ],
      ),
    );
  }

  void _showEditListDialog(BuildContext context, I18Next t, MapListModel list) {
    final titleCtrl = TextEditingController(text: list.title);
    final descCtrl = TextEditingController(text: list.description ?? '');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1B1F),
        title: Text(t.t('lists.editTitle')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: titleCtrl, decoration: InputDecoration(labelText: t.t('common.title'))),
            const SizedBox(height: 12),
            TextField(controller: descCtrl, decoration: InputDecoration(labelText: t.t('common.description')), maxLines: 3),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: Text(t.t('common.cancel'))),
          TextButton(
            onPressed: () {
              final title = titleCtrl.text.trim();
              if (title.isEmpty) return;
              context.read<MapListBloc>().add(UpdateMapList(list.id!, title: title, description: descCtrl.text.trim().isNotEmpty ? descCtrl.text.trim() : null));
              Navigator.of(ctx).pop();
            },
            child: Text(t.t('common.save'), style: const TextStyle(color: Color(0xFF00F5A4))),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteList(BuildContext context, I18Next t, String id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1B1F),
        title: Text(t.t('lists.deleteTitle')),
        content: Text(t.t('lists.deleteContent')),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: Text(t.t('common.cancel'))),
          TextButton(
            onPressed: () {
              context.read<MapListBloc>().add(DeleteMapList(id));
              Navigator.of(ctx).pop();
            },
            child: Text(t.t('common.delete'), style: const TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }
}

class _ListEmptyState extends StatelessWidget {
  const _ListEmptyState({required this.onCreateList});
  final VoidCallback onCreateList;

  @override
  Widget build(BuildContext context) {
    final t = I18Next.of(context)!;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.list_alt, size: 64, color: Colors.grey[600]),
          const SizedBox(height: 16),
          Text(t.t('lists.selectHint'), style: TextStyle(color: Colors.grey[400], fontSize: 14)),
          const SizedBox(height: 24),
          BlocBuilder<AuthBloc, AuthState>(
            builder: (context, authState) {
              if (authState.session == null) return const SizedBox.shrink();
              return ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00F5A4), foregroundColor: Colors.black),
                onPressed: onCreateList,
                icon: const Icon(Icons.add),
                label: Text(t.t('lists.createTitle')),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _ListDetailView extends StatelessWidget {
  const _ListDetailView({required this.list, required this.onEdit, required this.onDelete});
  final MapListModel list;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final t = I18Next.of(context)!;
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(list.title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold))),
              BlocBuilder<AuthBloc, AuthState>(
                builder: (context, authState) {
                  if (authState.session == null) return const SizedBox.shrink();
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(icon: const Icon(Icons.edit, color: Color(0xFF00F5A4)), onPressed: onEdit, tooltip: t.t('common.edit')),
                      IconButton(icon: const Icon(Icons.delete, color: Colors.redAccent), onPressed: onDelete, tooltip: t.t('common.delete')),
                    ],
                  );
                },
              ),
            ],
          ),
          if (list.description != null) ...[
            const SizedBox(height: 8),
            Text(list.description!, style: TextStyle(color: Colors.grey[400])),
          ],
          const SizedBox(height: 24),
          _InfoRow(icon: Icons.location_on, label: t.t('lists.markers'), value: '${list.markerIds.length}'),
          const SizedBox(height: 8),
          _InfoRow(icon: Icons.route, label: t.t('lists.routes'), value: '${list.routeIds.length}'),
          if (list.hasPassword) ...[
            const SizedBox(height: 8),
            _InfoRow(icon: Icons.vpn_key, label: t.t('lists.passwordProtected'), value: '', iconColor: Colors.orangeAccent),
          ],
          if (list.expiresAt != null) ...[
            const SizedBox(height: 8),
            _InfoRow(icon: Icons.timer, label: t.t('lists.expiresAt'), value: list.expiresAt!.toLocal().toString().split('.').first),
          ],
          if (list.shareToken != null) ...[
            const SizedBox(height: 8),
            _InfoRow(icon: Icons.link, label: t.t('lists.shareLink'), value: list.shareToken!),
          ],
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.label, required this.value, this.iconColor});
  final IconData icon;
  final String label;
  final String value;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: iconColor ?? const Color(0xFF00F5A4)),
        const SizedBox(width: 8),
        Text(label, style: TextStyle(color: Colors.grey[400], fontSize: 13)),
        if (value.isNotEmpty) ...[
          const SizedBox(width: 8),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
        ],
      ],
    );
  }
}
