import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ex_date/models/item_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class EditScreen extends StatefulWidget {
  const EditScreen({super.key, required this.item});
  final Item item;

  @override
  State<EditScreen> createState() {
    return _EditScreenState();
  }
}

class _EditScreenState extends State<EditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _purchaseDateController = TextEditingController();
  final _expiryDateController = TextEditingController();
  final _quantityController = TextEditingController();
  final _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.item.name;
    _purchaseDateController.text =
        DateFormat('yyyy-MM-dd').format(widget.item.purchaseDate);
    _expiryDateController.text =
        DateFormat('yyyy-MM-dd').format(widget.item.expiryDate);
    _quantityController.text = widget.item.quantity?.toString() ?? '';
    _notesController.text = widget.item.notes ?? '';
  }

  @override
  void dispose() {
    super.dispose();
    _nameController.dispose();
    _purchaseDateController.dispose();
    _expiryDateController.dispose();
    _quantityController.dispose();
    _notesController.dispose();
  }

  Future<void> _updateItem() async{
    if(_formKey.currentState!.validate()){
      try{
        final user = FirebaseAuth.instance.currentUser;
        if (user == null) {
          throw Exception('No user is currently logged in');
      }
      final userId = user.uid;
      final itemsCollection = FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('items');

      final itemRef = itemsCollection.doc(widget.item.id);

      final updatedItem = Item(
          id: widget.item.id,
          name: _nameController.text.trim(),
          purchaseDate: DateTime.parse(_purchaseDateController.text),
          expiryDate: DateTime.parse(_expiryDateController.text),
          quantity: int.tryParse(_quantityController.text) ?? 0,
          notes: _notesController.text.trim(),
        );
      // Update item in Firestore
        await itemRef.set(updatedItem.toMap());
        if (!mounted) return;
        Navigator.pop(context,updatedItem); // updatedItem also passed
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update item: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit the item"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Item Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter item name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _purchaseDateController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a date';
                  }
                  return null;
                },
                decoration: InputDecoration(
                  labelText: 'Purchase Date',
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.calendar_today),
                    onPressed: () =>
                        _selectDate(context, _purchaseDateController),
                  ),
                ),
                readOnly: true,
              ),
              TextFormField(
                controller: _expiryDateController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a date';
                  }
                  return null;
                },
                decoration: InputDecoration(
                  labelText: 'Expiry Date',
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.calendar_today),
                    onPressed: () =>
                        _selectDate(context, _expiryDateController),
                  ),
                ),
                readOnly: true,
              ),
              TextFormField(
                controller: _quantityController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Quantity'),
              ),
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(labelText: 'Notes'),
                maxLines: 3,
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(
                    width: 12,
                  ),
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _updateItem();
                      }
                    },
                    child: const Text('Update'),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _selectDate(
      BuildContext context, TextEditingController controller) async {
    final DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (selectedDate != null) {
      setState(() {
        controller.text = DateFormat('yyyy-MM-dd').format(selectedDate);
      });
    }
  }
}
