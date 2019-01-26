import 'dart:convert';

import 'package:flibusta_app/pages/book/book_page.dart';
import 'package:flibusta_app/services/http_client_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:simple_permissions/simple_permissions.dart';
import 'package:open_file/open_file.dart';

import 'dart:async';
import 'dart:io';

import 'package:html/parser.dart' show parse;
import 'package:html/dom.dart' as htmldom;

import '../../services/local_store_service.dart';
import '../../drawer.dart';
import '../../components/loading_indicator.dart';
import '../../model/bookCard.dart';

class Home extends StatefulWidget {
  @override
  createState() => HomeState();
}

class HomeState extends State<Home> {
  HttpClient _httpClient = ProxyHttpClient().getHttpClient();

  bool _isSearchActive = false;
  final TextEditingController searchTitleController = TextEditingController();

  List<BookCard> data;

  bool _load = false;

  final _biggerFont = const TextStyle(fontSize: 18.0);
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    LocalStore().getIntroComplete().then((bool introCompleted) {
      if (!introCompleted) {
        Navigator.of(context).pushNamed("/Intro").then((x) {
          _scaffoldKey.currentState.removeCurrentSnackBar();
          getData().then((response) {
            setState(() {
              data = response;
            });
          });
        });
      }
    });
    super.initState();
    getData().then((response) {
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
            setState(() {
              _isSearchActive = false;
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
                getData().then((response) {
                  setState(() {
                    data = response;          
                  });
                });
                setState(() {
                  searchTitleController.text = "";
                  _isSearchActive = false;
                });
              },
              child: TextField(
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18.0,
                ),
                autocorrect: true,
                autofocus: true,
                controller: searchTitleController,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: "Поиск по названию",
                  hintStyle: TextStyle(
                    color: Colors.white,
                    fontSize: 18.0,
                  ),
                ),
                onSubmitted: (String title) {
                  getData(title).then((response) {
                    setState(() {
                      data = response;          
                    });
                  });
                },
              ),
            )
          ),
        actions: <Widget>[
          IconButton(
            icon: Icon(FontAwesomeIcons.search),
            onPressed: () {
              if (_isSearchActive) {
                getData(searchTitleController.text).then((response) {
                  setState(() {
                    data = response;          
                  });
                });
              } else {
                setState(() {
                  _isSearchActive = true;
                });
              }
            },
          ),
          // !_isSearchActive ? IconButton(
          //   icon: Icon(FontAwesomeIcons.signInAlt),
          //   onPressed: () {
          //     Navigator.of(context).pushNamed("/Login");
          //   },
          // ) : Container(),
        ],
      ),
      drawer: MyDrawer().build(context),
      body: RefreshIndicator(
        onRefresh: () {
          return getData(_isSearchActive ? searchTitleController.text : null).then((response) {
            setState(() {
              data = response;          
            });
          });
        },
        child: Container(
          color: Colors.black12,
          child: _load ? LoadingIndicator() : 
            (data != null && data.length == 0 ? _noResults() : Scrollbar(
              child: ListView.builder(
                padding: EdgeInsets.all(0),
                itemCount: data == null ? 0 : data.length,
                itemBuilder: (BuildContext context, int index) {
                  return Column(
                    children: <Widget>[
                      Container(
                        decoration: BoxDecoration(color: Colors.white),
                        child: Column(
                          children: <Widget>[
                            ListTile(
                              leading: Tooltip(message: "Название произведения", preferBelow: false, child: Icon(Icons.title)),
                              title: Text(data[index].title, style: _biggerFont,),
                            ),
                            data[index].authors.isNotEmpty ? ListTile(
                              leading: Tooltip(message: "Автор(-ы)", preferBelow: false, child: Icon(Icons.assignment_ind)),
                              title: Text(data[index].authors.toString(), style: _biggerFont,),
                            ) : Container(),
                            data[index].translatorId != null ? ListTile(
                              leading: Tooltip(message: "Перевод", preferBelow: false, child: Icon(Icons.translate)),
                              title: Text(data[index].translatorName, style: _biggerFont,),
                            ) : Container(),
                            data[index].genres.isNotEmpty ? ListTile(
                              leading: Tooltip(message: "Жанр произведения", preferBelow: false, child: Icon(FontAwesomeIcons.americanSignLanguageInterpreting)),
                              title: Text(data[index].genres.toString().replaceAll(RegExp(r'(\[|\])'), ""), style: _biggerFont,),
                            ) : Container(),
                            data[index].seriesId != null ? ListTile(
                              leading: Tooltip(message: "Из серии произведений", preferBelow: false, child: Icon(Icons.collections_bookmark)),
                              title: Text(data[index].seriesName, style: _biggerFont,),
                            ) : Container(),
                            ListTile(
                              leading: Tooltip(message: "Размер книги", preferBelow: false, child: Icon(Icons.data_usage)),
                              title: Text(data[index].size, style: _biggerFont,),
                            ),
                            data[index].downloadFormats.isNotEmpty ? ListTile(
                              leading: data[index].downloadProgress == null ? Tooltip(message: "Форматы файлов", child: Icon(Icons.file_download)) : 
                                CircularProgressIndicator(value: data[index].downloadProgress == 0.0 ? null : data[index].downloadProgress),
                              title: Text(data[index].downloadFormats.toString(), style: _biggerFont,),
                            ) : Container(),
                            ButtonTheme.bar(
                              padding: EdgeInsets.symmetric(vertical: 12),
                              child: ButtonBar(
                                alignment: MainAxisAlignment.spaceAround,
                                children: <Widget>[
                                  FlatButton(
                                    padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                                    child: Text("ПОДРОБНЕЕ", style: TextStyle(fontSize: 20.0)),
                                    onPressed: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (BuildContext context) => BookPage(bookId: data[index].id,),
                                        ),
                                      );
                                    },
                                  ),
                                  FlatButton(
                                    padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                                    child: Text("СКАЧАТЬ", style: TextStyle(fontSize: 20.0)),
                                    onPressed: data[index].downloadProgress != null ? null : () {
                                      showModalBottomSheet<void>(context: context, builder: (BuildContext context) {
                                        return Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment: CrossAxisAlignment.stretch,
                                          children: data[index].downloadFormats.list.map((downloadFormat) {
                                            return Container(
                                              padding: EdgeInsets.all(0),
                                              child: FlatButton(
                                                padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 16.0),
                                                child: Row(
                                                  mainAxisSize: MainAxisSize.max,
                                                  mainAxisAlignment: MainAxisAlignment.start,
                                                  children: <Widget>[
                                                    Icon(DownloadFormats.getIconDataForFormat(downloadFormat.keys.first), size: 28,),
                                                    Padding(
                                                      padding: const EdgeInsets.only(left: 15),
                                                      child: Text(downloadFormat.keys.first, style: _biggerFont,),
                                                    ),
                                                  ],
                                                ),
                                                onPressed: () async {
                                                  Navigator.pop(context);
                                                  if (!await SimplePermissions.checkPermission(Permission.WriteExternalStorage)) {
                                                    await SimplePermissions.requestPermission(Permission.WriteExternalStorage);
                                                  }
                                                  setState(() {
                                                    data[index].downloadProgress = 0.0;
                                                  });

                                                  var prepareToDownloadSB = _scaffoldKey.currentState.showSnackBar(
                                                    SnackBar(
                                                      content: Text("Подготовка к загрузке"),
                                                      duration: Duration(minutes: 1),
                                                    )
                                                  );

                                                  Uri url = Uri.https("flibusta.is", "/b/${data[index].id}/${downloadFormat.values.first}");
                                                  var response = await _httpClient.getUrl(url).timeout(Duration(seconds: 10)).then((r) => r.close());
                                                  Directory saveDocDir = await getExternalStorageDirectory();
                                                  saveDocDir = Directory(saveDocDir.path + "/Flibusta");
                                                  if (!saveDocDir.existsSync()) {
                                                    saveDocDir.createSync(recursive: true);
                                                    await _rescanFolder(saveDocDir.path + "/Flibusta");
                                                  }

                                                  prepareToDownloadSB.close();

                                                  if (response.statusCode != 200) {
                                                    setState(() {
                                                      data[index].downloadProgress = null;
                                                    });
                                                    return;
                                                  }

                                                  var contentDisposition = response.headers["content-disposition"][0];
                                                  var fileUri = "";
                                                  try {
                                                    fileUri = saveDocDir.path + "/" + contentDisposition?.split("filename=")[1].replaceAll("\"", "");
                                                  } catch (e) {
                                                    setState(() {
                                                      data[index].downloadProgress = null;
                                                    });
                                                    return;
                                                  }
                                                  var myFile = File(fileUri);
                                                  if (myFile.existsSync()) {
                                                    setState(() {
                                                      data[index].downloadProgress = null;
                                                    });
                                                    _scaffoldKey.currentState.showSnackBar(
                                                      SnackBar(
                                                        content: Text("Файл с таким именем уже есть"),
                                                        action: SnackBarAction(
                                                          label: "Открыть",
                                                          onPressed: () async {
                                                            await OpenFile.open(myFile.uri.toFilePath());
                                                          },
                                                        ),
                                                      )
                                                    );
                                                    return;
                                                  }
                                                  
                                                  int downloadedContents = 0;
                                                  var myFileSink = myFile.openWrite();
                                                  var fileSize = response.contentLength;
                                                  try {
                                                    await response.listen((contents) {
                                                      myFileSink.add(contents);
                                                      downloadedContents += contents.length;
                                                      setState(() {
                                                        data[index].downloadProgress = downloadedContents / fileSize;
                                                      });
                                                    }).asFuture();
                                                  } catch (exc) {
                                                    print(exc);
                                                  }
                                                  await myFileSink.flush();
                                                  await myFileSink.close();
                                                  _httpClient.close();

                                                  await _rescanFolder(myFile.path);

                                                  setState(() {
                                                    data[index].downloadProgress = null;
                                                  });

                                                  _scaffoldKey.currentState.showSnackBar(
                                                    SnackBar(
                                                      content: Text("Файл скачан"),
                                                      action: SnackBarAction(
                                                        label: "Открыть",
                                                        onPressed: () async {
                                                          await OpenFile.open(myFile.uri.toFilePath());
                                                        },
                                                      ),
                                                    )
                                                  );
                                                },
                                              )
                                            );
                                          }).toList(),
                                        );
                                      });
                                    },
                                  )
                                ],
                              )
                            )
                          ],
                        )
                      ),
                      Divider(height: 1,)
                    ]
                  );
                },
              ),
            )
          ),
        ),
      )
    );
  }

  static const platform = const MethodChannel('ru.utopicnarwhal.flibusta/native_methods_channel');

  Future<void> _rescanFolder(String dir) async {
    try {
      await platform.invokeMethod('rescan_folder', dir);
      print("Сканирование успешно завершено");
    } on PlatformException catch (e) {
      print("Сканирование не удалось. Ошибка: " + e.toString());
    }
  }

  Future<List<BookCard>> getData([String title]) async {
    setState(() {
      _load = true;
    });
    Map<String, String> queryParams = { "ab" : "ab1", "sort": "sd2" };
    if (title != null && title.isNotEmpty) {
      queryParams.addAll({ "t": title });
    }
    Uri url = Uri.https("flibusta.is", "/makebooklist", queryParams);
    try {
      var superRealResponse = "";
      var response = await _httpClient.getUrl(url).timeout(Duration(seconds: 5)).then((r) => r.close());
      await response.transform(utf8.decoder).listen((contents) {
        superRealResponse += contents;
      }).asFuture();
      _httpClient.close();
      htmldom.Document document = parse(superRealResponse);
      var result = parseHtmlToBookCards(document);
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

  List<BookCard> parseHtmlToBookCards(htmldom.Document document) {
    var result = List<BookCard>();
    var form = document.getElementsByTagName("form");
    if (form.isEmpty) {
      return result;
    }

    var bookCardDivs = form.first.getElementsByTagName("div");
    for (var i = 0; i < bookCardDivs.length; ++i) {
      var allATags = bookCardDivs[i].getElementsByTagName("a");
      if (allATags.isEmpty) {
        continue;
      }

      var genres = List<String>();
      if (bookCardDivs[i].getElementsByTagName("p").isNotEmpty) {
        bookCardDivs[i].getElementsByTagName("p")?.first?.getElementsByTagName("a")?.forEach((f) {
          genres.add(f.text);
        });
      }
      
      var title = bookCardDivs[i].getElementsByTagName("input")?.first?.nextElementSibling;

      htmldom.Element translator;
      htmldom.Element series;
      var temp = title.nextElementSibling;
      while (temp.localName != "span") {
        if (temp.attributes["href"].contains("/a/")) {
          translator = temp;
        } else if (temp.attributes["href"].contains("/s/")) {
          series = temp;
        }
        temp = temp.nextElementSibling;
      }
      var size = temp;

      var downloadFormats = List<Map<String, String>>();
      for (temp = size.nextElementSibling; temp.attributes["href"] != null && temp.attributes["href"].contains("/b/"); temp = temp.nextElementSibling) {
        var downloadFormatName = temp.text.replaceAll(RegExp(r'(\(|\))'), "");
        if (downloadFormatName == 'читать') {
          continue;
        }
        downloadFormatName = downloadFormatName.replaceAll("скачать ", "");
        var downloadFormatType = temp.attributes["href"].split("/").last;
        downloadFormats.add({ downloadFormatName: downloadFormatType });
      }

      var authors = List<Map<int, String>>();
      for (; temp.attributes["href"] != null && temp.attributes["href"].contains("/a/"); temp = temp.nextElementSibling) {
        authors.add({ int.tryParse(temp?.attributes["href"]?.replaceAll("/a/", "")): temp.text });
      }

      result.add(BookCard(
        id: int.tryParse(bookCardDivs[i].getElementsByTagName("input")?.first?.attributes["name"]?.replaceAll("bchk", "")),
        genres: genres,
        title: title?.text,
        authors: Authors(authors),
        seriesId: series != null ? int.tryParse(series?.attributes["href"]?.replaceAll("/s/", "")) : null,
        seriesName: series?.text,
        translatorId: translator != null ? int.tryParse(translator?.attributes["href"]?.replaceAll("/a/", "")) : null,
        translatorName: translator?.text,
        size: size.text,
        downloadFormats: DownloadFormats(downloadFormats),
      ));
    }

    return result;
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