import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:light_novel_reader_client/components/novel_card.dart';
import 'package:light_novel_reader_client/components/search_bar.dart';
import 'package:light_novel_reader_client/extensions/context_extensions.dart';
import 'package:light_novel_reader_client/globals.dart';
import 'package:light_novel_reader_client/pages/details/details_view.dart';
import 'package:tab_container/tab_container.dart';

class FavouritesView extends StatelessWidget {
  const FavouritesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Scaffold(
        appBar: AppBar(
          scrolledUnderElevation: 0,
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
            if (context.isTabletOrDesktop)
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () async {
                  await uiController.getCategories();
                  await favouritesController.getFavourites();
                },
              ),
          ],
        ),
        body: Obx(() {
          if (favouritesController.isLoading || uiController.categories.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          return TabContainer(
            tabEdge: TabEdge.top,
            tabMaxLength: 150,
            borderRadius: BorderRadius.circular(10),
            tabBorderRadius: BorderRadius.circular(10),
            childPadding: const EdgeInsets.only(top: 8),
            selectedTextStyle: const TextStyle(
              fontSize: 15.0,
            ),
            unselectedTextStyle: TextStyle(
              color: Theme.of(context).colorScheme.onSecondary,
              fontSize: 13.0,
            ),
            colors: uiController.categories
                .map(
                  (c) => Theme.of(context).colorScheme.secondary,
                )
                .toList(),
            tabs: uiController.categories
                .map(
                  (c) => Text(
                    c.name,
                    style: Theme.of(context).textTheme.titleMedium!.copyWith(
                          color: Theme.of(context).colorScheme.onSecondary,
                        ),
                  ),
                )
                .toList(),
            children: uiController.categories.map((c) => favouritesBody(context, c.name)).toList(),
          );
        }),
      ),
    );
  }

  RefreshIndicator favouritesBody(BuildContext context, String category) {
    return RefreshIndicator(
      onRefresh: () async {
        await uiController.getCategories();
        await favouritesController.getFavourites();
      },
      child: Obx(() {
        if (favouritesController.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final items = favouritesController.favourites.where((novel) {
          final searchQuery = favouritesController.searchQuery.toLowerCase();
          return (novel.title.toLowerCase().contains(searchQuery) || novel.author.toLowerCase().contains(searchQuery)) &&
              (novel.categories.contains(category));
        }).toList();

        if (items.isEmpty) {
          return ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              SizedBox(
                height: context.height / 1.25,
                child: const Center(child: Text('No Favourites found.')),
              ),
            ],
          );
        }

        return Padding(
          padding: const EdgeInsets.only(top: 8.0, left: 8, right: 8),
          child: GridView.builder(
            itemCount: items.length,
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 200, // Each item's max width
              mainAxisSpacing: 2,
              crossAxisSpacing: 2,
              childAspectRatio: 200 / 320, // width / height
            ),
            itemBuilder: (context, index) {
              return NovelCard(
                maxHeight: 320,
                novelCardData: NovelCardData(
                  title: items[index].title,
                  cover: items[index].cover,
                  url: items[index].url,
                  source: items[index].source,
                  chapterCount: items[index].chapterCount,
                  readCount: items[index].readCount,
                ),
                onTap: () {
                  apiController.fetchDetails(
                    items[index].url,
                    source: items[index].source,
                    canCacheChapters: true,
                    canCacheNovel: true,
                    categories: items[index].categories,
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
    );
  }
}
