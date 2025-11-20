import 'package:get/get.dart';
import 'package:light_novel_reader_client/globals.dart';
import 'package:light_novel_reader_client/models/chapter.dart';
import 'package:light_novel_reader_client/models/chapters.dart';
import 'package:light_novel_reader_client/models/details.dart';
import 'package:light_novel_reader_client/models/favouriteWithNovelMeta.dart';
import 'package:light_novel_reader_client/models/latest.dart';
import 'package:light_novel_reader_client/models/search.dart';
import 'package:light_novel_reader_client/models/search_result.dart';
import 'package:light_novel_reader_client/models/source.dart';
import 'package:light_novel_reader_client/models/source_search.dart';

class ApiController extends GetxController {
  // Observables
  final _sources = <Source>[].obs;
  List<Source> get sources => _sources.toList();
  set sources(List<Source> value) => _sources.value = value;

  final _currentSource = "".obs;
  String get currentSource => _currentSource.value;
  set currentSource(String value) => _currentSource.value = value;

  final _search = Rxn<Search>();
  Search? get search => _search.value;
  set search(Search? value) => _search.value = value;

  final _searchResults = <SearchResult>[].obs;
  List<SearchResult> get searchResults => _searchResults.toList();
  set searchResults(List<SearchResult> value) => _searchResults.value = value;

  final _miltipleSourceSearch = <SourceSearch>[].obs;
  List<SourceSearch> get multipleSourceSearch => _miltipleSourceSearch.toList();
  set multipleSourceSearch(List<SourceSearch> value) => _miltipleSourceSearch.value = value;

  final _latestResults = <SearchResult>[].obs;
  List<SearchResult> get latestResults => _latestResults.toList();
  set latestResults(List<SearchResult> value) => _latestResults.value = value;

  final _details = Rxn<Details>();
  Details? get details => _details.value;
  set details(Details? value) => _details.value = value;

  final _chapters = Rxn<List<ChapterListItem>>();
  List<ChapterListItem>? get chapters => _chapters.value;
  set chapters(List<ChapterListItem>? value) => _chapters.value = value;

  final _latest = Rxn<Latest>();
  Latest? get latest => _latest.value;
  set latest(Latest? value) => _latest.value = value;

  // final _selectedChapter = Rxn<ChapterListItem>();
  // ChapterListItem? get selectedChapter => _selectedChapter.value;

  final _chapter = Rxn<Chapter>();
  Chapter? get chapter => _chapter.value;
  set chapter(Chapter? value) => _chapter.value = value;

  RxInterface<Chapter?> get chapterRx => _chapter;

  final _isLoading = false.obs;
  bool get isLoading => _isLoading.value;
  set isLoading(bool value) => _isLoading.value = value;

  final _isLatestLoading = false.obs;
  bool get isLatestLoading => _isLatestLoading.value;
  set isLatestLoading(bool value) => _isLatestLoading.value = value;

  final _isChapterLoading = false.obs;
  bool get isChapterLoading => _isChapterLoading.value;
  set isChapterLoading(bool value) => _isChapterLoading.value = value;

  final _isChaptersLoading = false.obs;
  bool get isChaptersLoading => _isChaptersLoading.value;
  set isChaptersLoading(bool value) => _isChaptersLoading.value = value;

  final _sortAsc = true.obs;
  bool get sortAsc => _sortAsc.value;
  set sortAsc(bool value) {
    _sortAsc.value = value;
    sortChapters();
    uiController.saveUISettings();
  }

  final _currentLatestPage = 1.obs;
  int get currentLatestPage => _currentLatestPage.value;
  set currentLatestPage(int value) => _currentLatestPage.value = value;

  final _currentSearchPage = 1.obs;
  int get currentSearchPage => _currentSearchPage.value;
  set currentSearchPage(int value) => _currentSearchPage.value = value;

  final _searchTerm = ''.obs;
  String get searchTerm => _searchTerm.value;
  set searchTerm(String value) => _searchTerm.value = value;

  final _filters = Rx<Map<String, dynamic>>({});
  Map<String, dynamic> get filters => _filters.value;
  set filters(Map<String, dynamic> value) => _filters.value = value;

  // Methods
  Future<void> fetchSources() async {
    try {
      isLoading = true;
      sources = await client.getSources();
    } catch (e) {
      print('Error: Failed to fetch sources: $e');
    } finally {
      isLoading = false;
    }
  }

  clearDetails() {
    details = null;
    chapters = null;
    chapter = null;
  }

  clearAll() {
    clearDetails();
    searchResults = [];
    sources = [];
    currentSource = "";
    latestResults = [];
    latest = null;
    currentLatestPage = 1;
  }

  clearSearch() {
    multipleSourceSearch = [];
    searchResults = [];
    currentSource = "";
    clearDetails();
    latestResults = [];
    latest = null;
    currentLatestPage = 1;
    filters = {};
    searchTerm = '';
  }

