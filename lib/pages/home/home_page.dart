import 'package:dio/dio.dart';
import 'package:flibusta/intro.dart';
import 'package:flibusta/model/advancedSearchParams.dart';
import 'package:flibusta/model/searchResults.dart';
import 'package:flibusta/pages/home/advanced_search/advanced_search_bs.dart';
import 'package:flibusta/pages/home/search_results_builder/search_results_builder.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'dart:async';

import 'package:flibusta/services/http_client_service.dart';
import 'package:flibusta/services/local_store_service.dart';
import 'package:flibusta/drawer.dart';
import 'package:flibusta/components/loading_indicator.dart';
import 'package:flibusta/model/bookCard.dart';
import 'package:flibusta/utils/html_parsers.dart';
import 'package:flibusta/pages/home/book_list_builder/book_list_builder.dart';

class Home extends StatefulWidget {
  static const routeName = "/Home";

  @override
  createState() => HomeState();
}

class HomeState extends State<Home> with SingleTickerProviderStateMixin {
  Dio _dio = ProxyHttpClient().getDio();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  bool _isSearchActive = false;
  bool _isAdvancedSearch = false;
  AdvancedSearchParams _advancedSearchParams = AdvancedSearchParams();
  final TextEditingController searchTitleController = TextEditingController();
  TabController tabController;

  List<BookCard> data;
  SearchResults searchResults;

  bool _load = false;

