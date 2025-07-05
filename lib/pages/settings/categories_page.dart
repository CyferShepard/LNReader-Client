import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:light_novel_reader_client/globals.dart';

class CategoriesPage extends StatefulWidget {
  const CategoriesPage({super.key});

  @override
  State<CategoriesPage> createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> {
  @override
  void initState() {
    super.initState();
    uiController.getCategories();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => RefreshIndicator(
        onRefresh: () async {
          await uiController.getCategories();
        },
        child: uiController.isCategoriesLoading
            ? const Center(child: CircularProgressIndicator())
            : Padding(
                padding: const EdgeInsets.all(16.0),
                child: ListView.builder(
                  itemCount: uiController.categories.length + (uiController.categories.length < 5 ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index >= uiController.categories.length && uiController.categories.length < 5) {
                      return ElevatedButton(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: const Text('Add New Category'),
                                content: TextField(
                                  decoration: const InputDecoration(
                                    labelText: 'Category Name',
                                  ),
                                  maxLength: 10,
                                  onSubmitted: (value) {
                                    if (value.isNotEmpty) {
                                      uiController.addCategory(value);
                                      Navigator.of(context).pop();
                                    }
                                  },
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.of(context).pop(),
                                    child: const Text('Cancel'),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 50), // Full width button
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          backgroundColor: Theme.of(context).colorScheme.primary,
                        ),
                        child: const Text(
                          'Add New Category',
                          style: TextStyle(fontSize: 14, color: Colors.white),
                        ),
                      );
                    }
                    final categories = uiController.categories[index];
                    return ListTile(
                      leading: const Icon(Icons.list),
                      title: Text(categories.name),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: const Text('Delete Category'),
                                content: Text('Are you sure you want to delete "${categories.name}"?'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.of(context).pop(),
                                    child: const Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      uiController.deleteCategory(categories.name);
                                      Navigator.of(context).pop();
                                    },
                                    child: const Text('Delete'),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
      ),
    );
  }
}