  Future<void> updateSources() async {
    try {
      isLoading = true;
      await client.updateSources();
      await fetchSources();
    } catch (e) {
      print('Error: Failed to update sources: $e');
    } finally {
      isLoading = false;
    }
  }

  Future<void> setSource(String source) async {
    try {
      isLoading = true;
      // var response = await apiClient.setSource(source);
      currentSource = source;
      // uiController.selectedIndex = 2;
      searchResults = [];
    } catch (e) {
      print('Error: Failed to set source: $e');
    } finally {
      isLoading = false;
    }
  }

  Future<void> searchNovel({int page = 1}) async {
    try {
      if (page == currentSearchPage && page != 1) {
        print('Skipping fetch for search page $page as it is already loaded.');
        return; // No need to fetch if already at or beyond current page
      }
      currentSearchPage = page;
      var csource = sources.firstWhereOrNull((s) => s.name == currentSource);
      String? searchParams = getFilters();

      if (csource == null) {
        print('Error: Current source not found in sources list.');
        return;
      }
      var mainSearchField = csource.filters.firstWhereOrNull((f) => f.isMainSearchField);
      if (searchTerm.isNotEmpty && mainSearchField != null) {
        searchParams ??= '';
        searchParams += '&${mainSearchField.fieldVar}=$searchTerm';
      }
      isLoading = page == 1;
      search = await client.search(
        currentSource,
        searchParams: searchParams,
        page: page,
      );
      if (search != null && search!.results.isNotEmpty) {
        if (page == 1) {
          searchResults = search!.results;
        } else {
          searchResults = [...searchResults, ...search!.results];
        }
      }
    } catch (e) {
      print('Error: Failed to search: $e');
    } finally {
      isLoading = false;
    }
  }

  searchMultiple() async {
    List<SourceSearch> searchPayload = [];
    for (var source in sources) {
      if (source.filters.isEmpty) {
        print('Error: No filters available for source ${source.name}.');
        continue;
      }

      String? searchParams = getFilters(source: source.name);
      var mainSearchField = source.filters.firstWhereOrNull((f) => f.isMainSearchField);
      if (searchTerm.isNotEmpty && mainSearchField != null) {
        searchParams ??= '';
        searchParams += '&${mainSearchField.fieldVar}=$searchTerm';
      }
      if (searchParams != null && searchParams.isNotEmpty) {
        searchPayload.add(SourceSearch(source: source.name, searchParams: searchParams));
      }
    }

    if (searchPayload.isEmpty) {
      print('Error: No valid search parameters found for any source.');
      return;
    }

    try {
      isLoading = true;
      multipleSourceSearch = await client.searchMultiple(searchPayload) ?? [];
    } catch (e) {
      multipleSourceSearch = [];
      print('Error: Failed to search multiple sources: $e');
    } finally {
      isLoading = false;
    }
  }

  getFilters({String? source}) {
    var csource = sources.firstWhereOrNull((s) => s.name == (source ?? currentSource));
    if (csource == null) {
      print('Error: Current source not found in sources list.');
      return;
    }

    if (csource.filters.isEmpty) {
      print('Error: No filters available for the current source.');
      return;
    }

    if (filters.isEmpty) {
      print('Error: No filter values provided.');
      return '';
    }

    String additionalParams = '';

    for (var filter in csource.filters) {
      if (filters.containsKey(filter.fieldName)) {
        var value = filters[filter.fieldName];
        if (value == null || (value is Set && value.isEmpty) || value.toString().isEmpty) {
          // print('Warning: Filter ${filter.fieldName} has no value.');
          continue; // Skip empty values
        }
        if (value is Set) {
          if (filter.isMultiVar) {
            for (var v in value) {
              additionalParams += '&${filter.fieldVar}=$v';
            }
          } else {
            additionalParams += '&${filter.fieldVar}=${value.join(',')}';
          }
        } else {
          additionalParams += '&${filter.fieldVar}=${Uri.encodeComponent(value)}';
        }
      } else {
        // print('Warning: Filter ${filter.fieldName} not found in provided values.');
      }
    }

    return additionalParams == '' ? null : additionalParams;
  }

  Future<Latest?> fetchLatest({String? source, int page = 1}) async {
    try {
      if (page == currentLatestPage && page != 1) {
        print('Skipping fetch for latest page $page as it is already loaded.');
        return null; // No need to fetch if already at or beyond current page
      }
      currentLatestPage = page;
      print('Fetching latest for source: $source, page: $page, latestPage: $currentLatestPage');
      isLatestLoading = page == 1;
      latest = await client.getLatest(source ?? currentSource, page: page);
      if (latest != null && latest!.results.isNotEmpty) {
        if (page == 1) {
          latestResults = latest!.results;
        } else {
          latestResults = [...latestResults, ...latest!.results];
        }
      }
    } catch (e) {
      print('Error: Failed to fetch latest: $e');
    } finally {
      isLatestLoading = false;
    }
    return null;
  }

