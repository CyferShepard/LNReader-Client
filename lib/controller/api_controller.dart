import 'package:get/get.dart';
import 'package:light_novel_reader_client/globals.dart';
import 'package:light_novel_reader_client/models/chapter.dart';
import 'package:light_novel_reader_client/models/chapters.dart';
import 'package:light_novel_reader_client/models/details.dart';
import 'package:light_novel_reader_client/models/history.dart';
import 'package:light_novel_reader_client/models/latest.dart';
import 'package:light_novel_reader_client/models/search_result.dart';

class ApiController extends GetxController {
  // Observables
  final _sources = <String>[].obs;
  List<String> get sources => _sources.toList();
  set sources(List<String> value) => _sources.value = value;

  final _currentSource = "".obs;
  String get currentSource => _currentSource.value;
  set currentSource(String value) => _currentSource.value = value;

  final _searchResults = <SearchResult>[].obs;
  List<SearchResult> get searchResults => _searchResults.toList();
  set searchResults(List<SearchResult> value) => _searchResults.value = value;

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

  Future<void> search(String searchTerm) async {
    try {
      isLoading = true;
      searchResults = await client.search(searchTerm, currentSource);
    } catch (e) {
      print('Error: Failed to search: $e');
    } finally {
      isLoading = false;
    }
  }

  Future<Latest?> fetchLatest({String? source, int page = 1}) async {
    try {
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

  Future<Details?> fetchDetails(
    String url, {
    String? source,
    String? lastChapterUrl,
    bool refresh = false,
    required bool canCacheNovel,
    required bool canCacheChapters,
  }) async {
    try {
      isLoading = true;
      details = await client.getDetails(url, source ?? currentSource, refresh: refresh, canCacheNovel: canCacheNovel);
      if (details != null) {
        if (details!.url == null) {
          details = details!.copyWith(url: url);
        }
        if (lastChapterUrl == null) {
          History? history = historyController.history
              .firstWhereOrNull((h) => h.novel.url == details!.url && h.source == (source ?? currentSource));
          lastChapterUrl = history?.chapter.url;
        }
        if (lastChapterUrl != null && lastChapterUrl.isNotEmpty) {
          // Fetch chapters only if lastChapterUrl is provided
          await historyController.getNovelHistory(
            details!.url!,
            source ?? currentSource,
          );
          lastChapterUrl = historyController.getLatestChapterHistory()?.url;
          isChapterLoading = true;
        }
        fetchChapters(
          url,
          source: source ?? currentSource,
          additionalProps: details!.additionalProps,
          lastChapterUrl: lastChapterUrl,
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
        chapters!.sort((a, b) => a.index.compareTo(b.index));
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
