import 'package:flibusta/model/searchResults.dart';
import 'package:flibusta/pages/book/book_page.dart';
import 'package:flutter/material.dart';

List<Widget> searchResultsBuilder(SearchResults searchResults) {
  final _biggerFont = const TextStyle(fontSize: 18.0);
  
  return <Widget>[
    Scrollbar(
      child: ListView.builder(
        padding: EdgeInsets.all(0),
        itemCount: searchResults.books == null ? 0 : searchResults.books.length,
        itemBuilder: (BuildContext context, int index) {
          return Column(
            children: <Widget>[
              Container(
                decoration: BoxDecoration(color: Colors.white),
                child: Column(
                  children: <Widget>[
                    ListTile(
                      leading: Tooltip(message: "Название произведения", preferBelow: false, child: Icon(Icons.title)),
                      title: Text(searchResults.books[index].title, style: _biggerFont,),
                    ),
                    searchResults.books[index].authors.isNotEmpty ? ListTile(
                      leading: Tooltip(message: "Автор(-ы)", preferBelow: false, child: Icon(Icons.assignment_ind)),
                      title: Text(searchResults.books[index].authors.toString(), style: _biggerFont,),
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
                                  builder: (BuildContext context) => BookPage(bookId: searchResults.books[index].id,),
                                ),
                              );
                            },
                          ),
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
    ),
    Scrollbar(
      child: ListView.builder(
        padding: EdgeInsets.all(0),
        itemCount: searchResults == null ? 0 : searchResults.authors.length,
        itemBuilder: (BuildContext context, int index) {
          return Column(
            children: <Widget>[
              Container(
                decoration: BoxDecoration(color: Colors.white),
                child: Column(
                  children: <Widget>[
                    ListTile(
                      leading: Tooltip(message: "Имя автора", preferBelow: false, child: Icon(Icons.title)),
                      title: Text(searchResults.authors[index].name, style: _biggerFont,),
                    ),
                    searchResults.authors[index].booksCount.isNotEmpty ? ListTile(
                      leading: Tooltip(message: "Количество книг", preferBelow: false, child: Icon(Icons.confirmation_number)),
                      title: Text(searchResults.authors[index].booksCount, style: _biggerFont,),
                    ) : Container(),
                  ],
                )
              ),
              Divider(height: 1,)
            ]
          );
        },
      ),
    ),
    Scrollbar(
      child: ListView.builder(
        padding: EdgeInsets.all(0),
        itemCount: searchResults == null ? 0 : searchResults.sequences.length,
        itemBuilder: (BuildContext context, int index) {
          return Column(
            children: <Widget>[
              Container(
                decoration: BoxDecoration(color: Colors.white),
                child: Column(
                  children: <Widget>[
                    ListTile(
                      leading: Tooltip(message: "Название серии", preferBelow: false, child: Icon(Icons.title)),
                      title: Text(searchResults.sequences[index].title, style: _biggerFont,),
                    ),
                    searchResults.sequences[index].booksCount.isNotEmpty ? ListTile(
                      leading: Tooltip(message: "Количество книг в серии", preferBelow: false, child: Icon(Icons.assignment_ind)),
                      title: Text(searchResults.sequences[index].booksCount, style: _biggerFont,),
                    ) : Container(),
                  ],
                )
              ),
              Divider(height: 1,)
            ]
          );
        },
      ),
    ),
  ];
}