  setCategories(List<String> categories, {Details? novelDetails}) async {
    if (details != null) {
      await client.updateFavouriteCategory((novelDetails ?? details!).url!, (novelDetails ?? details!).source!, categories);
      details = details!.copyWith(categories: categories);
      final updatedFavs = favouritesController.favourites
          .map((favourite) {
            if (favourite.url == details!.url && favourite.source == currentSource) {
              return favourite.copyWith(categories: categories);
            }
            return favourite;
          })
          .toList(growable: true)
          .cast<FavouriteWithNovelMeta>();
      favouritesController.favourites = updatedFavs;
    }
  }

  Future<Details?> fetchDetails(
    String url, {
    String? source,
    bool refresh = false,
    List<String>? categories,
    required bool canCacheNovel,
    required bool canCacheChapters,
  }) async {
    try {
      if (isLoading) {
        return null;
      }
      isLoading = true;
      details = await client.getDetails(url, source ?? currentSource, refresh: refresh, canCacheNovel: canCacheNovel);
      if (details != null) {
        if (categories != null && categories.isNotEmpty) {
          details = details!.copyWith(categories: categories);
        }

        if (categories == null || categories.isEmpty) {
          FavouriteWithNovelMeta? favouritedNovel =
              favouritesController.favourites.firstWhereOrNull((f) => f.url == url && f.source == (source ?? currentSource));
          if (favouritedNovel != null && favouritedNovel.categories.isNotEmpty) {
            categories = favouritedNovel.categories;
          }
          details = details!.copyWith(categories: categories);
        }
        if (details!.url == null) {
          details = details!.copyWith(url: url);
        }

        await historyController.getNovelHistory(
          details!.url!,
          source ?? currentSource,
        );

        fetchChapters(
          url,
          source: source ?? currentSource,
          additionalProps: details!.additionalProps,
          lastChapterUrl: details!.lastHistory?.url,
          refresh: refresh,
          canCacheChapters: canCacheChapters,
        );
      }
      return details;
    } catch (e) {
      print('Error: Failed to fetch details: $e');
    } finally {
      isLoading = false;
    }
    return null;
  }

  sortChapters() {
    print('Sorting chapters: ${sortAsc ? "Ascending" : "Descending"}');
    List<ChapterListItem> tempChapters = chapters ?? [];
    tempChapters.sort((a, b) => sortAsc ? a.index.compareTo(b.index) : b.index.compareTo(a.index));
    chapters = tempChapters;
  }

  Future<Chapters?> fetchChapters(String url,
      {String? source,
      Map<String, String>? additionalProps,
      String? lastChapterUrl,
      bool refresh = false,
      required bool canCacheChapters}) async {
    try {
      isChaptersLoading = true;
      chapters = (await client.getChapters(url, source ?? currentSource, additionalProps,
              refresh: refresh, canCacheChapters: canCacheChapters))
          .chapters;
      if (chapters != null) {
        if (refresh) {
          updatesController.getUpdates();
        }

        sortChapters();
        if (lastChapterUrl != null) {
          ChapterListItem? lastReadChapter = chapters!.firstWhereOrNull((chapter) => chapter.url == lastChapterUrl);
          if (lastReadChapter != null) {
            fetchChapter(lastReadChapter.url, source: source ?? currentSource);
          }
        }
      }
    } catch (e) {
      print('Error: Failed to fetch chapters: $e');
    } finally {
      isChaptersLoading = false;
    }
    return null;
  }

  Future<void> fetchChapter(String url, {String? source, bool addToHistory = true}) async {
    try {
      if (chapter != null && chapter!.url == url) {
        return; // Already loaded
      }
      isChapterLoading = true;
      _chapter.value = await client.getChapter(url, source ?? currentSource);
      // ChapterListItem? chapterMeta = chapters?.firstWhereOrNull((chapter) => chapter.url == url);
      // if (chapterMeta != null && addToHistory) {
      //   historyController.addToHistory(
      //     novel: details!,
      //     chapter: chapterMeta,
      //     source: source ?? currentSource,
      //     page: 0,
      //     position: 0,
      //   );
      // }
    } catch (e) {
      print('Error: Failed to fetch chapter: $e');
    } finally {
      isChapterLoading = false;
    }
  }

  Future<bool> addToFavourites(String? source) async {
    bool success = false;
    try {
      // isLoading = true;
      success = await client.addToFavourites(source ?? currentSource, details!);
    } catch (e) {
      print('Error: Failed to add to favourites: $e');
    } finally {
      // isLoading = false;
    }
    return success;
  }

  Future<bool> removeFromFavourites(String? source) async {
    bool success = false;
    try {
      // isLoading = true;
      success = await client.removeFromFavourites(details!.url!, source ?? currentSource);
    } catch (e) {
      print('Error: Failed to add to favourites: $e');
    } finally {
      // isLoading = false;
    }
    return success;
  }
}
