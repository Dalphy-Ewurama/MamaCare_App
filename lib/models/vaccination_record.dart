class VaccinationRecord {
  final String id;
  final String name;
  final String dueDate;
  final bool completed;
  final DateTime createdAt;

  const VaccinationRecord({
    required this.id,
    required this.name,
    required this.dueDate,
    required this.completed,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'dueDate': dueDate,
        'completed': completed,
        'createdAt': createdAt.toIso8601String(),
      };

  factory VaccinationRecord.fromJson(Map<String, dynamic> json) => VaccinationRecord(
        id: json['id'] as String,
        name: json['name'] as String,
        dueDate: json['dueDate'] as String,
        completed: json['completed'] as bool,
        createdAt: DateTime.parse(json['createdAt'] as String),
      );
}
