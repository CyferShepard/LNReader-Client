import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:light_novel_reader_client/components/novel_card.dart';
import 'package:light_novel_reader_client/components/search_bar.dart';
import 'package:light_novel_reader_client/extensions/context_extensions.dart';
import 'package:light_novel_reader_client/globals.dart';
import 'package:light_novel_reader_client/pages/details/details_view.dart';

class FavouritesView extends StatelessWidget {
  const FavouritesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Favourites (${favouritesController.favourites.length})'),
        actions: [
          CustomSearchBar(
            initialValue: favouritesController.searchQuery,
            onChanged: (value) {
              favouritesController.searchQuery = (value);
            },
            onClear: () {
              favouritesController.searchQuery = '';
            },
            hintText: 'Search Favourites',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await favouritesController.getFavourites();
        },
        child: Obx(() {
          if (favouritesController.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (favouritesController.favourites.isEmpty) {
            return const Center(child: Text('No Favourites found.'));
          }

          final items = favouritesController.favourites.where((novel) {
            final searchQuery = favouritesController.searchQuery.toLowerCase();
            return novel.title.toLowerCase().contains(searchQuery) || novel.author.toLowerCase().contains(searchQuery);
          }).toList();

          if (items.isEmpty) {
            return const Center(
              child: Text('No Favourites found'),
            );
          }

          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: GridView.builder(
              itemCount: items.length,
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 200, // Each item's max width
                mainAxisSpacing: 2,
                crossAxisSpacing: 2,
                childAspectRatio: 200 / 340, // width / height
              ),
              itemBuilder: (context, index) {
                return NovelCard(
                  maxHeight: 340,
                  novelCardData: NovelCardData(
                    title: items[index].title,
                    cover: items[index].cover,
                    url: items[index].url,
                    source: items[index].source,
                  ),
                  onTap: () {
                    apiController.fetchDetails(
                      items[index].url,
                      source: items[index].source,
                      canCacheChapters: true,
                      canCacheNovel: true,
                    );
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DetailsView(
                          source: items[index].source,
                          canCacheChapters: true,
                          canCacheNovel: true,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          );
        }),
      ),
      floatingActionButton: context.isTabletOrDesktop
          ? FloatingActionButton(
              onPressed: () async {
                await favouritesController.getFavourites();
              },
              child: const Icon(Icons.refresh),
            )
          : null,
    );
  }
}
