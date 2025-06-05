import 'package:responsiah/models/movie_model.dart';
import 'package:responsiah/services/movie_service.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class DetailPage extends StatelessWidget {
  final int id;

  const DetailPage({super.key, required this.id});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Korean Drama Detail"),
        backgroundColor: const Color(0xFF92C7FF), // pastel biru
        elevation: 3,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: _kdramaDetail(),
      ),
      backgroundColor: const Color(0xFFF6F7FB), // latar belakang soft
    );
  }

  Widget _kdramaDetail() {
    return FutureBuilder(
      future: KdramaService.getKdramaById(id),
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
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () async {
                  final uri = Uri.parse(kdrama.movieUrl!);
                  if (await canLaunchUrl(uri)) {
                    await launchUrl(uri);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF92C7FF), // pastel blue
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 4,
                  shadowColor: Colors.blue.shade200,
                ),
                child: const Text(
                  "Korean Drama Website",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            )
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
}
