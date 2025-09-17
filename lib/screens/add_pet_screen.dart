// screens/add_pet_screen.dart
import 'package:flutter/material.dart';
import '../services/pet_service.dart';

class AddPetScreen extends StatefulWidget {
  final int userId;
  final String userName;

  const AddPetScreen({super.key, required this.userId, required this.userName});

  @override
  State<AddPetScreen> createState() => _AddPetScreenState();
}

class _AddPetScreenState extends State<AddPetScreen> {
  final _formKey = GlobalKey<FormState>();
  final PetService _petService = PetService();

  final _nameController = TextEditingController();
  final _breedController = TextEditingController();
  final _ageController = TextEditingController();
  final _genderController = TextEditingController();
  String _pedigree = 'false';
  String _imageUrl = '';
  String _petType = 'BREEDING'; // Default to BREEDING
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Your Pet'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Pet Name
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Pet Name',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter pet name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Pet Type Dropdown
                DropdownButtonFormField<String>(
                  value: _petType,
                  decoration: const InputDecoration(
                    labelText: 'Listing Type',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'BREEDING', child: Text('For Breeding')),
                    DropdownMenuItem(value: 'ADVERTISEMENT', child: Text('For Adoption/Sale')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _petType = value!;
                    });
                  },
                ),
                const SizedBox(height: 16),

                // Breed
                TextFormField(
                  controller: _breedController,
                  decoration: const InputDecoration(
                    labelText: 'Breed',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter breed';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Age
                TextFormField(
                  controller: _ageController,
                  decoration: const InputDecoration(
                    labelText: 'Age',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter age';
                    }
                    if (int.tryParse(value) == null) {
                      return 'Please enter a valid number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Gender
                TextFormField(
                  controller: _genderController,
                  decoration: const InputDecoration(
                    labelText: 'Gender (MALE/FEMALE)',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter gender';
                    }
                    if (value.toUpperCase() != 'MALE' && value.toUpperCase() != 'FEMALE') {
                      return 'Please enter MALE or FEMALE';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Has Pedigree
                DropdownButtonFormField<String>(
                  value: _pedigree,
                  decoration: const InputDecoration(
                    labelText: 'Has Pedigree',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'true', child: Text('Yes')),
                    DropdownMenuItem(value: 'false', child: Text('No')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _pedigree = value!;
                    });
                  },
                ),
                const SizedBox(height: 16),

                // Image URL
                TextFormField(
                  onChanged: (value) => _imageUrl = value,
                  decoration: const InputDecoration(
                    labelText: 'Image URL (optional)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 24),

                // Submit Button
                _isLoading
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
                  onPressed: _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange[700],
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: const Text(
                    'Add Pet',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        // Подготви ги податоците за pet
        final petData = {
          'name': _nameController.text,
          'breed': _breedController.text,
          'age': int.parse(_ageController.text),
          'gender': _genderController.text.toUpperCase(),
          'has_pedigree': _pedigree == 'true',
          'image': _imageUrl.isNotEmpty ? _imageUrl : '',
          'user_id': widget.userId,
          'type': _petType,
        };

        // Испрати го барањето за pet до API
        final response = await _petService.createPet(petData);

        if (response) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Pet added successfully!')),
          );
          Navigator.pop(context); // Врати се назад
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to add pet')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _breedController.dispose();
    _ageController.dispose();
    _genderController.dispose();
    super.dispose();
  }
}