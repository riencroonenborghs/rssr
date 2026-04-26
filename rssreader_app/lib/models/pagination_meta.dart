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
