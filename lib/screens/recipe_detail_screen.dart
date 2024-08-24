// import 'package:flutter/material.dart';

// class RecipeDetailScreen extends StatelessWidget {
//   final Map<String, dynamic> recipe;

//   RecipeDetailScreen({required this.recipe});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(recipe['title']),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(8.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Image.network(recipe['image']),
//             SizedBox(height: 8),
//             Text(
//               recipe['title'],
//               style: Theme.of(context).textTheme.headline6,
//             ),
//             SizedBox(height: 16),
//             Text(
//               'Used Ingredients:',
//               style: Theme.of(context).textTheme.subtitle1,
//             ),
//             ...((recipe['usedIngredients'] as List<dynamic>).map((ingredient) {
//               return Text(ingredient['name']);
//             })),
//             SizedBox(height: 16),
//             Text(
//               'Missed Ingredients:',
//               style: Theme.of(context).textTheme.subtitle1,
//             ),
//             ...((recipe['missedIngredients'] as List<dynamic>).map((ingredient) {
//               return Text(ingredient['name']);
//             })),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';

class RecipeDetailScreen extends StatelessWidget {
  const RecipeDetailScreen({super.key, required this.recipe});

  final dynamic recipe;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(recipe['title']),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.black,
                    width: 3,
                  ),
                  borderRadius: BorderRadius.circular(8)),
              child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(recipe['image'])),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                recipe['title'],
                textAlign: TextAlign.center,
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Missed Ingredients:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            ...recipe['missedIngredients'].map((ingredient) {
              return ListTile(
                leading: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(ingredient['image']))),
                title: Text(ingredient['name']),
                subtitle: Text(ingredient['original']),
              );
            }).toList(),
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Used Ingredients:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            ...recipe['usedIngredients'].map((ingredient) {
              return ListTile(
                leading: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(ingredient['image']))),
                title: Text(ingredient['name']),
                subtitle: Text(ingredient['original']),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}
