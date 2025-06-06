import 'package:flutter/material.dart';

class SaranPesanPage extends StatelessWidget {
  const SaranPesanPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Saran dan Pesan'),
        backgroundColor: const Color(0xFFAEDFF7),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Profile Image Header
              Center(
                child: Container(
                  margin: const EdgeInsets.only(bottom: 24.0),
                  child: Column(
                    children: [
                      Text(
                        'Profile Developer',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.blueGrey[700],
                            ),
                      ),
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.3),
                              spreadRadius: 2,
                              blurRadius: 8,
                              offset: const Offset(0, 3),
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
                                child: const Icon(
                                  Icons.person,
                                  size: 60,
                                  color: Colors.grey,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Nama: Rizky Aprilia Ineztri Utomo',
                        style: TextStyle(fontSize: 16),
                      ),
                      const Text(
                        'NIM: 123220012',
                        style: TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Kesan Pengembangan Aplikasi Mobile',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.blueGrey[700],
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Berikut adalah beberapa kesan terkait pengembangan aplikasi mobile',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey[600],
                            ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Kesan:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                  '1. Pengembangan aplikasi mobile sangat menantang dan membutuhkan ketelitian.\n'
                  '2. Tugas yang diberikan cukup menantang.'),
              const SizedBox(height: 20),
              const Text(
                'Pesan:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                '1. Terima kasih atas bimbingan dan ilmu yang telah diberikan.\n'
                '2. Semoga Bapak/Ibu dosen selalu diberikan kesehatan dan keberkahan.\n'
                '3. Sukses selalu untuk karir dan pendidikan Bapak/Ibu dosen.',
              ),
              const SizedBox(height: 20),
              const Text(
                'Rating:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
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
    );
  }
}
