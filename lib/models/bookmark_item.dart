class BookmarkItem {
  final int id; // 主题ID
  final String title; // 主题标题
  final String avatarUrl; // 创建者头像URL
  final List<String> tags; // 主题标签
  final String category; // 所属分类
  final DateTime savedAt; // 保存时间
  final String username; // 创建者用户名
  final int userId; // 创建者ID
  final String? name; // 主题slug

  BookmarkItem({
    required this.id,
    required this.title,
    required this.avatarUrl,
    required this.tags,
    required this.category,
    required this.username,
    required this.userId,
    required this.name,
    DateTime? savedAt,
  }) : savedAt = savedAt ?? DateTime.now();

  factory BookmarkItem.fromJson(Map<String, dynamic> json) {
    return BookmarkItem(
      id: json['id'],
      title: json['title'],
      avatarUrl: json['avatarUrl'],
      tags: List<String>.from(json['tags'] ?? []),
      category: json['category'],
      savedAt: DateTime.parse(json['savedAt']),
      username: json['username'],
      userId: json['userId'],
      name: json['name'],
    );
  }

  // 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'avatarUrl': avatarUrl,
      'tags': tags,
      'category': category,
      'savedAt': savedAt.toIso8601String(),
      'username': username,
      'userId': userId,
      'name': name,
    };
  }

  // 用于比较是否为同一主题
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BookmarkItem && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
