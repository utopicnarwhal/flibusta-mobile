import 'package:flibusta/ds_controls/theme.dart';
import 'package:flibusta/pages/favorites/favorites_page.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class FavoritesCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 6.0),
          child: Text(
            'Избранные',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        SizedBox(height: 8),
        Card(
          margin: EdgeInsets.zero,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(kCardBorderRadius),
            child: Material(
              type: MaterialType.card,
              borderRadius: BorderRadius.circular(kCardBorderRadius),
              child: SizedBox(
                height: 90,
                child: Flex(
                  direction: Axis.horizontal,
                  children: [
                    Flexible(
                      fit: FlexFit.tight,
                      child: InkWell(
                        onTap: () {
                          Navigator.of(context).pushNamed(
                            FavoritesPage.routeName,
                            arguments: FavoritesType.Book,
                          );
                        },
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Icon(
                                FontAwesomeIcons.book,
                                size: 26,
                              ),
                            ),
                            Text(
                              'Книги',
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodyText1,
                            ),
                          ],
                        ),
                      ),
                    ),
                    VerticalDivider(
                      indent: 20,
                      endIndent: 20,
                    ),
                    Flexible(
                      fit: FlexFit.tight,
                      child: InkWell(
                        onTap: () {
                          Navigator.of(context).pushNamed(
                            FavoritesPage.routeName,
                            arguments: FavoritesType.Author,
                          );
                        },
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Icon(
                                FontAwesomeIcons.userEdit,
                                size: 26,
                              ),
                            ),
                            Text(
                              'Авторы',
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodyText1,
                            ),
                          ],
                        ),
                      ),
                    ),
                    VerticalDivider(
                      indent: 20,
                      endIndent: 20,
                    ),
                    Flexible(
                      fit: FlexFit.tight,
                      child: InkWell(
                        onTap: () {
                          Navigator.of(context).pushNamed(
                            FavoritesPage.routeName,
                            arguments: FavoritesType.Sequence,
                          );
                        },
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Icon(
                                FontAwesomeIcons.listOl,
                                size: 26,
                              ),
                            ),
                            Text(
                              'Серии',
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodyText1,
                            ),
                          ],
                        ),
                      ),
                    ),
                    VerticalDivider(
                      indent: 20,
                      endIndent: 20,
                    ),
                    Flexible(
                      fit: FlexFit.tight,
                      child: InkWell(
                        onTap: () {
                          Navigator.of(context).pushNamed(
                            FavoritesPage.routeName,
                            arguments: FavoritesType.Postpone,
                          );
                        },
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Icon(
                                FontAwesomeIcons.clock,
                                size: 26,
                              ),
                            ),
                            Text(
                              'На потом',
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodyText1,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
