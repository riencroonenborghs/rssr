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
