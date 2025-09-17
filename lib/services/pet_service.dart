// services/pet_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/pet.dart';

class PetService {
  final String baseUrl = 'http://10.0.2.2:8000/api/v1';

  Future<List<Pet>> getPets({int? userId, String? type}) async {
    try {
      String url = '$baseUrl/pets?';

      // Додади параметри за филтрирање
      final params = [];
      if (userId != null) params.add('user_id=$userId');
      if (type != null) params.add('type=$type');

      if (params.isNotEmpty) {
        url += params.join('&');
      }

      print('🔄 Fetching pets from: $url');

      final response = await http.get(
        Uri.parse(url),
        headers: {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      print('📡 HTTP Status Code: ${response.statusCode}');

      if (response.statusCode == 200) {
        final dynamic responseData = json.decode(response.body);
        print('✅ Successfully parsed JSON response');

        List<dynamic> petsList = [];

        if (responseData is List) {
          petsList = responseData;
        } else if (responseData is Map && responseData['data'] is List) {
          petsList = responseData['data'];
        } else if (responseData is Map && responseData['pets'] is List) {
          petsList = responseData['pets'];
        } else {
          print('❌ Unexpected response format');
          return [];
        }

        return petsList.map((petJson) => Pet.fromJson(petJson)).toList();
      } else {
        print('❌ HTTP Error: ${response.statusCode}');
        throw Exception('Failed to load pets: HTTP ${response.statusCode}');
      }
    } catch (e) {
      print('💥 Exception in getPets(): $e');
      throw Exception('Failed to load pets: $e');
    }
  }

  Future<bool> createPet(Map<String, dynamic> petData) async {
    try {
      print('🔄 Creating pet with data: $petData');

      final response = await http.post(
        Uri.parse('$baseUrl/pets'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(petData),
      );

      print('📡 Create Pet Status: ${response.statusCode}');
      print('📦 Create Pet Response: ${response.body}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        print('✅ Pet created successfully');
        return true;
      } else {
        if (response.statusCode == 422) {
          final errorData = json.decode(response.body);
          print('❌ Validation errors: $errorData');
        }
        return false;
      }
    } catch (e) {
      print('💥 Error creating pet: $e');
      return false;
    }
  }
}