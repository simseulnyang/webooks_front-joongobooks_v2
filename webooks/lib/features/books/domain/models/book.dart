import 'package:json_annotation/json_annotation.dart';

part 'book.g.dart';

/// 책 모델
@JsonSerializable()
class Book {
  final int id;
  final int writer;
  final String category;
  @JsonKey(name: 'sale_condition')
  final String saleCondition;
  final String title;
  final String author;
  final String publisher;
  final String condition;
  @JsonKey(name: 'original_price')
  final int originalPrice;
  @JsonKey(name: 'selling_price')
  final int sellingPrice;
  @JsonKey(name: 'detail_info')
  final String detailInfo;
  @JsonKey(name: 'book_image')
  final String? bookImage;
  @JsonKey(name: 'created_at')
  final String createdAt;
  @JsonKey(name: 'updated_at')
  final String updatedAt;
  @JsonKey(name: 'like_count')
  final int? likeCount; // nullable로 변경
  @JsonKey(name: 'is_liked')
  final bool? isLiked; // nullable로 변경

  Book({
    required this.id,
    required this.writer,
    required this.category,
    required this.saleCondition,
    required this.title,
    required this.author,
    required this.publisher,
    required this.condition,
    required this.originalPrice,
    required this.sellingPrice,
    required this.detailInfo,
    this.bookImage,
    required this.createdAt,
    required this.updatedAt,
    this.likeCount, // optional로 변경
    this.isLiked, // optional로 변경
  });

  factory Book.fromJson(Map<String, dynamic> json) => _$BookFromJson(json);
  Map<String, dynamic> toJson() => _$BookToJson(this);

  /// 판매 상태를 한글로 반환
  String get saleConditionKorean {
    switch (saleCondition) {
      case 'For Sale':
        return '판매중';
      case 'Reserved':
        return '예약중';
      case 'Sold Out':
        return '판매완료';
      default:
        return saleCondition;
    }
  }

  /// 카테고리를 한글로 반환
  String get categoryKorean {
    switch (category) {
      case 'Social Politic':
        return '사회 정치';
      case 'Literary Fiction':
        return '인문';
      case 'Child':
        return '아동';
      case 'Travel':
        return '여행';
      case 'History':
        return '역사';
      case 'Art':
        return '예술';
      case 'Novel':
        return '소설';
      case 'Poem':
        return '시';
      case 'Science':
        return '과학';
      case 'Fantasy':
        return '판타지';
      case 'Magazine':
        return '잡지';
      default:
        return category;
    }
  }

  @override
  String toString() => 'Book(id: $id, title: $title, price: $sellingPrice)';
}

/// 책 목록용 간단한 모델 (BookListSerializer에 맞춤)
@JsonSerializable()
class BookListItem {
  final int id;
  final String title;
  final String author;
  @JsonKey(name: 'selling_price')
  final int sellingPrice;
  @JsonKey(name: 'book_image')
  final String? bookImage;
  @JsonKey(name: 'sale_condition')
  final String saleCondition;
  @JsonKey(name: 'updated_at')
  final String updatedAt;
  @JsonKey(name: 'like_count')
  final int likeCount;

  BookListItem({
    required this.id,
    required this.title,
    required this.author,
    required this.sellingPrice,
    this.bookImage,
    required this.saleCondition,
    required this.updatedAt,
    required this.likeCount,
  });

  factory BookListItem.fromJson(Map<String, dynamic> json) =>
      _$BookListItemFromJson(json);
  Map<String, dynamic> toJson() => _$BookListItemToJson(this);

  /// 판매 상태를 한글로 반환
  String get saleConditionKorean {
    switch (saleCondition) {
      case 'For Sale':
        return '판매중';
      case 'Reserved':
        return '예약중';
      case 'Sold Out':
        return '판매완료';
      default:
        return saleCondition;
    }
  }
}

/// Pagination 응답 모델
@JsonSerializable(genericArgumentFactories: true)
class PaginatedResponse<T> {
  final int count;
  final String? next;
  final String? previous;
  final List<T> results;

  PaginatedResponse({
    required this.count,
    this.next,
    this.previous,
    required this.results,
  });

  factory PaginatedResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) => _$PaginatedResponseFromJson(json, fromJsonT);

  Map<String, dynamic> toJson(Object Function(T value) toJsonT) =>
      _$PaginatedResponseToJson(this, toJsonT);

  bool get hasNext => next != null;
  bool get hasPrevious => previous != null;
}
