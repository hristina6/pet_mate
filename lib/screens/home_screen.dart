import 'package:flutter/material.dart';
import '../models/pet.dart';
import '../services/pet_service.dart';
import 'posts_screen.dart' as posts_screen;
import 'pets_screen.dart' as pets_screen;
import 'notifications_screen.dart';
import 'profile_screen.dart';
import 'add_pet_screen.dart';
import 'add_post_screen.dart';

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
  bool _isLoading = false;

  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _petsFuture = _petService.getPets();
  }

  List<Widget> get _screens => [
    _buildHomeContent(),
    posts_screen.PostsScreen(),
    const NotificationsScreen(), // само мок ап, без аргументи
    ProfileScreen(userName: widget.userName, userId: widget.userId),
  ];

  Future<void> _refreshPets() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final pets = await _petService.getPets();
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
        title: _currentIndex == 0
            ? Text('Welcome, ${widget.userName}')
            : const Text('PetMate'),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (String value) {
              _handleMenuSelection(value, context);
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem<String>(
                value: 'all_pets',
                child: ListTile(
                  leading: Icon(Icons.pets),
                  title: Text('All Pets'),
                ),
              ),
              const PopupMenuItem<String>(
                value: 'my_pets',
                child: ListTile(
                  leading: Icon(Icons.person),
                  title: Text('My Pets'),
                ),
              ),
              const PopupMenuItem<String>(
                value: 'my_profile',
                child: ListTile(
                  leading: Icon(Icons.person),
                  title: Text('My Profile'),
                ),
              ),
            ],
          ),
          if (_currentIndex == 0)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _refreshPets,
            ),
        ],
      ),
      body: _screens[_currentIndex],
      floatingActionButton: _buildFAB(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.orange[700],
        unselectedItemColor: Colors.grey[600],
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.pets),
            label: 'Pets',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.article),
            label: 'Posts',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: 'Notifications',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
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
              builder: (context) => AddPetScreen(
                userId: widget.userId,
                userName: widget.userName,
              ),
            ),
          ).then((_) => _refreshPets());
        },
        backgroundColor: Colors.orange[700],
        child: const Icon(Icons.add, color: Colors.white),
      );
    } else if (_currentIndex == 1) {
      return FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddPostScreen(
                userId: widget.userId,
                userName: widget.userName,
              ),
            ),
          );
          if (result == true) {
            setState(() {});
          }
        },
        backgroundColor: Colors.orange[700],
        child: const Icon(Icons.add, color: Colors.white),
      );
    }
    return null;
  }

  void _handleMenuSelection(String value, BuildContext context) {
    switch (value) {
      case 'all_pets':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const pets_screen.PetsScreen()),
        );
        break;
      case 'my_pets':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => pets_screen.PetsScreen(
              filterUserId: widget.userId,
            ),
          ),
        );
        break;
      case 'my_profile':
        setState(() {
          _currentIndex = 3;
        });
        break;
    }
  }

  Widget _buildHomeContent() {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'Recent Pets',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
          child: _buildRecentPetsList(),
        ),
      ],
    );
  }

  Widget _buildRecentPetsList() {
    return FutureBuilder<List<Pet>>(
      future: _petsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No pets found'));
        } else {
          final recentPets = snapshot.data!;
          return ListView.builder(
            itemCount: recentPets.length,
            itemBuilder: (context, index) {
              final pet = recentPets[index];
              return _buildPetCard(pet);
            },
          );
        }
      },
    );
  }

  Widget _buildPetCard(Pet pet) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      elevation: 4.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12.0)),
            child: Image.network(
              pet.imageUrl,
              width: double.infinity,
              height: 200,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                height: 200,
                color: Colors.grey[200],
                child: const Icon(Icons.pets, size: 100, color: Colors.grey),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  pet.name,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text('Breed: ${pet.breed}'),
                Text('Age: ${pet.age} years'),
                Text('Gender: ${pet.gender}'),
                Text('Type: ${pet.type}'),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Owner: ${pet.user}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                    CircleAvatar(
                      child: Text(pet.user[0]),
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
}
