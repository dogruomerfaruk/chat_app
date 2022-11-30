import 'package:flutter/material.dart';

class AppBarChat extends StatelessWidget with PreferredSizeWidget {
  const AppBarChat({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        color: const Color(0xFF1A2321),
        onPressed: () {
          Navigator.of(context).pop();
        },
      ),
      title: const Text(
        'Mesajlarim',
        style: TextStyle(color: Color(0xFF1A2321)),
      ),
      backgroundColor: const Color(0xFFFCF9F4),
      actions: <Widget>[
        IconButton(
          icon: const Icon(Icons.account_circle),
          color: const Color(0xFF1A2321),
          tooltip: 'Show Snackbar',
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('This is a snackbar')));
          },
        ),
        IconButton(
          icon: const Icon(Icons.add_alert),
          color: const Color(0xFF1A2321),
          tooltip: 'Show Snackbar',
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('This is a snackbar')));
          },
        ),
      ],
    );
  }
}
