import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarView extends StatefulWidget {
  final Future<Map<DateTime, List<String>>> expiryItemsByDate;
  //now we are passing a map. expiry date: list of item names expiring on that date

  const CalendarView({super.key, required this.expiryItemsByDate});

  @override
  State<CalendarView> createState() => _CalendarViewState();
}

class _CalendarViewState extends State<CalendarView> {
  DateTime _focusedDay = DateTime.now(); //today
  DateTime? _selectedDay; //used to get expiry items on this particular selected day

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<DateTime, List<String>>>(
      future: widget.expiryItemsByDate, //to load expiry data
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasError) {
          return Scaffold(
            body: Center(child: Text("Error: ${snapshot.error}")),
          );
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Scaffold(
            body: Center(child: Text("No expiry items found.")),
          );
        }

        final events = snapshot.data!; //Map<DateTime, List<String>>

        //helper func to get items for selected date
        List<String> getEventsForDay(DateTime day) {
          final normalized = DateTime(day.year, day.month, day.day); //normalized to ignore time
          return events[normalized] ?? [];
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Expiry Calendar'),
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: TableCalendar(
                  headerStyle: const HeaderStyle(
                    formatButtonVisible: false,
                    titleTextStyle: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Georgia',
                    ),
                    titleCentered: true,
                    leftChevronIcon: Icon(Icons.arrow_back_ios),
                    rightChevronIcon: Icon(Icons.arrow_forward_ios),
                  ),
                  calendarStyle: CalendarStyle(
                    todayDecoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      shape: BoxShape.circle,
                      boxShadow: const [
                        BoxShadow(color: Colors.black12, blurRadius: 4)
                      ],
                    ),
                    selectedDecoration: BoxDecoration(
                      color: Colors.pink.shade300,
                      shape: BoxShape.circle,
                      boxShadow: const [
                        BoxShadow(color: Colors.black26, blurRadius: 6)
                      ],
                    ),
                    markerDecoration: const BoxDecoration(
                      color: Colors.redAccent,
                      shape: BoxShape.circle,
                    ),
                    weekendTextStyle: const TextStyle(color: Colors.red),
                  ),
                  firstDay: DateTime.utc(2023, 1, 1),
                  lastDay: DateTime.utc(2030, 12, 31),
                  focusedDay: _focusedDay,
                  selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                  eventLoader: getEventsForDay,
                  onDaySelected: (selectedDay, focusedDay) {
                    setState(() {
                      _selectedDay = selectedDay;
                      _focusedDay = focusedDay;
                    });
                  },
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Expiring Items on ${_selectedDay?.toLocal().toString().split(' ')[0] ?? 'No Date Selected'}',
                style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Montserrat'),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: getEventsForDay(_selectedDay ?? DateTime.now()).isEmpty
                    ? const Center(
                        child: Text(
                          "No items expiring on this day!",
                          style: TextStyle(fontSize: 15),
                        ),
                      )
                    : ListView.builder(
                        itemCount:
                            getEventsForDay(_selectedDay ?? DateTime.now())
                                .length,
                        itemBuilder: (context, index) {
                          final item = getEventsForDay(
                              _selectedDay ?? DateTime.now())[index];

                          return Card(
                            elevation: 3,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            margin: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 6),
                            color: Colors.pink.shade50,
                            child: ListTile(
                              leading: const Icon(Icons.warning_amber_rounded,
                                  color: Colors.deepOrange),
                              title: Text(item,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 15,
                                      fontFamily: "Segoe UI")),
                              trailing: const Icon(
                                  Icons.arrow_forward_ios_rounded,
                                  size: 14),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// class SettingsScreen extends StatefulWidget{
//   const SettingsScreen({super.key});

//   @override
//   State<SettingsScreen> createState(){
//     return _SettingsScreenState();
//   }
// }

// class _SettingsScreenState extends State<SettingsScreen>{

//   @override
//   Widget build(BuildContext context){
//     final user = FirebaseAuth.instance.currentUser;
//     final userId = user!.uid;
//     dynamic controller;
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Settings", style: TextStyle(color: Colors.white),),
//         backgroundColor: Theme.of(context).colorScheme.primary,
//       ),
//       body: StreamBuilder(
//           stream: FirebaseFirestore.instance.collection('users').doc(userId).snapshots(),
//           builder: (context, snapshot){
//             if(snapshot.connectionState == ConnectionState.waiting){
//               return const Center(child: CircularProgressIndicator(),);
//             }
//             if(snapshot.hasError){
//               return Center(child: Text("Error: ${snapshot.error}"),);
//             }
//             if(!snapshot.hasData || snapshot.data!.exists){
//               return const Center(child: Text("No data to preview"),);
//             }
//             final userData = snapshot.data!.data() as Map<String, dynamic>;
//             final username = userData['username'] ?? 'Guest user';
//             final useremail = userData['email'] ?? 'No email';
//             controller = TextEditingController(text: username);

//             return Scaffold(
//               body: SingleChildScrollView(
//                 scrollDirection: Axis.vertical,
//                 child: Column(
//                     mainAxisAlignment: MainAxisAlignment.start,
//                     children: [
//                       const Text("Customize your app's settings", style: TextStyle(fontFamily: "MontSerrat", fontWeight: FontWeight.bold),),
//                       const SizedBox(height: 12,),
//                       Card(
//                         child: ListTile(
//                           title: Text(useremail, style: const TextStyle(fontStyle: FontStyle.italic),),
//                         ),
//                       ),
//                       InkWell(
//                         child: SizedBox(
//                           width: double.infinity,
//                           child: Dialog(
//                             insetPadding: const EdgeInsets.all(16.0),
//                             child: Column(
//                               children: [
//                                 const Text("Edit your username"),
//                                 const SizedBox(height: 12,),
//                                 TextFormField(
//                                   controller: controller,
//                                   keyboardType: TextInputType.text,
//                                   decoration: const InputDecoration(
//                                     border: OutlineInputBorder(),
//                                     focusedBorder: InputBorder.none,
//                                   ),
//                                 ),
//                                 const SizedBox(height: 12,),
//                                 ElevatedButton.icon(
//                                   onPressed: (){
//                                     FirebaseFirestore.instance.collection('users').doc(userId).set(
//                                       {
//                                         'username': username,
//                                       }, SetOptions(merge: true)
//                                     );
//                                   },
//                                   icon: const Icon(Icons.save), 
//                                   label: const Text("Save changes"))
//                               ],
//                             ),
//                           ),
//                         ),
//                       )
//                     ],
//                   ),
//               ),
//             );
//           },
//         ),
//     );
//   }
// }

Future<Map<DateTime, List<String>>> getExpiryItemsByDate() async {
  final user = FirebaseAuth.instance.currentUser;
  final userId = user!.uid;
  final docs = await FirebaseFirestore.instance
      .collection('users')
      .doc(userId)
      .collection('items')
      .get();

  final map = <DateTime, List<String>>{};

  for (var doc in docs.docs) {
    final data = doc.data();
    // final timestamp = data['expiryDate'] as Timestamp;
    // final date = DateTime(timestamp.toDate().year, timestamp.toDate().month, timestamp.toDate().day);
    final date = DateTime.parse(data['expiryDate']); //i used parse method since in my database expiry date is of String datatype

    map.putIfAbsent(date, () => []);
    map[date]!.add(data['name']);
  }

  return map;
}
