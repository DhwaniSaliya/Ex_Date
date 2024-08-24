import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class RecipeService {
  final String apiKey = dotenv.env['SPOONACULAR_API_KEY']!; // Replace with your actual API key
  final String baseUrl = 'https://api.spoonacular.com/recipes';

  Future<List<dynamic>> fetchRecipes(List<String> ingredients) async {
    final query = ingredients.join(',');
    final response = await http.get(
      Uri.parse('$baseUrl/findByIngredients?ingredients=$query&number=5&apiKey=$apiKey'),
    );

    print('Response status: ${response.statusCode}'); // Print status code
    print('Response body: ${response.body}'); // Print response body

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data; // Return the list directly
    } else {
      throw Exception('Failed to load recipes: ${response.statusCode}');
    }
  }
}
