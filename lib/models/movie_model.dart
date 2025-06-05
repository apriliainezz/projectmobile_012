class KdramaModel {
  String? status;
  String? message;
  List<Kdrama>? data;

  KdramaModel({this.status, this.message, this.data});

  KdramaModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    if (json['data'] != null) {
      data = <Kdrama>[];
      json['data'].forEach((v) {
        data!.add(new Kdrama.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['message'] = this.message;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Kdrama {
  int? id;
  String? title;
  int? year;
  String? genre;
  String? director;
  double? rating;
  String? synopsis;
  String? imgUrl;
  String? movieUrl;

  Kdrama({
    this.id,
    this.title,
    this.year,
    this.genre,
    this.director,
    this.rating,
    this.synopsis,
    this.imgUrl,
    this.movieUrl,
  });

  Kdrama.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    year = json['year'];
    genre = json['genre'];
    director = json['director'];
    rating = json['rating'].toDouble();
    synopsis = json['synopsis'];
    imgUrl = json['imgUrl'];
    movieUrl = json['movieUrl'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['title'] = this.title;
    data['year'] = this.year;
    data['genre'] = this.genre;
    data['director'] = this.director;
    data['rating'] = this.rating;
    data['synopsis'] = this.synopsis;
    data['imgUrl'] = this.imgUrl;
    data['movieUrl'] = this.movieUrl;
    return data;
  }
}