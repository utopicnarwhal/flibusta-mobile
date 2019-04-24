import 'package:flibusta/blocs/home_grid/bloc.dart';
import 'package:flibusta/pages/home/components/drawer.dart';
import 'package:flibusta/services/local_store_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class Home extends StatefulWidget {
  static const routeName = "/Home";

  @override
  createState() => _HomeState();
}

class _HomeState extends State<Home> with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  BookSearch _bookSearch;
  List<String> _previousBookSearches;
  HomeGridBloc _homeGridBloc;

  TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(initialIndex: 0, vsync: this, length: 3);
    _bookSearch = BookSearch();
    LocalStore().getPreviousBookSearches().then((previousBookSearches) {
      _previousBookSearches = previousBookSearches;
      _bookSearch.suggestions = _previousBookSearches;
    });
    _homeGridBloc = HomeGridBloc();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        centerTitle: false,
        leading: IconButton(
          icon: Icon(Icons.menu),
          onPressed: () {
            _scaffoldKey.currentState.openDrawer();
          },
        ),
        title: Text(_bookSearch.query == null ? 'Книги' : 'Результаты поиска'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () async {
              var searchQuery = await showSearch(
                context: context,
                delegate: _bookSearch,
              );
              if (!_previousBookSearches.contains(searchQuery)) {
                _previousBookSearches.add(searchQuery);
                LocalStore().setPreviousBookSearches(_previousBookSearches);
              }
              _homeGridBloc.searchAllByQuery(searchQuery);
            },
          )
        ],
        bottom: TabBar(
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
        ),
      ),
      drawer: MyDrawer().build(context),
      body: BlocBuilder(
        bloc: _homeGridBloc,
        builder: (BuildContext context, HomeGridState state) {
          return Container();
        },
      ),
    );
  }

  @override
  void dispose() {
    _homeGridBloc.dispose();
    super.dispose();
  }
}

class BookSearch<String> extends SearchDelegate {
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
        close(context, query);
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
          title: Text(
            suggestions.elementAt(index).toString(),
          ),
        );
      },
    );
  }
}
