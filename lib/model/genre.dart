class Genre {
  int id;
  String name;
  String code;

  Genre({
    this.id,
    this.name,
    this.code,
  }): assert(id != null);
}