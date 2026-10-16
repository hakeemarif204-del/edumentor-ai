import 'package:flutter/material.dart';
import '../data/app_store.dart';
import 'progress_analytics_tab.dart';
import 'children_profiles_tab.dart';
import 'ai_insights_tab.dart';
import 'goals_tab.dart';
import 'activity_history_tab.dart';
import 'achievements_tab.dart';
import 'screen_time_tab.dart';
import 'notifications_screen.dart';
import 'settings_screen.dart';

/// Full Parents Zone dashboard shell.
/// TODO: Replace the hardcoded _activeChild data below with real data from
/// Firestore once Children Profiles (Phase 4) is wired to the backend.
class ParentsZoneScreen extends StatefulWidget {
  const ParentsZoneScreen({super.key});

  @override
  State<ParentsZoneScreen> createState() => _ParentsZoneScreenState();
}

class _ParentTab {
  final String label;
  final String emoji;
  const _ParentTab(this.label, this.emoji);
}

class _ParentsZoneScreenState extends State<ParentsZoneScreen> {
  int _selectedTab = 0;

  static const List<_ParentTab> _tabs = [
    _ParentTab('Progress', '📊'),
    _ParentTab('AI Insights', '🤖'),
    _ParentTab('Goals', '🎯'),
    _ParentTab('Children', '👧'),
    _ParentTab('History', '📚'),
    _ParentTab('Achievements', '🏆'),
    _ParentTab('Screen Time', '⏱️'),
  ];

  @override
  void initState() {
    super.initState();
    AppStore.instance.addListener(_refresh);
  }

  @override
  void dispose() {
    AppStore.instance.removeListener(_refresh);
    super.dispose();
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  void _showSwitchChildSheet() {
    final store = AppStore.instance;
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Switch Child', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            for (final child in store.children)
              ListTile(
                leading: Text(child.avatarEmoji, style: const TextStyle(fontSize: 28)),
                title: Text(child.name),
                subtitle: Text('${child.age} years'),
                trailing: child.id == store.activeChildId ? const Icon(Icons.check, color: Color(0xFF6B4EFF)) : null,
                onTap: () {
                  store.setActiveChild(child.id);
                  Navigator.pop(context);
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabContent() {
    final child = AppStore.instance.activeChild;
    if (_selectedTab == 0) {
      return ProgressAnalyticsTab(childName: child.name, childAge: child.age);
    }
    if (_selectedTab == 1) {
      return AiInsightsTab(childName: child.name);
    }
    if (_selectedTab == 2) {
      return const GoalsTab();
    }
    if (_selectedTab == 3) {
      return const ChildrenProfilesTab();
    }
    if (_selectedTab == 4) {
      return const ActivityHistoryTab();
    }
    if (_selectedTab == 5) {
      return const AchievementsTab();
    }
    return const ScreenTimeTab();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF6EE),
      body: SafeArea(
        child: Column(
          children: [
            // Top navigation
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Color(0xFF3B2A5A)),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Text('🛡️', style: TextStyle(fontSize: 22)),
                  const SizedBox(width: 6),
                  const Expanded(
                    child: Text(
                      'Parents Zone',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF3B2A5A),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const NotificationsScreen()),
                      );
                    },
                    icon: Badge(
                      isLabelVisible: AppStore.instance.unreadNotes > 0,
                      label: Text('${AppStore.instance.unreadNotes}'),
                      child: const Icon(Icons.notifications_none, color: Color(0xFF3B2A5A)),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.settings_outlined, color: Color(0xFF3B2A5A)),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const SettingsScreen()),
                      );
                    },
                  ),
                ],
              ),
            ),

            // Hero card
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6B4EFF), Color(0xFF673AB7)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'PARENT ZONE',
                      style: TextStyle(
                        color: Colors.white70,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Manage profiles, monitor progress, and help your child learn better.',
                      style: TextStyle(color: Colors.white, fontSize: 14),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 26,
                          backgroundColor: Colors.white,
                          child: Text(AppStore.instance.activeChild.avatarEmoji, style: const TextStyle(fontSize: 26)),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${AppStore.instance.activeChild.name} — ${AppStore.instance.activeChild.age} years',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              Container(
                                margin: const EdgeInsets.only(top: 4),
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.white24,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Text(
                                  'Active Profile',
                                  style: TextStyle(color: Colors.white, fontSize: 11),
                                ),
                              ),
                            ],
                          ),
                        ),
                        TextButton(
                          onPressed: _showSwitchChildSheet,
                          style: TextButton.styleFrom(
                            backgroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: const Text(
                            'Switch Child',
                            style: TextStyle(color: Color(0xFF3B2A5A), fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Tab navigation
            SizedBox(
              height: 44,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _tabs.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final tab = _tabs[index];
                  final isSelected = index == _selectedTab;
                  return ChoiceChip(
                    label: Text('${tab.emoji} ${tab.label}'),
                    selected: isSelected,
                    onSelected: (_) => setState(() => _selectedTab = index),
                    selectedColor: const Color(0xFF6B4EFF),
                    backgroundColor: Colors.white,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : const Color(0xFF3B2A5A),
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(
                        color: isSelected ? Colors.transparent : Colors.grey.shade300,
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 12),

            // Tab content area
            Expanded(
              child: Container(
                margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: _buildTabContent(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}