  @override
  void initState() {
    tabController = TabController(vsync: this, length: 3);

    LocalStore().getIntroComplete().then((bool introCompleted) {
      if (!introCompleted) {
        Navigator.of(context).pushNamed(IntroScreen.routeName).then((x) {
          _scaffoldKey.currentState.removeCurrentSnackBar();
          makeBookList(AdvancedSearchParams()).then((response) {
            setState(() {
              data = response;
            });
          });
        });
      }
    });
    super.initState();
    makeBookList(AdvancedSearchParams()).then((response) {
      setState(() {
        data = response;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        centerTitle: false,
        leading: _isSearchActive ? IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            makeBookList(AdvancedSearchParams()).then((response) {
              setState(() {
                data = response;
              });
            });
            setState(() {
              searchResults = null;
              searchTitleController.text = "";
              _isSearchActive = false;
              _isAdvancedSearch = false;
            });
          },
        ) : Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: Icon(Icons.menu),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          }
        ),
        title: 
          Container(
            child: !_isSearchActive ? Text("Главная") :
              WillPopScope(onWillPop: () {
                makeBookList(AdvancedSearchParams()).then((response) {
                  setState(() {
                    data = response;          
                  });
                });
                setState(() {
                  searchResults = null;
                  searchTitleController.text = "";
                  _isSearchActive = false;
                  _isAdvancedSearch = false;
                  _advancedSearchParams = AdvancedSearchParams();
                });
              },
              child: _isAdvancedSearch ? Text("Расширенный поиск") : TextField(
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18.0,
                ),
                autocorrect: true,
                autofocus: false,
                controller: searchTitleController,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: "Поиск",
                  hintStyle: TextStyle(
                    color: Colors.white,
                    fontSize: 18.0,
                  ),
                  suffixIcon: searchTitleController.text.isNotEmpty ? IconButton(
                    icon: Icon(Icons.clear), 
                    onPressed: () {
                      searchTitleController.clear();
                    },
                  ) : null,
                ),
                onSubmitted: (String text) {
                  setState(() {
                    searchResults = null;
                  });
                  bookSearch(text).then((response) {
                    setState(() {
                      searchResults = response;          
                    });
                  });
                },
              ),
            )
          ),
        actions: <Widget>[
          _isSearchActive ? IconButton(
            icon: Icon(FontAwesomeIcons.slidersH, size: 18,),
            onPressed: () async {
              setState(() {
                _isAdvancedSearch = true;
              });
              _advancedSearchParams = await showAdvancedSearchBS(_scaffoldKey, AdvancedSearchParams());
              if (_advancedSearchParams == null) {
                setState(() {
                  _isAdvancedSearch = false;
                  _advancedSearchParams = AdvancedSearchParams();
                });
                return;
              }

              setState(() {
                searchResults = null; 
              });
              makeBookList(_advancedSearchParams).then((response) {
                setState(() {
                  data = response;          
                });
              });
            },
          ) : Container(),
          !_isAdvancedSearch ? IconButton(
            icon: Icon(FontAwesomeIcons.search),
            onPressed: () {
              if (_isSearchActive) {
                setState(() {
                  searchResults = null;
                });
                bookSearch(searchTitleController.text).then((response) {
                  setState(() {
                    searchResults = response;
                  });
                });
              } else {
                setState(() {
                  _isSearchActive = true;
                });
              }
            },
          ) : Container(),
        ],
        bottom: searchResults != null ? TabBar(
          controller: tabController,
          tabs: <Widget>[
            Tab(text: "КНИГИ",),
            Tab(text: "ПИСАТЕЛИ",),
            Tab(text: "СЕРИИ",),
          ],
        ) : null,
      ),
      drawer: MyDrawer().build(context),
      body: RefreshIndicator(
        onRefresh: () {
          return makeBookList(AdvancedSearchParams(title: _isSearchActive ? searchTitleController.text : null)).then((response) {
            setState(() {
              data = response;          
            });
          });
        },
        child: Container(
          child: _load ? LoadingIndicator() : whatContentShow()
        ),
      ),
    );
  }

  Widget whatContentShow() {
    if (searchResults != null) {
      return TabBarView(
        controller: tabController,
        children: searchResultsBuilder(searchResults)
      );
    }
    return data != null && data.length == 0 ? _noResults() : BookListBuilder(data: data, scaffoldKey: _scaffoldKey,);
  }

  Future<List<BookCard>> makeBookList(AdvancedSearchParams advancedSearchParams) async {
    setState(() {
      _load = true;
    });
    Map<String, String> queryParams = { "ab" : "ab1", "sort": "sd2" };
    if (advancedSearchParams.title != null && advancedSearchParams.title.isNotEmpty) {
      queryParams.addAll({ "t": advancedSearchParams.title });
    }
    if (advancedSearchParams.firstname != null && advancedSearchParams.firstname.isNotEmpty) {
      queryParams.addAll({ "fn": advancedSearchParams.firstname });
    }
    if (advancedSearchParams.lastname != null && advancedSearchParams.lastname.isNotEmpty) {
      queryParams.addAll({ "ln": advancedSearchParams.lastname });
    }
    if (advancedSearchParams.middlename != null && advancedSearchParams.middlename.isNotEmpty) {
      queryParams.addAll({ "mn": advancedSearchParams.middlename });
    }
    if (advancedSearchParams.genres != null && advancedSearchParams.genres.isNotEmpty) {
      queryParams.addAll({ "g": advancedSearchParams.genres });
    }
    Uri url = Uri.https(ProxyHttpClient().getFlibustaHostAddress(), "/makebooklist", queryParams);
    try {
      var response = await _dio.getUri(url);
      var result = parseHtmlFromMakeBookList(response.data);
      setState(() {
        _load = false;     
      });
      return result;
    } on TimeoutException catch(timeoutError) {
      print(timeoutError);
      _scaffoldKey.currentState.showSnackBar(
        SnackBar(
          content: Text("Время ожидания ответа от сервера истекло. Проверьте соединение с интернетом и доступность прокси."),
        )
      );
      setState(() {
        _load = false;     
      });
      return null;
    } catch(error) {
      print(error);
      setState(() {
        _load = false;     
      });
      return null;
    }
  }

  Future<SearchResults> bookSearch(String searchText) async {
    if (searchText.trim().isEmpty) {
      _scaffoldKey.currentState.showSnackBar(
        SnackBar(
          content: Text("Введите хоть что-нибудь!"),
        )
      );
    }
    setState(() {
      _load = true;
    });
    Map<String, String> queryParams = { "page" : "0", "ask": searchText, "chs" : "on", "cha" : "on", "chb" : "on" };
    Uri url = Uri.https(ProxyHttpClient().getFlibustaHostAddress(), "/booksearch", queryParams);
    try {
      var response = await _dio.getUri(url);
      var result = parseHtmlFromBookSearch(response.data);
      setState(() {
        _load = false;     
      });
      return result;
    } on TimeoutException catch(timeoutError) {
      print(timeoutError);
      _scaffoldKey.currentState.showSnackBar(
        SnackBar(
          content: Text("Время ожидания ответа от сервера истекло. Проверьте соединение с интернетом и доступность прокси."),
        )
      );
      setState(() {
        _load = false;     
      });
      return null;
    } catch(error) {
      print(error);
      setState(() {
        _load = false;     
      });
      return null;
    }
  }

  Widget _noResults() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Icon(FontAwesomeIcons.frownOpen, size: 45),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text("Извините, но книг с данным названием не существует в нашей библиотеке.", style: TextStyle(fontSize: 22), textAlign: TextAlign.center),
        ),
      ],
    );
  }
}