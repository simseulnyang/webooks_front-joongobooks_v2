// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'book.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Book _$BookFromJson(Map<String, dynamic> json) => Book(
  id: (json['id'] as num).toInt(),
  writer: (json['writer'] as num).toInt(),
  category: json['category'] as String,
  saleCondition: json['sale_condition'] as String,
  title: json['title'] as String,
  author: json['author'] as String,
  publisher: json['publisher'] as String,
  condition: json['condition'] as String,
  originalPrice: (json['original_price'] as num).toInt(),
  sellingPrice: (json['selling_price'] as num).toInt(),
  detailInfo: json['detail_info'] as String,
  bookImage: json['book_image'] as String?,
  createdAt: json['created_at'] as String,
  updatedAt: json['updated_at'] as String,
  likeCount: (json['like_count'] as num?)?.toInt(),
  isLiked: json['is_liked'] as bool?,
);

Map<String, dynamic> _$BookToJson(Book instance) => <String, dynamic>{
  'id': instance.id,
  'writer': instance.writer,
  'category': instance.category,
  'sale_condition': instance.saleCondition,
  'title': instance.title,
  'author': instance.author,
  'publisher': instance.publisher,
  'condition': instance.condition,
  'original_price': instance.originalPrice,
  'selling_price': instance.sellingPrice,
  'detail_info': instance.detailInfo,
  'book_image': instance.bookImage,
  'created_at': instance.createdAt,
  'updated_at': instance.updatedAt,
  'like_count': instance.likeCount,
  'is_liked': instance.isLiked,
};

BookListItem _$BookListItemFromJson(Map<String, dynamic> json) => BookListItem(
  id: (json['id'] as num).toInt(),
  title: json['title'] as String,
  author: json['author'] as String,
  sellingPrice: (json['selling_price'] as num).toInt(),
  bookImage: json['book_image'] as String?,
  saleCondition: json['sale_condition'] as String,
  updatedAt: json['updated_at'] as String,
  likeCount: (json['like_count'] as num).toInt(),
);

Map<String, dynamic> _$BookListItemToJson(BookListItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'author': instance.author,
      'selling_price': instance.sellingPrice,
      'book_image': instance.bookImage,
      'sale_condition': instance.saleCondition,
      'updated_at': instance.updatedAt,
      'like_count': instance.likeCount,
    };

PaginatedResponse<T> _$PaginatedResponseFromJson<T>(
  Map<String, dynamic> json,
  T Function(Object? json) fromJsonT,
) => PaginatedResponse<T>(
  count: (json['count'] as num).toInt(),
  next: json['next'] as String?,
  previous: json['previous'] as String?,
  results: (json['results'] as List<dynamic>).map(fromJsonT).toList(),
);

Map<String, dynamic> _$PaginatedResponseToJson<T>(
  PaginatedResponse<T> instance,
  Object? Function(T value) toJsonT,
) => <String, dynamic>{
  'count': instance.count,
  'next': instance.next,
  'previous': instance.previous,
  'results': instance.results.map(toJsonT).toList(),
};
