import 'package:ex_date/main.dart';
import 'package:ex_date/models/item_model.dart';
import 'package:ex_date/screens/edit_item_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; //used to format dates, numbers, and currencies according to different locales

class ItemDetailScreen extends StatefulWidget{
  const ItemDetailScreen({super.key, required this.item});

  final Item item;

  @override
  State<ItemDetailScreen> createState() => _ItemDetailScreenState();
}

class _ItemDetailScreenState extends State<ItemDetailScreen> {
  late Item item; //local mutable copy of the item

  @override
  void initState() {
    super.initState();
    item = widget.item; //i initialized local item from widget
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(item.name),),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            detailCard(context, icon: Icons.shopping_cart, label: 'Name', value: widget.item.name),
            detailCard(context, icon: Icons.calendar_today, label: 'Purchase Date', value: DateFormat('yyyy-MM-dd').format(widget.item.purchaseDate)),
            detailCard(context, icon: Icons.event, label: 'Expiry Date', value: DateFormat('yyyy-MM-dd').format(widget.item.expiryDate)),
            detailCard(context, icon: Icons.format_list_numbered, label: 'Quantity', value: widget.item.quantity != null ? widget.item.quantity.toString(): 'N/A'),
            detailCard(context, icon: Icons.note, label: 'Notes', value: widget.item.notes ?? 'None'),

          ],
        ),
      ),
      // Edit button at bottom right corner
      floatingActionButton: FloatingActionButton(onPressed: () async{
        // Navigate to edit screen and wait for updated item
        final updatedItem = await Navigator.push(context, MaterialPageRoute(builder: (context)=>EditScreen(item: widget.item),),);
        //update the screen if an item is not null
        if (updatedItem != null) {
            setState(() {
              item = updatedItem;
            });
            //below is a safety check to ensure that the widget is still part of the widget tree 
            //(i.e. it hasn’t been disposed or removed from screen).
            //In async operations (like awaiting Navigator.push()), the user might leave the screen before the operation completes.
            //if below condition not made then there's a chance that app might crash
            if(!context.mounted) return; // Avoid calling context if unmounted
            // Pass updated item back to previous screen as we want to reflect that updated data on previous screen
            Navigator.pop(context, updatedItem);
          }
      }, child: const Icon(Icons.edit),),
    );
  }
}


Widget detailCard(BuildContext context, {required IconData icon, required String label, required String value}){
  return Card(
    margin: const EdgeInsets.symmetric(vertical: 6),
    child: ListTile(
      leading: Icon(icon, color: isLightTheme.value ? Theme.of(context).primaryColor : Theme.of(context).primaryColorLight,),
      title: Text(
        label, style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Text(
          value,
          style: const TextStyle(
            fontSize: 16,
          ),
        ),
      ),
  );
}