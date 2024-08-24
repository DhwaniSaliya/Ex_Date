import 'dart:convert';
import 'package:http/http.dart' as http;

class RecipeService {
  final String apiKey = '321f75dc8b79405f91ad5ce92900bc39'; // Replace with your actual API key
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
