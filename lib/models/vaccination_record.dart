// lib/models/vaccination_record.dart
class VaccinationRecord {
  final String id;
  final String name;
  final String dueDate;
  final bool completed;
  final String notes; // Stores specific doctor/midwife instructions
  final DateTime createdAt;

  const VaccinationRecord({
    required this.id,
    required this.name,
    required this.dueDate,
    required this.completed,
    required this.notes,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'dueDate': dueDate,
        'completed': completed ? 1 : 0,
        'notes': notes,
        'createdAt': createdAt.toIso8601String(),
      };

  factory VaccinationRecord.fromJson(Map<String, dynamic> json) => VaccinationRecord(
        id: json['id'] as String,
        name: json['name'] as String,
        dueDate: json['dueDate'] as String,
        completed: json['completed'] == 1 || json['completed'] == true,
        notes: json['notes'] ?? '',
        createdAt: DateTime.parse(json['createdAt'] as String),
      );
}
