import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/patient_model.dart';
import '../models/branch_model.dart';
import '../models/treatment_model.dart';

class DataProvider with ChangeNotifier {
  final ApiService _apiService;

  List<Patient> _patients = [];
  List<Branch> _branches = [];
  List<Treatment> _treatments = [];

  bool _isLoading = false;
  String _error = '';
  String _searchQuery = '';

  DataProvider(this._apiService);

  List<Patient> get patients => _patients;
  List<Patient> get filteredPatients {
    if (_searchQuery.isEmpty) return _patients;
    return _patients
        .where(
          (p) =>
              p.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              (p.treatmentName?.toLowerCase().contains(
                    _searchQuery.toLowerCase(),
                  ) ??
                  false),
        )
        .toList();
  }

  List<Branch> get branches => _branches;
  List<Treatment> get treatments => _treatments;
  bool get isLoading => _isLoading;
  String get error => _error;

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  Future<void> fetchPatients() async {
    _isLoading = true;
    notifyListeners();

    try {
      _patients = await _apiService.getPatients();
      _error = '';
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchBranches() async {
    try {
      _branches = await _apiService.getBranches();
      notifyListeners();
    } catch (e) {
      print('Error fetching branches: $e');
    }
  }

  Future<void> fetchTreatments() async {
    try {
      _treatments = await _apiService.getTreatments();
      notifyListeners();
    } catch (e) {
      print('Error fetching treatments: $e');
    }
  }

  Future<bool> registerPatient({
    required String name,
    required String whatsapp,
    required String address,
    required int branchId,
    required double totalAmount,
    required double discountAmount,
    required double advanceAmount,
    required double balanceAmount,
    required String date,
    required String hour,
    required String minute,
    required String paymentOption,
    required List<Map<String, dynamic>> treatments,
  }) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      // Format date as DD/MM/YYYY-HH:MM AM/PM
      // Input date is already DD/MM/YYYY
      final String amPm = int.parse(hour) >= 12 ? 'PM' : 'AM';
      final String formattedHour =
          (int.parse(hour) % 12 == 0 ? 12 : int.parse(hour) % 12)
              .toString()
              .padLeft(2, '0');
      final String dateTimeStr = '$date-$formattedHour:$minute $amPm';

      final String maleTreatmentIds = treatments
          .where((t) => (t['male'] as int) > 0)
          .map<int>((t) => t['treatment_id'] as int)
          .join(',');
      final String femaleTreatmentIds = treatments
          .where((t) => (t['female'] as int) > 0)
          .map<int>((t) => t['treatment_id'] as int)
          .join(',');
      final List<int> allTreatmentIds = treatments
          .map<int>((t) => t['treatment_id'] as int)
          .toList();

      final Map<String, dynamic> data = {
        'name': name,
        'excecutive': 'Admin',
        'payment': paymentOption.toLowerCase(),
        'phone': whatsapp,
        'address': address,
        'total_amount': totalAmount.toInt(),
        'discount_amount': discountAmount.toInt(),
        'advance_amount': advanceAmount.toInt(),
        'balance_amount': balanceAmount.toInt(),
        'date_nd_time': dateTimeStr,
        'id': '',
        'male': maleTreatmentIds,
        'female': femaleTreatmentIds,
        'branch': branchId.toString(),
        'treatments': allTreatmentIds.join(','),
      };

      final success = await _apiService.registerPatient(data);
      if (success) {
        await fetchPatients();
      }
      return success;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
