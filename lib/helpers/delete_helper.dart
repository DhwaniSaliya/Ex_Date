import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/item_model.dart';

Future<void> confirmDeletion({required BuildContext context, required Item item, required String collectionPath,
  required VoidCallback onDeletedFromUI, required void Function() onUndo}) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return;

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text("Delete Item"),
      content: const Text("Are you sure you want to delete this item?"),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel"),
        ),
        ElevatedButton(
          onPressed: () async {
            final deletedItem = item.toMap();

            // Delete item from Firestore
            await FirebaseFirestore.instance
                .collection('users')
                .doc(user.uid)
                .collection(collectionPath)
                .doc(item.id)
                .delete();

            onDeletedFromUI(); // UI callback

            if (!context.mounted) return;
            Navigator.pop(context); // Close dialog

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text("Item deleted!"),
                action: SnackBarAction(
                  label: "Undo",
                  textColor: Colors.white,
                  onPressed: () async {
                    await FirebaseFirestore.instance
                        .collection('users')
                        .doc(user.uid)
                        .collection(collectionPath)
                        .doc(item.id)
                        .set(deletedItem);
                    
                    onUndo();
                  },
                ),
              ),
            );
          },
          child: const Text("Delete"),
        ),
      ],
    ),
  );
}
