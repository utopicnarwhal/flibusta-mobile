import 'package:flibusta/model/genre.dart';

class AdvancedSearchParams {
  String title;
  String lastname;
  String firstname;
  String middlename;
  List<Genre> genres;
  String sizeStart;
  String sizeEnd;
  String issueYearMin;
  String issueYearMax;
  String formats;
  String languages;

  AdvancedSearchParams({
    this.title,
    this.lastname,
    this.firstname,
    this.middlename,
    this.genres,
    this.sizeStart,
    this.sizeEnd,
    this.issueYearMin,
    this.issueYearMax,
    this.formats,
    this.languages,
  });
}
