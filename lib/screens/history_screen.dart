import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ex_date/helpers/delete_helper.dart';
import 'package:ex_date/models/item_model.dart';
import 'package:ex_date/screens/item_list_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HistoryScreen extends StatefulWidget{
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState(){
    return _HistoryScreenState();
  }
}

class _HistoryScreenState extends State<HistoryScreen>{
  TextEditingController searchController = TextEditingController();
  List<Item> items = [];
  List<Item> filteredItems = [];
  late final User? user;
  String _sortCriterion = "Expiry Date";

  @override
  void initState(){
    super.initState();
    user = FirebaseAuth.instance.currentUser;
    if(user!=null){
      _fetchExpiredItems();
    }
    filteredItems = items;
    searchController.addListener(_filterItems);
  }

  @override
  void dispose(){
    super.dispose();
    searchController.removeListener(_filterItems);
    searchController.dispose();
  }

  void _fetchExpiredItems() async{
    if(user!=null){
      final userid= user!.uid;
      final snapshot = await FirebaseFirestore.instance.collection('users').doc(userid).collection('history').get();

      final fetchedExpiredItems = snapshot.docs.map((doc){
        return Item.fromMap(doc.data());
      }).toList();
      setState(() {
        items = fetchedExpiredItems;
        filteredItems = items;
        _sortItems(_sortCriterion);
      });
    }
  }

  void _filterItems(){
    setState(() {
      filteredItems = items.where((item){
        return item.name.toLowerCase().contains(searchController.text.toLowerCase());
      }).toList();
    });
  }

  //Sync-RealtimeContentCollaboration
  void _sortItems(String criterion){
    setState(() {
      _sortCriterion = criterion;
      if(criterion=="Expiry Date"){
        items.sort((a,b)=>a.expiryDate.compareTo(b.expiryDate));
      }else if(criterion == "Purchase Date"){
        items.sort((a,b)=>a.purchaseDate.compareTo(b.purchaseDate));
      }else if(criterion == "Name"){
        items.sort((a,b)=>a.name.compareTo(b.name));
      }

      filteredItems = List.from(items.where((item) {
        return item.name
            .toLowerCase()
            .contains(searchController.text.toLowerCase());
      }));
    });
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: const Text("History"),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: "Search...",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                suffixIcon: const Icon(Icons.search),
              ),
            ),
          ),
          DropdownButton(
            icon: const Icon(Icons.sort),
            value: _sortCriterion,
            items: ["Expiry Date", "Purchase Date", "Name"].map((String value){
              return DropdownMenuItem(
                value: value,
                child: Text(value));
            }).toList(), 
            onChanged: (String? newvalue){
              if(newvalue!=null){
                _sortItems(newvalue);
              }
            },),
          Expanded(
            child: ListView.builder(
              itemCount: filteredItems.length,
              itemBuilder: (context, index){
                return Dismissible(
                  key: UniqueKey(),
                  onDismissed: (direction){
                    final deletedItem = filteredItems[index];
                    confirmDeletion(context: context, item: filteredItems[index], collectionPath: 'history', 
                    onDeletedFromUI: (){
                      setState(() {
                        items.removeWhere((i) => i.id == deletedItem.id);
                        filteredItems.removeWhere((i) => i.id == deletedItem.id);
                      });
                    },
                    onUndo: (){
                      _fetchExpiredItems();
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
                  child: ItemCard(item: filteredItems[index]));
            }),
          ),
        ],
      ),
    );
  }
}