enum SortAuthorBooksBy {
  alphabet,
  sequence,
  date,
  popularity,
  genre,
}

String sortAuthorBooksByToString(SortAuthorBooksBy sortBooksBy) {
  switch (sortBooksBy) {
    case SortAuthorBooksBy.alphabet:
      return 'Алфавиту';
    case SortAuthorBooksBy.date:
      return 'Дате поступления';
    case SortAuthorBooksBy.genre:
      return 'Жанрам';
    case SortAuthorBooksBy.popularity:
      return 'Популярности';
    case SortAuthorBooksBy.sequence:
      return 'SortAuthorBooksBy';
    default:
      return 'Неизвестное значение';
  }
}

String sortAuthorBooksByToQueryParam(SortAuthorBooksBy sortBooksBy) {
  switch (sortBooksBy) {
    case SortAuthorBooksBy.alphabet:
      return 'a';
    case SortAuthorBooksBy.date:
      return 't';
    case SortAuthorBooksBy.genre:
      return 'g';
    case SortAuthorBooksBy.popularity:
      return 'p';
    case SortAuthorBooksBy.sequence:
      return 'b';
    default:
      return 't';
  }
}

enum SortGenreBooksBy {
  alphabet,
  authors,
  date,
  popularity,
}

String sortGenreBooksByToString(SortGenreBooksBy sortBooksBy) {
  switch (sortBooksBy) {
    case SortGenreBooksBy.alphabet:
      return 'Алфавиту';
    case SortGenreBooksBy.date:
      return 'Дате поступления';
    case SortGenreBooksBy.authors:
      return 'Авторам';
    case SortGenreBooksBy.popularity:
      return 'Популярности';
    default:
      return 'Неизвестное значение';
  }
}

String sortGenreBooksByToQueryParam(SortGenreBooksBy sortBooksBy) {
  switch (sortBooksBy) {
    case SortGenreBooksBy.alphabet:
      return 'Title';
    case SortGenreBooksBy.date:
      return 'Time';
    case SortGenreBooksBy.authors:
      return 'Author';
    case SortGenreBooksBy.popularity:
      return 'Pop';
    default:
      return '';
  }
}
