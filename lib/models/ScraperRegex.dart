class ScraperRegex {
  RegExp? regex;
  String? process; // Stores JavaScript code as a string

  ScraperRegex({
    this.regex,
    this.process,
  });

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      if (regex != null) 'regex': regex!.pattern,
      if (process != null) 'process': process,
    };
  }

  // Create from JSON
  factory ScraperRegex.fromJson(Map<String, dynamic> json) {
    RegExp? regexObj;
    if (json['regex'] != null && json['regex'] is String) {
      try {
        regexObj = RegExp(json['regex'] as String);
      } catch (e) {
        print('Failed to parse regex: ${e.toString()}');
      }
    }

    return ScraperRegex(
      regex: regexObj,
      process: json['process'] as String?,
    );
  }

  @override
  String toString() {
    return 'ScraperRegex(pattern: ${regex?.pattern}, hasProcess: ${process != null})';
  }

  copyWith({
    RegExp? regex,
    String? process,
  }) {
    return ScraperRegex(
      regex: regex ?? this.regex,
      process: process ?? this.process,
    );
  }
}
