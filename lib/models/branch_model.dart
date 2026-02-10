class Branch {
  final int id;
  final String name;
  final String location;

  Branch({required this.id, required this.name, required this.location});

  factory Branch.fromJson(Map<String, dynamic> json) {
    return Branch(
      id: json['id'],
      name: json['name'] ?? '',
      location: json['location'] ?? '',
    );
  }
}
