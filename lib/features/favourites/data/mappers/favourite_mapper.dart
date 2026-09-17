import '../../../search/domain/models/book.dart';
import '../dtos/favourite_dto.dart';

extension FavouriteDtoMapper on FavouriteDto {
  Book toBook() => Book(
    key: key,
    title: title,
    authorNames: authors,
    coverId: coverId,
    firstPublishYear: firstPublishYear,
  );
}

extension BookFavouriteMapper on Book {
  FavouriteDto toFavouriteDto() => FavouriteDto(
    key: key,
    title: title,
    authors: authorNames,
    coverId: coverId,
    firstPublishYear: firstPublishYear,
  );
}
