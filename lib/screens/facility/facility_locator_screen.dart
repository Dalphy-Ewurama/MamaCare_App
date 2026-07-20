import 'package:flutter/material.dart';

class FacilityLocatorScreen extends StatelessWidget {
  const FacilityLocatorScreen({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text("Health Facility Locator"),
        backgroundColor: const Color(0xFF2E6B65),
        foregroundColor: Colors.white,
      ),

      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,

          children: const [

            Icon(
              Icons.local_hospital,
              size: 80,
              color: Colors.blue,
            ),

            SizedBox(height:20),

            Text(
              "Nearby maternity facilities will appear here.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize:18,
              ),
            ),

          ],
        ),
      ),
    );
  }
}