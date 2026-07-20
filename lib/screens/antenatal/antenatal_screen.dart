import 'package:flutter/material.dart';
import 'package:mamacare/models/pregnant_woman.dart';
import 'package:mamacare/services/auth_service.dart';

class AntenatalScreen extends StatelessWidget {
  const AntenatalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Antenatal Visits'),
      ),
      body: FutureBuilder<List<PregnantWoman>>(
        future: AuthService.loadPregnantWomanRecords(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text('No pregnancy record found'),
            );
          }

          final woman = snapshot.data!.first;

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Card(
                child: ListTile(
                  leading: const Icon(Icons.pregnant_woman),
                  title: Text(woman.fullName),
                  subtitle: Text(
                    'Pregnancy Week: ${woman.gestationalAgeWeeks}\n'
                    'Expected Delivery: ${woman.expectedDeliveryDate}',
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}