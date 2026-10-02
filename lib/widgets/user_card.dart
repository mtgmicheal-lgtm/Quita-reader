import 'package:flutter/material.dart';
import '../models/user_usage.dart';

class UserCard extends StatelessWidget {
  final UserUsage user;
  const UserCard({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final pct = user.percentUsed;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  child: Text(
                    user.username.isEmpty ? '?' : user.username[0].toUpperCase(),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.username,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text('${user.routerName} • ${user.profile}'),
                    ],
                  ),
                ),
                if (user.activeSessions > 0)
                  const Chip(label: Text('Online')),
              ],
            ),
            const SizedBox(height: 12),
            Text('Download: ${UserUsage.formatBytes(user.downloadBytes)}'),
            Text('Upload: ${UserUsage.formatBytes(user.uploadBytes)}'),
            Text('Total: ${UserUsage.formatBytes(user.totalBytes)}'),
            if (user.quotaBytes != null) ...[
              Text('Quota: ${UserUsage.formatBytes(user.quotaBytes!)}'),
              Text(
                'Remaining: ${UserUsage.formatBytes(user.remainingBytes ?? 0)}',
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(value: (pct ?? 0).clamp(0, 1)),
              const SizedBox(height: 4),
              Text('${((pct ?? 0) * 100).toStringAsFixed(1)}% used'),
            ],
            if (user.endTime != null && user.endTime!.isNotEmpty)
              Text('Expires: ${user.endTime}'),
          ],
        ),
      ),
    );
  }
}
