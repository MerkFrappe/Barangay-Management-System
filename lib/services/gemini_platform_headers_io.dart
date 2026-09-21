import 'dart:io';

const _androidPackage = String.fromEnvironment(
  'GEMINI_ANDROID_PACKAGE',
  defaultValue: 'com.example.bms',
);
const _androidCertSha1 = String.fromEnvironment('GEMINI_ANDROID_CERT_SHA1');

Map<String, String> platformHeaders() {
  if (!Platform.isAndroid || _androidCertSha1.isEmpty) return const {};
  return {
    'X-Android-Package': _androidPackage,
    'X-Android-Cert': _androidCertSha1,
  };
}
