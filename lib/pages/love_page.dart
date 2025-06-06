import 'package:flutter/material.dart';
import 'package:responsiah/database/database_helper.dart';
import 'package:responsiah/services/session_service.dart';
import 'package:responsiah/pages/detail_page.dart';

class LovePage extends StatefulWidget {
  const LovePage({super.key});

  @override
  State<LovePage> createState() => _LovePageState();
}

class _LovePageState extends State<LovePage> {
  final Color primaryColor = const Color(0xFFAEDFF7); // pastel blue
  List<MovieLove> lovedMovies = [];

  @override
  void initState() {
    super.initState();
    _loadLovedMovies();
  }

  void _loadLovedMovies() {
    final userId = SessionService.currentUserId;
    if (userId != null) {
      setState(() {
        lovedMovies = DatabaseHelper.getUserLovedMovies(userId);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryColor.withOpacity(0.1),
      appBar: AppBar(
        title: const Text('Film Favorit'),
        backgroundColor: primaryColor,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: lovedMovies.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.favorite_outline,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Belum ada film favorit',
                    style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Mulai tambahkan film ke favorit!',
                    style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: lovedMovies.length,
              itemBuilder: (context, index) {
                final movie = lovedMovies[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              DetailPage(id: int.parse(movie.movieId)),
                        ),
                      );
                    },
                    child: ListTile(
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          movie.imageUrl.isNotEmpty
                              ? movie.imageUrl
                              : 'https://via.placeholder.com/50x50?text=No+Image',
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: primaryColor.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.movie),
                            );
                          },
                        ),
                      ),
                      title: Text(movie.movieTitle),
                      subtitle: Text(
                        'Ditambahkan: ${_formatDate(movie.createdAt)}',
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.favorite, color: Colors.red),
                        onPressed: () => _removeLove(movie),
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }

  void _removeLove(MovieLove movie) async {
    final userId = SessionService.currentUserId;
    if (userId != null) {
      final success = await DatabaseHelper.removeMovieLove(
        userId,
        movie.movieId,
      );
      if (success) {
        _loadLovedMovies();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Film dihapus dari favorit')),
        );
      }
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
