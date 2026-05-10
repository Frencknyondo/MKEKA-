import 'package:flutter/material.dart';
import '../../models/mkeka_model.dart';
import '../../models/tip_model.dart';
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
            child: IndexedStack(
              index: _selectedSection,
              children: [
                _AdminUsersView(admin: widget.admin),
                const _AdminPostsView(),
                const _AdminTipsView(),
                const _ComingSoonView(title: 'VIP'),
                const _ComingSoonView(title: 'Analytics'),
              ],
            ),
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
              icon: Icons.post_add_outlined,
              label: 'Posts',
              selected: selected == 1,
              onTap: () => onSelected?.call(1),
            ),
            _SidebarItem(
              icon: Icons.tips_and_updates_outlined,
              label: 'Tips',
              selected: selected == 2,
              onTap: () => onSelected?.call(2),
            ),
            _SidebarItem(
              icon: Icons.workspace_premium_outlined,
              label: 'VIP',
              selected: selected == 3,
              onTap: () => onSelected?.call(3),
              disabled: true,
            ),
            _SidebarItem(
              icon: Icons.analytics_outlined,
              label: 'Analytics',
              selected: selected == 4,
              onTap: () => onSelected?.call(4),
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
                        borderSide: const BorderSide(color: Color(0xFFE6E8EE)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFE6E8EE)),
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

class _AdminPostsView extends StatelessWidget {
  const _AdminPostsView();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Mkeka>>(
      stream: FirestoreService.streamAllMkekas(),
      builder: (context, snapshot) {
        final posts = snapshot.data ?? [];

        return ListView(
          padding: const EdgeInsets.fromLTRB(22, 22, 22, 32),
          children: [
            const Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Mkeka Manager',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Manage all mkekas as stored in the database.',
                        style: TextStyle(color: Color(0xFF737987)),
                      ),
                    ],
                  ),
                ),
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
                      'Manage Posts',
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
                  else if (posts.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(24),
                      child: Text(
                        'No posts found.',
                        style: TextStyle(color: Color(0xFF737987)),
                      ),
                    )
                  else
                    ...posts.map((post) => _PostAdminRow(post: post)),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _AdminTipsView extends StatelessWidget {
  const _AdminTipsView();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<AppTip>>(
      stream: FirestoreService.streamTips(includeInactive: true),
      builder: (context, snapshot) {
        final tips = snapshot.data ?? [];
        final freeCount = tips.where((tip) => !tip.isVip).length;
        final vipCount = tips.where((tip) => tip.isVip).length;
        final activeCount = tips.where((tip) => tip.isActive).length;

        return ListView(
          padding: const EdgeInsets.fromLTRB(22, 22, 22, 32),
          children: [
            _TipsHeader(onAddTip: () => _showTipDialog(context)),
            const SizedBox(height: 20),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _StatCard(label: 'Tips', value: '${tips.length}'),
                _StatCard(label: 'Free', value: '$freeCount'),
                _StatCard(label: 'VIP', value: '$vipCount'),
                _StatCard(label: 'Active', value: '$activeCount'),
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
                      'Manage Tips',
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
                  else if (tips.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(24),
                      child: Text(
                        'Hakuna tips bado. Bonyeza Add Tip kuongeza ya kwanza.',
                        style: TextStyle(color: Color(0xFF737987)),
                      ),
                    )
                  else
                    ...tips.map(
                      (tip) => _TipAdminRow(
                        tip: tip,
                        onEdit: () => _showTipDialog(context, tip: tip),
                      ),
                    ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showTipDialog(BuildContext context, {AppTip? tip}) async {
    final titleCtrl = TextEditingController(text: tip?.title ?? '');
    final contentCtrl = TextEditingController(text: tip?.content ?? '');
    var isVip = tip?.isVip ?? false;
    var isActive = tip?.isActive ?? true;
    var saving = false;

    await showDialog<void>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              title: Text(
                tip == null ? 'Add Tip' : 'Edit Tip',
                style: const TextStyle(color: Colors.black),
              ),
              content: SizedBox(
                width: 460,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: titleCtrl,
                      style: const TextStyle(color: Colors.black, fontSize: 13),
                      decoration: const InputDecoration(labelText: 'Title'),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: contentCtrl,
                      style: const TextStyle(color: Colors.black, fontSize: 13),
                      minLines: 4,
                      maxLines: 7,
                      decoration: const InputDecoration(labelText: 'Tip body'),
                    ),
                    const SizedBox(height: 12),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('VIP Tip'),
                      subtitle: const Text('Only active VIP users can see it.'),
                      value: isVip,
                      onChanged: (value) => setDialogState(() => isVip = value),
                    ),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Active'),
                      subtitle: const Text('Visible inside the Tips screen.'),
                      value: isActive,
                      onChanged: (value) =>
                          setDialogState(() => isActive = value),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: saving ? null : () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: saving
                      ? null
                      : () async {
                          if (titleCtrl.text.trim().isEmpty ||
                              contentCtrl.text.trim().isEmpty) {
                            showError(context, 'Weka title na maelezo ya tip.');
                            return;
                          }

                          setDialogState(() => saving = true);
                          if (tip == null) {
                            await FirestoreService.addTip(
                              title: titleCtrl.text,
                              content: contentCtrl.text,
                              isVip: isVip,
                              isActive: isActive,
                            );
                          } else {
                            await FirestoreService.updateTip(
                              tipId: tip.id,
                              title: titleCtrl.text,
                              content: contentCtrl.text,
                              isVip: isVip,
                              isActive: isActive,
                            );
                          }
                          if (context.mounted) Navigator.pop(context);
                        },
                  child: Text(saving ? 'Saving...' : 'Save'),
                ),
              ],
            );
          },
        );
      },
    );

    titleCtrl.dispose();
    contentCtrl.dispose();
  }
}

