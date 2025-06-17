import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class SuggestionAgent {
  final GenerativeModel model;

  SuggestionAgent(String apiKey)
    : model = GenerativeModel(
        model: 'gemini-1.5-flash',
        apiKey: dotenv.env['GEMINI_API_KEY']!,
      );

  Future<String> getSuggestion({
    required String timeOfDay,
    required LatLng userLocation,
    required Map<String, dynamic> restaurant,
  }) async {
    try {
      final name = restaurant['name'];
      final rating = restaurant['rating']?.toString() ?? 'N/A';
      final vicinity = restaurant['vicinity'] ?? 'nearby';
      final types = (restaurant['types'] as List?)?.join(', ') ?? '';
      final openNow =
          restaurant['opening_hours']?['open_now'] == true ? 'Yes' : 'No';
      final priceLevel = restaurant['price_level']?.toString() ?? 'Unknown';

      final prompt = '''
        You are a helpful assistant recommending a local spot.

        Time: $timeOfDay
        Restaurant: $name
        Rating: $rating
        Open Now: $openNow
        Price: $priceLevel
        Vicinity: $vicinity
        Tags: $types

        Generate a 60-word friendly suggestion. Include 2-3 sample dishes they might serve. Sound conversational and warm.
      ''';

      final response = await model.generateContent([Content.text(prompt)]);
      return response.text ?? "This place looks good!";
    } catch (e) {
      return "Error generating suggestion: $e";
    }
  }
}
