import 'package:flutter/material.dart';
import 'package:light_novel_reader_client/extensions/context_extensions.dart';
import 'package:light_novel_reader_client/pages/details/details_desktop_view.dart';
import 'package:light_novel_reader_client/pages/details/details_mobile_view.dart';

class DetailsView extends StatelessWidget {
  const DetailsView({super.key, this.source});

  final String? source;

  @override
  Widget build(BuildContext context) {
    return context.isTabletOrDesktop ? DetailsDesktopPage(source: source) : DetailsMobilePage(source: source);
  }
}
