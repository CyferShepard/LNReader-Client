import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:light_novel_reader_client/globals.dart';

class SourcesPage extends StatelessWidget {
  const SourcesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sources'),
      ),
      body: Obx(() {
        if (apiController.isLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (apiController.sources.isEmpty) {
          return const Center(
            child: Text('No sources available.'),
          );
        }

        return ListView.builder(
          itemCount: apiController.sources.length,
          itemBuilder: (context, index) {
            final source = apiController.sources[index];
            final icon = '${client.baseUrl}/proxy/icon?source=$source';
            return Padding(
              padding: const EdgeInsets.all(4.0),
              child: ListTile(
                leading: source.isNotEmpty ? Image.network(icon, height: 50, fit: BoxFit.cover) : const Icon(Icons.book),
                title: Text(source),
                onTap: () {
                  print('Source Selected: You selected $source');
                  apiController.setSource(source);
                },
              ),
            );
          },
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await apiController.fetchSources();
        },
        child: const Icon(Icons.refresh),
      ),
    );
  }
}
