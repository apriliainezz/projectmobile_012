import 'package:flutter/material.dart';
import 'package:responsiah/models/movie_model.dart';
import 'package:responsiah/pages/create_page.dart';
import 'package:responsiah/pages/detail_page.dart';
import 'package:responsiah/pages/rental_page.dart';
import 'package:responsiah/services/movie_service.dart';
import 'package:responsiah/services/session_service.dart';
import 'package:responsiah/database/database_helper.dart'; // Import DatabaseHelper

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _isReloading = false;

  final Color primaryColor = const Color(0xFFAEDFF7); // pastel blue

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final fullName = SessionService.currentFullName ?? 'Pengguna';

    return Scaffold(
      key: const PageStorageKey<String>('HomePage'), // Add PageStorageKey
      backgroundColor: primaryColor.withOpacity(0.2),
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: Text("Halo, $fullName"),
        automaticallyImplyLeading: false, // Remove back button
        actions: [
          IconButton(
            onPressed: _isReloading ? null : _reloadData,
            icon: _isReloading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Icon(Icons.refresh),
            tooltip: 'Reload',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: _kdramaContainer(),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.lightBlueAccent,
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.of(context)
              .push(MaterialPageRoute(builder: (_) => const CreatePage()))
              .then((_) {
            // Refresh data when returning from CreatePage
            setState(() {});
          });
        },
      ),
    );
  }

  void _reloadData() async {
    setState(() {
      _isReloading = true;
    });

    // Add a small delay to show the loading indicator
    await Future.delayed(const Duration(milliseconds: 500));

    if (!mounted) return; // Add this check

    setState(() {
      _isReloading = false;
    });

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Data berhasil dimuat ulang!'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  Widget _kdramaContainer() {
    return FutureBuilder(
      future: KdramaService.getKdrama(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text("Error: ${snapshot.error.toString()}");
        } else if (snapshot.hasData) {
          KdramaModel response = KdramaModel.fromJson(snapshot.data!);
          // Sort movies by ID in descending order (highest to lowest)
          List<Kdrama> sortedMovies = response.data!
            ..sort((a, b) => (b.id ?? 0).compareTo(a.id ?? 0));
          return _kdramaGrid(context, sortedMovies);
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  Widget _kdramaGrid(BuildContext context, List<Kdrama> kdrama) {
    return GridView.builder(
      itemCount: kdrama.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.65, // Increased height to prevent overflow
      ),
      itemBuilder: (context, index) {
        final kdramaItem = kdrama[index];
        final String currentUserId = SessionService.currentUserId ?? "";
        // Ensure kdramaItem.id is not null before converting to string
        final String movieIdString = kdramaItem.id?.toString() ?? "";

        bool isLoved = false;
        if (currentUserId.isNotEmpty && movieIdString.isNotEmpty) {
          isLoved = DatabaseHelper.isMovieLoved(currentUserId, movieIdString);
        }

        return InkWell(
          onTap: () {
            Navigator.of(context)
                .push(
              MaterialPageRoute(
                builder: (_) => DetailPage(id: kdramaItem.id!),
              ),
            )
                .then((_) {
              // Refresh data when returning from DetailPage in case of changes
              setState(() {});
            });
          },
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.blueGrey.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                  child: Image.network(
                    kdramaItem.imgUrl ?? '',
                    height: 140,
                    fit: BoxFit.cover,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        kdramaItem.title ?? '',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text("${kdramaItem.year ?? ''}"),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 16),
                          const SizedBox(width: 4),
                          Text("${kdramaItem.rating ?? '-'}"),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              icon: Icon(
                                isLoved
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                size: 18,
                                color:
                                    isLoved ? Colors.white : Colors.pinkAccent,
                              ),
                              label: Text(
                                "Suka",
                                style: TextStyle(
                                  color: isLoved
                                      ? Colors.white
                                      : Colors.pinkAccent,
                                ),
                              ),
                              onPressed: () {
                                if (kdramaItem.id != null) {
                                  _handleSuka(kdramaItem); // Pass kdramaItem
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    isLoved ? Colors.pinkAccent : Colors.white,
                                side: isLoved
                                    ? const BorderSide(
                                        color: Colors.pinkAccent,
                                      )
                                    : null,
                                foregroundColor:
                                    Colors.white, // Default text color
                                padding: const EdgeInsets.symmetric(
                                  vertical: 6,
                                ),
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
          ),
        );
      },
    );
  }

  void _handleSewa(Kdrama movie) async {
    final userId = SessionService.currentUserId;
    if (userId == null || userId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Harap login untuk menyewa film.")),
      );
      return;
    }

    // Navigate to rental page
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => RentalPage(movie: movie)))
        .then((_) {
      // Refresh data when returning from rental page
      setState(() {});
    });
  }

  void _handleSuka(Kdrama kdramaItem) async {
    // Accept kdramaItem
    final userId = SessionService.currentUserId;
    final movieId = kdramaItem.id?.toString() ?? "";
    if (userId == null || userId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Harap login untuk menyukai film.")),
      );
      return;
    }

    bool isCurrentlyLoved = DatabaseHelper.isMovieLoved(userId, movieId);
    bool success;

    if (isCurrentlyLoved) {
      success = await DatabaseHelper.removeMovieLove(userId, movieId);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Film ID: $movieId dihapus dari favorit.")),
        );
      }
    } else {
      // Pass the movie title and image URL to addMovieLove
      success = await DatabaseHelper.addMovieLove(
        userId,
        movieId,
        kdramaItem.title ?? 'Unknown Title',
        kdramaItem.imgUrl ?? '',
      );
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Film ID: $movieId ditambahkan ke favorit.")),
        );
      }
    }

    if (success) {
      setState(() {
        // This will trigger a rebuild of the grid, updating the button's appearance
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Gagal memperbarui status suka.")),
      );
    }
  }
}
