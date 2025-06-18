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
        You are a very helpful assistant recommending a local restaurant close to the user's current location and time of day [if it is eveneing, dinner, morning breakfast etc].
        Suggest an open restaurant or cafe nearby. If a restaurant is closed, find another one within the vicinity.
        Use the following details from Google Places:

        Time: $timeOfDay
        Restaurant: $name
        Rating: $rating
        Open Now: $openNow
        Price: $priceLevel
        Vicinity: $vicinity
        Tags: $types

        Generate a 60-word friendly suggestion. Sound conversational and warm.
        Reply in this format:

        Your introduction ... "Hey there..."
        Then
        Restaurant: [Name]
        Time: [Time]
        Review: [A user review of the restaurant from Google reviews]
        Rating: [Number of stars from Google reviews]
        Price: [Average meal cost]

        Finish with something like "Let me know if you'd prefer.... Enjoy your dinner/breakfast/lunch [based on time]

      ''';

      final response = await model.generateContent([Content.text(prompt)]);
      return response.text ?? "Sorry, I couldn't find anything.";
    } catch (e) {
      return "Error generating suggestion: $e";
    }
  }
}
