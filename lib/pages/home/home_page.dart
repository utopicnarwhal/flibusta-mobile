import 'package:flibusta/blocs/home_grid/bloc.dart';
import 'package:flibusta/model/advancedSearchParams.dart';
import 'package:flibusta/pages/home/advanced_search/advanced_search_bs.dart';
import 'package:flibusta/pages/home/components/drawer.dart';
import 'package:flibusta/services/local_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomePage extends StatefulWidget {
  static const routeName = "/HomePage";

  @override
  createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  BookSearch _bookSearch;
  List<String> _previousBookSearches;
  HomeGridBloc _homeGridBloc = HomeGridBloc();

  TabController _tabController;

  dynamic searchQuery;

  @override
  void initState() {
    super.initState();
    _bookSearch = BookSearch(_scaffoldKey);
    _tabController = TabController(initialIndex: 0, vsync: this, length: 3);
    LocalStorage().getPreviousBookSearches().then((previousBookSearches) {
      _previousBookSearches = previousBookSearches;
      _bookSearch.suggestions = _previousBookSearches;
    });
    _homeGridBloc.getLatestBooks();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder(
      bloc: _homeGridBloc,
      builder: (context, homeGridState) {
        return Scaffold(
          key: _scaffoldKey,
          appBar: AppBar(
            centerTitle: false,
            leading: IconButton(
              icon: Builder(
                builder: (context) {
                  if (homeGridState is LoadingHomeGridState ||
                      homeGridState is LatestBooksState) {
                    return Icon(Icons.menu);
                  }
                  if (homeGridState is GlobalSearchResultsState ||
                      homeGridState is AdvancedSearchResultsState) {
                    return WillPopScope(
                      child: Icon(Icons.arrow_back),
                      onWillPop: () {
                        _homeGridBloc.getLatestBooks();
                      },
                    );
                  }
                  return Icon(Icons.menu);
                },
              ),
              onPressed: () {
                if (homeGridState is LoadingHomeGridState ||
                    homeGridState is LatestBooksState) {
                  _scaffoldKey.currentState.openDrawer();
                }
                if (homeGridState is GlobalSearchResultsState ||
                    homeGridState is AdvancedSearchResultsState) {
                  _homeGridBloc.getLatestBooks();
                }
              },
            ),
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
              if (homeGridState is LatestBooksState)
                IconButton(
                  icon: Icon(Icons.search),
                  onPressed: () async {
                    searchQuery = await showSearch<dynamic>(
                      context: context,
                      delegate: _bookSearch,
                    );
                    if (searchQuery == null) {
                      return;
                    }
                    if (searchQuery is AdvancedSearchParams) {
                      var advancedSearchParams =
                          await Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) {
                            return AdvancedSearchPage(
                              advancedSearchParams: AdvancedSearchParams(),
                            );
                          },
                        ),
                      );
                      if (advancedSearchParams == null) {
                        return;
                      }
                      _homeGridBloc.advancedSearch(
                          advancedSearchParams: advancedSearchParams);
                      return;
                    }
                    if (searchQuery is String && searchQuery.trim() != '') {
                      searchQuery = searchQuery.trim().toLowerCase();
                      if (!_previousBookSearches.contains(searchQuery)) {
                        _previousBookSearches.add(searchQuery);
                        LocalStorage()
                            .setPreviousBookSearches(_previousBookSearches);
                      }
                      _homeGridBloc.globalSearch(searchQuery: searchQuery);
                    }
                  },
                ),
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
          drawer: ModalRoute.of(context).settings.name == HomePage.routeName ||
                  ModalRoute.of(context).settings.name == '/'
              ? FlibustaDrawer()
              : null,
          body: HomeGridScreen(
            scaffoldKey: _scaffoldKey,
            homeGridBloc: _homeGridBloc,
            tabController: _tabController,
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _homeGridBloc.dispose();
    _tabController.dispose();
    super.dispose();
  }
}

class BookSearch extends SearchDelegate<dynamic> {
  List<String> suggestions = [];

  final GlobalKey<ScaffoldState> _scaffoldKey;

  BookSearch(this._scaffoldKey);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      query != null && query.length > 0
          ? IconButton(
              icon: Icon(Icons.close),
              onPressed: () {
                query = '';
              },
            )
          : Container(),
      IconButton(
        icon: Icon(Icons.search),
        onPressed: () {
          showResults(context);
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    Future.microtask(() => close(context, query));
    return Container();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    var filteredSuggestions = suggestions
        .where(
            (suggestion) => suggestion.startsWith(query.trim().toLowerCase()))
        .toList();

    return ListView.builder(
      itemCount: (filteredSuggestions?.length ?? 0) + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return Material(
            elevation: 4.0,
            color: Theme.of(context).backgroundColor,
            child: ListTile(
              dense: true,
              title: Center(
                child: Text(
                  'Расширенный поиск',
                  style: Theme.of(context).textTheme.button,
                ),
              ),
              onTap: () {
                close(context, AdvancedSearchParams());
              },
            ),
          );
        }
        if (filteredSuggestions
            .elementAt(index - 1)
            .startsWith(query.trim().toLowerCase())) {
          return ListTile(
            leading: Icon(Icons.history),
            title: Text(
              filteredSuggestions.elementAt(index - 1),
            ),
            onTap: () {
              query = filteredSuggestions[index - 1];
              close(context, query);
            },
          );
        }
      },
    );
  }

  @override
  ThemeData appBarTheme(BuildContext context) {
    return Theme.of(context);
  }
}
