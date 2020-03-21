import 'package:flibusta/blocs/grid/grid_data/grid_data_bloc.dart';
import 'package:flibusta/blocs/grid/selected_view_type/selected_view_type_bloc.dart';
import 'package:flibusta/ds_controls/ui/flexible_space_bar.dart';
import 'package:flibusta/model/enums/gridViewType.dart';
import 'package:flibusta/pages/home/views/books_view/components/advanced_search_page.dart';
import 'package:flibusta/pages/home/views/books_view/components/books_view_search.dart';
import 'package:flibusta/pages/home/views/books_view/components/view_types_tab_bar.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class BooksViewSliverAppBar extends StatelessWidget {
  final GlobalKey<ScaffoldState> scafffoldKey;
  final SelectedViewTypeBloc selectedViewTypeBloc;
  final List<GridDataBloc> gridDataBlocsList;
  final bool forceElevated;
  final TextEditingController searchTextController;

  const BooksViewSliverAppBar({
    @required this.scafffoldKey,
    @required this.selectedViewTypeBloc,
    this.forceElevated,
    @required this.gridDataBlocsList,
    @required this.searchTextController,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<GridViewType>(
      initialData: selectedViewTypeBloc.currentViewType,
      stream: selectedViewTypeBloc.stream,
      builder: (context, userViewTypeSnapshot) {
        return SliverAppBar(
          pinned: true,
          snap: false,
          floating: false,
          expandedHeight: 183,
          forceElevated: forceElevated,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          flexibleSpace: DsFlexibleSpaceBar(
            collapseMode: CollapseMode.pin,
            centerTitle: false,
            scaleTitle: false,
            titlePadding: EdgeInsets.all(0),
            title: ViewTypesTabBar(),
            background: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.fromLTRB(16, 28, 16, 8),
                      child: Text(
                        'Книги',
                        style: Theme.of(context).textTheme.display1.copyWith(
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).textTheme.body1.color,
                            ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0),
                      child: IconButton(
                        icon: Icon(
                          FontAwesomeIcons.filter,
                          size: 22,
                        ),
                        onPressed: () {
                          Navigator.of(context).pushNamed(AdvancedSearchPage.routeName);
                        },
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.0,
                  ),
                  child: BooksViewSearch(
                    currentGridDataBloc:
                        gridDataBlocsList[userViewTypeSnapshot.data?.index],
                    searchTextController: searchTextController,
                  ),
                ),
                SizedBox(height: 48),
              ],
            ),
          ),
        );
      },
    );
  }
}
