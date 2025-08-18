String? getApiUrlFromEnv() {
  // Default for non-web platforms
  return null;
}

bool allowChangeServerFromEnv() {
  // Default for non-web platforms
  return true;
}
