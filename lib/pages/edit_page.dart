import 'package:responsiah/models/movie_model.dart';
import 'package:responsiah/pages/home_page.dart';
import 'package:responsiah/services/movie_service.dart';
import 'package:flutter/material.dart';

class EditPage extends StatefulWidget {
  final int id;
  const EditPage({super.key, required this.id});

  @override
  State<EditPage> createState() => _EditPageState();
}

class _EditPageState extends State<EditPage> {
  final title = TextEditingController();
  final year = TextEditingController();
  final genre = TextEditingController();
  final director = TextEditingController();
  final rating = TextEditingController();
  final synopsis = TextEditingController();

  bool _isDataLoaded = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEAF6FF), // biru pastel muda
      appBar: AppBar(
        title: const Text("Update Korean Drama"),
        centerTitle: true,
        backgroundColor: const Color(0xFF90CAF9), // biru pastel soft
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: _dataContainerWidget(),
      ),
    );
  }

  Widget _dataContainerWidget() {
    return FutureBuilder(
      future: KdramaService.getKdramaById(widget.id),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text("Error: ${snapshot.error.toString()}");
        } else if (snapshot.hasData) {
          if (!_isDataLoaded) {
            _isDataLoaded = true;

            Kdrama kdrama = Kdrama.fromJson(snapshot.data!["data"]);
            title.text = kdrama.title!;
            year.text = kdrama.year!.toString();
            genre.text = kdrama.genre!;
            director.text = kdrama.director!;
            rating.text = kdrama.rating!.toString();
            synopsis.text = kdrama.synopsis!;
          }

          return _editFormWidget(context);
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  Widget _editFormWidget(BuildContext context) {
  return Center(
    child: SingleChildScrollView( // <-- ini tambahan
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        elevation: 6,
        color: const Color(0xFFF6F7FB),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
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
                child: ElevatedButton(
                  onPressed: () => _update(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF92C7FF), // pastel blue
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "Update Korean Drama",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

  Widget _textField(TextEditingController controller, String label,
    {TextInputType inputType = TextInputType.text, int maxLines = 1}) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: TextFormField(
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
        fillColor: Color(0xFFEAF4FF), // pastel biru sangat terang
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Color(0xFFB3D1FF)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Color(0xFFB3D1FF)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Color(0xFF5B9CFF), width: 2),
        ),
      ),
    ),
  );
}

  Future<void> _update(BuildContext context) async {
    try {
      int? yearInt = int.tryParse(year.text.trim());
      double? ratingDouble = double.tryParse(rating.text.trim());

      if (yearInt == null || ratingDouble == null) {
        throw Exception("Input tidak valid.");
      }

      Kdrama updatedData = Kdrama(
        id: widget.id,
        title: title.text.trim(),
        genre: genre.text.trim(),
        director: director.text.trim(),
        synopsis: synopsis.text.trim(),
        rating: ratingDouble,
        year: yearInt,
      );

      final response = await KdramaService.updateKdrama(updatedData);

      if (response["status"] == "Success") {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Korean Drama Updated Successfully")),
        );

        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const HomePage()),
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
