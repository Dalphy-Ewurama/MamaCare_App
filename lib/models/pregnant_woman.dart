class PregnantWoman {
  final String id;
  final String fullName;
  final String email;
  final String phoneNumber;
  final int gestationalAgeWeeks;
  final String expectedDeliveryDate;
  final DateTime registeredAt;
  final DateTime? scanDate; // Added optional property for storage tracking

  const PregnantWoman({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    required this.gestationalAgeWeeks,
    required this.expectedDeliveryDate,
    required this.registeredAt,
    this.scanDate, // Added initialization parameter
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'fullName': fullName,
        'email': email,
        'phoneNumber': phoneNumber,
        'gestationalAgeWeeks': gestationalAgeWeeks,
        'expectedDeliveryDate': expectedDeliveryDate,
        'registeredAt': registeredAt.toIso8601String(),
        'scanDate': scanDate?.toIso8601String(), // Map to string storage
      };

  factory PregnantWoman.fromJson(Map<String, dynamic> json) => PregnantWoman(
        id: json['id'] as String,
        fullName: json['fullName'] as String,
        email: json['email'] as String,
        phoneNumber: json['phoneNumber'] as String,
        gestationalAgeWeeks: json['gestationalAgeWeeks'] as int,
        expectedDeliveryDate: json['expectedDeliveryDate'] as String,
        registeredAt: DateTime.parse(json['registeredAt'] as String),
        // Read string timestamp value back into a functional object instances safely
        scanDate: json['scanDate'] != null ? DateTime.parse(json['scanDate'] as String) : null,
      );
}
