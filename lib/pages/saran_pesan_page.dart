import 'package:flutter/material.dart';

class SaranPesanPage extends StatelessWidget {
  const SaranPesanPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Saran dan Pesan'),
        backgroundColor: const Color(0xFFAEDFF7),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Profile Card
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                child: Column(
                  children: [
                    Text(
                      'Profile Developer',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.blueGrey[800],
                          ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: Image.asset(
                          'assets/profile.png',
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey[300],
                              child: const Icon(Icons.person, size: 60, color: Colors.grey),
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text('Nama: Rizky Aprilia Ineztri Utomo', style: TextStyle(fontSize: 16)),
                    const Text('NIM: 123220012', style: TextStyle(fontSize: 16)),
                    const SizedBox(height: 16),
                    Text(
                      'Kesan Mata Kuliah Pemrograman Mobile',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.blueGrey[700],
                          ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Berikut adalah beberapa kesan terkait mata kuliah pemrograman mobile:',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Kesan
            _buildSectionCard(
              title: 'Kesan',
              content:
                  '1. Pemrograman aplikasi mobile sangat menantang dan membutuhkan ketelitian.\n'
                  '2. Tugas yang diberikan cukup menantang.',
            ),

            const SizedBox(height: 16),

            // Pesan
            _buildSectionCard(
              title: 'Pesan',
              content:
                  '1. Terima kasih atas bimbingan dan ilmu yang telah diberikan.\n'
                  '2. Semoga Bapak/Ibu dosen selalu diberikan kesehatan dan keberkahan.\n'
                  '3. Sukses selalu untuk karir dan pendidikan Bapak/Ibu dosen.',
            ),

            const SizedBox(height: 16),

            // Rating
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Text(
                      'Rating',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.star, color: Colors.amber),
                        Icon(Icons.star, color: Colors.amber),
                        Icon(Icons.star, color: Colors.amber),
                        Icon(Icons.star, color: Colors.amber),
                        Icon(Icons.star_border, color: Colors.amber),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Custom card builder
  Widget _buildSectionCard({required String title, required String content}) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Text(content, style: const TextStyle(fontSize: 14)),
          ],
        ),
      ),
    );
  }
}
