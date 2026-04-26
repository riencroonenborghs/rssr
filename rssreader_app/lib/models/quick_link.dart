enum QuickLinkType { feed, tag }

class QuickLink {
  final int id;
  final String title;
  final QuickLinkType type;

  const QuickLink({required this.id, required this.title, required this.type});

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'type': type.name,
      };

  factory QuickLink.fromJson(Map<String, dynamic> json) => QuickLink(
        id: json['id'] as int,
        title: json['title'] as String,
        type: QuickLinkType.values.byName(json['type'] as String),
      );
}
