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

class SourceFilterField {
  final SourceFilterFieldType type;
  final bool isParameter;
  final String fieldName;
  final String fieldVar;
  final bool isMultiVar;

  SourceFilterField({
    required this.type,
    this.isParameter = true,
    required this.fieldName,
    required this.fieldVar,
    this.isMultiVar = false,
  });

  factory SourceFilterField.fromJson(Map<String, dynamic> json) {
    return SourceFilterField(
      type: sourceFilterFieldTypeFromString(json['type'] as String),
      isParameter: json['isParameter'] ?? true,
      fieldName: json['fieldName'] as String,
      fieldVar: json['fieldVar'] as String,
      isMultiVar: json['isMultiVar'] ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'type': sourceFilterFieldTypeToString(type),
        'isParameter': isParameter,
        'fieldName': fieldName,
        'fieldVar': fieldVar,
        'isMultiVar': isMultiVar,
      };
}
