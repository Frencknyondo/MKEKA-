import 'package:flutter/material.dart';
import '../../models/user_model.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import '../../utils/app_theme.dart';
import '../../widgets/common_widgets.dart';

class AdminDashboard extends StatefulWidget {
  final AppUser admin;

  const AdminDashboard({super.key, required this.admin});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _selectedSection = 0;

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= 820;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F5F7),
      appBar: wide
          ? null
          : AppBar(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              iconTheme: const IconThemeData(color: Colors.black),
              titleTextStyle: const TextStyle(
                color: Colors.black,
                fontSize: 15,
                fontWeight: FontWeight.w800,
              ),
              title: const Text('Mkeka Plus Admin'),
            ),
      drawer: wide
          ? null
          : Drawer(
              child: _AdminSidebar(
                selected: _selectedSection,
                onSelected: (index) {
                  setState(() => _selectedSection = index);
                  Navigator.pop(context);
                },
              ),
            ),
      body: Row(
        children: [
          if (wide)
            SizedBox(
              width: 250,
              child: _AdminSidebar(
                selected: _selectedSection,
                onSelected: (index) => setState(() => _selectedSection = index),
              ),
            ),
          Expanded(
            child: _AdminUsersView(admin: widget.admin),
          ),
        ],
      ),
    );
  }
}

class _AdminSidebar extends StatelessWidget {
  final int selected;
  final ValueChanged<int>? onSelected;

  const _AdminSidebar({
    required this.selected,
    this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(18, 22, 18, 18),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: const BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                  ),
                  child: const Icon(
                    Icons.sports_soccer,
                    color: AppColors.neonGreen,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'Mkeka Admin',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),
            _SidebarItem(
              icon: Icons.people_alt_outlined,
              label: 'Users',
              selected: selected == 0,
              onTap: () => onSelected?.call(0),
            ),
            _SidebarItem(
              icon: Icons.receipt_long_outlined,
              label: 'Mkekas',
              selected: selected == 1,
              onTap: () => onSelected?.call(1),
              disabled: true,
            ),
            _SidebarItem(
              icon: Icons.workspace_premium_outlined,
              label: 'VIP',
              selected: selected == 2,
              onTap: () => onSelected?.call(2),
              disabled: true,
            ),
            _SidebarItem(
              icon: Icons.analytics_outlined,
              label: 'Analytics',
              selected: selected == 3,
              onTap: () => onSelected?.call(3),
              disabled: true,
            ),
            const Spacer(),
            const _SidebarItem(
              icon: Icons.logout,
              label: 'Logout',
              selected: false,
              onTap: AuthService.signOut,
              danger: true,
            ),
          ],
        ),
      ),
    );
  }
}

