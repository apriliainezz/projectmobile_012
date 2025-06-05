import 'package:responsiah/models/movie_model.dart';
import 'package:responsiah/pages/home_page.dart';
import 'package:responsiah/services/movie_service.dart';
import 'package:flutter/material.dart';

class CreatePage extends StatefulWidget {
  const CreatePage({super.key});

  @override
  State<CreatePage> createState() => _CreatePageState();
}

class _CreatePageState extends State<CreatePage> {
  final title = TextEditingController();
  final year = TextEditingController();
  final genre = TextEditingController();
  final director = TextEditingController();
  final rating = TextEditingController();
  final synopsis = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add New Movie"),
        backgroundColor: const Color(0xFF92C7FF), // pastel biru
        elevation: 3,
        centerTitle: true,
      ),
      backgroundColor: const Color(0xFFF6F7FB),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            _textField(title, "Title"),
            _textField(year, "Year", inputType: TextInputType.number),
            _textField(genre, "Genre"),
            _textField(director, "Director"),
            _textField(rating, "Rating", inputType: TextInputType.number),
            _textField(synopsis, "Synopsis", maxLines: 3),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  _create(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF92C7FF),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 4,
                  shadowColor: Colors.blue.shade200,
                ),
                child: const Text(
                  "Submit New Korean Drama",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _textField(TextEditingController controller, String label,
      {TextInputType inputType = TextInputType.text, int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        keyboardType: inputType,
        maxLines: maxLines,
        style: const TextStyle(fontSize: 16, color: Colors.black87),
        decoration: InputDecoration(
          labelText: label,
          floatingLabelBehavior: FloatingLabelBehavior.auto,
          labelStyle: const TextStyle(
            fontSize: 14,
            color: Color(0xFF5B9CFF), // soft blue
          ),
          filled: true,
          fillColor: const Color(0xFFEAF4FF), // pastel biru sangat terang
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFB3D1FF)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFB3D1FF)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFF5B9CFF), width: 2),
          ),
        ),
      ),
    );
  }

  Future<void> _create(BuildContext context) async {
    try {
      int? yearInt = int.tryParse(year.text.trim());
      double? ratingDouble = double.tryParse(rating.text.trim());

      if (yearInt == null || ratingDouble == null) {
        throw Exception("Input tidak valid.");
      }

      Kdrama newKdrama = Kdrama(
        title: title.text.trim(),
        genre: genre.text.trim(),
        director: director.text.trim(),
        synopsis: synopsis.text.trim(),
        rating: ratingDouble,
        year: yearInt,
      );

      final response = await KdramaService.addKdrama(newKdrama);

      if (response["status"] == "Success") {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("New Korean Drama Added")),
        );

        Navigator.pop(context);
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (BuildContext context) => const HomePage(),
          ),
        );
      } else {
        throw Exception(response["message"]);
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal: $error")),
      );
    }
  }
}
