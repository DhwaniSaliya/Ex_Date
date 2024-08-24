import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ex_date/models/item_model.dart';
import 'package:ex_date/screens/item_detail_screen.dart';
import 'package:ex_date/widgets/get_color.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ItemListScreen extends StatefulWidget {
  const ItemListScreen({super.key});

  @override
  State<ItemListScreen> createState() {
    return _ItemListScreenState();
  }
}

class _ItemListScreenState extends State<ItemListScreen> {
  TextEditingController searchController = TextEditingController();
  List<Item> items = []; // Initialize with your list of items
  List<Item> filteredItems = [];
  String _sortCriterion = 'Expiry Date';
  late final User? user;

  @override
  void initState() {
    super.initState();
    user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _fetchItems();
    }
    // Initially, the filtered list is the same as the full list
    filteredItems = items;
    searchController.addListener(_filterItems);
  }

  @override
  void dispose() {
    searchController.removeListener(_filterItems);
    searchController.dispose();
    super.dispose();
  }

  void _fetchItems() async {
    if (user != null) {
      final userId = user!.uid;
      print("Fetching items for user: $userId");
      try{
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('items')
          .get();

      final fetchedItems = snapshot.docs.map((doc) {
        return Item.fromMap(doc.data());
      }).toList();


      print("Fetched items: $fetchedItems");


      setState(() {
        items = fetchedItems;
        filteredItems = items; // Initially, the filtered list is the same as the full list
        _sortItems(_sortCriterion);
      });
      }catch(e){
        print("Failed to fretch, $e");
      }
    }
  }

  void _filterItems() {
    setState(() {
      filteredItems = items.where((item) {
        return item.name
            .toLowerCase()
            .contains(searchController.text.toLowerCase());
      }).toList();
    });
  }

  void _sortItems(String criterion){
    setState(() {
      _sortCriterion = criterion;
      
      if(criterion == 'Expiry Date'){
        items.sort((a,b)=>a.expiryDate.compareTo(b.expiryDate));
      }else if(criterion == 'Purchase Date'){
        items.sort((a,b)=>a.purchaseDate.compareTo(b.purchaseDate));
      }else if(criterion == 'Name'){
        items.sort((a,b)=>a.name.compareTo(b.name));
      }

      // Update filteredItems to reflect the sorting
      filteredItems = List.from(items.where((item) {
        return item.name
            .toLowerCase()
            .contains(searchController.text.toLowerCase());
      }));
    });
  }


  @override
  Widget build(BuildContext context) {
    return PopScope(
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Items"),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8),
              child: TextField(
                controller: searchController,
                decoration: InputDecoration(
                  hintText: 'Search...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  suffixIcon: const Icon(Icons.search),
                ),
              ),
            ),
            DropdownButton<String>(
            value: _sortCriterion,
            icon: const Icon(Icons.sort),
            items: <String>['Expiry Date', 'Purchase Date', 'Name'].map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: (String? newValue) {
              if (newValue != null) {
                _sortItems(newValue);
              }
            },
          ),
            Expanded(
              child: ListView.builder(
                itemCount: filteredItems.length,
                itemBuilder: (context, index) {
                  return ItemCard(item: filteredItems[index]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ItemCard extends StatelessWidget {
  const ItemCard({super.key, required this.item});

  final Item item;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: getColorIndicator(item.expiryDate),
        ),
        title: Text(item.name),
        subtitle: Text(
            'Expires on: ${DateFormat('yyyy-MM-dd').format(item.expiryDate)}'),
        trailing: Text(item.quantity != null ? 'Qty: ${item.quantity}' : ''),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ItemDetailScreen(item: item),
            ),
          );
        },
      ),
    );
  }
}








// Future<void> addItem(String userId, Item item) async {
//   await FirebaseFirestore.instance
//       .collection('users')
//       .doc(userId)
//       .collection('items')
//       .doc(item.id) // Or use auto-generated ID
//       .set(item.toMap());
// }

// Future<List<Item>> fetchItems(String userId) async {
//   final snapshot = await FirebaseFirestore.instance
//       .collection('users')
//       .doc(userId)
//       .collection('items')
//       .get();

//   return snapshot.docs.map((doc) => Item.fromMap(doc.data())).toList();
// }

// Future<void> updateItem(String userId, Item item) async {
//   await FirebaseFirestore.instance
//       .collection('users')
//       .doc(userId)
//       .collection('items')
//       .doc(item.id)
//       .update(item.toMap());
// }

// Future<void> deleteItem(String userId, String itemId) async {
//   await FirebaseFirestore.instance
//       .collection('users')
//       .doc(userId)
//       .collection('items')
//       .doc(itemId)
//       .delete();
// }