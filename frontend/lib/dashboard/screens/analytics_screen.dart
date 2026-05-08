import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../../services/api_service.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        title: Text('Analytics', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: const Color(0xFF1E293B),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: ApiService().getAnalytics(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final analytics = snapshot.data!;
          
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle('Overview Metrics'),
                const SizedBox(height: 16),
                _buildMetricsGrid(analytics),
                const SizedBox(height: 32),
                _buildSectionTitle('Usage Trends'),
                const SizedBox(height: 16),
                _buildTrendCard('Daily Active Users', '842', '+12% from last week', Colors.blue),
                const SizedBox(height: 16),
                _buildTrendCard('New Document Uploads', '124', '+5% from last week', Colors.green),
                const SizedBox(height: 16),
                _buildTrendCard('Average Rating', '4.8', '+0.2 from last month', Colors.orange),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.inter(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: const Color(0xFF1E293B),
      ),
    );
  }

  Widget _buildMetricsGrid(Map<String, dynamic> analytics) {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.5,
      children: analytics.entries.map((entry) {
        return _buildMetricCard(
          entry.key.replaceAll('_', ' ').toUpperCase(),
          entry.value.toString(),
          _getIconForMetric(entry.key),
          _getColorForMetric(entry.key),
        );
      }).toList(),
    );
  }

  Widget _buildMetricCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 24),
          const Spacer(),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF64748B),
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrendCard(String title, String value, String trend, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Symbols.trending_up, color: color),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: const Color(0xFF1E293B)),
                ),
                Text(
                  trend,
                  style: GoogleFonts.inter(fontSize: 12, color: Colors.green, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
          Text(
            value,
            style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B)),
          ),
        ],
      ),
    );
  }

  IconData _getIconForMetric(String key) {
    if (key.contains('user')) return Symbols.person;
    if (key.contains('document') || key.contains('pdf')) return Symbols.description;
    if (key.contains('view')) return Symbols.visibility;
    if (key.contains('download')) return Symbols.download;
    return Symbols.analytics;
  }

  Color _getColorForMetric(String key) {
    if (key.contains('user')) return Colors.blue;
    if (key.contains('document')) return Colors.orange;
    if (key.contains('view')) return Colors.purple;
    if (key.contains('download')) return Colors.green;
    return Colors.grey;
  }
}
