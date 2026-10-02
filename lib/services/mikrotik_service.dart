import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/router_config.dart';
import '../models/user_usage.dart';

class MikroTikService {
  final http.Client _client;
  MikroTikService({http.Client? client}) : _client = client ?? http.Client();

  Map<String, String> _headers(RouterConfig router) {
    final token = base64Encode(
      utf8.encode('${router.username}:${router.password}'),
    );
    return {
      'Authorization': 'Basic $token',
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
  }

  Future<void> testConnection(RouterConfig router) async {
    final response = await _client.get(
      Uri.parse('${router.baseUrl}/system/resource'),
      headers: _headers(router),
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Connection failed: HTTP ${response.statusCode}');
    }
  }

  Future<List<UserUsage>> fetchUsers(RouterConfig router) async {
    final usersResponse = await _client.get(
      Uri.parse('${router.baseUrl}/user-manager/user'),
      headers: _headers(router),
    );

    if (usersResponse.statusCode < 200 || usersResponse.statusCode >= 300) {
      throw Exception(
        'User Manager users failed: HTTP ${usersResponse.statusCode}',
      );
    }

    final profilesResponse = await _client.get(
      Uri.parse('${router.baseUrl}/user-manager/user-profile'),
      headers: _headers(router),
    );

    final users = (jsonDecode(usersResponse.body) as List)
        .cast<Map<String, dynamic>>();

    final profiles = profilesResponse.statusCode >= 200 &&
            profilesResponse.statusCode < 300
        ? (jsonDecode(profilesResponse.body) as List)
            .cast<Map<String, dynamic>>()
        : <Map<String, dynamic>>[];

    final profileByUser = <String, Map<String, dynamic>>{};
    for (final p in profiles) {
      final user = (p['user'] ?? '').toString();
      final state = (p['state'] ?? '').toString();
      if (user.isEmpty) continue;

      // Prefer currently active/running profile over old "used" entries.
      if (!profileByUser.containsKey(user) ||
          state.contains('running active') ||
          state == 'running') {
        profileByUser[user] = p;
      }
    }

    final result = <UserUsage>[];

    for (final user in users) {
      final username = (user['name'] ?? '').toString();
      if (username.isEmpty) continue;

      final monitor = await _fetchMonitor(router, user);
      final p = profileByUser[username];

      result.add(
        UserUsage(
          username: username,
          routerName: router.name,
          profile: (monitor['actual-profile'] ??
                  p?['profile'] ??
                  'No profile')
              .toString(),
          state: (p?['state'] ?? '').toString(),
          downloadBytes: _parseInt(monitor['total-download']),
          uploadBytes: _parseInt(monitor['total-upload']),
          endTime: p?['end-time']?.toString(),
          activeSessions: _parseInt(monitor['active-sessions']),
          // Quota will be added in the next step by reading
          // /user-manager limitation + profile-limitation.
          quotaBytes: null,
        ),
      );
    }

    return result;
  }

  Future<Map<String, dynamic>> _fetchMonitor(
    RouterConfig router,
    Map<String, dynamic> user,
  ) async {
    final id = user['.id']?.toString();

    // RouterOS REST POST exposes console commands.
    // User Manager's `monitor` command returns:
    // total-download, total-upload, active-sessions, actual-profile, ...
    final body = <String, String>{
      if (id != null && id.isNotEmpty) 'numbers': id,
      'once': '',
    };

    final response = await _client.post(
      Uri.parse('${router.baseUrl}/user-manager/user/monitor'),
      headers: _headers(router),
      body: jsonEncode(body),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      return const {};
    }

    final decoded = jsonDecode(response.body);
    if (decoded is List && decoded.isNotEmpty) {
      return Map<String, dynamic>.from(decoded.first as Map);
    }
    if (decoded is Map) {
      return Map<String, dynamic>.from(decoded);
    }
    return const {};
  }

  int _parseInt(dynamic value) =>
      int.tryParse((value ?? '0').toString()) ?? 0;
}
