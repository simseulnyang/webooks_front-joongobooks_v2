// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'book_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 책 목록 Provider

@ProviderFor(BookList)
final bookListProvider = BookListProvider._();

/// 책 목록 Provider
final class BookListProvider
    extends $NotifierProvider<BookList, BookListState> {
  /// 책 목록 Provider
  BookListProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'bookListProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$bookListHash();

  @$internal
  @override
  BookList create() => BookList();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(BookListState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<BookListState>(value),
    );
  }
}

String _$bookListHash() => r'69522b37a1d188776c5def43a687cd3527ccf219';

/// 책 목록 Provider

abstract class _$BookList extends $Notifier<BookListState> {
  BookListState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<BookListState, BookListState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<BookListState, BookListState>,
              BookListState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

/// 책 상세 Provider

@ProviderFor(BookDetail)
final bookDetailProvider = BookDetailFamily._();

/// 책 상세 Provider
final class BookDetailProvider
    extends $NotifierProvider<BookDetail, BookDetailState> {
  /// 책 상세 Provider
  BookDetailProvider._({
    required BookDetailFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'bookDetailProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$bookDetailHash();

  @override
  String toString() {
    return r'bookDetailProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  BookDetail create() => BookDetail();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(BookDetailState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<BookDetailState>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is BookDetailProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$bookDetailHash() => r'aa5c8261091152bcc986fba304bf020a9af35b59';

/// 책 상세 Provider

final class BookDetailFamily extends $Family
    with
        $ClassFamilyOverride<
          BookDetail,
          BookDetailState,
          BookDetailState,
          BookDetailState,
          int
        > {
  BookDetailFamily._()
    : super(
        retry: null,
        name: r'bookDetailProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// 책 상세 Provider

  BookDetailProvider call(int bookId) =>
      BookDetailProvider._(argument: bookId, from: this);

  @override
  String toString() => r'bookDetailProvider';
}

/// 책 상세 Provider

abstract class _$BookDetail extends $Notifier<BookDetailState> {
  late final _$args = ref.$arg as int;
  int get bookId => _$args;

  BookDetailState build(int bookId);
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<BookDetailState, BookDetailState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<BookDetailState, BookDetailState>,
              BookDetailState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(_$args));
  }
}

/// 좋아요한 책 목록 Provider

@ProviderFor(FavoriteBookList)
final favoriteBookListProvider = FavoriteBookListProvider._();

/// 좋아요한 책 목록 Provider
final class FavoriteBookListProvider
    extends $NotifierProvider<FavoriteBookList, FavoriteState> {
  /// 좋아요한 책 목록 Provider
  FavoriteBookListProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'favoriteBookListProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$favoriteBookListHash();

  @$internal
  @override
  FavoriteBookList create() => FavoriteBookList();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FavoriteState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FavoriteState>(value),
    );
  }
}

String _$favoriteBookListHash() => r'da9d1a24cadf8bebe87c426afb03428eee3782e1';

/// 좋아요한 책 목록 Provider

abstract class _$FavoriteBookList extends $Notifier<FavoriteState> {
  FavoriteState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<FavoriteState, FavoriteState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<FavoriteState, FavoriteState>,
              FavoriteState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
