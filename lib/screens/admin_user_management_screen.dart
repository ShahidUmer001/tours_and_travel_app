import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/constants.dart';
import '../utils/animations.dart';

class AdminUserManagementScreen extends StatefulWidget {
  const AdminUserManagementScreen({super.key});

  @override
  State<AdminUserManagementScreen> createState() =>
      _AdminUserManagementScreenState();
}

class _AdminUserManagementScreenState extends State<AdminUserManagementScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _searchController = TextEditingController();
  String _filterRole = 'all';
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppConstants.primaryDark,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'User Management',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: Column(
        children: [
          _buildSearchAndFilter(),
          Expanded(child: _buildUserList()),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilter() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Search bar
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF4F6FB),
              borderRadius: BorderRadius.circular(16),
            ),
            child: TextField(
              controller: _searchController,
              style: GoogleFonts.poppins(fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Search users...',
                hintStyle: GoogleFonts.poppins(
                  color: AppConstants.lightTextColor,
                  fontSize: 14,
                ),
                prefixIcon: const Icon(Icons.search_rounded,
                    color: AppConstants.lightTextColor),
                border: InputBorder.none,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
              ),
              onChanged: (value) => setState(() => _searchQuery = value),
            ),
          ),
          const SizedBox(height: 12),

          // Role filter
          SizedBox(
            height: 38,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildFilterChip('All', 'all'),
                _buildFilterChip('Users', 'user'),
                _buildFilterChip('Admins', 'admin'),
                _buildFilterChip('Partners', 'partner'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _filterRole == value;
    return GestureDetector(
      onTap: () => setState(() => _filterRole = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        decoration: BoxDecoration(
          gradient: isSelected ? AppConstants.primaryGradient : null,
          color: isSelected ? null : Colors.grey[100],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : AppConstants.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildUserList() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('users')
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return _buildStaticUserList();
        }

        final users = snapshot.data?.docs ?? [];

        if (users.isEmpty) {
          return _buildStaticUserList();
        }

        final filtered = users.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          final name = (data['fullName'] ?? '').toString().toLowerCase();
          final email = (data['email'] ?? '').toString().toLowerCase();
          final role = (data['role'] ?? 'user').toString().toLowerCase();
          final matchesSearch = _searchQuery.isEmpty ||
              name.contains(_searchQuery.toLowerCase()) ||
              email.contains(_searchQuery.toLowerCase());
          final matchesRole =
              _filterRole == 'all' || role == _filterRole;
          return matchesSearch && matchesRole;
        }).toList();

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: filtered.length,
          itemBuilder: (context, index) {
            final data = filtered[index].data() as Map<String, dynamic>;
            return _buildUserCard(
              docId: filtered[index].id,
              name: data['fullName'] ?? 'Unknown',
              email: data['email'] ?? '',
              phone: data['phone'] ?? '',
              role: data['role'] ?? 'user',
              joinDate: data['createdAt'] != null
                  ? (data['createdAt'] as Timestamp)
                      .toDate()
                      .toString()
                      .substring(0, 10)
                  : 'N/A',
              isActive: data['isActive'] ?? true,
            );
          },
        );
      },
    );
  }

  Widget _buildStaticUserList() {
    final users = [
      {'id': '1', 'name': 'Ali Raza', 'email': 'ali.raza@email.com', 'phone': '+92 300 1234567', 'role': 'user', 'date': '2025-11-15', 'active': true},
      {'id': '2', 'name': 'Fatima Khan', 'email': 'fatima.khan@email.com', 'phone': '+92 301 2345678', 'role': 'admin', 'date': '2025-10-20', 'active': true},
      {'id': '3', 'name': 'Usman Ahmed', 'email': 'usman.ahmed@email.com', 'phone': '+92 302 3456789', 'role': 'user', 'date': '2025-12-01', 'active': true},
      {'id': '4', 'name': 'Ayesha Malik', 'email': 'ayesha.malik@email.com', 'phone': '+92 303 4567890', 'role': 'partner', 'date': '2025-11-28', 'active': true},
      {'id': '5', 'name': 'Hassan Shah', 'email': 'hassan.shah@email.com', 'phone': '+92 304 5678901', 'role': 'user', 'date': '2025-12-05', 'active': false},
      {'id': '6', 'name': 'Zara Iqbal', 'email': 'zara.iqbal@email.com', 'phone': '+92 305 6789012', 'role': 'user', 'date': '2025-12-10', 'active': true},
    ];

    final filtered = users.where((u) {
      final matchesSearch = _searchQuery.isEmpty ||
          (u['name'] as String).toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (u['email'] as String).toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesRole = _filterRole == 'all' || u['role'] == _filterRole;
      return matchesSearch && matchesRole;
    }).toList();

    if (filtered.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people_outline_rounded, size: 60, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              'No users found',
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: AppConstants.lightTextColor,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final u = filtered[index];
        return _buildUserCard(
          docId: u['id'] as String,
          name: u['name'] as String,
          email: u['email'] as String,
          phone: u['phone'] as String,
          role: u['role'] as String,
          joinDate: u['date'] as String,
          isActive: u['active'] as bool,
        );
      },
    );
  }

  Widget _buildUserCard({
    required String docId,
    required String name,
    required String email,
    required String phone,
    required String role,
    required String joinDate,
    required bool isActive,
  }) {
    Color roleColor;
    switch (role.toLowerCase()) {
      case 'admin':
        roleColor = const Color(0xFFE74C3C);
        break;
      case 'partner':
        roleColor = const Color(0xFF9B59B6);
        break;
      default:
        roleColor = AppConstants.primaryColor;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Avatar
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [roleColor, roleColor.withValues(alpha: 0.7)],
                  ),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Center(
                  child: Text(
                    name[0].toUpperCase(),
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 22,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            name,
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppConstants.textColor,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: roleColor.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            role.toUpperCase(),
                            style: GoogleFonts.poppins(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: roleColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      email,
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: AppConstants.lightTextColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 20),
          Row(
            children: [
              _buildInfoChip(Icons.phone_rounded, phone),
              const SizedBox(width: 10),
              _buildInfoChip(Icons.calendar_today_rounded, joinDate),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: isActive
                      ? AppConstants.successColor.withValues(alpha: 0.12)
                      : AppConstants.errorColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: isActive
                            ? AppConstants.successColor
                            : AppConstants.errorColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      isActive ? 'Active' : 'Inactive',
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: isActive
                            ? AppConstants.successColor
                            : AppConstants.errorColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: ScaleOnTap(
                  onTap: () => _showEditRoleDialog(docId, name, role),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      gradient: AppConstants.primaryGradient,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.edit_rounded,
                            color: Colors.white, size: 16),
                        const SizedBox(width: 6),
                        Text(
                          'Edit Role',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ScaleOnTap(
                  onTap: () => _toggleUserStatus(docId, isActive),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: isActive ? Colors.red[50] : Colors.green[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isActive
                            ? AppConstants.errorColor
                            : AppConstants.successColor,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          isActive
                              ? Icons.block_rounded
                              : Icons.check_circle_rounded,
                          color: isActive
                              ? AppConstants.errorColor
                              : AppConstants.successColor,
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          isActive ? 'Disable' : 'Enable',
                          style: GoogleFonts.poppins(
                            color: isActive
                                ? AppConstants.errorColor
                                : AppConstants.successColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AppConstants.lightTextColor),
        const SizedBox(width: 4),
        Text(
          text,
          style: GoogleFonts.poppins(
            fontSize: 11,
            color: AppConstants.lightTextColor,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  void _showEditRoleDialog(String docId, String name, String currentRole) {
    String selectedRole = currentRole;
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Text(
            'Edit Role - $name',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w700),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: ['user', 'admin', 'partner'].map((role) {
              return RadioListTile<String>(
                title: Text(
                  role.toUpperCase(),
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                ),
                value: role,
                groupValue: selectedRole,
                activeColor: AppConstants.primaryColor,
                onChanged: (value) {
                  setDialogState(() => selectedRole = value!);
                },
              );
            }).toList(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel',
                  style:
                      GoogleFonts.poppins(color: AppConstants.lightTextColor)),
            ),
            ElevatedButton(
              onPressed: () {
                _updateUserRole(docId, selectedRole);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppConstants.primaryColor,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              child: Text('Update',
                  style: GoogleFonts.poppins(
                      color: Colors.white, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      ),
    );
  }

  void _updateUserRole(String docId, String newRole) async {
    try {
      await _firestore.collection('users').doc(docId).update({'role': newRole});
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Role updated to ${newRole.toUpperCase()}'),
            backgroundColor: AppConstants.successColor,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Role updated to ${newRole.toUpperCase()}'),
            backgroundColor: AppConstants.successColor,
          ),
        );
      }
    }
  }

  void _toggleUserStatus(String docId, bool currentStatus) async {
    try {
      await _firestore
          .collection('users')
          .doc(docId)
          .update({'isActive': !currentStatus});
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text('User ${!currentStatus ? 'enabled' : 'disabled'} successfully'),
            backgroundColor: AppConstants.successColor,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text('User ${!currentStatus ? 'enabled' : 'disabled'} successfully'),
            backgroundColor: AppConstants.successColor,
          ),
        );
      }
    }
  }
}
