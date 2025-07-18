import 'package:ex_date/services/image_service.dart';
import 'package:flutter/material.dart';

final Map<String, String> imageCache =
    {}; //Caches image URLs by item name to avoid redundant network calls.
//key: item name, value: image URL (fetched from API)

// Displays a circular image for a given item with a colored border
//uses FutureBuilder to wait for the async image URL (from cache or API)
Widget displayImage(String itemName, Color borderColor) {
  return FutureBuilder<String>(
    future: _getcachedImageUrl(itemName), // asynchronous call
    builder: (context, snapshot) {
      String fallbackUrl =
          "https://static.vecteezy.com/system/resources/previews/032/242/170/large_2x/beautiful-waterfall-flowers-water-nature-waterfall-hd-wallpaper-ai-generated-free-photo.jpg";

      //while loading show a spinner
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const SizedBox(
          width: 50,
          height: 50,
          child: CircularProgressIndicator(strokeWidth: 2),
        );
      } else if (snapshot.hasError ||
          !snapshot.hasData ||
          snapshot.data!.isEmpty) {
        // If error or empty data, use fallback image
        return _buildImageCircle(fallbackUrl, borderColor, context);
      } else {
        // Image URL fetched successfully
        return _buildImageCircle(snapshot.data!, borderColor, context);
      }
    },
  );
}

// Builds a circular image avatar with border, and opens full-screen dialog on tap
Widget _buildImageCircle(
    String imageUrl, Color borderColor, BuildContext context) {
  return GestureDetector(
    onTap: () {
      showDialog(
        context: context,
        builder: (_) => Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(16),
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: InteractiveViewer(
              child: Image.network(imageUrl),
            ),
          ),
        ),
      );
    },
    child: Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: borderColor,
          width: 3,
        ),
        image: DecorationImage(
          image: NetworkImage(imageUrl),
          fit: BoxFit.cover,
        ),
      ),
    ),
  );
}

Future<String> _getcachedImageUrl(String itemName) async {
  //This avoids multiple API calls for the same item.
  if (imageCache.containsKey(itemName)) {
    // If image URL for the itemName is already in memory cache, return it.
    return imageCache[itemName]!;
  } else {
    // Otherwise, call fetchImageUrl (from image_service.dart), store in cache, and return it
    String url = await fetchImageUrl(itemName);
    imageCache[itemName] = url;
    return url;
  }
}

//note: let's understand
//1. builder: (context) => Dialog(...)
//This is explicit and clear: you're naming the parameter context and potentially using it inside the dialog widget
//for things like: Theme.of(context), MediaQuery.of(context)
//2. builder: (_) => Dialog(...)
//This is a shorthand, used when you don’t care about the context and don’t plan to use it.
//The underscore _ is a convention in Dart meaning “I’m accepting this parameter because I have to, but I won’t use it.”