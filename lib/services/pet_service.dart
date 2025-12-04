import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/pet.dart';

class PetService {
  final String baseUrl = 'http://10.0.2.2:8000/api/v1';

  Future<List<Pet>> getPets({int? userId, String? type}) async {
    try {
      String url = '$baseUrl/pets?';
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
      ).timeout(const Duration(seconds: 20));

      print('📡 HTTP Status Code: ${response.statusCode}');
      print('📦 Raw Response: ${response.body}'); // Додадов raw response print

      if (response.statusCode == 200) {
        final dynamic responseData = json.decode(response.body);
        print('✅ Successfully parsed JSON response');

        List<dynamic> petsList = [];

        if (responseData is List) {
          petsList = responseData;
          print('📋 Response is a List with ${petsList.length} items');
        } else if (responseData is Map && responseData['data'] is List) {
          petsList = responseData['data'];
          print('📋 Response has data list with ${petsList.length} items');
        } else if (responseData is Map && responseData['pets'] is List) {
          petsList = responseData['pets'];
          print('📋 Response has pets list with ${petsList.length} items');
        } else {
          print('❌ Unexpected response format: ${responseData.runtimeType}');
          return [];
        }

        // ДЕТАЛНО DEBUG ЗА СЛИКИТЕ - Додадов оваа секција
        print('🔍 Detailed image analysis:');
        for (var i = 0; i < petsList.length; i++) {
          final pet = petsList[i];
          print('🐕 Pet $i: ${pet['name']}');
          print('   📸 Available image fields:');
          pet.keys.where((key) => key.toString().toLowerCase().contains('image')).forEach((key) {
            print('   - $key: "${pet[key]}" (type: ${pet[key].runtimeType})');
          });
          if (!pet.keys.any((key) => key.toString().toLowerCase().contains('image'))) {
            print('   ❌ No image fields found in this pet object');
            print('   🔍 All fields: ${pet.keys.toList()}');
          }
        }

        // Final mapping and debug
        final pets = petsList.map((petJson) => Pet.fromJson(petJson)).toList();

        print('🔍 Final image URLs after mapping:');
        for (var pet in pets) {
          print('   📸 ${pet.name}: "${pet.imageUrl}" (length: ${pet.imageUrl.length})');
          print('   🔗 URL starts with http: ${pet.imageUrl.startsWith('http')}');
        }

        return pets;
      } else {
        print('❌ HTTP Error: ${response.statusCode}');
        throw Exception('Failed to load pets: HTTP ${response.statusCode}');
      }
    } catch (e) {
      print('💥 Exception in getPets(): $e');
      throw Exception('Failed to load pets: $e');
    }
  }

  Future<bool> createPet({
    required Map<String, dynamic> petData,
    String? imageUrl, // Add image URL parameter
  }) async {
    try {
      print('🔄 Creating pet with data: $petData');

      // Create a copy of petData and add image URL if provided
      final dataToSend = Map<String, dynamic>.from(petData);
      if (imageUrl != null && imageUrl.isNotEmpty) {
        dataToSend['image'] = imageUrl;
        print('🖼️ Adding image URL: $imageUrl');
      } else {
        print('🖼️ No image URL provided');
      }

      final response = await http.post(
        Uri.parse('$baseUrl/pets'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(dataToSend),
      );

      print('📡 Create Pet Status: ${response.statusCode}');
      print('📦 Create Pet Response: ${response.body}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        final responseData = json.decode(response.body);
        print('✅ Pet created successfully');
        print('📸 Image in response: ${responseData['image']}'); // Додадов print за слика во response
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