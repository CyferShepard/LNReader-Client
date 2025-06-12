import 'package:equatable/equatable.dart';

import './ScraperRegex.dart';

class ScraperQuery extends Equatable {
  final String label;
  final String? element;
  final bool getContent;
  final bool withHref;
  final String? dataProp;
  final List<ScraperQuery>? subQuery;
  final List<int> selectItemsAtIndex;
  final ScraperRegex? regex;
  final String? transformProcess; // Stores JavaScript code as a string

  ScraperQuery({
    required this.label,
    this.element,
    this.getContent = true,
    this.withHref = false,
    this.dataProp,
    this.subQuery,
    List<int>? selectItemsAtIndex,
    this.regex,
    this.transformProcess,
  }) : selectItemsAtIndex = selectItemsAtIndex ?? [];

  Map<String, dynamic> toJson() {
    return {
      if (label.isNotEmpty) 'label': label,
      if (element != null) 'element': element,
      'getContent': getContent, // Always included since it's non-nullable
      'withHref': withHref, // Always included since it's non-nullable
      if (dataProp != null) 'dataProp': dataProp,
      if (subQuery != null && subQuery!.isNotEmpty) 'subQuery': subQuery!.map((e) => e.toJson()).toList(),
      if (selectItemsAtIndex.isNotEmpty) 'selectItemsAtIndex': selectItemsAtIndex,
      if (regex != null) 'regex': regex!.toJson(),
      if (transformProcess != null && transformProcess!.isNotEmpty) 'transformProcess': transformProcess,
    };
  }

  factory ScraperQuery.fromJson(Map<String, dynamic> json) {
    return ScraperQuery(
      label: json['label'] as String,
      element: json['element'] as String?,
      getContent: json['getContent'] as bool? ?? true,
      withHref: json['withHref'] as bool? ?? false,
      dataProp: json['dataProp'] as String?,
      subQuery: (json['subQuery'] as List?)?.map((e) => ScraperQuery.fromJson(e as Map<String, dynamic>)).toList(),
      selectItemsAtIndex: (json['selectItemsAtIndex'] as List?)?.map((e) => e as int).toList() ?? [],
      regex: json['regex'] != null ? ScraperRegex.fromJson(json['regex'] as Map<String, dynamic>) : null,
      transformProcess: json['transformProcess'] as String?,
    );
  }

  copyWith({
    String? label,
    String? element,
    bool? getContent,
    bool? withHref,
    String? dataProp,
    List<ScraperQuery>? subQuery,
    List<int>? selectItemsAtIndex,
    ScraperRegex? regex,
    String? transformProcess,
  }) {
    return ScraperQuery(
      label: label ?? this.label,
      element: element ?? this.element,
      getContent: getContent ?? this.getContent,
      withHref: withHref ?? this.withHref,
      dataProp: dataProp ?? this.dataProp,
      subQuery: subQuery ?? this.subQuery,
      selectItemsAtIndex: selectItemsAtIndex ?? this.selectItemsAtIndex,
      regex: regex ?? this.regex,
      transformProcess: transformProcess ?? this.transformProcess,
    );
  }

  @override
  List<Object?> get props => [
        label,
        element,
        getContent,
        withHref,
        dataProp,
        subQuery,
        selectItemsAtIndex,
        regex,
        transformProcess,
      ];
}
