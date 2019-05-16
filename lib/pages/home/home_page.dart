import 'package:flibusta/blocs/home_grid/bloc.dart';
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

  BookSearch _bookSearch = BookSearch();
  List<String> _previousBookSearches;
  HomeGridBloc _homeGridBloc = HomeGridBloc();

  TabController _tabController;

  String searchQuery;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(initialIndex: 0, vsync: this, length: 3);
    LocalStorage().getPreviousBookSearches().then((previousBookSearches) {
      _previousBookSearches = previousBookSearches;
      _bookSearch.suggestions = _previousBookSearches;
    });
    _homeGridBloc.getLatestBooks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        centerTitle: false,
        leading: IconButton(
          icon: BlocBuilder(
              bloc: _homeGridBloc,
              builder: (context, homeGridState) {
                if (homeGridState is LoadingHomeGridState ||
                    homeGridState is LatestBooksState) {
                  return Icon(Icons.menu);
                }
                if (homeGridState is GlobalSearchResultsState) {
                  return WillPopScope(
                    child: Icon(Icons.arrow_back),
                    onWillPop: () {
                      _homeGridBloc.getLatestBooks();
                    },
                  );
                }
                return Icon(Icons.menu);
              }),
          onPressed: () {
            if (_homeGridBloc.currentState is LoadingHomeGridState ||
                _homeGridBloc.currentState is LatestBooksState) {
              _scaffoldKey.currentState.openDrawer();
            }
          },
        ),
        title: BlocBuilder(
            bloc: _homeGridBloc,
            builder: (context, homeGridState) {
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
              if (homeGridState is GlobalSearchResultsState) {
                return Text(
                  'Результаты поиска',
                  overflow: TextOverflow.fade,
                );
              }
              return Text(
                'Что?',
                overflow: TextOverflow.fade,
              );
            }),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () async {
              searchQuery = await showSearch<String>(
                context: context,
                delegate: _bookSearch,
              );
              if (searchQuery == null) {
                return;
              }
              if (!_previousBookSearches.contains(searchQuery)) {
                _previousBookSearches.add(searchQuery);
                LocalStorage().setPreviousBookSearches(_previousBookSearches);
              }
              _homeGridBloc.globalSearch(searchQuery: searchQuery);
            },
          )
        ],
        bottom: _homeGridBloc.currentState is GlobalSearchResultsState
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
  }

  @override
  void dispose() {
    _homeGridBloc.dispose();
    _tabController.dispose();
    super.dispose();
  }
}

class BookSearch extends SearchDelegate<String> {
  List<String> suggestions = [];

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
    return ListView.builder(
      itemCount: suggestions?.length ?? 0,
      itemBuilder: (context, index) {
        return ListTile(
          leading: Icon(Icons.history),
          title: Text(
            suggestions.elementAt(index).toString(),
          ),
          onTap: () {
            query = suggestions[index];
            close(context, query);
          },
        );
      },
    );
  }
}
