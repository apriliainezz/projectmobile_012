import 'package:responsiah/database/database_helper.dart';
import 'package:responsiah/models/movie_model.dart';
import 'package:responsiah/services/movie_service.dart';
import 'package:responsiah/pages/edit_page.dart';
import 'package:responsiah/pages/rental_page.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:responsiah/services/session_service.dart'; // Import SessionService

class DetailPage extends StatefulWidget {
  final int id;

  const DetailPage({super.key, required this.id});

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  bool _isRented = false;

  @override
  void initState() {
    super.initState();
    _checkRentalStatus();
  }

  @override
  void dispose() {
    // Cancel any pending futures or state updates
    _isRented = false;
    // Always call super.dispose() last
    super.dispose();
  }

  void _checkRentalStatus() {
    final currentUserId = SessionService.currentUserId ?? 'guest';
    final movieIdString = widget.id.toString();

    setState(() {
      _isRented = DatabaseHelper.isMovieRented(currentUserId, movieIdString);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Korean Drama Detail"),
        backgroundColor: const Color(0xFF92C7FF), // pastel biru
        elevation: 3,
        centerTitle: true,
      ),
      body: Padding(padding: const EdgeInsets.all(20), child: _kdramaDetail()),
      backgroundColor: const Color(0xFFF6F7FB), // latar belakang soft
    );
  }

  Widget _kdramaDetail() {
    return FutureBuilder(
      future: KdramaService.getKdramaById(widget.id),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text(
              "Error: ${snapshot.error.toString()}",
              style: const TextStyle(color: Colors.red),
            ),
          );
        } else if (snapshot.hasData) {
          Kdrama kdrama = Kdrama.fromJson(snapshot.data!["data"]);
          return _kdramaWidget(kdrama);
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  Widget _kdramaWidget(Kdrama kdrama) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 6,
      color: Colors.white,
      shadowColor: Colors.blue.shade100,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          shrinkWrap: true,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    kdrama.imgUrl!,
                    height: 180,
                    width: 120,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      height: 180,
                      width: 120,
                      color: Colors.grey.shade300,
                      child: const Icon(Icons.broken_image, size: 50),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _infoText("Title", kdrama.title!),
                      _infoText("Director", kdrama.director!),
                      _infoText("Genre", kdrama.genre!),
                      _infoText("Year", kdrama.year!.toString()),
                      _infoText("Rating", "${kdrama.rating} / 10.0"),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Text(
              "Synopsis",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Color(0xFF5B9CFF), // soft blue
              ),
            ),
            const SizedBox(height: 8),
            Text(
              kdrama.synopsis!,
              style: const TextStyle(fontSize: 16, color: Colors.black87),
              textAlign: TextAlign.justify,
            ),
            const SizedBox(height: 24),

            // Action buttons
            Column(
              children: [
                // Rental button (full width)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isRented
                        ? null // Disable the button if rented
                        : () async {
                            await Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => RentalPage(movie: kdrama),
                              ),
                            );
                            // Refresh rental status when returning from rental page
                            _checkRentalStatus();
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isRented
                          ? Colors.grey // Change color to grey if rented
                          : const Color(0xFF27AE60),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 4,
                      shadowColor: Colors.green.shade200,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.movie, size: 20),
                        SizedBox(width: 8),
                        Text(
                          _isRented
                              ? "Anda Sudah Menyewa"
                              : "Sewa Film - Rp 10.000/6 jam",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Other action buttons
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: () async {
                          final uri = Uri.parse(kdrama.movieUrl!);
                          if (await canLaunchUrl(uri)) {
                            await launchUrl(uri);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF92C7FF),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 4,
                          shadowColor: Colors.blue.shade200,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text(
                          "Visit Website",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: _showEditDialog,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange[400],
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 4,
                        padding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 16,
                        ),
                      ),
                      child: const Icon(Icons.edit),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: _showDeleteDialog,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red[400],
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 4,
                        padding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 16,
                        ),
                      ),
                      child: const Icon(Icons.delete),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoText(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: RichText(
        text: TextSpan(
          text: "$label: ",
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
            color: Color(0xFF5B9CFF), // soft blue
          ),
          children: [
            TextSpan(
              text: value,
              style: const TextStyle(
                fontWeight: FontWeight.normal,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditDialog() {
    // Navigate to edit page instead of showing dialog
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => EditPage(id: widget.id)));
  }

  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Row(
            children: [
              Icon(Icons.warning, color: Colors.red),
              SizedBox(width: 8),
              Text('Hapus Korean Drama'),
            ],
          ),
          content: const Text(
            'Apakah Anda yakin ingin menghapus drama ini?\n\nTindakan ini tidak dapat dibatalkan.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _deleteKdrama();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[400],
                foregroundColor: Colors.white,
              ),
              child: const Text('Hapus'),
            ),
          ],
        );
      },
    );
  }

  void _deleteKdrama() async {
    try {
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const Center(child: CircularProgressIndicator());
        },
      );

      // Call actual delete API
      final response = await KdramaService.deleteKdrama(widget.id);

      // Close loading dialog
      Navigator.of(context).pop();

      // Check if deletion was successful
      if (response["status"] == "Success") {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Korean Drama berhasil dihapus!'),
            backgroundColor: Colors.green,
          ),
        );

        // Go back to previous page (home page)
        Navigator.of(context).pop();
      } else {
        // Handle API error response
        throw Exception(response["message"] ?? "Gagal menghapus drama");
      }
    } catch (e) {
      // Close loading dialog if still open
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }

      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menghapus drama: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
