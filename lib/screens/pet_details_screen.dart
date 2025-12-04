import 'package:flutter/material.dart';
import '../models/pet.dart';
import 'otheruserprofilescreen.dart';

class PetDetailsScreen extends StatelessWidget {
  final Pet pet;
  final String currentUserName;

  const PetDetailsScreen({
    super.key,
    required this.pet,
    required this.currentUserName,
  });

  @override
  Widget build(BuildContext context) {
    // Determine status badge info
    final bool isBreeding = pet.type == 'BREEDING';
    final String statusText = isBreeding ? 'Breeding' : 'Adoption';
    final Color primaryColor = const Color(0xFFFF9800); // Your app's orange theme
    final Color backgroundColor = const Color(0xFFE6B578);

    return Scaffold(
      body: Stack(
        children: [
          // 1. Background Image (Top Half)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: MediaQuery.of(context).size.height * 0.5,
            child: pet.imageUrl != null && pet.imageUrl!.isNotEmpty
                ? Image.network(
              pet.imageUrl!,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                color: Colors.grey[200],
                child: const Center(child: Icon(Icons.pets, size: 80, color: Colors.grey)),
              ),
            )
                : Container(
              color: Colors.grey[200],
              child: const Center(child: Icon(Icons.pets, size: 80, color: Colors.grey)),
            ),
          ),

          // 2. Custom Navigation Buttons (Back & Menu)
          Positioned(
            top: 50,
            left: 20,
            child: _buildTopButton(
              context,
              icon: Icons.arrow_back_ios_new,
              onTap: () => Navigator.pop(context),
            ),
          ),

          // 3. White Content Sheet (Bottom Half)
          Positioned(
            top: MediaQuery.of(context).size.height * 0.40,
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(35),
                  topRight: Radius.circular(35),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 30, 24, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                  // Header: Name and Price/Type Badge
                  Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                        Text(
                        pet.name,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.location_on, size: 16, color: primaryColor),
                            const SizedBox(width: 4),
                            Text(
                              pet.location ?? 'Unknown Location',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          statusText,
                          style: TextStyle(
                            color: primaryColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Stats Row (Sex, Age, Breed/Weight)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildStatBox('Sex', pet.gender, backgroundColor),
                        _buildStatBox('Age', '${pet.age} yrs', backgroundColor),
                        // Using Breed here as "Weight" isn't in your Pet model
                        _buildStatBox('Breed', _shorten(pet.breed), backgroundColor),
                      ],
                    ),

                    const SizedBox(height: 24),

// In PetDetailsScreen build method, update the Owner/Contact Section:

// Owner/Contact Section
                    const Text(
                      'Main Contact',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 16),
                    InkWell(
                      onTap: () {
                        // Navigate to other user's profile
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => OtherUserProfileScreen(
                              userName: pet.user,
                              currentUserName: currentUserName,
                            ),
                          ),
                        );
                      },
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 25,
                            backgroundColor: Colors.grey[200],
                            child: Text(
                              pet.user.isNotEmpty ? pet.user[0].toUpperCase() : 'U',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[600],
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  pet.user,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                Text(
                                  'Owner',
                                  style: TextStyle(
                                    color: Colors.grey[500],
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(Icons.arrow_forward_ios_rounded,
                              color: Colors.grey[400],
                              size: 16),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Summary Section
                    const Text(
                      'Summary',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Text(
                          // Placeholder description since Pet model doesn't seem to have one
                          '${pet.name} is a wonderful ${pet.breed}. This pet is currently available for $statusText. Contact the owner to learn more about their personality and history.',
                          style: TextStyle(
                            color: Colors.grey[600],
                            height: 1.5,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),

                    // Bottom "Adopt" Button
                    SafeArea(
                      top: false,
                      child: Container(
                        width: double.infinity,
                        height: 56,
                        margin: const EdgeInsets.symmetric(vertical: 10),
                        child: ElevatedButton(
                          onPressed: () {
                            // Show success message and go back
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Request sent to ${pet.user}!'),
                                backgroundColor: Colors.green,
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor, // Using your theme color
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            elevation: 4,
                            shadowColor: primaryColor.withOpacity(0.4),
                          ),
                          child: Text(
                            isBreeding ? 'Request Breeding' : 'Adopt this pet',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper widget for top navigation buttons
  Widget _buildTopButton(BuildContext context, {required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.5), // Semi-transparent dark background like the image
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }

  // Helper widget for the 3 stats boxes
  Widget _buildStatBox(String label, String value, Color color) {
    return Container(
      width: 100, // Fixed width for uniformity
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05), // Very light tint
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  // Helper for small circle contact icons
  Widget _buildContactIcon(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: Colors.grey[700], size: 20),
    );
  }

  String _shorten(String txt) {
    if (txt.length > 8) return '${txt.substring(0, 8)}...';
    return txt;
  }
}