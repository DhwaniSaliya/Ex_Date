import 'dart:convert'; //to decode JSON responses from the API
import 'package:flutter_dotenv/flutter_dotenv.dart'; //securely store and load environment variables e.g api key from .env file
import 'package:http/http.dart' as http;//to make network requests (GET, POST, etc.) (yaha hum pixabay api ko call kar rahe)

//an asynchronous function that takes a query (e.g 'apple') and returns a Future<String> containing the image URL
Future<String> fetchImageUrl(String query) async {
  final String apiKey = dotenv.env['PIXABAY_API_KEY']!;
  //Constructs the Pixabay API request URL using the query and the API key
  final url = Uri.parse('https://pixabay.com/api/?key=$apiKey&q=$query&image_type=photo&per_page=3'); //per_page=3 limits the response to 3 images
  
  //Sends a GET request to the Pixabay API and waits for the response asynchronously
  final response = await http.get(url);

  if (response.statusCode == 200) { //status code 200 = OK
    final data = json.decode(response.body); //Decodes the JSON response body into a Dart Map
    if (data['hits'] != null && data['hits'].length > 0) { //Checks if the API returned any images in the hits list
      return data['hits'][0]['webformatURL']; //Returns the URL of the first image in the results (in webformatURL resolution)
    }
  }
  return 'https://example.com/default-image.png'; // fallback
}

