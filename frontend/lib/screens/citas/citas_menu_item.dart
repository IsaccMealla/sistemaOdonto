import 'package:flutter/material.dart';
import 'citas_screen.dart';

class CitasMenuItem extends StatelessWidget {
  final String userRole;
  const CitasMenuItem({Key? key, required this.userRole}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.calendar_today),
      title: const Text('Citas Médicas'),
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => CitasScreen(userRole: userRole),
          ),
        );
      },
    );
  }
}
