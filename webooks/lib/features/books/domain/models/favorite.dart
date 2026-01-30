import 'package:json_annotation/json_annotation.dart';
import 'book.dart';

part 'favorite.g.dart';

@JsonSerializable()
class Favorite {
  final int id;

  @JsonKey(name: 'created_at')
  final String createdAt;

  final BookListItem book;

  Favorite({required this.id, required this.createdAt, required this.book});

  factory Favorite.fromJson(Map<String, dynamic> json) =>
      _$FavoriteFromJson(json);

  Map<String, dynamic> toJson() => _$FavoriteToJson(this);
}

@JsonSerializable(genericArgumentFactories: true)
class FavoritePaginatedResponse<T> {
  final int count;
  final String? next;
  final String? previous;
  final List<T> results;

  FavoritePaginatedResponse({
    required this.count,
    this.next,
    this.previous,
    required this.results,
  });

  factory FavoritePaginatedResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) => _$FavoritePaginatedResponseFromJson(json, fromJsonT);

  Map<String, dynamic> toJson(Object Function(T value) toJsonT) =>
      _$FavoritePaginatedResponseToJson(this, toJsonT);

  bool get hasNext => next != null;
  bool get hasPrevious => next != null;
}
