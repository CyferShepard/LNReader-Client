import 'package:get/get.dart';
import 'package:light_novel_reader_client/globals.dart';
import 'package:light_novel_reader_client/models/favouriteWithNovelMeta.dart';

enum SortBy { dateAdded, lastRead, lastUpdated, title, author }

class FavouritesController extends GetxController {
  final _favourites = List<FavouriteWithNovelMeta>.empty(growable: true).obs;
  List<FavouriteWithNovelMeta> get favourites => _favourites.toList();
  set favourites(List<FavouriteWithNovelMeta> value) => _favourites.value = value;

  final _isLoading = false.obs;
  bool get isLoading => _isLoading.value;
  set isLoading(bool value) => _isLoading.value = value;

  final _searchQuery = ''.obs;
  String get searchQuery => _searchQuery.value;
  set searchQuery(String value) => _searchQuery.value = value;

  final _sortOrder = SortBy.lastUpdated.obs;
  SortBy get sortOrder => _sortOrder.value;
  set sortOrder(SortBy value) {
    _sortOrder.value = value;
    sortFavourites();
  }

  final _sortAsc = false.obs;
  bool get sortAsc => _sortAsc.value;
  set sortAsc(bool value) {
    _sortAsc.value = value;
    sortFavourites();
  }

  sortFavourites() {
    List<FavouriteWithNovelMeta> tempFavourites = favourites;
    tempFavourites.sort((a, b) {
      switch (sortOrder) {
        case SortBy.dateAdded:
          return sortAsc ? a.dateAdded.compareTo(b.dateAdded) : b.dateAdded.compareTo(a.dateAdded);
        case SortBy.lastRead:
          if (a.lastRead != null && b.lastRead != null) {
            return sortAsc ? a.lastRead!.compareTo(b.lastRead!) : b.lastRead!.compareTo(a.lastRead!);
          }

          if (a.lastRead == null) return 1; // a at end
          return -1;
        case SortBy.lastUpdated:
          if (a.chapterDateAdded != null && b.chapterDateAdded != null) {
            return sortAsc
                ? a.chapterDateAdded!.compareTo(b.chapterDateAdded!)
                : b.chapterDateAdded!.compareTo(a.chapterDateAdded!);
          }

          if (a.chapterDateAdded == null) return 1; // a at end
          return -1;
        case SortBy.title:
          return sortAsc ? a.title.compareTo(b.title) : b.title.compareTo(a.title);
        case SortBy.author:
          return sortAsc ? a.author.compareTo(b.author) : b.author.compareTo(a.author);
      }
    });

    favourites = tempFavourites;
  }

  Future<void> getFavourites({bool suppressLoader = false}) async {
    if (suppressLoader == false) {
      isLoading = true;
    }

    await client.getFavourites().then((value) {
      favourites = value;
      sortFavourites();
    }).catchError((error) {
      print('Error fetching favourites: $error');
    });

    if (suppressLoader == false) {
      isLoading = false;
    }
  }

  Future<void> addToFavourites(String url, String source) async {
    try {
      print('Adding to favourites: $url from source: $source');
      List<FavouriteWithNovelMeta> favs = await client.getFavourites(url: url, source: source);
      bool alreadyExists = favs.isNotEmpty;
      print('Already exists: $alreadyExists');
      bool success =
          alreadyExists ? await apiController.removeFromFavourites(source) : await apiController.addToFavourites(source);
      print(alreadyExists ? 'Removed from favourites: $success' : 'Added to favourites: $success');
      if (success) {
        getFavourites(suppressLoader: true).then((_) {
          if (apiController.details != null && apiController.details!.categories.isEmpty) {
            FavouriteWithNovelMeta? favouritedNovel = favourites.firstWhereOrNull((f) => f.url == url && f.source == source);
            if (favouritedNovel != null && favouritedNovel.categories.isNotEmpty) {
              apiController.details = apiController.details!.copyWith(categories: favouritedNovel.categories);
            }
          }
        });
        print('Favourites updated successfully');
      }
    } catch (e) {
      print('Error adding to favourites: $e');
    }
  }

  Future<void> clearFavourites() async {
    favourites = [];
  }

  bool isFavourite(String url, String source) {
    return favouritesController.favourites.isNotEmpty && favourites.any((f) => f.url == url && f.source == source);
  }

  void updateReadCount(int read, String url, String source) async {
    FavouriteWithNovelMeta? favourite = favourites.firstWhereOrNull((f) => f.url == url && f.source == source);
    if (favourite != null) {
      favourite = favourite.copyWith(readCount: read);
      List<FavouriteWithNovelMeta> favouritesList =
          favourites.map((f) => f.url == url && f.source == source ? favourite! : f).toList();
      favourites = favouritesList;
    }
  }
}
