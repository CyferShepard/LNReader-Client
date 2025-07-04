enum SourceFilterFieldType {
  text,
  numeric,
  dropdown,
  multiSelect,
  singleSelect,
  slider,
}

SourceFilterFieldType sourceFilterFieldTypeFromString(String type) {
  switch (type) {
    case 'text':
      return SourceFilterFieldType.text;
    case 'numeric':
      return SourceFilterFieldType.numeric;
    case 'dropdown':
      return SourceFilterFieldType.dropdown;
    case 'multiSelect':
      return SourceFilterFieldType.multiSelect;
    case 'singleSelect':
      return SourceFilterFieldType.singleSelect;
    case 'slider':
      return SourceFilterFieldType.slider;
    default:
      throw ArgumentError('Unknown SourceFilterFieldType: $type');
  }
}

String sourceFilterFieldTypeToString(SourceFilterFieldType type) {
  return type.toString().split('.').last;
}

class FieldOptions {
  final String name;
  final String value;

  FieldOptions({
    required this.name,
    required this.value,
  });

  factory FieldOptions.fromJson(Map<String, dynamic> json) {
    return FieldOptions(
      name: json['name'] as String,
      value: json['value'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'value': value,
      };
}

class SourceFilterField {
  final FilterType type; // "text" | "numeric" | "dropdown" | "multiSelect" | "singleSelect" | "slider"
  final bool isParameter;
  final String fieldName;
  final String fieldVar;
  final bool isMultiVar;

  bool get isMainSearchField => type.type == 'main';

  SourceFilterField({
    required this.type,
    this.isParameter = true,
    required this.fieldName,
    required this.fieldVar,
    this.isMultiVar = false,
  });

  factory SourceFilterField.fromJson(Map<String, dynamic> json) {
    return SourceFilterField(
      type: json['type'] != null
          ? FilterType.fromJson(json['type'] as Map<String, dynamic>)
          : FilterType(type: 'text'), // Default to 'text' if not provided
      isParameter: json['isParameter'] ?? true,
      fieldName: json['fieldName'] as String,
      fieldVar: json['fieldVar'] as String,
      isMultiVar: json['isMultiVar'] ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'type': type,
        'isParameter': isParameter,
        'fieldName': fieldName,
        'fieldVar': fieldVar,
        'isMultiVar': isMultiVar,
      };
}

class FilterType {
  final String type; // "text" | "numeric" | "dropdown" | "multiSelect" | "singleSelect" | "slider"
  final List<FieldOptions> fieldOptions;
  final num? minValue;
  final num? maxValue;
  final dynamic defaultValue; // String | FieldOptions | num

  FilterType({
    required this.type,
    this.fieldOptions = const [],
    this.minValue,
    this.maxValue,
    this.defaultValue,
  });

  factory FilterType.fromJson(Map<String, dynamic> json) {
    bool isNumeric(dynamic s) {
      if (s == null) return false;
      return int.tryParse(s.toString()) != null;
    }

    return FilterType(
      type: json['type'] as String,
      fieldOptions:
          (json['fieldOptions'] as List<dynamic>?)?.map((e) => FieldOptions.fromJson(e as Map<String, dynamic>)).toList() ?? [],
      minValue: json['minValue'],
      maxValue: json['maxValue'],
      defaultValue: json['defaultValue'] is Map<String, dynamic>
          ? FieldOptions.fromJson(json['defaultValue'] as Map<String, dynamic>)
          : isNumeric(json['defaultValue'])
              ? int.parse(json['defaultValue'].toString())
              : json['defaultValue'], // Handle both FieldOptions and num
    );
  }

  Map<String, dynamic> toJson() => {
        'type': type,
        'fieldOptions': fieldOptions.map((e) => e.toJson()).toList(),
        if (minValue != null) 'minValue': minValue,
        if (maxValue != null) 'maxValue': maxValue,
        if (defaultValue != null) 'defaultValue': defaultValue,
      };
}
