class Treatment {
  final int id;
  final String name;
  final String duration;
  final String price;

  Treatment({
    required this.id,
    required this.name,
    required this.duration,
    required this.price,
  });

  factory Treatment.fromJson(Map<String, dynamic> json) {
    return Treatment(
      id: json['id'],
      name: json['name'] ?? '',
      duration: json['duration'] ?? '',
      price: json['price'] ?? '',
    );
  }
}
