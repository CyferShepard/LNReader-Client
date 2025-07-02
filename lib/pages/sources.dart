import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:light_novel_reader_client/extensions/context_extensions.dart';
import 'package:light_novel_reader_client/globals.dart';

class SourcesPage extends StatelessWidget {
  const SourcesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0,
        title: const Text('Sources'),
        actions: [
          if (context.isTabletOrDesktop)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () async {
                await apiController.fetchSources();
              },
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await apiController.fetchSources();
        },
        child: Obx(() {
          if (apiController.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (apiController.sources.isEmpty) {
            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                SizedBox(
                  height: context.height / 1.25,
                  child: const Center(child: Text('No Sources found.')),
                ),
              ],
            );
          }

          return ListView.builder(
            itemCount: apiController.sources.length,
            itemBuilder: (context, index) {
              final source = apiController.sources[index].name;
              final icon = '${client.baseUrl}/proxy/icon?source=$source';
              return Padding(
                padding: const EdgeInsets.all(4.0),
                child: ListTile(
                  leading: source.isNotEmpty ? Image.network(icon, height: 50, fit: BoxFit.cover) : const Icon(Icons.book),
                  title: Text(source),
                  onTap: () {
                    print('Source Selected: You selected $source');
                    apiController.setSource(source);
                    apiController.fetchLatest(source: source);
                  },
                ),
              );
            },
          );
        }),
      ),
    );
  }
}
