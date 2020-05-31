import 'package:flare_flutter/flare_actor.dart';
import 'package:flibusta/blocs/grid/grid_data/bloc.dart';
import 'package:flibusta/ds_controls/ui/decor/shimmers.dart';
import 'package:flibusta/model/enums/gridViewType.dart';
import 'package:flibusta/model/grid_data/grid_data.dart';
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

  @override
  void initState() {
    super.initState();

    
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

  @override
  Widget build(BuildContext context) {
    Widget body;

    int shimmerListCount = (MediaQuery.of(context).size.height / 110).round();

    if ((gridDataState.stateCode == GridDataStateCode.Normal ||
            gridDataState.stateCode == GridDataStateCode.Error) &&
        gridDataState.gridData?.isEmpty == true) {
      body = Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          SizedBox(
            height: 230,
            width: 300,
            child: FlareActor(
              'assets/animations/empty_state.flr',
              alignment: Alignment.topCenter,
              fit: BoxFit.contain,
              animation: 'idle',
              color: Theme.of(context).textTheme.bodyText2.color,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Text(
              'В данной серии пока нет книг',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      );
    } else if (gridDataState?.stateCode == GridDataStateCode.Loading) {
      body = ShimmerGridTileBuilder(
        itemCount: shimmerListCount,
        gridViewType: GridViewType.suquence,
      );
    } else if (gridDataState.gridData != null) {
      body = Scrollbar(
        child: ListView.separated(
          physics: kBouncingAlwaysScrollableScrollPhysics,
          addSemanticIndexes: false,
          itemCount: gridDataState.uploadingMore
              ? (gridDataState.gridData.length + 1)
              : gridDataState.gridData.length,
          padding: EdgeInsets.only(top: 20),
          separatorBuilder: (context, index) {
            return Material(
              type: MaterialType.card,
              borderRadius: BorderRadius.zero,
              child: Divider(indent: 16),
            );
          },
          itemBuilder: (context, index) {
            if (index == gridDataState.gridData.length) {
              return Material(
                type: MaterialType.card,
                borderRadius: BorderRadius.zero,
                child: Column(
                  children: <Widget>[
                    ShimmerListTile(
                      index: index,
                      gridViewType: GridViewType.suquence,
                    ),
                    Divider(),
                  ],
                ),
              );
            }

            List<String> genresStrings =
                (gridDataState.gridData[index] as BookCard)
                    ?.genres
                    ?.list
                    ?.map((genre) {
              return genre.values?.first;
            })?.toList();
            var score = (gridDataState.gridData[index] as BookCard)?.fileScore;

            return Material(
              type: MaterialType.card,
              borderRadius: BorderRadius.zero,
              child: GridDataTile(
                index: index,
                isFirst: false,
                isLast: true,
                showTopDivider: index == 0,
                showBottomDivier: !gridDataState.uploadingMore &&
                    index == gridDataState.gridData.length - 1,
                title: gridDataState.gridData[index].tileTitle,
                subtitle: gridDataState.gridData[index].tileSubtitle,
                genres: genresStrings,
                score: score,
                onTap: () {
                  LocalStorage()
                      .addToLastOpenBooks(gridDataState.gridData[index]);
                  Navigator.of(context).pushNamed(
                    BookPage.routeName,
                    arguments: gridDataState.gridData[index].id,
                  );
                },
                onLongPress: () {
                  showCupertinoModalPopup(
                    filter: ImageFilter.blur(sigmaX: 3.0, sigmaY: 3.0),
                    context: context,
                    builder: (context) {
                      return Center(
                        child: FullInfoCard<BookCard>(
                          data: gridDataState.gridData[index],
                        ),
                      );
                    },
                  );
                },
              ),
            );
          },
        ),
      );
    } else {
      body = ShimmerGridTileBuilder(
        itemCount: shimmerListCount,
        gridViewType: GridViewType.suquence,
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

  @override
  void dispose() {
    super.dispose();
  }
}
