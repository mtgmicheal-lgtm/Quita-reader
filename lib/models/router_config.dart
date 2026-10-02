class RouterConfig {
  final String id;
  final String name;
  final String host;
  final int port;
  final bool useHttps;
  final String username;
  final String password;

  const RouterConfig({
    required this.id,
    required this.name,
    required this.host,
    this.port = 443,
    this.useHttps = true,
    required this.username,
    required this.password,
  });

  String get baseUrl =>
      '${useHttps ? 'https' : 'http'}://$host:$port/rest';

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'host': host,
        'port': port,
        'useHttps': useHttps,
        'username': username,
        'password': password,
      };

  factory RouterConfig.fromJson(Map<String, dynamic> json) => RouterConfig(
        id: json['id'] as String,
        name: json['name'] as String,
        host: json['host'] as String,
        port: json['port'] as int? ?? 443,
        useHttps: json['useHttps'] as bool? ?? true,
        username: json['username'] as String,
        password: json['password'] as String,
      );
}
