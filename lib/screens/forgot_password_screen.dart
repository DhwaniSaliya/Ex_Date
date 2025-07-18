import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();                                                      
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> resetPassword() async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: _emailController.text.trim(),
      );
      // ScaffoldMessenger.of(context).showSnackBar(
      //   const SnackBar(content: Text('Password reset email sent')),
      // );
      if(!mounted) return; //if i would have not used mounted then i would have to add a line ignore: use_build_context_synchronously
      // coz we want widget to be alive but it may be dead/removed so to suppress the warning we use it.. 
      showDialog(context: context, builder: (context){
        return const AlertDialog(
          content: Text('Password reset link has been sent! Please check your mail.'),
        );
      });
    } on FirebaseAuthException catch (e) {
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(content: Text('Error: ${e.toString()}')),
      // );
      print(e);
      showDialog(context: context, builder: (context){
        return const AlertDialog(
          content: Text('Enter a valid email id.'),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text("Resetting Password!", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 25.0),
            child: Text(
              'Enter your email Id, we will send you a link to reset your password.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 15),
            ),
          ),

          const SizedBox(height: 10),
          //Email textfield
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25.0),
            child: TextField(
              controller: _emailController,
              decoration: InputDecoration(
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.white),
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.pink),
                  borderRadius: BorderRadius.circular(12),
                ),
                hintText: 'Email',
                fillColor: Colors.grey[200],
                filled: true,
              ),
            ),
          ),

          const SizedBox(height: 10),

          // reset password textfield
          MaterialButton(
            onPressed: resetPassword,
            textColor: Colors.white,
            color: Theme.of(context).primaryColor,
            child: const Text('Reset Password'),
          ),
        ],
      ),
    );
  }
}

