class PaginationWrapper<T> {
  final List<T> results;
  final int page;
  final int pageSize;
  final int totalCount;
  final int totalPages;

  PaginationWrapper({
    required this.results,
    required this.page,
    required this.pageSize,
    required this.totalCount,
    required this.totalPages,
  });

  factory PaginationWrapper.empty() {
    return PaginationWrapper<T>(
      results: [],
      page: 1,
      pageSize: 10,
      totalCount: 0,
      totalPages: 1,
    );
  }
}
