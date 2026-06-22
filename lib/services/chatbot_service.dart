import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/knowledge.dart';
import '../utils/app_theme.dart';

class ChatbotService {
  final String _apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';
  final String _base = AppStrings.geminiApiBase;

  static const _systemPrompt = '''You are SmartFarm Assistant, an expert agricultural advisor.
You help farmers with:
- Crop cultivation and management
- Plant disease identification and treatment
- Soil health and fertilization
- Pest management
- Weather-based farming advice
- Irrigation management
- Organic farming practices

Keep responses concise, practical, and farmer-friendly. Use simple language.
Always provide actionable advice. If asked about something outside agriculture, 
politely redirect to farming topics.''';

  Future<String> sendMessage(
    String userMessage,
    List<ChatMessage> history,
  ) async {
    final contents = [
      {
        'role': 'user',
        'parts': [{'text': _systemPrompt}]
      },
      {
        'role': 'model',
        'parts': [{'text': 'Understood! I am your SmartFarm Assistant. How can I help you today?'}]
      },
      ...history.take(10).map((m) => {
            'role': m.isUser ? 'user' : 'model',
            'parts': [{'text': m.content}]
          }),
      {
        'role': 'user',
        'parts': [{'text': userMessage}]
      },
    ];

    final url = '$_base/models/gemini-pro:generateContent?key=$_apiKey';
    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'contents': contents}),
    );

    if (response.statusCode != 200) {
      throw Exception('Chatbot API error: ${response.statusCode}');
    }

    final data = jsonDecode(response.body);
    return data['candidates'][0]['content']['parts'][0]['text'] as String;
  }
}
