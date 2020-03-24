enum SortBooksBy {
  alphabet,
  sequence,
  date,
  popularity,
  genre,
}

String sortBooksByToString(SortBooksBy sortBooksBy) {
  switch (sortBooksBy) {
    case SortBooksBy.alphabet:
      return 'Алфавиту';
    case SortBooksBy.date:
      return 'Дате поступления';
    case SortBooksBy.genre:
      return 'Жанрам';
    case SortBooksBy.popularity:
      return 'Популярности';
    case SortBooksBy.sequence:
      return 'Сериям';
    default:
      return 'Неизвестное значение';
  }
}

String sortBooksByToQueryParam(SortBooksBy sortBooksBy) {
  switch (sortBooksBy) {
    case SortBooksBy.alphabet:
      return 'a';
    case SortBooksBy.date:
      return 't';
    case SortBooksBy.genre:
      return 'g';
    case SortBooksBy.popularity:
      return 'p';
    case SortBooksBy.sequence:
      return 'b';
    default:
      return 'Неизвестное значение';
  }
}