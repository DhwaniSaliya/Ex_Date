import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ex_date/helpers/delete_helper.dart';
import 'package:ex_date/models/item_model.dart';
import 'package:ex_date/screens/item_detail_screen.dart';
import 'package:ex_date/widgets/display_image.dart';
import 'package:ex_date/widgets/get_color.dart';
import 'package:ex_date/widgets/pie_chart.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

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
      _expiredHistory();
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

  //fetching items from the collection items of the user to display in the item list
  void _fetchItems() async {
    if (user != null) {
      final userId = user!.uid;
      print("Fetching items for user: $userId");
      try {
        final snapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('items')
            .get();

        //returning the items and storing it in the list
        final fetchedItems = snapshot.docs.map((doc) {
          return Item.fromMap(doc.data());
        }).toList();

        print("Fetched items: $fetchedItems");

        setState(() {
          items = fetchedItems;
          filteredItems =
              items; // Initially, the filtered list is the same as the full list
          _sortItems(_sortCriterion);
        });
      } catch (e) {
        print("Failed to fretch, $e");
      }
    }
  }

  // Move items older than 15 days to "history" and delete from "items"
  Future<void> _expiredHistory() async {
    try {
      if (user != null) {
        final userid = user!.uid;
        final snapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(userid)
            .collection('items')
            .get();

        final fetchedItems = snapshot.docs.map((doc) {
          return Item.fromMap(doc.data());
        }).toList();

        final now = DateTime.now();

        for (var doc in fetchedItems) {
          print('Checking item: ${doc.name}, expiry: ${doc.expiryDate}');

          if (doc.expiryDate.isBefore(now.subtract(const Duration(days: 15)))) {
            print('Moving to history: ${doc.name}');
            await FirebaseFirestore.instance
                .collection("users")
                .doc(userid)
                .collection("history")
                .doc(doc.id)
                .set(doc.toMap());

            //if i also want to delete from the items list screen
            await FirebaseFirestore.instance
                .collection("users")
                .doc(userid)
                .collection('items')
                .doc(doc.id)
                .delete();
          }
        }
      }
    } catch (e) {
      print("Failed to save item: $e");
      if (!mounted) return;
      //avoid this if context is not available and also, if above mounted condition not made
      //then, blue line comes under context.
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to save item: $e")),
      );
    }
  }

  //function to filter items based on letters the item contains while searching
  void _filterItems() {
    setState(() {
      filteredItems = items.where((item) {
        return item.name
            .toLowerCase()
            .contains(searchController.text.toLowerCase());
      }).toList();
    });
  }

  void _sortItems(String criterion) {
    setState(() {
      _sortCriterion = criterion;

      if (criterion == 'Expiry Date') {
        items.sort((a, b) => a.expiryDate.compareTo(b.expiryDate));
      } else if (criterion == 'Purchase Date') {
        items.sort((a, b) => a.purchaseDate.compareTo(b.purchaseDate));
      } else if (criterion == 'Name') {
        items.sort((a, b) => a.name.compareTo(b.name));
      }

      _filterItems(); // Re-apply search filter after sorting
    });
  }

  //history screen retains the item even after getting deleted from item list - helps in shopping later :)
  void _confirmDeletion(int index, Item item) {
    // Show a confirmation dialog before deleting the item
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text("Delete Item"),
          content: const Text("Are you sure you want to delete this item?"),
          actions: [
            //cancel button to close the dialog without deleting
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
              },
              child: const Text("Cancel"),
            ),
            //confirm delete button
            ElevatedButton(
              onPressed: () async {
                final deletedItem = item.toMap(); // Save for undo

                //delete from firestore
                await FirebaseFirestore.instance
                    .collection('users')
                    .doc(user!.uid)
                    .collection('items')
                    .doc(item.id)
                    .delete();

                //remove the item from both local lists so UI updates instantly
                setState(() {
                  items.removeWhere(
                      (i) => i.id == item.id); // Remove from master list
                  filteredItems
                      .removeAt(index); // Remove from filtered/search list
                });

                // Check if context is still available
                if (!context.mounted) return;
                Navigator.of(context).pop(); // Close dialog

                ScaffoldMessenger.of(context).showSnackBar(
                  //snackbar with an undo option
                  SnackBar(
                    content: const Text("Item deleted!"),
                    action: SnackBarAction(
                      label: "Undo",
                      textColor: Colors.white,
                      onPressed: () async {
                        // Restore the deleted item in Firestore
                        await FirebaseFirestore.instance
                            .collection('users')
                            .doc(user!.uid)
                            .collection('items')
                            .doc(item.id)
                            .set(deletedItem);

                        _fetchItems(); //re-fetch updated list to include restored item
                      },
                    ),
                  ),
                );
              },
              child: const Text("Delete"),
            ),
          ],
        );
      },
    );
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
              items: <String>['Expiry Date', 'Purchase Date', 'Name']
                  .map((String value) {
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
                  return Dismissible(
                      key: UniqueKey(),
                      onDismissed: (direction) {
                        // _confirmDeletion(index, filteredItems[index]);
                        final deletedItem = filteredItems[index];
                        confirmDeletion(
                          context: context,
                          item: filteredItems[index],
                          collectionPath: 'items',
                          onDeletedFromUI: () {
                            setState(() {
                              items.removeWhere((i) => i.id == deletedItem.id);
                              filteredItems.removeWhere((i) => i.id == deletedItem.id);
                            });
                          },
                          onUndo: _fetchItems,
                        );
                      },
                      direction: DismissDirection.endToStart,
                      background: Container(
                        color: Colors.red,
                        margin: const EdgeInsets.symmetric(horizontal: 15),
                        alignment: Alignment.centerRight,
                        child: const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Icon(
                            Icons.delete,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      child: ItemCard(item: filteredItems[index]));
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
        leading: displayImage(item.name, getColorIndicator(item.expiryDate)),
        title: Text(item.name),
        // subtitle: Text(
        //   'Expires on: ${DateFormat('yyyy-MM-dd').format(item.expiryDate)}',
        // ),
        subtitle: buildProgressLine(item.expiryDate),
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