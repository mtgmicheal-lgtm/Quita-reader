class UserUsage {
  final String username;
  final String routerName;
  final String profile;
  final String state;
  final int downloadBytes;
  final int uploadBytes;
  final int? quotaBytes;
  final String? endTime;
  final int activeSessions;

  const UserUsage({
    required this.username,
    required this.routerName,
    required this.profile,
    required this.state,
    required this.downloadBytes,
    required this.uploadBytes,
    this.quotaBytes,
    this.endTime,
    this.activeSessions = 0,
  });

  int get totalBytes => downloadBytes + uploadBytes;
 int? get remainingBytes {
  if (quotaBytes == null) return null;

  final remaining = quotaBytes! - totalBytes;

  if (remaining <= 0) return 0;
  if (remaining >= quotaBytes!) return quotaBytes!;

  return remaining;
}

  double? get percentUsed =>
      quotaBytes == null || quotaBytes == 0 ? null : totalBytes / quotaBytes!;

  static String formatBytes(int bytes) {
    const kb = 1024;
    const mb = kb * 1024;
    const gb = mb * 1024;

    if (bytes >= gb) return '${(bytes / gb).toStringAsFixed(2)} GB';
    if (bytes >= mb) return '${(bytes / mb).toStringAsFixed(2)} MB';
    if (bytes >= kb) return '${(bytes / kb).toStringAsFixed(2)} KB';
    return '$bytes B';
  }
}
