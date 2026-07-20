class AntenatalVisit {
  final String id;
  final String title;
  final String date;
  final String notes;
  final DateTime createdAt;

  const AntenatalVisit({
    required this.id,
    required this.title,
    required this.date,
    required this.notes,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'date': date,
        'notes': notes,
        'createdAt': createdAt.toIso8601String(),
      };

  factory AntenatalVisit.fromJson(Map<String, dynamic> json) => AntenatalVisit(
        id: json['id'] as String,
        title: json['title'] as String,
        date: json['date'] as String,
        notes: json['notes'] as String,
        createdAt: DateTime.parse(json['createdAt'] as String),
      );
}
