// screens/profile_screen.dart
import 'package:flutter/material.dart';
import '../models/pet.dart';
import '../services/pet_service.dart';

class ProfileScreen extends StatefulWidget {
  final String userName;
  final int userId;

  const ProfileScreen({super.key, required this.userName, required this.userId});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final PetService _petService = PetService();
  late Future<List<Pet>> _userPetsFuture;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _userPetsFuture = _petService.getPets(userId: widget.userId);
  }

  Future<void> _refreshPets() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final pets = await _petService.getPets(userId: widget.userId);
      setState(() {
        _userPetsFuture = Future.value(pets);
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.userName}\'s Profile'),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshPets,
        child: FutureBuilder<List<Pet>>(
          future: _userPetsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return _buildEmptyState();
            } else {
              return _buildPetsList(snapshot.data!);
            }
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.pets, size: 80, color: Colors.grey),
          const SizedBox(height: 20),
          const Text(
            'No pets yet',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Text(
            '${widget.userName} hasn\'t added any pets',
            style: const TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildPetsList(List<Pet> pets) {
    return Column(
      children: [
        // User info
        Container(
          padding: const EdgeInsets.all(20),
          color: Colors.orange[50],
          child: Row(
            children: [
              const CircleAvatar(
                radius: 40,
                child: Icon(Icons.person, size: 40),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.userName,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${pets.length} pet${pets.length == 1 ? '' : 's'}',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Pets list
        Expanded(
          child: ListView.builder(
            itemCount: pets.length,
            itemBuilder: (context, index) {
              final pet = pets[index];
              return _buildPetCard(pet);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPetCard(Pet pet) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: ListTile(
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            pet.imageUrl,
            width: 50,
            height: 50,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(
              width: 50,
              height: 50,
              color: Colors.grey[200],
              child: const Icon(Icons.pets),
            ),
          ),
        ),
        title: Text(
          pet.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text('${pet.breed} • ${pet.age} years'),
        trailing: Chip(
          label: Text(pet.gender),
          backgroundColor: Colors.orange[50],
        ),
      ),
    );
  }
}