// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database_helper.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserAdapter extends TypeAdapter<User> {
  @override
  final int typeId = 0;

  @override
  User read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return User(
      id: fields[0] as String,
      username: fields[1] as String,
      hashedPassword: fields[2] as String,
      createdAt: fields[3] as DateTime,
      fullName: fields[5] as String,
      profileImagePath: fields[4] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, User obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.username)
      ..writeByte(2)
      ..write(obj.hashedPassword)
      ..writeByte(3)
      ..write(obj.createdAt)
      ..writeByte(4)
      ..write(obj.profileImagePath)
      ..writeByte(5)
      ..write(obj.fullName);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class MovieLoveAdapter extends TypeAdapter<MovieLove> {
  @override
  final int typeId = 1;

  @override
  MovieLove read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MovieLove(
      id: fields[0] as String,
      userId: fields[1] as String,
      movieId: fields[2] as String,
      movieTitle: fields[3] as String,
      createdAt: fields[4] as DateTime,
      imageUrl: fields[5] as String,
    );
  }

  @override
  void write(BinaryWriter writer, MovieLove obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.userId)
      ..writeByte(2)
      ..write(obj.movieId)
      ..writeByte(3)
      ..write(obj.movieTitle)
      ..writeByte(4)
      ..write(obj.createdAt)
      ..writeByte(5)
      ..write(obj.imageUrl);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MovieLoveAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class MovieRentalAdapter extends TypeAdapter<MovieRental> {
  @override
  final int typeId = 2;

  @override
  MovieRental read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MovieRental(
      id: fields[0] as String,
      movieId: fields[1] as String,
      userId: fields[2] as String,
      statusPembelian: fields[3] as String,
      harga: fields[4] as double,
      rentalDate: fields[5] as DateTime,
      expiryDate: fields[6] as DateTime,
      imageUrl: fields[7] as String,
      title: fields[8] as String,
      synopsis: fields[9] as String,
      genre: fields[10] as String,
      currency: fields[11] as String,
      paymentTime: fields[12] as String,
    );
  }

  @override
  void write(BinaryWriter writer, MovieRental obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.movieId)
      ..writeByte(2)
      ..write(obj.userId)
      ..writeByte(3)
      ..write(obj.statusPembelian)
      ..writeByte(4)
      ..write(obj.harga)
      ..writeByte(5)
      ..write(obj.rentalDate)
      ..writeByte(6)
      ..write(obj.expiryDate)
      ..writeByte(7)
      ..write(obj.imageUrl)
      ..writeByte(8)
      ..write(obj.title)
      ..writeByte(9)
      ..write(obj.synopsis)
      ..writeByte(10)
      ..write(obj.genre)
      ..writeByte(11)
      ..write(obj.currency)
      ..writeByte(12)
      ..write(obj.paymentTime);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MovieRentalAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
