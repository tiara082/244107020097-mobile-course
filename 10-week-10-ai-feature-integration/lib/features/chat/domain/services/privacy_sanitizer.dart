class PrivacySanitizer {
  const PrivacySanitizer();

  static final RegExp _nikRegex = RegExp(r'\b\d{16}\b');
  static final RegExp _nimRegex = RegExp(r'\b\d{10,12}\b');
  static final RegExp _phoneRegex = RegExp(r'\b(\+62|62|08)[0-9]{8,12}\b');
  static final RegExp _emailRegex = RegExp(r'[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}');

  String sanitize(String input) {
    var result = input;
    result = result.replaceAll(_nikRegex, '[REDACTED_NIK]');
    result = result.replaceAll(_phoneRegex, '[REDACTED_PHONE]');
    result = result.replaceAll(_nimRegex, '[REDACTED_NIM]');
    result = result.replaceAll(_emailRegex, '[REDACTED_EMAIL]');
    return result;
  }
}
