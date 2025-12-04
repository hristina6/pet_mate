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
  final _locationController = TextEditingController();
  String _pedigree = 'false';
  String _imageUrl = '';
  String _petType = 'BREEDING';
  bool _isLoading = false;

  // Modern color scheme
  final Color _primaryColor = const Color(0xFFFF9800);
  final Color _backgroundColor = Colors.white;
  final Color _cardColor = Colors.grey[50]!;
  final Color _textColor = Colors.grey[800]!;
  final Color _hintColor = Colors.grey[500]!;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.arrow_back_ios_new_rounded,
                color: _primaryColor, size: 20),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Add Your Pet',
          style: TextStyle(
            color: _textColor,
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                const SizedBox(height: 20),

                // Pet Name
                _buildModernTextField(
                  controller: _nameController,
                  label: 'Pet Name',
                  icon: Icons.pets_rounded,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter pet name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Pet Type Selection
                _buildTypeSelection(),
                const SizedBox(height: 16),

                // Breed
                _buildModernTextField(
                  controller: _breedController,
                  label: 'Breed',
                  icon: Icons.emoji_nature_rounded,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter breed';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Age
                _buildModernTextField(
                  controller: _ageController,
                  label: 'Age (years)',
                  icon: Icons.cake_rounded,
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
                const SizedBox(height: 14),

                // Location
                _buildModernTextField(
                  controller: _locationController,
                  label: 'Location (City, Country)',
                  icon: Icons.location_on_rounded,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter location';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 14),

                // Gender Selection
                _buildGenderSelection(),
                const SizedBox(height: 14),

                // Pedigree Selection
                _buildPedigreeSelection(),
                const SizedBox(height: 14),

                // Image URL
                _buildModernTextField(
                  onChanged: (value) => _imageUrl = value,
                  label: 'Image URL (optional)',
                  icon: Icons.image_rounded,
                  controller: null,
                ),
                const SizedBox(height: 18),

                // Submit Button
                _buildSubmitButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }


  Widget _buildModernTextField({
    required TextEditingController? controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    void Function(String)? onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        validator: validator,
        onChanged: onChanged,
        style: TextStyle(color: _textColor, fontSize: 16),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: _hintColor),
          prefixIcon: Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: _primaryColor, size: 20),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: _primaryColor, width: 2),
          ),
          filled: true,
          fillColor: _cardColor,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }

  Widget _buildTypeSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 8),
          child: Text(
            'Listing Type',
            style: TextStyle(
              color: _textColor,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ),
        Row(
          children: [
            Expanded(
              child: _buildSelectionCard(
                title: 'For Breeding',
                subtitle: 'Breeding purposes',
                isSelected: _petType == 'BREEDING',
                onTap: () => setState(() => _petType = 'BREEDING'),
                icon: Icons.family_restroom_rounded,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSelectionCard(
                title: 'Adoption/Sale',
                subtitle: 'Find a new home',
                isSelected: _petType == 'ADVERTISEMENT',
                onTap: () => setState(() => _petType = 'ADVERTISEMENT'),
                icon: Icons.favorite_rounded,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildGenderSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 8),
          child: Text(
            'Gender',
            style: TextStyle(
              color: _textColor,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ),
        Row(
          children: [
            Expanded(
              child: _buildSelectionCard(
                title: 'Male',
                isSelected: _genderController.text.toUpperCase() == 'MALE',
                onTap: () => setState(() => _genderController.text = 'MALE'),
                icon: Icons.male_rounded,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSelectionCard(
                title: 'Female',
                isSelected: _genderController.text.toUpperCase() == 'FEMALE',
                onTap: () => setState(() => _genderController.text = 'FEMALE'),
                icon: Icons.female_rounded,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPedigreeSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 8),
          child: Text(
            'Pedigree',
            style: TextStyle(
              color: _textColor,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ),
        Row(
          children: [
            Expanded(
              child: _buildSelectionCard(
                title: 'Yes',
                isSelected: _pedigree == 'true',
                onTap: () => setState(() => _pedigree = 'true'),
                icon: Icons.check_circle_rounded,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSelectionCard(
                title: 'No',
                isSelected: _pedigree == 'false',
                onTap: () => setState(() => _pedigree = 'false'),
                icon: Icons.cancel_rounded,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSelectionCard({
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
    required IconData icon,
    String? subtitle,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? _primaryColor.withOpacity(0.15) : _cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? _primaryColor : Colors.transparent,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? _primaryColor : _hintColor,
              size: 24,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                color: isSelected ? _primaryColor : _textColor,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  color: isSelected ? _primaryColor.withOpacity(0.8) : _hintColor,
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return _isLoading
        ? Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        color: _primaryColor.withOpacity(0.8),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      ),
    )
        : ElevatedButton(
      onPressed: _submitForm,
      style: ElevatedButton.styleFrom(
        backgroundColor: _primaryColor,
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 56),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 4,
        shadowColor: _primaryColor.withOpacity(0.3),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.add_circle_rounded, size: 20),
          const SizedBox(width: 8),
          const Text(
            'Add Pet',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      // Validate gender selection
      if (_genderController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Please select gender'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
        return;
      }

      // Validate location
      if (_locationController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Please enter location'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
        return;
      }

      setState(() {
        _isLoading = true;
      });

      try {
        final petData = {
          'name': _nameController.text,
          'breed': _breedController.text,
          'age': int.parse(_ageController.text),
          'gender': _genderController.text.toUpperCase(),
          'has_pedigree': _pedigree == 'true',
          'image': _imageUrl.isNotEmpty ? _imageUrl : '',
          'user_id': widget.userId,
          'type': _petType,
          'location': _locationController.text,
        };

        final response = await _petService.createPet(petData: petData);

        if (response) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Pet added successfully!'),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          );
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Failed to add pet'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
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
    _locationController.dispose();
    super.dispose();
  }
}