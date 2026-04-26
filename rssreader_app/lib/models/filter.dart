class Filter {
  final int id;
  final String comparison;
  final String value;

  const Filter({required this.id, required this.comparison, required this.value});

  factory Filter.fromJson(Map<String, dynamic> json) => Filter(
        id: json['id'] as int,
        comparison: json['comparison'] as String,
        value: json['value'] as String,
      );

  String get humanReadable {
    final comp = comparison == 'includes' ? 'contains' : 'tagged with';
    return 'the title $comp ${value.toUpperCase()}';
  }
}
