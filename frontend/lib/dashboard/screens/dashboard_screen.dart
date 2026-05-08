import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:provider/provider.dart';
import 'package:animated_digit/animated_digit.dart';
import '../../services/api_service.dart';
import '../../models/models.dart';
import '../../services/auth_service.dart';
import 'package:go_router/go_router.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final ApiService _apiService = ApiService();
  late Future<AdminDashboardPayload> _dashboardFuture;

  @override
  void initState() {
    super.initState();
    _dashboardFuture = _apiService.getAdminDashboard();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth > 1000) {
            return _buildWebLayout();
          } else {
            return _buildMobileLayout();
          }
        },
      ),
    );
  }

  Widget _buildWebLayout() {
    return Row(
      children: [
        _buildSidebar(isWeb: true),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(40),
            child: _buildContent(),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout() {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'NUST Admin',
          style: GoogleFonts.inter(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: const Color(0xFF1E293B),
      ),
      drawer: Drawer(
        child: _buildSidebar(isWeb: false),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: _buildContent(),
      ),
    );
  }

  Widget _buildContent() {
    return FutureBuilder<AdminDashboardPayload>(
      future: _dashboardFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Symbols.error, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                Text('Error loading dashboard: ${snapshot.error}'),
                TextButton(
                  onPressed: () => setState(() => _dashboardFuture = _apiService.getAdminDashboard()),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }
        final data = snapshot.data!;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 32),
            _buildStatsGrid(data.summary),
            const SizedBox(height: 32),
            if (MediaQuery.of(context).size.width > 1000)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 2, child: _buildRecentDocuments(data.flaggedDocuments)),
                  const SizedBox(width: 32),
                  Expanded(flex: 1, child: _buildRecentUsers(data.recentUsers)),
                ],
              )
            else
              Column(
                children: [
                  _buildRecentDocuments(data.flaggedDocuments),
                  const SizedBox(height: 24),
                  _buildRecentUsers(data.recentUsers),
                ],
              ),
          ],
        );
      },
    );
  }

  Widget _buildSidebar({required bool isWeb}) {
    return Container(
      width: isWeb ? 280 : null,
      color: Colors.white,
      child: Column(
        children: [
          if (isWeb)
            Padding(
              padding: const EdgeInsets.all(32),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Symbols.dashboard, color: Colors.white),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'NUST Admin',
                    style: GoogleFonts.inter(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1E293B),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 16),
          _buildSidebarItem(Symbols.home, 'Overview', true, () => context.go('/admin')),
          _buildSidebarItem(Symbols.description, 'Documents', false, () => context.push('/admin/documents')),
          _buildSidebarItem(Symbols.group, 'Users', false, () => context.push('/admin/users')),
          _buildSidebarItem(Symbols.analytics, 'Analytics', false, () => context.push('/admin/analytics')),
          _buildSidebarItem(Symbols.settings, 'Settings', false, () {}),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.all(32),
            child: _buildSidebarItem(Symbols.logout, 'Logout', false, () => context.read<AuthService>().logout(), isLogout: true),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebarItem(IconData icon, String label, bool isActive, VoidCallback onTap, {bool isLogout = false}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: isActive ? Theme.of(context).primaryColor.withValues(alpha: 0.1) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: isActive ? Theme.of(context).primaryColor : const Color(0xFF64748B),
          size: 20,
        ),
        title: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
            color: isActive ? Theme.of(context).primaryColor : const Color(0xFF64748B),
          ),
        ),
        onTap: onTap,
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Dashboard Overview',
              style: GoogleFonts.inter(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Welcome back, here is what is happening today.',
              style: GoogleFonts.inter(
                fontSize: 16,
                color: const Color(0xFF64748B),
              ),
            ),
          ],
        ),
        if (MediaQuery.of(context).size.width > 600)
          Row(
            children: [
              _buildHeaderIconButton(Symbols.notifications),
              const SizedBox(width: 16),
              _buildHeaderIconButton(Symbols.search),
              const SizedBox(width: 16),
              const CircleAvatar(
                radius: 20,
                backgroundImage: NetworkImage('https://ui-avatars.com/api/?name=Admin+User&background=FF3D1B&color=fff'),
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildHeaderIconButton(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Icon(icon, size: 20, color: const Color(0xFF64748B)),
    );
  }

  Widget _buildStatsGrid(Map<String, dynamic> summary) {
    final isWeb = MediaQuery.of(context).size.width > 1000;
    return GridView.count(
      crossAxisCount: isWeb ? 4 : 2,
      crossAxisSpacing: 24,
      mainAxisSpacing: 24,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: isWeb ? 1.5 : 1.2,
      children: [
        _buildStatCard('Total Users', summary['total_users']?.toString() ?? '0', Symbols.group, const Color(0xFF3B82F6)),
        _buildStatCard('Documents', summary['documents']?.toString() ?? '0', Symbols.description, const Color(0xFF10B981)),
        _buildStatCard('Pending Uploads', summary['pending_uploads']?.toString() ?? '0', Symbols.pending_actions, const Color(0xFFF59E0B)),
        _buildStatCard('Pending Flags', summary['flags']?.toString() ?? '0', Symbols.flag, const Color(0xFFEF4444)),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    final numValue = num.tryParse(value) ?? 0;
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const Spacer(),
          AnimatedDigitWidget(
            value: numValue,
            duration: const Duration(milliseconds: 1000),
            curve: Curves.easeOutExpo,
            textStyle: GoogleFonts.inter(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF64748B),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildRecentDocuments(List<PdfDocument> documents) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Flagged Documents',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1E293B),
                ),
              ),
              TextButton(onPressed: () => context.push('/admin/documents'), child: const Text('View All')),
            ],
          ),
          const SizedBox(height: 16),
          if (documents.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 40),
              child: Center(child: Text('No flagged documents', style: TextStyle(color: Color(0xFF64748B)))),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: documents.length,
              separatorBuilder: (context, index) => const Divider(height: 24),
              itemBuilder: (context, index) {
                final doc = documents[index];
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Symbols.picture_as_pdf, color: Color(0xFFEF4444)),
                  ),
                  title: Text(
                    doc.title,
                    style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text('${doc.views} views • ${doc.categoryName ?? 'Uncategorized'}'),
                  trailing: const Icon(Symbols.more_vert),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildRecentUsers(List<Map<String, dynamic>> users) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'New Users',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 24),
          if (users.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 40),
              child: Center(child: Text('No new users', style: TextStyle(color: Color(0xFF64748B)))),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: users.length,
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final user = users[index];
                return Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                      child: Text(
                        user['name']?[0] ?? 'U',
                        style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user['name'] ?? 'Unknown User',
                            style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                          ),
                          Text(
                            user['email'] ?? '',
                            style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF64748B)),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
        ],
      ),
    );
  }
}
