import 'package:flutter/material.dart';

class DangerSignsScreen extends StatelessWidget {
  const DangerSignsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Danger Signs"),
        backgroundColor: const Color(0xFF2E6B65),
        foregroundColor: Colors.white,
      ),

      body: ListView(
        padding: const EdgeInsets.all(20),
        children: const [

          Text(
            "Warning signs during pregnancy",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),

          SizedBox(height: 20),

          ListTile(
            leading: Icon(Icons.warning, color: Colors.red),
            title: Text("Severe abdominal pain"),
          ),

          ListTile(
            leading: Icon(Icons.warning, color: Colors.red),
            title: Text("Heavy bleeding"),
          ),

          ListTile(
            leading: Icon(Icons.warning, color: Colors.red),
            title: Text("Severe headache or blurred vision"),
          ),

          ListTile(
            leading: Icon(Icons.warning, color: Colors.red),
            title: Text("Reduced baby movement"),
          ),

        ],
      ),
    );
  }
}