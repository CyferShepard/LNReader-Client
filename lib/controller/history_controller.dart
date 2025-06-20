import 'package:get/get.dart';
import 'package:light_novel_reader_client/globals.dart';
import 'package:light_novel_reader_client/models/chapters.dart';
import 'package:light_novel_reader_client/models/details.dart';
import 'package:light_novel_reader_client/models/history.dart';

class HistoryController extends GetxController {
  final _history = List<History>.empty(growable: true).obs;
  List<History> get history => _history.toList();
  set history(List<History> value) => _history.value = value;

  final _novelhistory = List<History>.empty(growable: true).obs;
  List<History> get novelhistory => _novelhistory.toList();
  set novelhistory(List<History> value) => _novelhistory.value = value;

  final _isLoading = false.obs;
  bool get isLoading => _isLoading.value;
  set isLoading(bool value) => _isLoading.value = value;

  final _searchQuery = ''.obs;
  String get searchQuery => _searchQuery.value;
  set searchQuery(String value) => _searchQuery.value = value;

  Future<void> getHistory() async {
    isLoading = true;
    await client.getHistory().then((value) {
      value.sort((a, b) => b.lastRead.compareTo(a.lastRead));
      history = value;
    }).catchError((error) {
      print('Error fetching history: $error');
    });
    isLoading = false;
  }

  Future<void> getNovelHistory(String url, String source) async {
    isLoading = true;
    await client.getHistory(novelUrl: url, source: source).then((value) {
      value.sort((a, b) => b.lastRead.compareTo(a.lastRead));
      novelhistory = value;
    }).catchError((error) {
      print('Error fetching history: $error');
    });
    isLoading = false;
  }

  chapterHistory(String url, String source) {
    return novelhistory.where((h) => h.url == url && h.source == source).firstOrNull;
  }

  History? getLatestChapterHistory() {
    if (novelhistory.isEmpty) return null;
    return novelhistory.reduce((a, b) => a.chapter.index > b.chapter.index ? a : b);
  }

  Future<void> addToHistory(
      {required Details novel,
      required ChapterListItem chapter,
      required String source,
      int page = 0,
      double position = 0.0}) async {
    // isLoading = true;
    try {
      print('Adding to history: ${novel.title} - ${chapter.title} at position $position');
      History? history =
          await client.addToHistory(novel: novel, chapter: chapter, source: source, page: page, position: position);
      if (history != null) {
        // Check if the novel already exists in history
        final existingIndex = this.history.indexWhere((h) => h.novel.url == history.novel.url);
        if (existingIndex != -1) {
          // Update existing history entry
          this.history = this.history.map((h) => h.novel.url == history.novel.url ? history : h).toList();
        } else {
          // Add new history entry
          this.history = [history, ...this.history];
        }
        final updated = [...this.history];
        updated.sort((a, b) => b.lastRead.compareTo(a.lastRead));
        this.history = updated;
        if (!novelhistory.any((h) => h.url == history.url && h.source == history.source)) {
          novelhistory = [history, ...novelhistory];
        } else {
          novelhistory = novelhistory.map((h) => h.url == history.url && h.source == history.source ? history : h).toList();
        }
      }
    } catch (error) {
      print('Error adding to history: $error');
    } finally {
      // isLoading = false;
    }
  }

  Future<void> markAsRead(
    List<ChapterListItem> chapters,
    Details novel,
    String source, {
    bool isRead = true,
  }) async {
    try {
      print('Marking chapters as read: ${novel.title}');
      List<History>? history =
          await client.markAsRead(novel: novel, chapters: chapters, source: source, page: 0, position: isRead ? 1 : 0);

      if (history != null && history.isNotEmpty) {
        updateNovelHistoryList(history);
      }
    } catch (error) {
      print('Error in markAsRead: $error');
    }
    uiController.clearChapterSelection();
  }

  void updateNovelHistoryList(List<History> newItems) {
    final current = [...novelhistory];
    for (final item in newItems) {
      final index = current.indexWhere((h) => h.url == item.url && h.source == item.source);
      if (index != -1) {
        current[index] = item; // Replace existing
      } else {
        current.add(item); // Add new
      }
    }
    novelhistory = current;
  }

  clearHistory() {
    history = [];
  }

  clearNovelHistory() {
    novelhistory = [];
  }
}