class _TipsHeader extends StatelessWidget {
  final VoidCallback onAddTip;

  const _TipsHeader({required this.onAddTip});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Tips Manager',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Add, edit, publish, or remove betting tips.',
                style: TextStyle(color: Color(0xFF737987)),
              ),
            ],
          ),
        ),
        ElevatedButton.icon(
          onPressed: onAddTip,
          icon: const Icon(Icons.add),
          label: const Text('Add Tip'),
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

class _PostAdminRow extends StatefulWidget {
  final Mkeka post;

  const _PostAdminRow({required this.post});

  @override
  State<_PostAdminRow> createState() => _PostAdminRowState();
}

class _PostAdminRowState extends State<_PostAdminRow> {
  bool _saving = false;

  Future<void> _confirmDelete() async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text('Delete Post'),
        content: Text('Unataka kufuta "${widget.post.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.lost),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (shouldDelete != true) return;

    setState(() => _saving = true);
    await FirestoreService.deleteMkeka(widget.post.id);
    if (!mounted) return;
    setState(() => _saving = false);
    showSuccess(context, 'Post imefutwa.');
  }

  Future<void> _updateStatus(MkekaStatus status) async {
    setState(() => _saving = true);
    await FirestoreService.updateMkekaStatus(widget.post.id, status);
    if (!mounted) return;
    setState(() => _saving = false);
  }

  Future<void> _toggleFeatured() async {
    setState(() => _saving = true);
    await FirestoreService.toggleMkekaFeatured(
      widget.post.id,
      !widget.post.isFeatured,
    );
    if (!mounted) return;
    setState(() => _saving = false);
  }

  @override
  Widget build(BuildContext context) {
    final post = widget.post;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Color(0xFFE6E8EE))),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (post.imageUrls.isNotEmpty)
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                color: const Color(0xFFF4F5F7),
                image: DecorationImage(
                  image: NetworkImage(post.imageUrls.first),
                  fit: BoxFit.cover,
                ),
              ),
            )
          else
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                color: const Color(0xFFF4F5F7),
              ),
              child: const Icon(Icons.image_not_supported,
                  color: Color(0xFF737987)),
            ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  post.title,
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Tipster: ${post.tipsterName}',
                  style:
                      const TextStyle(color: Color(0xFF737987), fontSize: 12),
                ),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    _SmallPill(label: post.isVip ? 'VIP' : 'Free'),
                    _SmallPill(
                      label: post.statusLabel,
                      muted: post.status != MkekaStatus.pending,
                    ),
                    if (post.isFeatured) const _SmallPill(label: 'Featured'),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'Created: ${post.createdAt.day}/${post.createdAt.month}/${post.createdAt.year}',
                  style:
                      const TextStyle(color: Color(0xFF737987), fontSize: 11),
                ),
              ],
            ),
          ),
          if (_saving)
            const SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          else
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, color: Color(0xFF737987)),
              itemBuilder: (context) => [
                const PopupMenuItem(
                    value: 'pending', child: Text('Set Pending')),
                const PopupMenuItem(value: 'won', child: Text('Set Won')),
                const PopupMenuItem(value: 'lost', child: Text('Set Lost')),
                const PopupMenuItem(value: 'void', child: Text('Set Void')),
                PopupMenuItem(
                  value: 'toggle_featured',
                  child: Text(
                      post.isFeatured ? 'Remove Featured' : 'Mark Featured'),
                ),
                const PopupMenuItem(
                    value: 'delete', child: Text('Delete Post')),
              ],
              onSelected: (value) async {
                switch (value) {
                  case 'pending':
                    await _updateStatus(MkekaStatus.pending);
                    break;
                  case 'won':
                    await _updateStatus(MkekaStatus.won);
                    break;
                  case 'lost':
                    await _updateStatus(MkekaStatus.lost);
                    break;
                  case 'void':
                    await _updateStatus(MkekaStatus.void_);
                    break;
                  case 'toggle_featured':
                    await _toggleFeatured();
                    break;
                  case 'delete':
                    await _confirmDelete();
                    break;
                }
              },
            ),
        ],
      ),
    );
  }
}

