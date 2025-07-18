import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ex_date/helpers/delete_helper.dart';
import 'package:ex_date/models/item_model.dart';
import 'package:ex_date/screens/add_item_screen.dart';
import 'package:ex_date/screens/item_detail_screen.dart';
import 'package:ex_date/screens/login_screen.dart';
import 'package:ex_date/widgets/display_image.dart';
import 'package:ex_date/widgets/get_color.dart';
import 'package:ex_date/widgets/main_drawer.dart';
import 'package:ex_date/widgets/pie_chart.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ex_date/main.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Item> items = [];
  List<Item> upcomingItems = [];
  // String _sortCriterion = 'Expiry Date';

  @override
  void initState() {
    super.initState();
  }
  
  //just a function to navigate to item details
  Future<void> _navigateToItemDetail(Item item) async {
    final updatedItem = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ItemDetailScreen(item: item)),
    );

    if (updatedItem != null) {
      // _fetchItems();
      setState(() {});
    }
  }

  
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
     if(user == null){
        return const Center(child: Text('Please log in to see your items'));
     }
        
    return Scaffold(
      appBar: AppBar(
        title: const Text('ExDate'),
        actions: [
          IconButton(
            onPressed: (){
              setState(() {
                isLightTheme.value=!isLightTheme.value;
              });
            },
            icon: isLightTheme.value ? const Icon(Icons.dark_mode): const Icon(Icons.light_mode),
          ),
          IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const AddItemScreen()),
                );
              },
              icon: const Icon(Icons.add)),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              FirebaseAuth.instance.signOut();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            },
          ),
        ],
      ),
      drawer: const MainDrawer(),
      body:
           StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(user.uid)
                  .collection('items')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('No items found'));
                }

                final items = snapshot.data!.docs.map((doc) {
                  return Item.fromMap(doc.data() as Map<String, dynamic>);
                }).toList();

                final now = DateTime.now();
                final upcomingItems = items.where((item) {
                  final expiryDate = item.expiryDate;
                  return expiryDate.isAfter(now) &&
                      expiryDate.isBefore(now.add(const Duration(days: 30)));
                }).toList();

                upcomingItems.sort((a, b) => a.expiryDate.compareTo(b.expiryDate));

                return Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const Text("UPCOMING EXPIRATIONS",
                        style: TextStyle(
                            fontSize: 20,
                            fontStyle: FontStyle.italic,
                            fontWeight: FontWeight.bold)),
                    Expanded(
                      child: ListView.builder(
                        itemCount: upcomingItems.length,
                        itemBuilder: (context, index) {
                          final item = upcomingItems[index];
                          return Dismissible(
                            key: UniqueKey(),
                            onDismissed: (direction){
                              //i also want to delete it from the database,so, but doing undo is not working
                              // final snapshot = FirebaseFirestore.instance.collection('users').doc(user.uid).collection('items');
                              // final item = snapshot.doc(upcomingItems[index].id).snapshots();
                              // FirebaseFirestore.instance.collection('users').doc(user.uid).collection('items')
                              // .doc(upcomingItems[index].id).delete();
                              // ScaffoldMessenger.of(context).showSnackBar(
                              //   SnackBar(content: const Text("Item deleted!"),
                              //   action: SnackBarAction(
                              //     label: "UNDO", 
                              //     onPressed: (){
                              //       setState((){
                              //         FirebaseFirestore.instance.collection('users').doc(user.uid).collection('items')
                              //         .doc(upcomingItems[index].id).set(item as Map<String, dynamic>);
                              //       });
                              //     }),),
                              // );
                              final deletedItem = upcomingItems[index];
                              confirmDeletion(context: context, item: item, collectionPath: 'items', 
                              onDeletedFromUI: () {
                                setState(() {
                                  items.removeWhere((i) => i.id == deletedItem.id);
                                  upcomingItems.removeWhere((i)=> i.id == deletedItem.id);
                                });
                              }, 
                              onUndo: (){
                                setState(() {}); //this will trigger a rebuild to reflect undo
                              });
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
                            child: Card(
                              margin: const EdgeInsets.symmetric(
                                  vertical: 4, horizontal: 8),
                              child: ListTile(
                                leading: displayImage(item.name, getColorIndicator(item.expiryDate)),
                                title: Text(item.name),
                                subtitle: buildProgressLine(item.expiryDate),
                                trailing: Text(item.quantity != null
                                    ? 'Qty: ${item.quantity}'
                                    : ''),
                                onTap: () {
                                  _navigateToItemDetail(item);
                                },
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                );
              }),
    );
  }
}
