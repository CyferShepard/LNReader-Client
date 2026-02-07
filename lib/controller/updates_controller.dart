import 'package:get/get.dart';
import 'package:light_novel_reader_client/globals.dart';
import 'package:light_novel_reader_client/models/favouritesWithChapterMeta.dart';

class UpdatesController extends GetxController {
  final _updates = List<FavouriteWitChapterMeta>.empty(growable: true).obs;
  List<FavouriteWitChapterMeta> get updates => _updates.toList();
  set updates(List<FavouriteWitChapterMeta> value) => _updates.value = value;

  final _isLoading = false.obs;
  bool get isLoading => _isLoading.value;
  set isLoading(bool value) => _isLoading.value = value;

  final _searchQuery = ''.obs;
  String get searchQuery => _searchQuery.value;
  set searchQuery(String value) => _searchQuery.value = value;

  int currentPage = 1;
  int pageSize = 10;
  int totalPages = 1;

  Future<void> getUpdates() async {
    isLoading = true;
    currentPage = 1;
    totalPages = 1;
    await client.getLatestChapters(page: currentPage, pageSize: pageSize).then((value) {
      if (value.results.isEmpty) {
        print('No updates found');
        return;
      }
      value.results.sort((a, b) => b.chapter.dateAdded.compareTo(a.chapter.dateAdded));
      updates = value.results;
      currentPage = value.page;
      pageSize = value.pageSize;
      totalPages = value.totalPages;
    }).catchError((error) {
      print('Error fetching history: $error');
    });
    isLoading = false;
  }

  Future<void> loadMoreUpdates() async {
    if (currentPage >= totalPages) return; // No more pages to load
    currentPage++;
    await client.getLatestChapters(page: currentPage, pageSize: pageSize).then((value) {
      if (value.results.isEmpty) {
        print('No more updates found');
        return;
      }
      value.results.sort((a, b) => b.chapter.dateAdded.compareTo(a.chapter.dateAdded));
      updates = [...updates, ...value.results];
      currentPage = value.page;
      pageSize = value.pageSize;
      totalPages = value.totalPages;
    }).catchError((error) {
      print('Error fetching more updates: $error');
    });
  }

  clearUpdates() {
    updates = [];
  }
}
