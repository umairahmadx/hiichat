import 'package:flutter/material.dart';

import '../login.dart';
import '../../../firebase/authentication.dart';

Future<void> logoutUser(BuildContext context) async {
  bool? confirm = await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            "Logout User",
          ),
          content: const Text("Are you sure you want to continue?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
// No
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
// Yes
              child: const Text("Yes"),
            ),
          ],
        );
      });
  if (confirm == true) {
    try {
      await AuthService().signOut();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Logout Successful')),
        );
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const Login()),
          (Route<dynamic> route) => false,
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error signing out: $e')),
        );
      }
    }
  }
}
