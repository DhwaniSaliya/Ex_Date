import 'package:flutter/material.dart';
import 'package:ex_date/widgets/recipe_service.dart';
import 'package:ex_date/screens/recipe_detail_screen.dart';

class RecipeSuggestionsScreen extends StatefulWidget {
  const RecipeSuggestionsScreen({super.key, required this.ingredients});

  final List<String> ingredients;

  @override
  State<RecipeSuggestionsScreen> createState() => _RecipeSuggestionsScreenState();
}

class _RecipeSuggestionsScreenState extends State<RecipeSuggestionsScreen> {
  final RecipeService _recipeService = RecipeService();
  List<dynamic> _recipes = [];
  bool _isLoading = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchRecipes();
  }

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
        _recipes = recipes;
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
                          return ListTile(
                            tileColor: Colors.pink.shade100,
                            contentPadding: const EdgeInsets.all(12),
                            title: Text(recipe['title']),
                            leading: Image.network(recipe['image']),
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
                          );
                        },
                      ),
                  
    );
  }
}
