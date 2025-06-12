import 'dart:convert';

// import 'package:http/http.dart' as http;
import 'package:equatable/equatable.dart';

import './ScraperQuery.dart';

enum HTTPMethod { get, post, put, delete, patch, head, options }

extension HTTPMethodExtension on HTTPMethod {
  String get value {
    switch (this) {
      case HTTPMethod.get:
        return 'GET';
      case HTTPMethod.post:
        return 'POST';
      case HTTPMethod.put:
        return 'PUT';
      case HTTPMethod.delete:
        return 'DELETE';
      case HTTPMethod.patch:
        return 'PATCH';
      case HTTPMethod.head:
        return 'HEAD';
      case HTTPMethod.options:
        return 'OPTIONS';
    }
  }

  static HTTPMethod fromString(String value) {
    switch (value.toUpperCase()) {
      case 'GET':
        return HTTPMethod.get;
      case 'POST':
        return HTTPMethod.post;
      case 'PUT':
        return HTTPMethod.put;
      case 'DELETE':
        return HTTPMethod.delete;
      case 'PATCH':
        return HTTPMethod.patch;
      case 'HEAD':
        return HTTPMethod.head;
      case 'OPTIONS':
        return HTTPMethod.options;
      default:
        return HTTPMethod.get;
    }
  }
}

enum BodyType { JSON, FORM_DATA }

extension BodyTypeExtension on BodyType {
  String get value {
    switch (this) {
      case BodyType.JSON:
        return 'JSON';
      case BodyType.FORM_DATA:
        return 'FORM_DATA';
    }
  }

  static BodyType fromString(String value) {
    switch (value.toUpperCase()) {
      case 'JSON':
        return BodyType.JSON;
      case 'FORM_DATA':
        return BodyType.FORM_DATA;
      default:
        return BodyType.JSON;
    }
  }
}

class ScraperPayload extends Equatable {
  String url;
  HTTPMethod type;
  dynamic body; // Using dynamic since it can be Map<String, dynamic> or FormData
  BodyType bodyType;
  bool waitForPageLoad;
  String? waitForElement;
  List<ScraperQuery> query;

  ScraperPayload({
    required this.url,
    this.type = HTTPMethod.get,
    this.body,
    this.bodyType = BodyType.JSON,
    this.waitForPageLoad = false,
    this.waitForElement,
    required this.query,
  });
  Map<String, dynamic> toJson() {
    String? bodyString = '';
    if (body is Map<String, dynamic>) {
      if (bodyType == BodyType.FORM_DATA) {
        // Convert Map to URL-encoded string
        final parts = <String>[];
        (body as Map<String, dynamic>).forEach((key, value) {
          parts.add('${Uri.encodeComponent(key)}=${Uri.encodeComponent(value.toString())}');
        });
        bodyString = parts.join('&');
      } else {
        bodyString = json.encode(body);
      }
    } else {
      bodyString = body != null ? body.toString() : body;
    }

    return {
      'url': url,
      'type': type.value,
      if (bodyString != null && bodyString.isNotEmpty) 'body': bodyString,
      'bodyType': bodyType.value,
      'waitForPageLoad': waitForPageLoad,
      if (waitForElement != null) 'waitForElement': waitForElement,
      if (query.isNotEmpty) 'query': query.map((e) => e.toJson()).toList(),
    };
  }

  factory ScraperPayload.fromJson(Map<String, dynamic> json) {
    return ScraperPayload(
      url: json['url'] ?? '',
      type: HTTPMethodExtension.fromString(json['type'] ?? 'GET'),
      body: json['body'],
      bodyType: BodyTypeExtension.fromString(json['bodyType'] ?? 'JSON'),
      waitForPageLoad: json['waitForPageLoad'] ?? false,
      waitForElement: json['waitForElement'],
      query: (json['query'] as List?)?.map((e) => ScraperQuery.fromJson(e)).toList() ?? [],
    );
  }

  copyWith({
    String? url,
    HTTPMethod? type,
    dynamic body,
    BodyType? bodyType,
    bool? waitForPageLoad,
    String? waitForElement,
    List<ScraperQuery>? query,
  }) {
    return ScraperPayload(
      url: url ?? this.url,
      type: type ?? this.type,
      body: body ?? this.body,
      bodyType: bodyType ?? this.bodyType,
      waitForPageLoad: waitForPageLoad ?? this.waitForPageLoad,
      waitForElement: waitForElement ?? this.waitForElement,
      query: query ?? this.query,
    );
  }

  @override
  List<Object?> get props => [
        url,
        type,
        body,
        bodyType,
        waitForPageLoad,
        waitForElement,
        query,
      ];
}