class _SidebarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback? onTap;
  final bool disabled;
  final bool danger;

  const _SidebarItem({
    required this.icon,
    required this.label,
    required this.selected,
    this.onTap,
    this.disabled = false,
    this.danger = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = danger
        ? AppColors.lost
        : selected
            ? Colors.black
            : const Color(0xFF737987);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: disabled ? null : onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: selected ? const Color(0xFFFFF1C7) : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: disabled ? const Color(0xFFB8BDC8) : color,
                    fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AdminUsersView extends StatelessWidget {
  final AppUser admin;

  const _AdminUsersView({required this.admin});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<AppUser>>(
      stream: FirestoreService.streamUsers(),
      builder: (context, snapshot) {
        final users = snapshot.data ?? [];
        final tipsters = users.where((u) => u.role == UserRole.tipster).length;
        final admins = users.where((u) => u.role == UserRole.admin).length;
        final vip = users.where((u) => u.isSubscriptionActive).length;

        return ListView(
          padding: const EdgeInsets.fromLTRB(22, 22, 22, 32),
          children: [
            _AdminHeader(
              admin: admin,
              onAddUser: () => _showAddUserDialog(context),
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _StatCard(label: 'Users', value: '${users.length}'),
                _StatCard(label: 'Tipsters', value: '$tipsters'),
                _StatCard(label: 'Admins', value: '$admins'),
                _StatCard(label: 'VIP Active', value: '$vip'),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFE6E8EE)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.fromLTRB(18, 18, 18, 10),
                    child: Text(
                      'Manage Users',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  if (snapshot.connectionState == ConnectionState.waiting)
                    const Padding(
                      padding: EdgeInsets.all(28),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else if (users.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(24),
                      child: Text(
                        'No users found.',
                        style: TextStyle(color: Color(0xFF737987)),
                      ),
                    )
                  else
                    ...users.map((user) => _UserRow(user: user)),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showAddUserDialog(BuildContext context) async {
    final nameCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    var role = UserRole.user;

    await showDialog<void>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              title: const Text(
                'Add User Record',
                style: TextStyle(color: Colors.black),
              ),
              content: SizedBox(
                width: 420,
                child: Theme(
                  data: Theme.of(context).copyWith(
                    inputDecorationTheme: InputDecorationTheme(
                      labelStyle: const TextStyle(
                        color: Color(0xFF737987),
                        fontSize: 12,
                      ),
                      filled: true,
                      fillColor: const Color(0xFFF4F5F7),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            const BorderSide(color: Color(0xFFE6E8EE)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            const BorderSide(color: Color(0xFFE6E8EE)),
                      ),
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: nameCtrl,
                        style:
                            const TextStyle(color: Colors.black, fontSize: 13),
                        decoration: const InputDecoration(labelText: 'Name'),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: emailCtrl,
                        style:
                            const TextStyle(color: Colors.black, fontSize: 13),
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(labelText: 'Email'),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<UserRole>(
                        initialValue: role,
                        decoration: const InputDecoration(labelText: 'Role'),
                        items: UserRole.values
                            .map(
                              (item) => DropdownMenuItem(
                                value: item,
                                child: Text(item.name),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setDialogState(() => role = value);
                          }
                        },
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'This creates a Firestore user record. Auth account creation needs a backend Admin SDK later.',
                        style:
                            TextStyle(color: Color(0xFF737987), fontSize: 11),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (nameCtrl.text.trim().isEmpty ||
                        emailCtrl.text.trim().isEmpty) {
                      showError(context, 'Weka jina na email.');
                      return;
                    }
                    await FirestoreService.createUserRecord(
                      name: nameCtrl.text,
                      email: emailCtrl.text,
                      role: role,
                    );
                    if (context.mounted) Navigator.pop(context);
                  },
                  child: const Text('Add'),
                ),
              ],
            );
          },
        );
      },
    );

    nameCtrl.dispose();
    emailCtrl.dispose();
  }
}

class _AdminHeader extends StatelessWidget {
  final AppUser admin;
  final VoidCallback onAddUser;

  const _AdminHeader({
    required this.admin,
    required this.onAddUser,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Your Dashboard',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Karibu ${admin.name.isEmpty ? 'Admin' : admin.name}',
                style: const TextStyle(color: Color(0xFF737987)),
              ),
            ],
          ),
        ),
        ElevatedButton.icon(
          onPressed: onAddUser,
          icon: const Icon(Icons.person_add_alt_1),
          label: const Text('Add User'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            minimumSize: const Size(0, 46),
            padding: const EdgeInsets.symmetric(horizontal: 16),
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;

  const _StatCard({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 160,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(color: Color(0xFFB8BDC8), fontSize: 11),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                color: Color(0xFFFFD66B),
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _UserRow extends StatefulWidget {
  final AppUser user;

  const _UserRow({required this.user});

  @override
  State<_UserRow> createState() => _UserRowState();
}

class _UserRowState extends State<_UserRow> {
  bool _saving = false;

  @override
  Widget build(BuildContext context) {
    final user = widget.user;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Color(0xFFE6E8EE))),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: const Color(0xFFFFF1C7),
            child: Text(
              user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.name.isEmpty ? 'No name' : user.name,
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  user.email,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Color(0xFF737987), fontSize: 11),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          if (_saving)
            const SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          else
            DropdownButton<UserRole>(
              value: user.role,
              underline: const SizedBox.shrink(),
              borderRadius: BorderRadius.circular(12),
              items: UserRole.values
                  .map(
                    (role) => DropdownMenuItem(
                      value: role,
                      child: Text(role.name),
                    ),
                  )
                  .toList(),
              onChanged: (role) async {
                if (role == null || role == user.role) return;
                setState(() => _saving = true);
                await FirestoreService.updateUserRole(
                  userId: user.id,
                  role: role,
                );
                if (mounted) setState(() => _saving = false);
              },
            ),
        ],
      ),
    );
  }
}