class _TipAdminRow extends StatelessWidget {
  final AppTip tip;
  final VoidCallback onEdit;

  const _TipAdminRow({
    required this.tip,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Color(0xFFE6E8EE))),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: tip.isVip
                  ? AppColors.vipGold.withValues(alpha: 0.16)
                  : AppColors.neonGreen.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              tip.isVip
                  ? Icons.workspace_premium_outlined
                  : Icons.tips_and_updates_outlined,
              color: tip.isVip ? AppColors.vipGold : AppColors.neonGreen,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        tip.title,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    _SmallPill(label: tip.isVip ? 'VIP' : 'Free'),
                    const SizedBox(width: 6),
                    _SmallPill(
                      label: tip.isActive ? 'Active' : 'Hidden',
                      muted: !tip.isActive,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  tip.content,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF737987),
                    fontSize: 12,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Edit',
            onPressed: onEdit,
            icon: const Icon(Icons.edit_outlined),
          ),
          IconButton(
            tooltip: 'Delete',
            onPressed: () => _confirmDelete(context),
            icon: const Icon(Icons.delete_outline, color: AppColors.lost),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text('Delete Tip'),
        content: Text('Unataka kufuta "${tip.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.lost),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (shouldDelete == true) {
      await FirestoreService.deleteTip(tip.id);
      if (context.mounted) showSuccess(context, 'Tip imefutwa.');
    }
  }
}

class _SmallPill extends StatelessWidget {
  final String label;
  final bool muted;

  const _SmallPill({
    required this.label,
    this.muted = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: muted ? const Color(0xFFF4F5F7) : AppColors.surface,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: muted ? const Color(0xFF737987) : AppColors.neonGreen,
          fontSize: 10,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _ComingSoonView extends StatelessWidget {
  final String title;

  const _ComingSoonView({required this.title});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        '$title coming soon',
        style: const TextStyle(
          color: Color(0xFF737987),
          fontWeight: FontWeight.w700,
        ),
      ),
    );
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
                  style:
                      const TextStyle(color: Color(0xFF737987), fontSize: 11),
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
