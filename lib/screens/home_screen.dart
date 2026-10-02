import 'package:flutter/material.dart';
import '../models/router_config.dart';
import '../models/user_usage.dart';
import '../services/mikrotik_service.dart';
import '../services/router_store.dart';
import '../services/mock_data.dart';
import '../widgets/user_card.dart';
import 'router_form_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with TickerProviderStateMixin {
  final _store = RouterStore();
  final _api = MikroTikService();
  final _search = TextEditingController();

  List<RouterConfig> _routers = [];
  final Map<String, List<UserUsage>> _users = {};
  final Map<String, String?> _errors = {};
  bool _loading = true;
  bool _demoMode = true;

  @override
  void initState() {
    super.initState();
    _loadRouters();
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _loadRouters() async {
    final routers = await _store.load();
    setState(() {
      _routers = routers;
      _loading = false;
    });
    if (routers.isNotEmpty) {
      await _refreshAll();
    }
  }

  Future<void> _addRouter() async {
    final router = await Navigator.push<RouterConfig>(
      context,
      MaterialPageRoute(builder: (_) => const RouterFormScreen()),
    );
    if (router == null) return;

    setState(() => _routers = [..._routers, router]);
    await _store.save(_routers);
    await _refreshRouter(router);
  }

  Future<void> _refreshRouter(RouterConfig router) async {
    setState(() => _errors[router.id] = null);
    try {
      final data = _demoMode
          ? mockUsers(router.name)
          : await _api.fetchUsers(router);
      setState(() => _users[router.id] = data);
    } catch (e) {
      setState(() => _errors[router.id] = e.toString());
    }
  }

  Future<void> _refreshAll() async {
    for (final router in _routers) {
      await _refreshRouter(router);
    }
  }

  List<UserUsage> _filtered(List<UserUsage> source) {
    final q = _search.text.trim().toLowerCase();
    if (q.isEmpty) return source;
    return source
        .where((u) => u.username.toLowerCase().contains(q))
        .toList();
  }

  Widget _usersView(List<UserUsage> source, {String? error}) {
    final users = _filtered(source);
    return RefreshIndicator(
      onRefresh: _refreshAll,
      child: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          if (error != null)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Text(error),
              ),
            ),
          if (users.isEmpty)
            const Padding(
              padding: EdgeInsets.only(top: 80),
              child: Center(child: Text('No users found')),
            ),
          ...users.map((u) => UserCard(user: u)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final allUsers = _routers
        .expand((r) => _users[r.id] ?? const <UserUsage>[])
        .toList();

    final tabCount = 1 + _routers.length;

    return DefaultTabController(
      length: tabCount,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('MikroTik User Manager'),
          actions: [
            IconButton(
              tooltip: 'Refresh',
              onPressed: _refreshAll,
              icon: const Icon(Icons.refresh),
            ),
            IconButton(
              tooltip: 'Add router',
              onPressed: _addRouter,
              icon: const Icon(Icons.add),
            ),
          ],
          bottom: TabBar(
            isScrollable: true,
            tabs: [
              const Tab(text: 'All Routers'),
              ..._routers.map((r) => Tab(text: r.name)),
            ],
          ),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 6),
              child: TextField(
                controller: _search,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: 'Search username...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _search.text.isEmpty
                      ? null
                      : IconButton(
                          onPressed: () {
                            _search.clear();
                            setState(() {});
                          },
                          icon: const Icon(Icons.clear),
                        ),
                  border: const OutlineInputBorder(),
                ),
              ),
            ),
            SwitchListTile(
              dense: true,
              title: const Text('Demo data'),
              subtitle: Text(
                _demoMode
                    ? 'Showing sample users'
                    : 'Reading real MikroTik REST API',
              ),
              value: _demoMode,
              onChanged: (value) async {
                setState(() => _demoMode = value);
                await _refreshAll();
              },
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _usersView(allUsers),
                  ..._routers.map(
                    (r) => _usersView(
                      _users[r.id] ?? const <UserUsage>[],
                      error: _errors[r.id],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        floatingActionButton: _routers.isEmpty
            ? FloatingActionButton.extended(
                onPressed: _addRouter,
                icon: const Icon(Icons.router),
                label: const Text('Add MikroTik'),
              )
            : null,
      ),
    );
  }
}
