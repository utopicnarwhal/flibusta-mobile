enum GridViewType {
  newBooks,
  genres,
  authors,
  sequences,
  downloaded,
}

String gridViewTypeToString(GridViewType gridViewType) {
  switch (gridViewType) {
    case GridViewType.newBooks:
      return 'Последние поступления';
    case GridViewType.genres:
      return 'Жанры';
    case GridViewType.authors:
      return 'Авторы';
    case GridViewType.sequences:
      return 'Сериалы';
    case GridViewType.downloaded:
      return 'Скачанные';
    default:
  }
  return '';
}