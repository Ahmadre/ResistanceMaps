import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:i18next/i18next.dart';
import '../../auth/application/auth_bloc.dart';
import '../../groups/group_bloc.dart';
import '../../groups/group_model.dart';

class GroupsPage extends StatelessWidget {
  const GroupsPage({super.key});

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
                const Icon(Icons.group, size: 64, color: Color(0xFF00F5A4)),
                const SizedBox(height: 16),
                Text(t.t('groups.loginRequired'), style: TextStyle(color: Colors.grey[400], fontSize: 16)),
              ],
            ),
          );
        }
        return BlocBuilder<GroupBloc, GroupState>(
          builder: (context, state) {
            final selected = state.selectedGroup;
            if (selected == null) {
              return _GroupEmptyState(
                onCreateGroup: () => _showCreateGroupDialog(context, t),
              );
            }
            return _GroupDetailView(
              group: selected,
              members: state.members,
              onEdit: () => _showEditGroupDialog(context, t, selected),
              onDelete: () => _confirmDeleteGroup(context, t, selected.id!),
              onAddMember: () => _showAddMemberDialog(context, t, selected.id!),
            );
          },
        );
      },
    );
  }

  void _showCreateGroupDialog(BuildContext context, I18Next t) {
    final nameCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1B1F),
        title: Text(t.t('groups.createTitle')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameCtrl, decoration: InputDecoration(labelText: t.t('groups.name'))),
            const SizedBox(height: 12),
            TextField(controller: descCtrl, decoration: InputDecoration(labelText: t.t('common.description')), maxLines: 3),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: Text(t.t('common.cancel'))),
          TextButton(
            onPressed: () {
              final name = nameCtrl.text.trim();
              if (name.isEmpty) return;
              context.read<GroupBloc>().add(CreateGroup(name: name, description: descCtrl.text.trim().isNotEmpty ? descCtrl.text.trim() : null));
              Navigator.of(ctx).pop();
            },
            child: Text(t.t('common.create'), style: const TextStyle(color: Color(0xFF00F5A4))),
          ),
        ],
      ),
    );
  }

  void _showEditGroupDialog(BuildContext context, I18Next t, GroupModel group) {
    final nameCtrl = TextEditingController(text: group.name);
    final descCtrl = TextEditingController(text: group.description ?? '');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1B1F),
        title: Text(t.t('groups.editTitle')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameCtrl, decoration: InputDecoration(labelText: t.t('groups.name'))),
            const SizedBox(height: 12),
            TextField(controller: descCtrl, decoration: InputDecoration(labelText: t.t('common.description')), maxLines: 3),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: Text(t.t('common.cancel'))),
          TextButton(
            onPressed: () {
              final name = nameCtrl.text.trim();
              if (name.isEmpty) return;
              context.read<GroupBloc>().add(UpdateGroup(group.id!, name: name, description: descCtrl.text.trim().isNotEmpty ? descCtrl.text.trim() : null));
              Navigator.of(ctx).pop();
            },
            child: Text(t.t('common.save'), style: const TextStyle(color: Color(0xFF00F5A4))),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteGroup(BuildContext context, I18Next t, String id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1B1F),
        title: Text(t.t('groups.deleteTitle')),
        content: Text(t.t('groups.deleteContent')),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: Text(t.t('common.cancel'))),
          TextButton(
            onPressed: () {
              context.read<GroupBloc>().add(DeleteGroup(id));
              Navigator.of(ctx).pop();
            },
            child: Text(t.t('common.delete'), style: const TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }

  void _showAddMemberDialog(BuildContext context, I18Next t, String groupId) {
    final userIdCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1B1F),
        title: Text(t.t('groups.addMember')),
        content: TextField(controller: userIdCtrl, decoration: InputDecoration(labelText: t.t('groups.userId'))),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: Text(t.t('common.cancel'))),
          TextButton(
            onPressed: () {
              final uid = userIdCtrl.text.trim();
              if (uid.isEmpty) return;
              context.read<GroupBloc>().add(AddGroupMember(groupId, uid));
              Navigator.of(ctx).pop();
            },
            child: Text(t.t('common.add'), style: const TextStyle(color: Color(0xFF00F5A4))),
          ),
        ],
      ),
    );
  }
}

class _GroupEmptyState extends StatelessWidget {
  const _GroupEmptyState({required this.onCreateGroup});
  final VoidCallback onCreateGroup;

  @override
  Widget build(BuildContext context) {
    final t = I18Next.of(context)!;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.group_outlined, size: 64, color: Colors.grey[600]),
          const SizedBox(height: 16),
          Text(t.t('groups.selectHint'), style: TextStyle(color: Colors.grey[400], fontSize: 14)),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00F5A4), foregroundColor: Colors.black),
            onPressed: onCreateGroup,
            icon: const Icon(Icons.add),
            label: Text(t.t('groups.createTitle')),
          ),
        ],
      ),
    );
  }
}

class _GroupDetailView extends StatelessWidget {
  const _GroupDetailView({required this.group, required this.members, required this.onEdit, required this.onDelete, required this.onAddMember});
  final GroupModel group;
  final List<GroupMemberModel> members;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onAddMember;

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
              Expanded(child: Text(group.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold))),
              IconButton(icon: const Icon(Icons.edit, color: Color(0xFF00F5A4)), onPressed: onEdit, tooltip: t.t('common.edit')),
              IconButton(icon: const Icon(Icons.delete, color: Colors.redAccent), onPressed: onDelete, tooltip: t.t('common.delete')),
            ],
          ),
          if (group.description != null) ...[
            const SizedBox(height: 8),
            Text(group.description!, style: TextStyle(color: Colors.grey[400])),
          ],
          const SizedBox(height: 24),
          Row(
            children: [
              Text(t.t('groups.members'), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(color: const Color(0xFF00F5A4).withValues(alpha: 0.15), borderRadius: BorderRadius.circular(8)),
                child: Text('${members.length}', style: const TextStyle(fontSize: 12, color: Color(0xFF00F5A4))),
              ),
              const Spacer(),
              TextButton.icon(onPressed: onAddMember, icon: const Icon(Icons.person_add, size: 18), label: Text(t.t('groups.addMember'))),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              itemCount: members.length,
              itemBuilder: (context, index) {
                final member = members[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: const Color(0xFF00F5A4).withValues(alpha: 0.2),
                    child: Text(member.userId.isNotEmpty ? member.userId[0].toUpperCase() : '?', style: const TextStyle(color: Color(0xFF00F5A4))),
                  ),
                  title: Text(member.userId),
                  subtitle: Text(groupRoleToString(member.role), style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (member.role == GroupRole.member)
                        IconButton(
                          icon: const Icon(Icons.arrow_upward, size: 18, color: Color(0xFF00F5A4)),
                          tooltip: t.t('groups.promote'),
                          onPressed: () => context.read<GroupBloc>().add(PromoteGroupMember(group.id!, member.userId)),
                        ),
                      if (member.role == GroupRole.admin)
                        IconButton(
                          icon: const Icon(Icons.arrow_downward, size: 18, color: Colors.orangeAccent),
                          tooltip: t.t('groups.demote'),
                          onPressed: () => context.read<GroupBloc>().add(DemoteGroupMember(group.id!, member.userId)),
                        ),
                      if (member.role != GroupRole.owner)
                        IconButton(
                          icon: const Icon(Icons.remove_circle_outline, size: 18, color: Colors.redAccent),
                          tooltip: t.t('groups.removeMember'),
                          onPressed: () => context.read<GroupBloc>().add(RemoveGroupMember(group.id!, member.userId)),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
