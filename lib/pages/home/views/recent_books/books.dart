import 'dart:async';

import 'package:flibusta/blocs/home_grid/bloc.dart';
import 'package:flibusta/blocs/home_grid/home_grid_state.dart';
import 'package:flibusta/pages/home/components/home_bottom_nav_bar.dart';
import 'package:flibusta/pages/home/components/search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BooksPage extends StatefulWidget {
  static const routeName = "/Books";

  final StreamController<int> selectedNavItemController;
  final GlobalKey<ScaffoldState> scaffoldKey;

  const BooksPage({
    Key key,
    @required this.scaffoldKey,
    @required this.selectedNavItemController,
  }) : super(key: key);

  @override
  _BooksPageState createState() => _BooksPageState();
}

class _BooksPageState extends State<BooksPage>
    with SingleTickerProviderStateMixin {
  TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(initialIndex: 0, vsync: this, length: 3);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder(
      bloc: BlocProvider.of<HomeGridBloc>(context),
      builder: (context, homeGridState) {
        var showBackButton = homeGridState is GlobalSearchResultsState ||
            homeGridState is AdvancedSearchResultsState;
            
        return Scaffold(
          key: widget.scaffoldKey,
          appBar: AppBar(
            centerTitle: false,
            leading: showBackButton
                ? WillPopScope(
                    child: IconButton(
                      icon: Icon(Icons.arrow_back),
                      onPressed: () {
                        if (showBackButton) {
                          BlocProvider.of<HomeGridBloc>(context)
                              .getLatestBooks();
                        }
                      },
                    ),
                    onWillPop: () async {
                      BlocProvider.of<HomeGridBloc>(context).getLatestBooks();
                      return false;
                    },
                  )
                : null,
            title: Builder(
              builder: (context) {
                if (homeGridState is LoadingHomeGridState) {
                  return Text(
                    'Поиск...',
                    overflow: TextOverflow.fade,
                  );
                }
                if (homeGridState is LatestBooksState) {
                  return Text(
                    'Последние книги',
                    overflow: TextOverflow.fade,
                  );
                }
                if (homeGridState is GlobalSearchResultsState ||
                    homeGridState is AdvancedSearchResultsState) {
                  return Text(
                    'Результаты поиска',
                    overflow: TextOverflow.fade,
                  );
                }
                return Text(
                  '...',
                  overflow: TextOverflow.fade,
                );
              },
            ),
            actions: <Widget>[
              if (homeGridState is LatestBooksState) BookSearch(),
            ],
            bottom: homeGridState is GlobalSearchResultsState
                ? TabBar(
                    controller: _tabController,
                    tabs: <Widget>[
                      Tab(
                        text: "КНИГИ",
                      ),
                      Tab(
                        text: "ПИСАТЕЛИ",
                      ),
                      Tab(
                        text: "СЕРИИ",
                      ),
                    ],
                  )
                : null,
          ),
          body: HomeGridScreen(
            scaffoldKey: widget.scaffoldKey,
            homeGridBloc: BlocProvider.of<HomeGridBloc>(context),
            tabController: _tabController,
          ),
          bottomNavigationBar: HomeBottomNavBar(
            key: Key('HomeBottomNavBar'),
            index: 0,
            onTap: (index) {
              widget.selectedNavItemController.add(index);
            },
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }
}
