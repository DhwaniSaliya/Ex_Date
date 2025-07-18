import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ex_date/main.dart';
import 'package:ex_date/screens/login_screen.dart';
import 'package:ex_date/services/notification_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  //Form widget helps group and manage multiple form fields like TextFormField
  //A GlobalKey<FormState> is like a controller for the Form
  //It lets you access and control the state of the form from outside the widget tree where the form is declared
  final _form = GlobalKey<FormState>(); //.validate() and .save() jaisi mehtods hum call kar sakte hai
  final _usernameController = TextEditingController();
  final user = FirebaseAuth.instance.currentUser;

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  //this funct is used when a user changes its username or notification settings
  void submit() async {
    final userId = user!.uid;
    final isValid = _form.currentState!.validate();
    if (!isValid) return;

    await FirebaseFirestore.instance.collection('users').doc(userId).set(
      {
        'username': _usernameController.text.trim(),
        'notificationsOn': isOn.value,
      },
      SetOptions(merge: true),
    );

    if (!mounted) return;
    Navigator.pop(context);
  }

  //this dialog is shown when the user wants to edit the username 
  void showEditDialog() {
  showDialog(
    context: context,
    builder: (context) => Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _form,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Edit Profile",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: "Username",
                  hintText: "Enter your name",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.person),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return "Please enter a username";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: submit,
                  icon: const Icon(Icons.save),
                  label: const Text("Save Changes"),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

//when you need to change the username info
void submitInfo(String username){
  final user = FirebaseAuth.instance.currentUser;
  final userid = user!.uid;
  //obviously, the user can't be null, so there's no need to use any condition
  FirebaseFirestore.instance.collection("users").doc(userid).set({
    "username": username
  }, SetOptions(merge: true));
}

  @override
  Widget build(BuildContext context) {
    final userId = user!.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Profile"),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: showEditDialog,
          ),
        ],
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('users').doc(userId).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text("Unable to fetch profile details"));
          }

          final userData = snapshot.data!.data() as Map<String, dynamic>;
          final userName = userData['username'] ?? 'Guest User';
          final userEmail = userData['email'] ?? 'No Email';
          final notificationsEnabled = userData['notificationsOn'] ?? true;
          isOn.value = notificationsEnabled;

          if (_usernameController.text.isEmpty) {
            _usernameController.text = userName;
          }

          // Returns the first two initials of the user
          String getInitials(String name) {
            List<String> parts = name.trim().split(' ');
            if (parts.length >= 2) {
              return parts[0][0] + parts[1][0];
            } else {
              return parts[0][0];
            }
          }

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  const SizedBox(height: 32),
                  // Profile Picture with initials
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.pink.shade100,
                    child: Text(
                      getInitials(userName).toUpperCase(),
                      style: const TextStyle(fontSize: 32, color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Username display
                  Text(
                    userName,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      fontFamily: "Georgia",
                    ),
                  ),
                  const SizedBox(height: 4),
                   // Email display
                  Text(
                    userEmail,
                    style: TextStyle(color: Colors.grey.shade700),
                  ),
                  const SizedBox(height: 32),

                  // Settings Section
                  Column(
                    children: [
                      // Notification toggle
                      Card(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 4,
                        child: ListTile(
                          title: const Text("Notification Settings"),
                          trailing: ValueListenableBuilder(
                            valueListenable: isOn,
                            builder: (context, value, _) {
                              return Switch(
                                value: value,
                                onChanged: (bool newValue) async {
                                  isOn.value = newValue;
                                  // Save toggle to Firestore
                                  await FirebaseFirestore.instance
                                      .collection('users')
                                      .doc(userId)
                                      .set({'notificationsOn': newValue}, SetOptions(merge: true));
                                  
                                  // Start or stop scheduled notifications
                                  if (newValue) {
                                    await scheduleNotification(true);
                                  } else {
                                    await flutterLocalNotificationsPlugin.cancelAll();
                                  }
                                },
                              );
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      //password reset
                      Card(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 4,
                        child: ListTile(
                          title: const Text("Reset Password"),
                          trailing: const Icon(Icons.lock_reset),
                          onTap: () {
                            FirebaseAuth.instance.sendPasswordResetEmail(email: userEmail);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Password reset email sent.")),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 10),
                      //logout
                      Card(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 4,
                        child: ListTile(
                          title: const Text("Logout"),
                          trailing: const Icon(Icons.logout),
                          onTap: () {
                            FirebaseAuth.instance.signOut();
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(builder: (context) => const LoginScreen()),
                              (route) => false,
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
