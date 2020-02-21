import 'package:flibusta/constants.dart';
import 'package:flutter/material.dart';

class LastOpenBooksCard extends StatefulWidget {
  const LastOpenBooksCard({
    Key key,
  });

  @override
  _LastOpenBooksCardState createState() => _LastOpenBooksCardState();
}

class _LastOpenBooksCardState extends State<LastOpenBooksCard> {
  int notSentToWorkGridLength;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 6.0),
          child: Text(
            'Последние открытые книги',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        SizedBox(height: 8),
        Card(
          margin: EdgeInsets.zero,
          child: notSentToWorkGridLength == 0
              ? Column(
                  children: [
                    Container(
                      padding: EdgeInsets.all(20.0),
                      child: Text(
                        'Нет неотправленных заявок',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ],
                )
              : Column(
                  children: [
                    ListTile(
                      title: Text(
                        '',
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: kIconArrowForward,
                      onTap: () {},
                    ),
                    Divider(indent: 16),
                    ListTile(
                      title: Text(
                        '',
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: kIconArrowForward,
                      onTap: () {},
                    ),
                    Divider(indent: 16),
                    ListTile(
                      title: Text(
                        '',
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: kIconArrowForward,
                      onTap: () {},
                    ),
                  ],
                ),
        ),
      ],
    );
  }
}
