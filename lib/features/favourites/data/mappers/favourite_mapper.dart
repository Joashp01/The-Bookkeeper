import '../../../search/domain/models/book.dart';
import '../dtos/favourite_dto.dart';

/// Maps between the persisted [FavouriteDto] and the [Book] domain model, so a
/// favourited book round-trips through storage without the UI seeing the DTO.
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
