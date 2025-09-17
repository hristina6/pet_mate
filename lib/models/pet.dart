// models/pet.dart
class Pet {
  final int id;
  final String name;
  final String breed;
  final int age;
  final bool hasPedigree;
  final String gender;
  final String imageUrl;
  final String user;
  final DateTime createdAt;
  final String type;

  Pet({
    required this.id,
    required this.name,
    required this.breed,
    required this.age,
    required this.hasPedigree,
    required this.gender,
    required this.imageUrl,
    required this.user,
    required this.createdAt,
    required this.type,
  });

  factory Pet.fromJson(Map<String, dynamic> json) {
    print('🐕 Creating Pet from JSON: $json');

    return Pet(
      id: json['id'] ?? 0,
      name: json['name'] ?? 'Unknown',
      breed: json['breed'] ?? 'Unknown breed',
      age: json['age'] ?? 0,
      hasPedigree: _convertToBool(json['has_pedigree']),
      gender: json['gender'] ?? 'Unknown',
      imageUrl: json['image'] ?? '',
      user: _extractUserName(json),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      type: json['type'] ?? 'UNKNOWN',
    );
  }

  static String _extractUserName(Map<String, dynamic> json) {
    print('👤 Extracting user name from: $json');

    // Check different possible structures
    if (json['user'] is Map<String, dynamic>) {
      final userMap = json['user'] as Map<String, dynamic>;
      if (userMap['name'] != null) {
        print('✅ Found user name in user object: ${userMap['name']}');
        return userMap['name'] as String;
      }
    }

    if (json['user_name'] != null) {
      print('✅ Found user_name field: ${json['user_name']}');
      return json['user_name'] as String;
    }

    if (json['owner'] != null) {
      print('✅ Found owner field: ${json['owner']}');
      return json['owner'] as String;
    }

    if (json['user'] is String) {
      print('✅ Found user as string: ${json['user']}');
      return json['user'] as String;
    }

    if (json['user_id'] != null) {
      print('ℹ️ Found user_id: ${json['user_id']}, returning generic name');
      return 'User ${json['user_id']}';
    }

    print('❌ No user information found, returning Unknown owner');
    return 'Unknown owner';
  }

  static bool _convertToBool(dynamic value) {
    if (value == null) {
      print('⚫ has_pedigree is null, returning false');
      return false;
    }

    if (value is bool) {
      print('✅ has_pedigree is bool: $value');
      return value;
    }

    if (value is int) {
      print('✅ has_pedigree is int: $value, converting to bool');
      return value == 1;
    }

    if (value is String) {
      print('✅ has_pedigree is string: "$value", converting to bool');
      return value.toLowerCase() == 'true' || value == '1';
    }

    print('❌ has_pedigree is unknown type: ${value.runtimeType}, returning false');
    return false;
  }

  @override
  String toString() {
    return 'Pet{id: $id, name: $name, user: $user}';
  }
}