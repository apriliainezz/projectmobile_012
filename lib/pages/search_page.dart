import 'package:flutter/material.dart';
import 'package:responsiah/models/movie_model.dart';
import 'package:responsiah/services/movie_service.dart';
import 'package:responsiah/pages/detail_page.dart'; // For navigation to detail

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  final Color primaryColor = const Color(0xFFAEDFF7); // pastel blue

  List<Kdrama> _allMovies = [];
  List<Kdrama> _filteredMovies = [];
  bool _isLoading = true;
  String? _selectedYear;
  String? _selectedRating;

  // Define available years and ratings for dropdowns
  // These could be dynamically generated if needed
  final List<String> _availableYears = [
    'All',
    '2023',
    '2022',
    '2021',
    '2020',
    '2019',
    '2018',
  ];
  final List<String> _availableRatings = ['All', '9+', '8+', '7+', '6+', '5+'];

  @override
  void initState() {
    super.initState();
    _fetchMovies();
    _searchController.addListener(_applyFiltersAndSearch);
  }

  Future<void> _fetchMovies() async {
    if (!mounted) return; // Check if widget is still mounted

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await KdramaService.getKdrama();

      // Check if widget is still mounted before calling setState
      if (!mounted) return;

      if (response['data'] != null) {
        final kdramaModel = KdramaModel.fromJson(response);
        setState(() {
          _allMovies = kdramaModel.data ?? [];
          _filteredMovies = List.from(_allMovies); // Initially show all movies
          _isLoading = false;
        });
      } else {
        setState(() {
          _allMovies = [];
          _filteredMovies = [];
          _isLoading = false;
        });
        // Handle error or empty data case
        if (mounted) {
          // Check mounted before showing SnackBar
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(response['message'] ?? 'Gagal memuat film')),
          );
        }
      }
    } catch (e) {
      // Check if widget is still mounted before calling setState
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        // Check mounted before showing SnackBar
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error fetching movies: $e')));
      }
    }
  }

  void _applyFiltersAndSearch() {
    if (!mounted) return; // Check if widget is still mounted

    String query = _searchController.text.toLowerCase();
    List<Kdrama> tempFilteredMovies = List.from(_allMovies);

    // Apply search query
    if (query.isNotEmpty) {
      tempFilteredMovies =
          tempFilteredMovies.where((movie) {
            return movie.title?.toLowerCase().contains(query) ?? false;
          }).toList();
    }

    // Apply year filter
    if (_selectedYear != null && _selectedYear != 'All') {
      int year = int.parse(_selectedYear!);
      tempFilteredMovies =
          tempFilteredMovies.where((movie) {
            return movie.year == year;
          }).toList();
    }

    // Apply rating filter
    if (_selectedRating != null && _selectedRating != 'All') {
      double minRating = double.parse(_selectedRating!.replaceAll('+', ''));
      tempFilteredMovies =
          tempFilteredMovies.where((movie) {
            return (movie.rating ?? 0) >= minRating;
          }).toList();
    }

    setState(() {
      _filteredMovies = tempFilteredMovies;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryColor.withOpacity(0.1),
      appBar: AppBar(
        title: const Text('Cari Film'),
        backgroundColor: primaryColor,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Search bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Cari berdasarkan judul film...',
                  border: InputBorder.none,
                  icon: const Icon(Icons.search),
                  suffixIcon: ClearButton(
                    controller: _searchController,
                  ), // Added clear button
                ),
                // onChanged handled by listener
              ),
            ),
            const SizedBox(height: 16),

            // Filter dropdowns
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: DropdownButton<String>(
                      value: _selectedYear,
                      hint: const Text('Filter Tahun'),
                      isExpanded: true,
                      underline: const SizedBox(),
                      items:
                          _availableYears
                              .map(
                                (year) => DropdownMenuItem(
                                  value: year,
                                  child: Text(year),
                                ),
                              )
                              .toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedYear = value;
                          _applyFiltersAndSearch();
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: DropdownButton<String>(
                      value: _selectedRating,
                      hint: const Text('Filter Rating'),
                      isExpanded: true,
                      underline: const SizedBox(),
                      items:
                          _availableRatings
                              .map(
                                (rating) => DropdownMenuItem(
                                  value: rating,
                                  child: Text(rating),
                                ),
                              )
                              .toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedRating = value;
                          _applyFiltersAndSearch();
                        });
                      },
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Search results
            Expanded(
              child:
                  _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _filteredMovies.isEmpty
                      ? Center(
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
                              'Tidak ada film yang cocok.',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      )
                      : ListView.builder(
                        itemCount: _filteredMovies.length,
                        itemBuilder: (context, index) {
                          final movie = _filteredMovies[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ListTile(
                              leading: ClipRRect(
                                borderRadius: BorderRadius.circular(8.0),
                                child: Image.network(
                                  movie.imgUrl ?? '',
                                  width: 50,
                                  height: 70,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      width: 50,
                                      height: 70,
                                      color: Colors.grey[300],
                                      child: const Icon(
                                        Icons.movie_creation_outlined,
                                        color: Colors.grey,
                                      ),
                                    );
                                  },
                                ),
                              ),
                              title: Text(movie.title ?? 'No Title'),
                              subtitle: Text(
                                'Tahun: ${movie.year ?? 'N/A'} - Rating: ${movie.rating?.toStringAsFixed(1) ?? 'N/A'}',
                              ),
                              trailing: const Icon(
                                Icons.arrow_forward_ios,
                                size: 16,
                              ),
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => DetailPage(id: movie.id!),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.removeListener(_applyFiltersAndSearch);
    _searchController.dispose();
    super.dispose();
  }
}

// Helper widget for clear button in TextField
class ClearButton extends StatelessWidget {
  final TextEditingController controller;

  const ClearButton({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: controller,
      builder: (context, value, child) {
        if (value.text.isEmpty) {
          return const SizedBox.shrink();
        }
        return IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () => controller.clear(),
        );
      },
    );
  }
}
