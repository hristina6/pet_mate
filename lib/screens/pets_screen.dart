// screens/pets_screen.dart
import 'package:flutter/material.dart';
import '../services/pet_service.dart';
import '../models/pet.dart';

class PetsScreen extends StatefulWidget {
  final int? filterUserId;

  const PetsScreen({super.key, this.filterUserId});

  @override
  State<PetsScreen> createState() => _PetsScreenState();
}

class _PetsScreenState extends State<PetsScreen> {
  final PetService _petService = PetService();
  late Future<List<Pet>> _petsFuture;
  String _selectedType = 'ALL';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _petsFuture = _loadPets();
  }

  Future<List<Pet>> _loadPets({String? type}) async {
    try {
      if (widget.filterUserId != null) {
        return await _petService.getPets(userId: widget.filterUserId, type: type);
      } else if (type == 'ALL' || type == null) {
        return await _petService.getPets();
      } else {
        return await _petService.getPets(type: type);
      }
    } catch (e) {
      print('Error loading pets: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load pets: $e')),
      );
      return [];
    }
  }

  Future<void> _refreshPets() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final pets = await _loadPets(
          type: _selectedType == 'ALL' ? null : _selectedType
      );
      setState(() {
        _petsFuture = Future.value(pets);
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
        title: widget.filterUserId != null
            ? const Text('My Pets')
            : const Text('All Pets'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshPets,
          ),
        ],
      ),
      body: Column(
        children: [
          // Type Filter
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: DropdownButtonFormField<String>(
              value: _selectedType,
              decoration: const InputDecoration(
                labelText: 'Filter by Type',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'ALL', child: Text('All Types')),
                DropdownMenuItem(value: 'ADVERTISEMENT', child: Text('For Adoption/Sale')),
                DropdownMenuItem(value: 'BREEDING', child: Text('For Breeding')),
              ],
              onChanged: (String? value) {
                setState(() {
                  _selectedType = value!;
                });
                _refreshPets();
              },
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Pet>>(
              future: _petsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error, size: 48, color: Colors.red),
                        const SizedBox(height: 16),
                        Text(
                          'Error: ${snapshot.error}',
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _refreshPets,
                          child: const Text('Try Again'),
                        ),
                      ],
                    ),
                  );
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.pets, size: 48, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          'No pets found',
                          style: TextStyle(fontSize: 18),
                        ),
                      ],
                    ),
                  );
                } else {
                  return RefreshIndicator(
                    onRefresh: _refreshPets,
                    child: ListView.builder(
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        final pet = snapshot.data![index];
                        return _buildPetCard(pet);
                      },
                    ),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPetCard(Pet pet) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
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
              title: Text(pet.name),
              subtitle: Text('${pet.breed} • ${pet.age} years'),
              trailing: Chip(
                label: Text(pet.gender),
                backgroundColor: Colors.orange[50],
              ),
              onTap: () {
                _showPetDetails(context, pet);
              },
            ),
            const SizedBox(height: 4),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  textStyle: const TextStyle(fontSize: 12),
                ),
                onPressed: () {
                  // Мок ап popup
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: const Text('Success'),
                        content: Text('Request for ${pet.name} sent successfully!'),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: const Text('OK'),
                          ),
                        ],
                      );
                    },
                  );
                },
                child: const Text('Send Request'),
              ),
            ),
          ],
        ),
      ),
    );
  }



  void _showPetDetails(BuildContext context, Pet pet) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(pet.name),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailRow('Breed', pet.breed),
                _buildDetailRow('Age', '${pet.age} years'),
                _buildDetailRow('Gender', pet.gender),
                _buildDetailRow('Pedigree', pet.hasPedigree ? 'Yes' : 'No'),
                _buildDetailRow('Type', pet.type),
                _buildDetailRow('Owner', pet.user),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(value),
        ],
      ),
    );
  }
}