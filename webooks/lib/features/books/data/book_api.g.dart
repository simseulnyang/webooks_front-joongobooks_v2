// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'book_api.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(bookApi)
final bookApiProvider = BookApiProvider._();

final class BookApiProvider
    extends $FunctionalProvider<BookApi, BookApi, BookApi>
    with $Provider<BookApi> {
  BookApiProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'bookApiProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$bookApiHash();

  @$internal
  @override
  $ProviderElement<BookApi> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  BookApi create(Ref ref) {
    return bookApi(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(BookApi value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<BookApi>(value),
    );
  }
}

String _$bookApiHash() => r'ba40c6fb7610275a23cc7df81dea9da544817db9';
