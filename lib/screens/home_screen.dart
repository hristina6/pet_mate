import 'dart:async';

import 'package:flutter/material.dart';
import '../models/pet.dart';
import '../services/pet_service.dart';
import 'notifications_screen.dart';
import 'profile_screen.dart';
import 'add_pet_screen.dart';
import 'posts_screen.dart' as posts_screen;
import 'add_post_screen.dart';
import 'pet_details_screen.dart';

class HomeScreen extends StatefulWidget {
  final String userName;
  final int userId;

  const HomeScreen({super.key, required this.userName, required this.userId});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PetService _petService = PetService();
  late Future<List<Pet>> _petsFuture;
  String _selectedType = 'ALL';
  String? _selectedLocation;
  int _currentIndex = 0;
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _locationSearchController = TextEditingController();

  // Modern color scheme
  final Color _primaryColor = const Color(0xFFFF9800);
  final Color _backgroundColor = Colors.white;
  final Color _cardColor = Colors.grey[50]!;
  final Color _textColor = Colors.grey[800]!;
  final Color _hintColor = Colors.grey[500]!;

  // Variables for location dropdown
  List<String> _locations = [];
  List<String> _filteredLocations = [];
  bool _isLoadingLocations = false;
  bool _showLocationDropdown = false;

  @override
  void initState() {
    super.initState();
    _petsFuture = _loadPets();
    _loadLocations();

    // Listen for location search changes
    _locationSearchController.addListener(() {
      _filterLocations();
    });
  }

  @override
  void dispose() {
    _locationSearchController.dispose();
    super.dispose();
  }

  void _filterLocations() {
    final query = _locationSearchController.text.toLowerCase();
    setState(() {
      _filteredLocations = _locations
          .where((location) => location.toLowerCase().contains(query))
          .toList();
      _showLocationDropdown = query.isNotEmpty && _filteredLocations.isNotEmpty;
    });
  }

  void _selectLocation(String location) {
    setState(() {
      _selectedLocation = location;
      _locationSearchController.text = location;
      _showLocationDropdown = false;
    });
    _performCombinedSearch();
  }

  void _clearLocation() {
    setState(() {
      _selectedLocation = null;
      _locationSearchController.clear();
      _showLocationDropdown = false;
    });
    _performCombinedSearch();
  }

