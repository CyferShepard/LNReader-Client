import 'package:get/get.dart';
import 'package:light_novel_reader_client/globals.dart';
import 'package:light_novel_reader_client/models/chapters.dart';
import 'package:light_novel_reader_client/models/details.dart';
import 'package:light_novel_reader_client/models/history.dart';

class HistoryController extends GetxController {
  final _history = List<History>.empty(growable: true).obs;
  List<History> get history => _history.toList();
  set history(List<History> value) => _history.value = value;

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

  Future<void> addToHistory(
      {required Details novel,
      required ChapterListItem chapter,
      required String source,
      int page = 0,
      double position = 0.0}) async {
    // isLoading = true;
    try {
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
        this.history.sort((a, b) => b.lastRead.compareTo(a.lastRead));
      }
    } catch (error) {
      print('Error adding to history: $error');
    } finally {
      // isLoading = false;
    }
  }

  clearHistory() {
    history = [];
  }
}
