import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/patient_model.dart';
import '../models/branch_model.dart';
import '../models/treatment_model.dart';

class ApiService {
  final String _baseUrl = 'https://flutter-amr.noviindus.in/api/';
  String? _token;

  void setToken(String token) {
    _token = token;
  }

  Future<String?> login(String username, String password) async {
    final url = Uri.parse('${_baseUrl}Login');
    try {
      final response = await http.post(
        url,
        body: {'username': username, 'password': password},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == true) {
          _token = data['token'];
          return _token;
        } else {
          return null; 
        }
      } else {
        throw Exception('Failed to login');
      }
    } catch (e) {
      throw Exception('Error connecting to server: $e');
    }
  }

  Future<List<Patient>> getPatients() async {
    if (_token == null) throw Exception('Token not found');
    final url = Uri.parse('${_baseUrl}PatientList');

    try {
      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer $_token'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == true) {
          final List<dynamic> patientList =
              data['patient']; 
          return patientList.map((json) => Patient.fromJson(json)).toList();
        } else {
          return [];
        }
      } else {
        throw Exception('Failed to load patients');
      }
    } catch (e) {
      throw Exception('Error fetching patients: $e');
    }
  }

  Future<List<Branch>> getBranches() async {
    if (_token == null) throw Exception('Token not found');
    final url = Uri.parse('${_baseUrl}BranchList');

    try {
      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer $_token'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == true) {
          final List<dynamic> branches = data['branches']; // Check actual key
          return branches.map((json) => Branch.fromJson(json)).toList();
        } else {
          return [];
        }
      } else {
        throw Exception('Failed to load branches');
      }
    } catch (e) {
      throw Exception('Error fetching branches: $e');
    }
  }

  Future<List<Treatment>> getTreatments() async {
    if (_token == null) throw Exception('Token not found');
    final url = Uri.parse('${_baseUrl}TreatmentList');

    try {
      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer $_token'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == true) {
          final List<dynamic> treatments =
              data['treatments']; 
          return treatments.map((json) => Treatment.fromJson(json)).toList();
        } else {
          return [];
        }
      } else {
        throw Exception('Failed to load treatments');
      }
    } catch (e) {
      throw Exception('Error fetching treatments: $e');
    }
  }

  Future<bool> registerPatient(Map<String, dynamic> patientData) async {
    if (_token == null) throw Exception('Token not found');
    final url = Uri.parse('${_baseUrl}PatientUpdate');

    try {
      final request = http.MultipartRequest('POST', url);
      request.headers['Authorization'] = 'Bearer $_token';

      patientData.forEach((key, value) {
        request.fields[key] = value.toString();
      });

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == true) return true;
        throw Exception(data['message'] ?? 'Registration failed');
      } else {
        print('Registration Error Status: ${response.statusCode}');
        print('Registration Error Body: ${response.body}');
        throw Exception('Failed to register patient');
      }
    } catch (e) {
      throw Exception('Error registering patient: $e');
    }
  }
}
