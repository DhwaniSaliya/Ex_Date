import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ex_date/models/item_model.dart';
import 'package:ex_date/screens/add_item_screen.dart';
import 'package:ex_date/screens/item_detail_screen.dart';
import 'package:ex_date/screens/login_screen.dart';
import 'package:ex_date/widgets/get_color.dart';
import 'package:ex_date/widgets/main_drawer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';


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
                          return Card(
                            margin: const EdgeInsets.symmetric(
                                vertical: 4, horizontal: 8),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor:
                                    getColorIndicator(item.expiryDate),
                              ),
                              title: Text(item.name),
                              subtitle: Text(
                                'Expires on: ${DateFormat('yyyy-MM-dd').format(item.expiryDate)}',
                              ),
                              trailing: Text(item.quantity != null
                                  ? 'Qty: ${item.quantity}'
                                  : ''),
                              onTap: () {
                                _navigateToItemDetail(item);
                              },
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


// void _fetchItems() async { //yaha pehle future<void> thaa
  //   final user = FirebaseAuth.instance.currentUser;
  //   if (user != null) {
  //     final userId = user.uid;
  //     try {
  //       final snapshot = await FirebaseFirestore.instance
  //           .collection('users')
  //           .doc(userId)
  //           .collection('items')
  //           .get();

  //       final fetchedItems = snapshot.docs.map((doc) {
  //         return Item.fromMap(doc.data());
  //       }).toList();

  //       final now = DateTime.now();
  //       final upcomingExpirations = fetchedItems.where((item) {
  //         final expiryDate = item.expiryDate;
  //         return expiryDate.isAfter(now) &&
  //             expiryDate.isBefore(now.add(const Duration(days: 30)));
  //       }).toList();

  //       setState(() {
  //         items = fetchedItems;
  //         upcomingItems = upcomingExpirations;
  //       });
  //     } catch (e) {
  //       print("Failed to fetch items: $e");
  //     }
  //   }
  // }


// void _sortItems(String criterion){
  //   setState(() {
  //     _sortCriterion = criterion;
      
  //     if(criterion == 'Expiry Date'){
  //       items.sort((a,b)=>a.expiryDate.compareTo(b.expiryDate));
  //     }else if(criterion == 'Purchase Date'){
  //       items.sort((a,b)=>a.purchaseDate.compareTo(b.purchaseDate));
  //     }else if(criterion == 'Name'){
  //       items.sort((a,b)=>a.name.compareTo(b.name));
  //     }

  //     final now = DateTime.now();
  //     upcomingItems = items.where((item) {
  //       final expiryDate = item.expiryDate;
  //       return expiryDate.isAfter(now) && expiryDate.isBefore(now.add(const Duration(days: 30)));
  //     }).toList();
  //   });
  // }

  // DropdownButton<String>(
          //   value: _sortCriterion,
          //   icon: const Icon(Icons.sort),
          //   items: <String>['Expiry Date', 'Purchase Date', 'Name'].map((String value) {
          //     return DropdownMenuItem<String>(
          //       value: value,
          //       child: Text(value),
          //     );
          //   }).toList(),
          //   onChanged: (String? newValue) {
          //     if (newValue != null) {
          //       _sortItems(newValue);
          //     }
          //   },
          // ),