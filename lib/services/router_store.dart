import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/router_config.dart';

class RouterStore {
  static const _key = 'routers';

  Future<List<RouterConfig>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null || raw.isEmpty) return [];
    final list = (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
    return list.map(RouterConfig.fromJson).toList();
  }

  Future<void> save(List<RouterConfig> routers) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _key,
      jsonEncode(routers.map((e) => e.toJson()).toList()),
    );
  }
}
