import 'dart:math';

import 'package:flibusta/blocs/grid/grid_data/grid_data_bloc.dart';
import 'package:flibusta/blocs/grid/grid_data/grid_data_screen.dart';
import 'package:flibusta/blocs/grid/selected_view_type/selected_view_type_bloc.dart';
import 'package:flibusta/constants.dart';
import 'package:flibusta/ds_controls/default_tab_controller.dart';
import 'package:flibusta/ds_controls/ui/decor/staggers.dart';
import 'package:flibusta/model/enums/gridViewType.dart';
import 'package:flibusta/pages/home/components/home_bottom_nav_bar.dart';
import 'package:flibusta/pages/home/views/books_view/components/books_view_sliver_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:rxdart/rxdart.dart';

class BooksView extends StatelessWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;
  final SelectedViewTypeBloc selectedViewTypeBloc;
  final BehaviorSubject<int> selectedNavItemController;
  final List<GridDataBloc> gridDataBlocsList;
  final TextEditingController searchTextController;

  BooksView({
    @required this.scaffoldKey,
    @required this.selectedViewTypeBloc,
    @required this.selectedNavItemController,
    @required this.searchTextController,
    @required this.gridDataBlocsList,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      body: SafeArea(
        child: DefaultDsTabController(
          onChangeHandler: (newValue) {
            if (newValue > GridViewType.values.length - 1) {
              return;
            }
            selectedViewTypeBloc.changeViewType(GridViewType.values[newValue]);
          },
          length: GridViewType.values.length,
          child: NestedScrollView(
            physics: kBouncingAlwaysScrollableScrollPhysics,
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return [
                SliverOverlapAbsorber(
                  handle: NestedScrollView.sliverOverlapAbsorberHandleFor(
                    context,
                  ),
                  child: BooksViewSliverAppBar(
                    scafffoldKey: scaffoldKey,
                    selectedViewTypeBloc: selectedViewTypeBloc,
                    gridDataBlocsList: gridDataBlocsList,
                    forceElevated: innerBoxIsScrolled,
                    searchTextController: searchTextController,
                  ),
                ),
              ];
            },
            body: Scrollbar(
              child: Builder(
                builder: (context) {
                  List<Widget> tabViews = [];
                  for (var gridViewType in GridViewType.values) {
                    tabViews.add(
                      GridDataScreen(
                        key: ValueKey(gridViewType),
                        scaffoldKey: scaffoldKey,
                        gridDataBloc: gridDataBlocsList[gridViewType.index],
                      ),
                    );
                  }

                  return AnimationLimiter(
                    child: TabBarView(
                      physics: PageScrollPhysics(
                        parent: kBouncingAlwaysScrollableScrollPhysics,
                      ),
                      children: tabViews.map((tabBarView) {
                        return ListFadeInSlideStagger(
                          index: tabViews.indexOf(tabBarView),
                          child: AnimatedBuilder(
                            child: tabBarView,
                            animation:
                                DefaultTabController.of(context).animation,
                            builder: (context, child) {
                              var animationValue =
                                  DefaultTabController.of(context)
                                      .animation
                                      .value;
                              var currentScale =
                                  (pow(animationValue % 1 - 0.5, 2) / 2.5) +
                                      0.9;

                              return Transform(
                                alignment: Alignment.bottomLeft,
                                transform: Matrix4.diagonal3Values(
                                  currentScale,
                                  currentScale,
                                  1.0,
                                ),
                                child: child,
                              );
                            },
                          ),
                        );
                      }).toList(),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: HomeBottomNavBar(
        index: 1,
        selectedNavItemController: selectedNavItemController,
      ),
    );
  }
}
