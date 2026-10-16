import 'package:flutter/material.dart';

import '../data/app_store.dart';
import '../data/models.dart';

class ScreenTimeTab extends StatelessWidget {
  const ScreenTimeTab({super.key});

  @override
  Widget build(BuildContext context) {
    final store = AppStore.instance;
    final progress = store.dailyMinutes == 0 ? 0.0 : (store.todayMinutes / store.dailyMinutes).clamp(0.0, 1.0);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('⏱️ Learning & Screen Time', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF3B2A5A))),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: const Color(0xFFF3E5F5), borderRadius: BorderRadius.circular(20)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Today's Learning", style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text('${store.todayMinutes} minutes', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF3B2A5A))),
                Text('Goal: ${store.dailyMinutes} minutes', style: const TextStyle(fontSize: 12, color: Colors.black54)),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(value: progress.toDouble(), minHeight: 10, backgroundColor: Colors.white, color: const Color(0xFF6B4EFF)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Text('Daily Learning Time', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            children: [15, 30, 45, 60].map((minutes) {
              final selected = minutes == store.dailyMinutes;
              return ChoiceChip(
                label: Text('$minutes min'),
                selected: selected,
                onSelected: (_) => store.setDailyMinutes(minutes),
                selectedColor: const Color(0xFF6B4EFF),
                labelStyle: TextStyle(color: selected ? Colors.white : Colors.black87),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
          const Text('Learning Schedule', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: weekDayLabels.map((day) {
              final enabled = store.enabledDays.contains(day);
              return GestureDetector(
                onTap: () => store.toggleDay(day),
                child: Container(
                  width: 44,
                  height: 44,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: enabled ? const Color(0xFF6B4EFF) : Colors.white,
                    border: Border.all(color: enabled ? Colors.transparent : Colors.grey.shade300),
                  ),
                  child: Text(day.substring(0, 2), style: TextStyle(color: enabled ? Colors.white : Colors.black54, fontWeight: FontWeight.w600, fontSize: 12)),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
          const Text('Controls', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Break reminders'),
            subtitle: const Text('A gentle pause after 15 minutes'),
            value: store.breakReminders,
            onChanged: store.setBreakReminders,
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Session limit'),
            subtitle: const Text('Stop play when the daily minutes are used'),
            value: store.sessionLimit,
            onChanged: store.setSessionLimit,
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Bedtime restriction'),
            subtitle: Text('Pause learning after ${store.bedtimeHour}:00'),
            value: store.bedtimeRestriction,
            onChanged: store.setBedtime,
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Daily learning reminder'),
            value: store.dailyReminder,
            onChanged: store.setDailyReminder,
          ),
        ],
      ),
    );
  }
}
