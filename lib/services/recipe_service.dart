import 'dart:convert'; //for decoding json response
import 'package:http/http.dart' as http;  //fro making http requests
import 'package:flutter_dotenv/flutter_dotenv.dart'; //to access api keys from .env files

class RecipeService {
  final String apiKey = dotenv.env['SPOONACULAR_API_KEY']!; //Replace with your actual API key
  final String baseUrl = 'https://api.spoonacular.com/recipes'; //base url of spoonacular api

  //asynchronous method that takes a list of ingredients (e.g., ["apple", "flour", "sugar"]) 
  //and returns a list of matching recipes from the API
  Future<List<dynamic>> fetchRecipes(List<String> ingredients) async {
    final query = ingredients.join(','); // Combine ingredient list into a comma-separated string
    //construct the full API request URL using the base, ingredients, number of results (yaha 10), and the API key
    //Sends a GET request to Spoonacular's findByIngredients endpoint
    final response = await http.get(
      Uri.parse('$baseUrl/findByIngredients?ingredients=$query&number=10&apiKey=$apiKey'),
    );

    print('Response status: ${response.statusCode}'); //http status code
    print('Response body: ${response.body}'); //full response json for debugging

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body); //decode json array
      return data; // Return the list of recipes directly
    } else {
      throw Exception('Failed to load recipes: ${response.statusCode}');
    }
  }
}
