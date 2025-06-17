import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:near2me/models/agent_context.dart';

class SuggestionAgent {
  final GenerativeModel model;

  SuggestionAgent()
    : model = GenerativeModel(
        model: 'gemini-2.0-flash',
        apiKey: dotenv.env['GEMINI_API_KEY']!,
      );
  //Coordinates: ${context.lat}, ${context.lng}
  Future<String> getSuggestion(AgentContext context) async {
    try {
      final prompt = '''
          You are a smart assistant that gives local suggestions based on the user's time and precise location.

          Current time: ${context.timeOfDay}  
          Location description: ${context.locationDescription}  
          Radius: 1000 meters (1 kilometer)

          Only suggest options that are very close — within 1 kilometer of the coordinates. Mention one highly-rated place to eat nearby. Include its name, short menu, user reviews, and approximate walking distance from the coordinates.

          Keep your response friendly and conversational.
        ''';

      final response = await model.generateContent([Content.text(prompt)]);
      final output = response.text;

      if (output == null || output.trim().isEmpty) {
        return "Hmm, I couldn't find anything right now. Try changing the time or location.";
      }
      return output;
    } catch (e) {
      return "There was a problem generating the suggestion: $e";
    }
  }
}
