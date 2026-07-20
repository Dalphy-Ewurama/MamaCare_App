import 'package:flutter/material.dart';

class ReminderScreen extends StatelessWidget {
  const ReminderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("MamaCare Reminder"),
        backgroundColor: const Color(0xFF2E6B65),
        foregroundColor: Colors.white,
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [

            const Icon(
              Icons.favorite,
              size: 60,
              color: Color(0xFF2E6B65),
            ),

            const SizedBox(height:20),

            const Text(
              "Pregnancy Care Reminder",
              style: TextStyle(
                fontSize:24,
                fontWeight:FontWeight.bold,
              ),
            ),

            const SizedBox(height:20),

            const Text(
              """
• Drink enough water daily

• Take your iron and folic acid supplements

• Attend your antenatal appointments

• Eat healthy fruits and vegetables

• Get enough rest and sleep

Take care of yourself and your baby ❤️
""",
              style: TextStyle(
                fontSize:18,
                height:1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}