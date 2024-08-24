import 'package:ex_date/screens/recipe_suggestions_screen.dart';
import 'package:flutter/material.dart';

class SearchRecipesScreen extends StatefulWidget {
  const SearchRecipesScreen({super.key});

  @override
  State<SearchRecipesScreen> createState(){
    return _SearchRecipesScreenState();
  } 
}

class _SearchRecipesScreenState extends State<SearchRecipesScreen> {
  final _controller = TextEditingController();
  final Set<String> _ingredients = {};

  void _addIngredient() {
    final ingredient = _controller.text.trim();
    if (ingredient.isNotEmpty) {
      setState(() {
        _ingredients.add(ingredient);
        _controller.clear();
      });
    }
  }

  void _searchRecipes() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RecipeSuggestionsScreen(
          ingredients: _ingredients.toList(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:const Text('Search Recipes'),
      ),
      body: Container(
        margin: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _controller,
              decoration: const InputDecoration(labelText: 'Add Ingredient'),
              onSubmitted: (_) => _addIngredient(),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView(
                children: _ingredients.map((ingredient) {
                  return ListTile(
                    title: Text(ingredient),
                    trailing: IconButton(
                      icon:const Icon(Icons.remove),
                      onPressed: () {
                        setState(() {
                          _ingredients.remove(ingredient);
                        });
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
            ElevatedButton(
              onPressed: _searchRecipes,
              child: const Text('Find Recipes'),
            ),
          ],
        ),
      ),
    );
  }
}
