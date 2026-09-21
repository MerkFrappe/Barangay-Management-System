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
      throw const CivicaChatException(
        'Civica has not been configured with a demo Gemini key.',
      );
    }
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
    final response = await http.post(
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
    );
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
