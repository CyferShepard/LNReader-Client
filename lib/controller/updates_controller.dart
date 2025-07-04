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

  Future<void> getUpdates() async {
    isLoading = true;
    await client.getLatestChapters().then((value) {
      if (value == null) {
        print('No updates found');
        return;
      }
      value.sort((a, b) => b.chapter.dateAdded.compareTo(a.chapter.dateAdded));
      updates = value;
    }).catchError((error) {
      print('Error fetching history: $error');
    });
    isLoading = false;
  }

  clearUpdates() {
    updates = [];
  }
}
