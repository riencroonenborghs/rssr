class Tag {
  final int id;
  final String name;

  const Tag({required this.id, required this.name});

  factory Tag.fromJson(Map<String, dynamic> json) =>
      Tag(id: json['id'] as int, name: json['name'] as String);
}

class Feed {
  final int id;
  final String title;
  final String url;

  const Feed({required this.id, required this.title, required this.url});

  factory Feed.fromJson(Map<String, dynamic> json) => Feed(
        id: json['id'] as int,
        title: json['title'] as String,
        url: json['url'] as String,
      );
}

class Entry {
  final int id;
  final String title;
  final String? description;
  final String link;
  final String? image;
  final DateTime? publishedAt;
  final bool viewed;
  final bool bookmarked;
  final int? bookmarkId;
  final List<Tag> tags;
  final Feed feed;

  const Entry({
    required this.id,
    required this.title,
    this.description,
    required this.link,
    this.image,
    this.publishedAt,
    required this.viewed,
    required this.bookmarked,
    this.bookmarkId,
    required this.tags,
    required this.feed,
  });

  factory Entry.fromJson(Map<String, dynamic> json) => Entry(
        id: json['id'] as int,
        title: json['title'] as String,
        description: json['description'] as String?,
        link: json['link'] as String,
        image: json['image'] as String?,
        publishedAt: json['published_at'] != null
            ? DateTime.tryParse(json['published_at'] as String)
            : null,
        viewed: json['viewed'] as bool? ?? false,
        bookmarked: json['bookmarked'] as bool? ?? false,
        bookmarkId: json['bookmark_id'] as int?,
        tags: (json['tags'] as List<dynamic>? ?? [])
            .map((t) => Tag.fromJson(t as Map<String, dynamic>))
            .toList(),
        feed: Feed.fromJson(json['feed'] as Map<String, dynamic>),
      );
}

class PaginationMeta {
  final int currentPage;
  final int totalPages;
  final int totalCount;

  const PaginationMeta({
    required this.currentPage,
    required this.totalPages,
    required this.totalCount,
  });

  factory PaginationMeta.fromJson(Map<String, dynamic> json) => PaginationMeta(
        currentPage: json['current_page'] as int,
        totalPages: json['total_pages'] as int,
        totalCount: json['total_count'] as int,
      );
}
