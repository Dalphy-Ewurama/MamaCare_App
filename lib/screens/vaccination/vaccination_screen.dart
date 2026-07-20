import 'package:flutter/material.dart';

class VaccinationScreen extends StatelessWidget {
  const VaccinationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Infant Vaccinations"),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          ListTile(
            leading: Icon(Icons.check_circle, color: Colors.green),
            title: Text("BCG"),
            subtitle: Text("Birth"),
          ),
          ListTile(
            leading: Icon(Icons.check_circle, color: Colors.green),
            title: Text("OPV"),
            subtitle: Text("6 Weeks"),
          ),
          ListTile(
            leading: Icon(Icons.radio_button_unchecked),
            title: Text("Pentavalent"),
            subtitle: Text("10 Weeks"),
          ),
          ListTile(
            leading: Icon(Icons.radio_button_unchecked),
            title: Text("Measles"),
            subtitle: Text("9 Months"),
          ),
        ],
      ),
    );
  }
}