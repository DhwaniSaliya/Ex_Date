class Item {
  final String id;
  final String name;
  final DateTime purchaseDate;
  final DateTime expiryDate;
  final int? quantity;
  final String? notes;

  Item({
    required this.id,
    required this.name,
    required this.purchaseDate,
    required this.expiryDate,
    this.quantity,
    this.notes,
  });

  // Converted an Item to a Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'purchaseDate': purchaseDate.toString(),
      'expiryDate': expiryDate.toString(),
      'quantity': quantity,
      'notes': notes,
    };
  }

   // Created an Item from a Map
  factory Item.fromMap(Map<String, dynamic> map) {
    return Item(
      id: map['id'],
      name: map['name'],
      purchaseDate: DateTime.parse(map['purchaseDate']),
      expiryDate: DateTime.parse(map['expiryDate']),
      quantity: map['quantity'],
      notes: map['notes'] ?? '',
    );
  }
}