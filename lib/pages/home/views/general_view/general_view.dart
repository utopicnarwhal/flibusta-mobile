import 'package:flibusta/constants.dart';
import 'package:flibusta/pages/home/components/home_bottom_nav_bar.dart';
import 'package:flibusta/pages/home/views/general_view/components/last_open_books.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

class GeneralView extends StatelessWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;
  final BehaviorSubject<int> selectedNavItemController;

  const GeneralView({
    Key key,
    @required this.scaffoldKey,
    @required this.selectedNavItemController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<Widget> children = [
      Padding(
        padding: EdgeInsets.symmetric(vertical: 12.0),
        child: Text(
          'Главная',
          style: Theme.of(context).textTheme.display1.copyWith(
                fontWeight: FontWeight.w600,
                color: Theme.of(context).textTheme.body1.color,
              ),
        ),
      ),
      SizedBox(height: 8),
      LastOpenBooksCard(),
      SizedBox(height: 8),
    ];

    return Scaffold(
      key: scaffoldKey,
      body: SafeArea(
        // child: RefreshIndicator(
        //   onRefresh: () async {
        //     UserContactDataBloc().refreshUserContactData();
        //   },
        child: Scrollbar(
          child: ListView(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 42),
            physics: kBouncingAlwaysScrollableScrollPhysics,
            addSemanticIndexes: false,
            children: children,
          ),
        ),
        // ),
      ),
      bottomNavigationBar: HomeBottomNavBar(
        index: 0,
        selectedNavItemController: selectedNavItemController,
      ),
    );
  }
}
