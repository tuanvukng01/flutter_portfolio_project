class User {
  final String id;
  final double availableFunds;
  final double totalValue;

  User({
    required this.id,
    required this.availableFunds,
    required this.totalValue,
  });

  // Add the copyWith method for immutability
  User copyWith({
    String? id,
    double? availableFunds,
    double? totalValue,
  }) {
    return User(
      id: id ?? this.id,  // If id is passed, use it, otherwise keep the current id
      availableFunds: availableFunds ?? this.availableFunds,
      totalValue: totalValue ?? this.totalValue,
    );
  }

  // Assuming this method already exists for creating User from JSON
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      availableFunds: (json['availableFunds'] ?? 0.0).toDouble(),
      totalValue: (json['totalValue'] ?? 0.0).toDouble(),
    );
  }
}