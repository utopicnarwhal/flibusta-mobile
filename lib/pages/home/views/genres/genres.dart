// import 'dart:async';

// import 'package:flibusta/blocs/genres_list/genres_list_bloc.dart';
// import 'package:flibusta/blocs/home_grid/bloc.dart';
// import 'package:flibusta/ds_controls/ui/app_bar.dart';
// import 'package:flibusta/model/advancedSearchParams.dart';
// import 'package:flibusta/model/genre.dart';
// import 'package:flibusta/pages/home/components/home_bottom_nav_bar.dart';
// import 'package:flibusta/services/local_storage.dart';
// import 'package:flutter/material.dart';
// import 'package:flibusta/components/loading_indicator.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// import 'package:rxdart/rxdart.dart';

// class GenresView extends StatelessWidget {
//   final GlobalKey<ScaffoldState> scaffoldKey;
//   final GenresListBloc genresListBloc;
//   final StreamController<int> selectedNavItemController;
//   final BehaviorSubject<List<String>> favoriteGenreCodesController;

//   GenresView({
//     @required this.scaffoldKey,
//     @required this.genresListBloc,
//     @required this.selectedNavItemController,
//     @required this.favoriteGenreCodesController,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       key: scaffoldKey,
//       appBar: DsAppBar(
//         title: Text('Жанры'),
//       ),
//       body: StreamBuilder<List<Genre>>(
//         stream: genresListBloc.allGenresListStream,
//         builder: (context, genresListSnapshot) {
//           if (!genresListSnapshot.hasData) {
//             return LoadingIndicator();
//           }
//           return RefreshIndicator(
//             onRefresh: () async {
//               genresListBloc.refreshGenresList();
//             },
//             child: Scrollbar(
//               child: StreamBuilder<List<String>>(
//                 stream: favoriteGenreCodesController,
//                 builder: (context, favoriteGenreCodesSnapshot) {
//                   genresListSnapshot.data.sort(
//                     (genre1, genre2) => _genreSorting(
//                         favoriteGenreCodesSnapshot?.data, genre1, genre2),
//                   );

//                   return ListView.separated(
//                     itemCount: genresListSnapshot.data.length,
//                     separatorBuilder: (context, index) {
//                       return Divider();
//                     },
//                     itemBuilder: (context, index) {
//                       var isFavorite = favoriteGenreCodesSnapshot.data
//                               ?.any((favoriteGenreCode) {
//                             return favoriteGenreCode ==
//                                 genresListSnapshot.data[index].code;
//                           }) ??
//                           false;
//                       return ListTile(
//                         title: Text(genresListSnapshot.data[index].name),
//                         trailing: Column(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: <Widget>[
//                             Icon(
//                               Icons.arrow_forward_ios,
//                               size: 16,
//                             )
//                           ],
//                         ),
//                         leading: Column(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: <Widget>[
//                             IconButton(
//                               icon: Icon(
//                                 isFavorite
//                                     ? FontAwesomeIcons.solidStar
//                                     : FontAwesomeIcons.star,
//                                 size: 22,
//                                 color: isFavorite
//                                     ? Theme.of(context).primaryColor
//                                     : null,
//                               ),
//                               onPressed: () async {
//                                 if (isFavorite) {
//                                   await LocalStorage().deleteFavoriteGenre(
//                                       genresListSnapshot.data[index].code);
//                                 } else {
//                                   await LocalStorage().addFavoriteGenre(
//                                       genresListSnapshot.data[index].code);
//                                 }
//                                 favoriteGenreCodesController.add(
//                                   await LocalStorage().getfavoriteGenreCodes(),
//                                 );
//                               },
//                             ),
//                           ],
//                         ),
//                         onTap: () {
//                           var selectedGenreString =
//                               genresListSnapshot.data[index].code;

//                           BlocProvider.of<HomeGridBloc>(context).advancedSearch(
//                             advancedSearchParams: AdvancedSearchParams(
//                               genres: selectedGenreString,
//                             ),
//                           );
//                           selectedNavItemController.add(0);
//                         },
//                       );
//                     },
//                   );
//                 },
//               ),
//             ),
//           );
//         },
//       ),
//       bottomNavigationBar: HomeBottomNavBar(
//         key: Key('HomeBottomNavBar'),
//         index: 1,
//         selectedNavItemController: selectedNavItemController,
//       ),
//     );
//   }

//   int _genreSorting(
//       List<String> favoriteGenreCodes, Genre genre1, Genre genre2) {
//     var isFavorite1 = favoriteGenreCodes?.any((favoriteGenreCode) {
//           return favoriteGenreCode == genre1.code;
//         }) ??
//         false;

//     var isFavorite2 = favoriteGenreCodes?.any((favoriteGenreCode) {
//           return favoriteGenreCode == genre2.code;
//         }) ??
//         false;

//     if (isFavorite1 && isFavorite2)
//       return genre1.name.compareTo(genre2.name);
//     else if (isFavorite1)
//       return -1;
//     else if (isFavorite2)
//       return 1;
//     else
//       return genre1.name.compareTo(genre2.name);
//   }
// }
