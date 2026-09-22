import 'dart:convert';

import 'package:http/http.dart' as http;

import 'gemini_platform_headers.dart';

class CivicaChatService {
  CivicaChatService._();

  // Supplied only at build/run time. It is intentionally not stored in source.
  static const _apiKey = String.fromEnvironment('GEMINI_API_KEY');
  static const _endpoint =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent';

  static const _systemInstruction =
      '''You are Civica, the official digital resident assistant for Barangay Apokon, Tagum City, Davao del Norte, Philippines. You serve residents using the Civica Resident Portal.

Scope: explain Civica features (document requests, request tracking, announcements, health and community services, emergency reports, polls, and barangay officials) and provide helpful, practical guidance about ordinary barangay concerns.

Accuracy rules:
- Treat only the information in this instruction and the resident's message as confirmed local facts. Do not invent Apokon office hours, fees, phone numbers, names of officials, document requirements, schedules, ordinances, case outcomes, or service availability.
- For local details that are unconfirmed or may change, say that the resident should confirm with Barangay Apokon or the relevant Civica announcement. Offer a short checklist or next step instead of guessing.
- You may explain general Philippine barangay processes in plain language, but say when a barangay officer, Lupon Tagapamayapa, city office, lawyer, police, health professional, or emergency service must make the official decision.
- Do not promise approvals, submit forms, access private records, determine eligibility, or claim to be an official decision-maker.
- For an immediate threat to life, crime in progress, fire, disaster, or medical emergency, tell the resident to call 911 / local emergency services now and use Civica's Report Emergency feature if safe.

Style: be warm, concise, respectful, and useful. Answer in the resident's language (English, Filipino, or Cebuano) when possible. For complex matters, provide numbered next steps. If a question is outside Civica/barangay-resident assistance, briefly say so and redirect to relevant local assistance.''';

  static Future<String> ask({
    required String message,
    required List<CivicaChatTurn> history,
  }) async {
    if (_apiKey.isEmpty) {
      return fallbackResponse(message);
    }
    try {
      return await _askGemini(message: message, history: history);
    } catch (_) {
      // The resident assistant must remain useful when the device is offline,
      // Gemini is unavailable, or the API key has been rejected.
      return fallbackResponse(message);
    }
  }

  static Future<String> _askGemini({
    required String message,
    required List<CivicaChatTurn> history,
  }) async {
    final contents =
        history
            .take(12)
            .map(
              (turn) => {
                'role': turn.isUser ? 'user' : 'model',
                'parts': [
                  {'text': turn.text},
                ],
              },
            )
            .toList()
          ..add({
            'role': 'user',
            'parts': [
              {'text': message},
            ],
          });
    final response = await http
        .post(
          Uri.parse(_endpoint),
          headers: {
            'Content-Type': 'application/json',
            'x-goog-api-key': _apiKey,
            'x-goog-api-client': 'civica-school-demo/1.0',
            ...geminiPlatformHeaders(),
          },
          body: jsonEncode({
            'systemInstruction': {
              'parts': [
                {'text': _systemInstruction},
              ],
            },
            'contents': contents,
            'generationConfig': {'temperature': 0.25, 'maxOutputTokens': 700},
          }),
        )
        .timeout(const Duration(seconds: 12));
    if (response.statusCode < 200 || response.statusCode >= 300) {
      final responseBody = jsonDecode(response.body);
      String? apiMessage;
      if (responseBody is Map && responseBody['error'] is Map) {
        apiMessage = (responseBody['error'] as Map)['message']?.toString();
      }
      throw CivicaChatException(
        apiMessage == null || apiMessage.isEmpty
            ? 'Gemini rejected the request (HTTP ${response.statusCode}).'
            : 'Gemini rejected the request (HTTP ${response.statusCode}): $apiMessage',
      );
    }
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final candidates = data['candidates'] as List<dynamic>?;
    final firstCandidate = candidates?.isNotEmpty == true
        ? candidates!.first as Map<String, dynamic>
        : null;
    final parts = firstCandidate?['content']?['parts'] as List<dynamic>?;
    final answer = parts
        ?.whereType<Map<String, dynamic>>()
        .map((part) => part['text']?.toString() ?? '')
        .join()
        .trim();
    if (answer == null || answer.trim().isEmpty) {
      throw const CivicaChatException('Civica could not prepare a response.');
    }
    return answer.trim();
  }

  /// Provides safe, predetermined guidance when Gemini cannot be reached.
  /// This deliberately avoids local facts such as current fees or office hours.
  static String fallbackResponse(String message) {
    final question = message.toLowerCase().trim();

    if (_containsAny(question, [
      'emergency',
      'fire',
      'crime',
      'accident',
      'medical',
      'danger',
      'disaster',
    ])) {
      return 'For an immediate threat to life, a crime in progress, fire, or a medical emergency, call 911 or local emergency services now. If it is safe to do so, you can also use Civica\'s Report Emergency feature to send a report to the barangay.';
    }

    if (_containsAny(question, [
      'track my request',
      'track request',
      'request status',
      'status of my',
      'requested document',
    ])) {
      return 'To check a document request, open Civica\'s request-tracking section and look for your submitted request. Its status may show as pending, approved, rejected, finished, or released. For a status that has not changed, please confirm with Barangay Apokon.';
    }

    if (_containsAny(question, [
      'business clearance',
      'business permit',
    ])) {
      return 'For a Barangay Business Clearance, start by checking Civica\'s document-request options or visit Barangay Apokon. The barangay can confirm the current form, supporting documents, fee, and release process before you apply.';
    }

    if (_containsAny(question, [
      'indigency',
      'indigent',
    ])) {
      return 'For a Certificate of Indigency, ask Barangay Apokon about the current application process and supporting documents. The barangay must verify eligibility and can tell you the current fee, if any, and release schedule.';
    }

    if (_containsAny(question, [
      'residency',
      'residence certificate',
      'certificate of residency',
    ])) {
      return 'A Certificate of Residency generally confirms that you live in the barangay. Submit a document request in Civica or contact Barangay Apokon to confirm the current requirements, fee, and processing time.';
    }

    if (_containsAny(question, [
      'barangay clearance',
      'barangay certificate',
      'clearance',
      'document issuance',
      'permit',
    ])) {
      return 'You can begin by opening Civica\'s document-request feature and choosing the document you need. Provide complete, accurate details, then track the request in the portal. Barangay Apokon will confirm any current requirements, fee, and release schedule.';
    }

    if (_containsAny(question, [
      'service',
      'announcement',
      'health',
      'community',
      'poll',
      'official',
    ])) {
      return 'Civica can help you view announcements, request documents, track requests, report emergencies, find community and health updates, join polls, and view barangay information. Check the relevant portal section for current details, since schedules and availability can change.';
    }

    if (_containsAny(question, [
      'office hour',
      'open',
      'schedule',
      'fee',
      'contact',
      'phone',
    ])) {
      return 'I cannot confirm current office hours, fees, or contact details while the online assistant is unavailable. Please check the latest Civica announcement or contact Barangay Apokon directly for the official information.';
    }

    return 'I\'m currently using Civica\'s offline help. I can assist with document requests, request tracking, announcements, barangay services, and emergency reporting. For current local details, please check Civica announcements or confirm with Barangay Apokon.';
  }

  static bool _containsAny(String text, List<String> phrases) =>
      phrases.any((phrase) => text.contains(phrase));
}

class CivicaChatTurn {
  final String text;
  final bool isUser;

  const CivicaChatTurn({required this.text, required this.isUser});
}

class CivicaChatException implements Exception {
  final String message;
  const CivicaChatException(this.message);
}
