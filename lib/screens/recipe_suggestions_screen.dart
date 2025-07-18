import 'package:flutter/material.dart';
import 'package:ex_date/services/recipe_service.dart';
import 'package:ex_date/screens/recipe_detail_screen.dart';

class RecipeSuggestionsScreen extends StatefulWidget {
  const RecipeSuggestionsScreen({super.key, required this.ingredients});

  final List<String> ingredients;

  @override
  State<RecipeSuggestionsScreen> createState() =>
      _RecipeSuggestionsScreenState();
}

class _RecipeSuggestionsScreenState extends State<RecipeSuggestionsScreen> {
  final RecipeService _recipeService = RecipeService(); // Create service instance
  List<dynamic> _recipes = []; // Will hold recipe list from API
  bool _isLoading = false; // Show loading spinner while fetching
  String _errorMessage = '';  //to show any error messages

  @override
  void initState() {
    super.initState();
    _fetchRecipes(); //start fetching recipes on screen load
  }

  //func to fetch recipes from using spoonacular api
  void _fetchRecipes() async {
    if (widget.ingredients.isEmpty) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final recipes = await _recipeService.fetchRecipes(widget.ingredients);
      setState(() {
        _recipes = recipes; //update ui with fetched recipes
      });
    } catch (e) {
      print('Error details: $e'); // Print error details
      setState(() {
        _errorMessage = 'Error fetching recipes: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recipe Suggestions'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
              ? Center(child: Text(_errorMessage))
              : _recipes.isEmpty
                  ? const Center(child: Text('No recipes found'))
                  : ListView.builder(
                      itemCount: _recipes.length,
                      itemBuilder: (context, index) {
                        final recipe = _recipes[index];
                        return RCard(recipe: recipe);
                      },
                    ),
    );
  }
}

//A custom card to display a single recipe (image and title)
class RCard extends StatelessWidget {
  final dynamic recipe;
  
  const RCard({super.key, required this.recipe});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        tileColor: Colors.pink.shade50,
        selectedTileColor: Colors.pink.shade300,
        leading: Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black, width: 2),
            borderRadius: BorderRadius.circular(3),
          ),
          child: Image.network(recipe['image'])), //Recipe thumbnail
        title: Text(recipe['title'], style: const TextStyle(fontStyle: FontStyle.italic, fontWeight: FontWeight.bold, color: Colors.black),),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => RecipeDetailScreen(
                recipe: recipe,
              ),
            ),
          );
        },
      ),
    );
  }
}
