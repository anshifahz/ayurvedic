class Patient {
  final int id;
  final String name;
  final String date;
  final String? time;
  final String user; 
  final String payment;
  final String? phone;
  final String? address;
  final double? totalAmount;
  final double? discountAmount;
  final double? advanceAmount;
  final double? balanceAmount;
  final String? branchName;
  final String? treatmentName;

  Patient({
    required this.id,
    required this.name,
    required this.date,
    this.time,
    required this.user,
    required this.payment,
    this.phone,
    this.address,
    this.totalAmount,
    this.discountAmount,
    this.advanceAmount,
    this.balanceAmount,
    this.branchName,
    this.treatmentName,
  });

  factory Patient.fromJson(Map<String, dynamic> json) {
    // Note: Adjust mapping based on actual API response structure
    return Patient(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id'].toString()) ?? 0,
      name: json['name'] ?? '',
      date: json['date_nd_time'] ?? '', 
      time: json['time'], 
      user: json['user'] ?? '',
      payment: json['payment'] ?? '',
      phone: json['phone'],
      address: json['address'],
      totalAmount: double.tryParse(json['total_amount'].toString()),
      discountAmount: double.tryParse(json['discount_amount'].toString()),
      advanceAmount: double.tryParse(json['advance_amount'].toString()),
      balanceAmount: double.tryParse(json['balance_amount'].toString()),
      branchName: json['branch_name'], 
      treatmentName: json['treatment_name'], 
    );
  }
}