  Future<List<Pet>> _loadPets({String? type, String? location}) async {
    try {
      List<Pet> pets;
      if (type == 'ALL' || type == null) {
        pets = await _petService.getPets();
      } else {
        pets = await _petService.getPets(type: type);
      }

      // Filter by location if selected
      if (location != null && location.isNotEmpty) {
        pets = pets.where((pet) =>
            pet.location.toLowerCase().contains(location.toLowerCase())
        ).toList();
      }

      // Sort pets from newest to oldest based on createdAt
      pets.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      return pets;
    } on TimeoutException {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Request timed out. Please try again.')),
      );
      return [];
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load pets: $e')),
      );
      return [];
    }
  }

  Future<void> _loadLocations() async {
    setState(() {
      _isLoadingLocations = true;
    });

    try {
      final pets = await _petService.getPets();
      final locations = <String>{};

      for (var pet in pets) {
        if (pet.location != null && pet.location!.isNotEmpty) {
          locations.add(pet.location!);
        }
      }

      setState(() {
        _locations = locations.toList()..sort();
        _filteredLocations = List.from(_locations);
        _isLoadingLocations = false;
      });
    } catch (e) {
      print('Error loading locations: $e');
      setState(() {
        _isLoadingLocations = false;
      });
    }
  }

  Future<void> _refreshPets() async {
    final pets = await _loadPets(
      type: _selectedType == 'ALL' ? null : _selectedType,
      location: _selectedLocation,
    );
    setState(() {
      _petsFuture = Future.value(pets);
    });
  }

  // Perform combined search by both name/breed AND location
  void _performCombinedSearch() {
    final nameQuery = _searchController.text.toLowerCase();
    final locationQuery = _selectedLocation?.toLowerCase() ?? '';

    if (nameQuery.isEmpty && locationQuery.isEmpty) {
      // No filters - show all pets
      setState(() {
        _petsFuture = _loadPets(
          type: _selectedType == 'ALL' ? null : _selectedType,
        );
      });
    } else {
      // Apply combined filters
      setState(() {
        _petsFuture = _loadPets(
          type: _selectedType == 'ALL' ? null : _selectedType,
        ).then((pets) {
          List<Pet> filteredPets = List.from(pets);

          // Filter by name/breed if search query exists
          if (nameQuery.isNotEmpty) {
            filteredPets = filteredPets.where((pet) =>
            pet.name.toLowerCase().contains(nameQuery) ||
                pet.breed.toLowerCase().contains(nameQuery)
            ).toList();
          }

          // Filter by location if selected
          if (locationQuery.isNotEmpty) {
            filteredPets = filteredPets.where((pet) =>
                pet.location.toLowerCase().contains(locationQuery)
            ).toList();
          }

          // Sort by creation date
          filteredPets.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return filteredPets;
        });
      });
    }
  }

  // Clear both search fields
  void _clearAllFilters() {
    setState(() {
      _searchController.clear();
      _selectedLocation = null;
      _locationSearchController.clear();
      _showLocationDropdown = false;
    });
    _refreshPets();
  }

  List<Widget> get _screens => [
    _buildPetsHomeContent(),
    posts_screen.PostsScreen(),
    const NotificationsScreen(),
    ProfileScreen(userName: widget.userName, userId: widget.userId),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      floatingActionButton: _buildFAB(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        child: _buildCustomBottomNavBar(),
      ),
    );
  }

  Widget _buildCustomBottomNavBar() {
    return Container(
      height: 75,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(35),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const SizedBox(width: 20),
          _buildBubbleNavItem(Icons.home_outlined, 0),
          _buildBubbleNavItem(Icons.forum_outlined, 1),
          _buildBubbleNavItem(Icons.person_outline, 3),
          const SizedBox(width: 20),
        ],
      ),
    );
  }

  Widget _buildBubbleNavItem(IconData icon, int index) {
    final bool isSelected = _currentIndex == index;

    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        height: 55,
        width: 55,
        decoration: BoxDecoration(
          color: isSelected ? _primaryColor : Colors.white,
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? _primaryColor : Colors.grey[300]!,
            width: 2,
          ),
          boxShadow: isSelected
              ? [
            BoxShadow(
              color: _primaryColor.withOpacity(0.5),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ]
              : [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(
          icon,
          color: isSelected ? Colors.white : Colors.black87,
          size: 26,
        ),
      ),
    );
  }

  Widget _buildPetsHomeContent() {
    return SafeArea(
      child: RefreshIndicator(
        onRefresh: _refreshPets,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _currentIndex = 3;
                      });
                    },
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 28,
                          backgroundColor: Colors.grey[200],
                          child: Text(
                            widget.userName.isNotEmpty
                                ? widget.userName[0].toUpperCase()
                                : 'U',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.black54,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Text(
                          widget.userName,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _currentIndex = 2;
                      });
                    },
                    child: Stack(
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.grey[300]!, width: 2),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.notifications_none,
                            color: Colors.grey[700],
                            size: 28,
                          ),
                        ),
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Container(
                            width: 16,
                            height: 16,
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            child: const Center(
                              child: Text(
                                '3',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Combined Search and Location Fields - Side by side
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      // Search for name or breed
                      Expanded(
                        child: Container(
                          height: 50,
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(25),
                            border: Border.all(color: Colors.grey[300]!),
                          ),
                          child: Row(
                            children: [
                              const SizedBox(width: 16),
                              Icon(Icons.search, color: Colors.grey[600], size: 20),
                              const SizedBox(width: 12),
                              Expanded(
                                child: TextField(
                                  controller: _searchController,
                                  decoration: const InputDecoration(
                                    hintText: 'Search name or breed..',
                                    border: InputBorder.none,
                                    hintStyle: TextStyle(color: Colors.grey),
                                  ),
                                  onChanged: (value) {
                                    _performCombinedSearch();
                                  },
                                ),
                              ),
                              if (_searchController.text.isNotEmpty)
                                IconButton(
                                  icon: Icon(Icons.clear, color: Colors.grey[600], size: 20),
                                  onPressed: () {
                                    _searchController.clear();
                                    _performCombinedSearch();
                                  },
                                ),
                              const SizedBox(width: 8),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(width: 12),

                      // Location dropdown field
                      Expanded(
                        child: Column(
                          children: [
                            Container(
                              height: 50,
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                borderRadius: BorderRadius.circular(25),
                                border: Border.all(color: Colors.grey[300]!),
                              ),
                              child: Row(
                                children: [
                                  const SizedBox(width: 16),
                                  Icon(Icons.location_on_outlined, color: Colors.grey[600], size: 20),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: TextField(
                                      controller: _locationSearchController,
                                      decoration: InputDecoration(
                                        hintText: 'Location...',
                                        border: InputBorder.none,
                                        hintStyle: const TextStyle(color: Colors.grey),
                                        suffixIcon: _selectedLocation != null
                                            ? IconButton(
                                          icon: Icon(Icons.clear, color: Colors.grey[600], size: 20),
                                          onPressed: _clearLocation,
                                        )
                                            : _isLoadingLocations
                                            ? const Padding(
                                          padding: EdgeInsets.all(10),
                                          child: SizedBox(
                                            width: 16,
                                            height: 16,
                                            child: CircularProgressIndicator(strokeWidth: 2),
                                          ),
                                        )
                                            : IconButton(
                                          icon: Icon(
                                            _showLocationDropdown ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                                            color: Colors.grey[600],
                                            size: 24,
                                          ),
                                          onPressed: () {
                                            setState(() {
                                              _showLocationDropdown = !_showLocationDropdown;
                                              if (_showLocationDropdown && _locationSearchController.text.isEmpty) {
                                                _filteredLocations = List.from(_locations);
                                              }
                                            });
                                          },
                                        ),
                                      ),
                                      onTap: () {
                                        setState(() {
                                          _showLocationDropdown = true;
                                          if (_locationSearchController.text.isEmpty) {
                                            _filteredLocations = List.from(_locations);
                                          }
                                        });
                                      },
                                      onChanged: (value) {
                                        // Update the location search
                                        if (value.isEmpty) {
                                          _selectedLocation = null;
                                          _performCombinedSearch();
                                        }
                                      },
                                      onSubmitted: (value) {
                                        if (value.isNotEmpty) {
                                          _selectLocation(value);
                                        }
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  // Clear all filters button (only shown when filters are active)
                  if (_searchController.text.isNotEmpty || _selectedLocation != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          InkWell(
                            onTap: _clearAllFilters,
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: Colors.grey[300]!),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.clear_all, size: 16, color: Colors.grey[600]),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Clear all filters',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Location dropdown list (appears below both fields)
                  if (_showLocationDropdown && _filteredLocations.isNotEmpty)
                    Container(
                      margin: const EdgeInsets.only(top: 4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      constraints: const BoxConstraints(maxHeight: 200),
                      child: _buildLocationDropdownList(),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildFilterCircle('All Types', Icons.all_inclusive, 'ALL'),
                  _buildFilterCircle('Adoption/Sale', Icons.favorite, 'ADVERTISEMENT'),
                  _buildFilterCircle('Breeding', Icons.pets, 'BREEDING'),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: FutureBuilder<List<Pet>>(
                future: _petsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return _buildEmptyState();
                  }

                  final pets = snapshot.data!;
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    itemCount: pets.length,
                    itemBuilder: (context, index) => _buildPetCard(pets[index]),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationDropdownList() {
    return ListView.builder(
      shrinkWrap: true,
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: _filteredLocations.length,
      itemBuilder: (context, index) {
        final location = _filteredLocations[index];
        final bool isSelected = _selectedLocation == location;

        return ListTile(
          leading: Icon(
            isSelected ? Icons.check_circle : Icons.location_on_outlined,
            color: isSelected ? _primaryColor : Colors.grey[600],
            size: 20,
          ),
          title: Text(
            location,
            style: TextStyle(
              color: isSelected ? _primaryColor : Colors.grey[800],
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
          onTap: () => _selectLocation(location),
          dense: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    bool hasSearchFilter = _searchController.text.isNotEmpty;
    bool hasLocationFilter = _selectedLocation != null;

    String message = 'No pets found';
    String details = '';

    if (hasSearchFilter && hasLocationFilter) {
      message = 'No pets found matching your search';
      details = 'for "${_searchController.text}" in "$_selectedLocation"';
    } else if (hasSearchFilter) {
      message = 'No pets found';
      details = 'matching "${_searchController.text}"';
    } else if (hasLocationFilter) {
      message = 'No pets found';
      details = 'in "$_selectedLocation"';
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          if (details.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              details,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
          const SizedBox(height: 20),
          if (hasSearchFilter || hasLocationFilter)
            ElevatedButton(
              onPressed: _clearAllFilters,
              style: ElevatedButton.styleFrom(
                backgroundColor: _primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: const Text('Clear All Filters'),
            ),
        ],
      ),
    );
  }

  Widget _buildFilterCircle(String label, IconData icon, String type) {
    final isSelected = _selectedType == type;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedType = type;
        });
        _performCombinedSearch(); // Update with new type filter
      },
      child: Column(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: isSelected ? _primaryColor : Colors.grey[200],
            child: Icon(icon, color: isSelected ? Colors.white : Colors.black54),
          ),
          const SizedBox(height: 6),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildPetCard(Pet pet) {
    String typeText = '';
    Color typeColor = Colors.grey;

    if (pet.type == 'ADVERTISEMENT') {
      typeText = 'Adoption/Sale';
      typeColor = Colors.yellow;
    } else if (pet.type == 'BREEDING') {
      typeText = 'Breeding';
      typeColor = Colors.red;
    }

    final String formattedDate = _formatDate(pet.createdAt);

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      margin: const EdgeInsets.only(bottom: 20),
      elevation: 4,
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
                child: pet.imageUrl != null && pet.imageUrl!.isNotEmpty
                    ? Image.network(
                  pet.imageUrl!,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 200,
                    color: Colors.grey[200],
                    child: const Icon(Icons.pets, size: 60, color: Colors.grey),
                  ),
                )
                    : Container(
                  height: 200,
                  color: Colors.grey[200],
                  child: const Icon(Icons.pets, size: 60, color: Colors.grey),
                ),
              ),
              Positioned(
                top: 12,
                right: 12,
                child: GestureDetector(
                  onTap: () => _handleContactTap(pet),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.person_add_alt_1,
                      color: Colors.grey[700],
                      size: 20,
                    ),
                  ),
                ),
              ),
            ],
          ),

          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
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
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 6),

                      Row(
                        children: [
                          Text(
                            pet.breed,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '• ${pet.age} years',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),

                      // Location information
                      if (pet.location != null && pet.location!.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.location_on, size: 14, color: Colors.grey[500]),
                            const SizedBox(width: 4),
                            Text(
                              pet.location!,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ],

                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.calendar_today, size: 14, color: Colors.grey[500]),
                          const SizedBox(width: 4),
                          Text(
                            formattedDate,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Transform.rotate(
                      angle: 0.174533,
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: Colors.black,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: IconButton(
                          icon: const Icon(
                            Icons.arrow_outward,
                            size: 20,
                            color: Colors.white,
                          ),
                          onPressed: () => _showPetDetails(context, pet),
                          padding: EdgeInsets.zero,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: typeColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: typeColor.withOpacity(0.3)),
                      ),
                      child: Text(
                        typeText,
                        style: TextStyle(
                          fontSize: 10,
                          color: typeColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '${weeks}w ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  void _handleContactTap(Pet pet) {
    if (pet.type == 'BREEDING') {
      _showModernBreedingRequestDialog(pet);
    } else {
      _showModernContactDialog(pet);
    }
  }

  void _showModernBreedingRequestDialog(Pet pet) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 32,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue.shade400, Colors.blue.shade600],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.family_restroom_rounded,
                  color: Colors.white,
                  size: 40,
                ),
              ),
              const SizedBox(height: 20),

              Text(
                'Breeding Request Sent',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: _textColor,
                ),
              ),
              const SizedBox(height: 16),

              Text(
                'Your request for connection to ${pet.user} for ${pet.name} has been successfully sent.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: _hintColor,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade600,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 2,
                  ),
                  child: const Text(
                    'Got It',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showModernContactDialog(Pet pet) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 32,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [_primaryColor.withOpacity(0.9), _primaryColor],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.favorite_rounded,
                  color: Colors.white,
                  size: 40,
                ),
              ),
              const SizedBox(height: 20),

              Text(
                'Contact Owner',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: _textColor,
                ),
              ),
              const SizedBox(height: 16),

              Text(
                'Would you like to contact the owner about ${pet.name}?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: _hintColor,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: _hintColor,
                        side: BorderSide(color: _hintColor.withOpacity(0.3)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Contact request sent for ${pet.name}'),
                            backgroundColor: Colors.green,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _primaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        elevation: 2,
                      ),
                      child: const Text(
                        'Send Request',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showPetDetails(BuildContext context, Pet pet) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PetDetailsScreen(
          pet: pet,
          currentUserName: widget.userName,
        ),
      ),
    );
  }

  Widget? _buildFAB() {
    if (_currentIndex == 0) {
      return FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddPetScreen(userId: widget.userId, userName: widget.userName),
            ),
          ).then((_) => _refreshPets());
        },
        backgroundColor: _primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      );
    } else if (_currentIndex == 1) {
      return FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddPostScreen(userId: widget.userId, userName: widget.userName),
            ),
          );
          if (result == true) setState(() {});
        },
        backgroundColor: _primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      );
    }
    return null;
  }
}