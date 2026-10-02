import '../models/user_usage.dart';

List<UserUsage> mockUsers(String routerName) => [
      UserUsage(
        username: 'Martha',
        routerName: routerName,
        profile: 'Monthly_10GB',
        state: 'running active',
        downloadBytes: 5_800_000_000,
        uploadBytes: 650_000_000,
        quotaBytes: 10 * 1024 * 1024 * 1024,
        endTime: '2026-10-03 16:53:07',
        activeSessions: 1,
      ),
      UserUsage(
        username: 'Peter',
        routerName: routerName,
        profile: 'Monthly_20GB',
        state: 'running',
        downloadBytes: 14_500_000_000,
        uploadBytes: 1_200_000_000,
        quotaBytes: 20 * 1024 * 1024 * 1024,
        endTime: '2026-10-20 12:00:00',
        activeSessions: 0,
      ),
    ];
