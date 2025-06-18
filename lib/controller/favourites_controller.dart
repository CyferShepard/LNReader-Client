import 'package:get/get.dart';
import 'package:light_novel_reader_client/globals.dart';
import 'package:light_novel_reader_client/models/favouriteWithNovelMeta.dart';

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

  Future<void> getFavourites({bool suppressLoader = false}) async {
    if (suppressLoader == false) {
      isLoading = true;
    }

    await client.getFavourites().then((value) {
      value.sort((a, b) => b.dateAdded.compareTo(a.dateAdded));
      favourites = value;
    }).catchError((error) {
      print('Error fetching favourites: $error');
    });

    if (suppressLoader == false) {
      isLoading = false;
    }
  }

  Future<void> addToFavourites(String url, String source) async {
    List<FavouriteWithNovelMeta> favs = await client.getFavourites(url: url, source: source);
    bool alreadyExists = favs.isNotEmpty;
    bool success = alreadyExists ? await apiController.removeFromFavourites(source) : await apiController.addToFavourites(source);
    if (success) {
      getFavourites(suppressLoader: true);
    }
  }

  Future<void> clearFavourites() async {
    favourites = [];
  }

  bool isFavourite(String url, String source) {
    return favouritesController.favourites.isNotEmpty && favourites.any((f) => f.url == url && f.source == source);
  }
}
