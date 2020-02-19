import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flibusta/constants.dart';
import 'package:flibusta/ds_controls/ui/decor/staggers.dart';
import 'package:flibusta/pages/home/components/home_bottom_nav_bar.dart';
import 'package:flibusta/pages/home/views/profile_view/components/about/about.dart';
import 'package:flibusta/pages/home/views/profile_view/components/settings/settings.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:launch_review/launch_review.dart';

class ProfileView extends StatelessWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;
  final BehaviorSubject<int> selectedNavItemController;

  const ProfileView({
    Key key,
    @required this.scaffoldKey,
    @required this.selectedNavItemController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      body: SafeArea(
        child: Scrollbar(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                physics: kBouncingAlwaysScrollableScrollPhysics,
                padding: EdgeInsets.fromLTRB(16, 16, 16, 42),
                child: Container(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight,
                    maxWidth: constraints.maxWidth,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: 12.0),
                            child: Text(
                              'Профиль',
                              style: Theme.of(context)
                                  .textTheme
                                  .display1
                                  .copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: Theme.of(context)
                                        .textTheme
                                        .body1
                                        .color,
                                  ),
                            ),
                          ),
                          SizedBox(height: 16),
                          ProfileScreen(),
                          SizedBox(height: 16),
                        ],
                      ),
                      // ListFadeInSlideStagger(
                      //   index: 2,
                      //   child: Card(
                      //     margin: EdgeInsets.zero,
                      //     child: ListTile(
                      //       title: Text(
                      //         'Выйти',
                      //         textAlign: TextAlign.center,
                      //       ),
                      //       onTap: () async {
                      //         var signOutConfirm =
                      //             await DialogUtils.confirmationDialog(
                      //           context,
                      //           'Выйти из аккаунта?',
                      //         );
                      //         if (signOutConfirm == true) {
                      //           AuthenticationBloc().signOut();
                      //         }
                      //       },
                      //     ),
                      //   ),
                      // ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
      bottomNavigationBar: HomeBottomNavBar(
        key: Key('HomeBottomNavBar'),
        index: 4,
        selectedNavItemController: selectedNavItemController,
      ),
    );
  }
}

class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // BlocBuilder(
        //   bloc: ProfileDataBloc(),
        //   builder: (context, profileDataState) {
        //     Widget child = profileDataState is InProfileDataState
        //         ? Card(
        //             child: ListTile(
        //               contentPadding: EdgeInsets.symmetric(
        //                 vertical: 10,
        //                 horizontal: 18,
        //               ),
        //               trailing: CircleAvatar(
        //                 radius: 30,
        //                 child: Text(
        //                   StringUtils.getInitials(
        //                       firstname:
        //                           profileDataState.profileData?.firstName,
        //                       lastname: profileDataState.profileData?.lastName),
        //                   style: TextStyle(
        //                     fontSize: 24,
        //                     fontWeight: FontWeight.w400,
        //                   ),
        //                 ),
        //               ),
        //               title: Text(
        //                 StringUtils.getShortName(
        //                     firstname: profileDataState.profileData?.firstName,
        //                     lastname: profileDataState.profileData?.lastName),
        //                 style: TextStyle(
        //                   fontSize: 16,
        //                   fontWeight: FontWeight.w800,
        //                 ),
        //               ),
        //               subtitle: Padding(
        //                 padding: const EdgeInsets.only(top: 8.0),
        //                 child: Text(
        //                   UserUtils.getUserCustomerType(
        //                       customerTypeCode: profileDataState
        //                           .profileData?.customerTypeCode),
        //                 ),
        //               ),
        //               onTap: () {
        //                 Navigator.of(context).pushNamed(ProfilePage.routeName);
        //               },
        //             ),
        //           )
        //         : Container();

        //     return ListFadeInSlideStagger(
        //       index: 1,
        //       child: child,
        //     );
        //   },
        // ),
        // SizedBox(height: 16),
        ListFadeInSlideStagger(
          index: 1,
          child: Card(
            margin: EdgeInsets.zero,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                ListTile(
                  leading: Icon(EvaIcons.settings2Outline, size: 26.0),
                  title: Text('Настройки'),
                  trailing: kIconArrowForward,
                  onTap: () {
                    Navigator.of(context).pushNamed(SettingsPage.routeName);
                  },
                ),
                Divider(indent: 72),
                ListTile(
                  leading: Icon(EvaIcons.starOutline, size: 26.0),
                  title: Text('Оценить приложение'),
                  trailing: kIconArrowForward,
                  onTap: () {
                    LaunchReview.launch(
                      androidAppId: "ru.utopicnarwhal.flibusta",
                    );
                  },
                ),
                Divider(indent: 72),
                ListTile(
                  leading: Icon(EvaIcons.infoOutline, size: 26.0),
                  title: Text('О приложении'),
                  trailing: kIconArrowForward,
                  onTap: () {
                    Navigator.of(context).pushNamed(AboutPage.routeName);
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
