extension CamelCaseSplitAndCapitalize on String {
  String splitCamelCaseAndCapitalize() {
    // Split on uppercase letters, join with space, and capitalize each word
    return replaceAllMapped(
      RegExp(r'([a-z])([A-Z])'),
      (m) => '${m.group(1)} ${m.group(2)}',
    ).split(' ').map((word) => word.isNotEmpty ? '${word[0].toUpperCase()}${word.substring(1)}' : '').join(' ');
  }
}
