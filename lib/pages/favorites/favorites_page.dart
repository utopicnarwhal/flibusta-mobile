import 'package:flare_flutter/flare_actor.dart';
import 'package:flibusta/ds_controls/ui/decor/shimmers.dart';
import 'package:flibusta/model/enums/gridViewType.dart';
import 'package:flibusta/model/grid_data/grid_data.dart';
import 'package:flibusta/model/searchResults.dart';
import 'package:flibusta/pages/author/author_page.dart';
import 'package:flibusta/pages/sequence/sequence_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:flibusta/blocs/grid/grid_data/components/full_info_card.dart';
import 'package:flibusta/blocs/grid/grid_data/components/grid_data_tile.dart';
import 'package:flibusta/constants.dart';
import 'package:flibusta/ds_controls/ui/app_bar.dart';
import 'package:flibusta/model/bookCard.dart';
import 'package:flibusta/pages/book/book_page.dart';
import 'package:flibusta/services/local_storage.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

enum FavoritesType {
  Book,
  Author,
  Sequence,
  Postpone,
}

class FavoritesPage extends StatefulWidget {
  static const routeName = "/FavoritesPage";

  final FavoritesType favoritesType;

  const FavoritesPage({Key key, this.favoritesType}) : super(key: key);
  @override
  _FavoritesPageState createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  List<GridData> _favoritesList;
  SlidableController _slidableController;

  @override
  void initState() {
    super.initState();
    _getFavoritesList();
    _slidableController = SlidableController();
  }

  void _getFavoritesList() async {
    switch (widget.favoritesType) {
      case FavoritesType.Author:
        _favoritesList = await LocalStorage().getFavoriteAuthors();
        break;
      case FavoritesType.Book:
        _favoritesList = await LocalStorage().getFavoriteBooks();
        break;
      case FavoritesType.Sequence:
        _favoritesList = await LocalStorage().getFavoriteSequences();
        break;
      case FavoritesType.Postpone:
        _favoritesList = await LocalStorage().getPostponeBooks();
        break;
    }
    setState(() {});
  }

  String _favoriteTypeToTitle(FavoritesType favoritesType) {
    switch (favoritesType) {
      case FavoritesType.Author:
        return 'Избранные авторы';
      case FavoritesType.Book:
        return 'Избранные книги';
      case FavoritesType.Sequence:
        return 'Избранные сериалы';
      case FavoritesType.Postpone:
        return 'Отложенное на потом';
      default:
        return '';
    }
  }

  String _favoriteTypeToNoResultMessage(FavoritesType favoritesType) {
    switch (favoritesType) {
      case FavoritesType.Author:
        return 'Добавляйте авторов в избранное, чтобы увидеть их здесь';
      case FavoritesType.Book:
        return 'Добавляйте книги в избранное, чтобы увидеть их здесь';
      case FavoritesType.Sequence:
        return 'Добавляйте сериалы в избранное, чтобы увидеть их здесь';
      case FavoritesType.Postpone:
        return 'Добавляйте книги в отложенное, чтобы увидеть их здесь';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget body;

    int shimmerListCount = (MediaQuery.of(context).size.height / 110).round();

    if (_favoritesList == null) {
      body = ShimmerGridTileBuilder(
        itemCount: shimmerListCount,
        gridViewType: GridViewType.suquence,
      );
    } else if (_favoritesList.isEmpty) {
      body = Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          SizedBox(
            height: 230,
            width: 300,
            child: FlareActor(
              'assets/animations/like.flr',
              alignment: Alignment.topCenter,
              fit: BoxFit.contain,
              animation: 'Animations',
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Text(
              _favoriteTypeToNoResultMessage(widget.favoritesType),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      );
    } else {
      body = Scrollbar(
        child: ListView.separated(
          physics: kBouncingAlwaysScrollableScrollPhysics,
          addSemanticIndexes: false,
          itemCount: _favoritesList.length,
          padding: EdgeInsets.only(top: 20),
          separatorBuilder: (context, index) {
            return Material(
              type: MaterialType.card,
              borderRadius: BorderRadius.zero,
              child: Divider(indent: 16),
            );
          },
          itemBuilder: (context, index) {
            List<String> genresStrings;
            int score;

            if (_favoritesList[index] is BookCard) {
              genresStrings = (_favoritesList[index] as BookCard)
                  ?.genres
                  ?.list
                  ?.map((genre) {
                return genre.values?.first;
              })?.toList();
              score = (_favoritesList[index] as BookCard)?.fileScore;
            }

            return Material(
              type: MaterialType.card,
              borderRadius: BorderRadius.zero,
              child: GridDataTile(
                index: index,
                isFirst: false,
                isLast: true,
                showTopDivider: index == 0,
                showBottomDivier: index == _favoritesList.length - 1,
                title: _favoritesList[index].tileTitle,
                subtitle: _favoritesList[index].tileSubtitle,
                genres: genresStrings,
                score: score,
                isSlidable: true,
                slidableController: _slidableController,
                onDismissed: () async {
                  switch (widget.favoritesType) {
                    case FavoritesType.Author:
                      await LocalStorage()
                          .deleteFavoriteAuthor(_favoritesList[index].id);
                      break;
                    case FavoritesType.Book:
                      await LocalStorage()
                          .deleteFavoriteBook(_favoritesList[index].id);
                      break;
                    case FavoritesType.Sequence:
                      await LocalStorage()
                          .deleteFavoriteSequence(_favoritesList[index].id);
                      break;
                    case FavoritesType.Postpone:
                      await LocalStorage()
                          .deletePostponeBook(_favoritesList[index].id);
                      break;
                  }
                  _getFavoritesList();
                },
                onTap: () {
                  if (_favoritesList[index] is BookCard) {
                    LocalStorage().addToLastOpenBooks(_favoritesList[index]);
                    Navigator.of(context).pushNamed(
                      BookPage.routeName,
                      arguments: _favoritesList[index].id,
                    );
                  } else if (_favoritesList[index] is AuthorCard) {
                    Navigator.of(context).pushNamed(
                      AuthorPage.routeName,
                      arguments: _favoritesList[index].id,
                    );
                  } else if (_favoritesList[index] is SequenceCard) {
                    Navigator.of(context).pushNamed(
                      SequencePage.routeName,
                      arguments: _favoritesList[index].id,
                    );
                  }
                },
                onLongPress: () {
                  if (_favoritesList[index] is BookCard) {
                    showCupertinoModalPopup(
                      filter: ImageFilter.blur(sigmaX: 3.0, sigmaY: 3.0),
                      context: context,
                      builder: (context) {
                        return Center(
                          child: FullInfoCard<BookCard>(
                            data: _favoritesList[index],
                          ),
                        );
                      },
                    );
                  }
                },
              ),
            );
          },
        ),
      );
    }

    return Scaffold(
      key: _scaffoldKey,
      appBar: DsAppBar(
        title: Text(
          _favoriteTypeToTitle(widget.favoritesType),
          overflow: TextOverflow.fade,
        ),
      ),
      body: body,
    );
  }
}
