class PregnantWoman {
  final String id;
  final String fullName;
  final String email;
  final String phoneNumber;
  final int gestationalAgeWeeks;
  final String expectedDeliveryDate;
  final DateTime registeredAt;

  const PregnantWoman({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    required this.gestationalAgeWeeks,
    required this.expectedDeliveryDate,
    required this.registeredAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'fullName': fullName,
        'email': email,
        'phoneNumber': phoneNumber,
        'gestationalAgeWeeks': gestationalAgeWeeks,
        'expectedDeliveryDate': expectedDeliveryDate,
        'registeredAt': registeredAt.toIso8601String(),
      };

  factory PregnantWoman.fromJson(Map<String, dynamic> json) => PregnantWoman(
        id: json['id'] as String,
        fullName: json['fullName'] as String,
        email: json['email'] as String,
        phoneNumber: json['phoneNumber'] as String,
        gestationalAgeWeeks: json['gestationalAgeWeeks'] as int,
        expectedDeliveryDate: json['expectedDeliveryDate'] as String,
        registeredAt: DateTime.parse(json['registeredAt'] as String),
      );
}
