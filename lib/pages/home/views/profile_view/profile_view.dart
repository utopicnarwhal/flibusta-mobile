import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flibusta/blocs/user_contact_data/user_contact_data_bloc.dart';
import 'package:flibusta/constants.dart';
import 'package:flibusta/ds_controls/theme.dart';
import 'package:flibusta/ds_controls/ui/decor/error_screen.dart';
import 'package:flibusta/ds_controls/ui/decor/staggers.dart';
import 'package:flibusta/ds_controls/ui/progress_indicator.dart';
import 'package:flibusta/pages/home/components/home_bottom_nav_bar.dart';
import 'package:flibusta/pages/home/views/profile_view/pages/about.dart';
import 'package:flibusta/pages/home/views/profile_view/pages/settings.dart';
import 'package:flibusta/pages/login_page/login_page.dart';
import 'package:flibusta/services/http_client.dart';
import 'package:flibusta/utils/dialog_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:rxdart/rxdart.dart';
import 'package:launch_review/launch_review.dart';
import 'package:share/share.dart';

class ProfileView extends StatefulWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;
  final BehaviorSubject<int> selectedNavItemController;

  const ProfileView({
    Key key,
    @required this.scaffoldKey,
    @required this.selectedNavItemController,
  }) : super(key: key);

  @override
  _ProfileViewState createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: widget.scaffoldKey,
      body: SafeArea(
        child: Scrollbar(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                physics: kBouncingAlwaysScrollableScrollPhysics,
                padding: EdgeInsets.fromLTRB(16, 0, 16, 0),
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
                        children: [
                          SizedBox(height: 16),
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: 12.0),
                            child: Text(
                              'Профиль',
                              style: Theme.of(context)
                                  .textTheme
                                  .headline4
                                  .copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodyText2
                                        .color,
                                  ),
                            ),
                          ),
                          SizedBox(height: 16),
                          ProfileScreen(),
                        ],
                      ),
                      if (ProxyHttpClient().isAuthorized())
                        ListFadeInSlideStagger(
                          index: 2,
                          child: Card(
                            margin: EdgeInsets.only(bottom: 16),
                            child: ListTile(
                              title: Text(
                                'Выйти',
                                textAlign: TextAlign.center,
                                style: Theme.of(context)
                                    .textTheme
                                    .button
                                    .copyWith(fontSize: 16),
                              ),
                              onTap: () async {
                                var signOutConfirm =
                                    await DialogUtils.confirmationDialog(
                                  context,
                                  'Выйти из аккаунта?',
                                );
                                if (signOutConfirm == true) {
                                  setState(() {
                                    ProxyHttpClient().signOut();
                                  });
                                }
                              },
                            ),
                          ),
                        ),
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
        index: 3,
        selectedNavItemController: widget.selectedNavItemController,
      ),
    );
  }
}

class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (!ProxyHttpClient().isAuthorized()) ...[
          ListFadeInSlideStagger(
            index: 0,
            child: Card(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(kCardBorderRadius),
                child: Material(
                  type: MaterialType.card,
                  borderRadius: BorderRadius.circular(kCardBorderRadius),
                  child: ListTile(
                    leading: Icon(FontAwesomeIcons.signInAlt),
                    title: Text('Авторизоваться'),
                    onTap: () {
                      Navigator.of(context).pushNamed(LoginPage.routeName);
                    },
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 4),
          ListFadeInSlideStagger(
            index: 0,
            child: Align(
              alignment: Alignment.topRight,
              child: FlatButton(
                child: Text('Что позволяет авторизация?'),
                onPressed: () {
                  DialogUtils.simpleAlert(
                    context,
                    'Что позволяет авторизация?',
                    content: Text(
                        'Вроде бы, вам становится доступна иностранная литература.'),
                  );
                },
              ),
            ),
          ),
        ],
        if (ProxyHttpClient().isAuthorized())
          ListFadeInSlideStagger(
            index: 0,
            child: Card(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(kCardBorderRadius),
                child: Material(
                  type: MaterialType.card,
                  borderRadius: BorderRadius.circular(kCardBorderRadius),
                  child: BlocBuilder<UserContactDataBloc, UserContactDataState>(
                    cubit: UserContactDataBloc(),
                    builder: (context, userContactDataState) {
                      if (userContactDataState is InUserContactDataState) {
                        return ListTile(
                          contentPadding: EdgeInsets.symmetric(
                            vertical: 10,
                            horizontal: 18,
                          ),
                          trailing: CircleAvatar(
                            radius: 30,
                            child: userContactDataState
                                        .userContactData.profileImgSrc ==
                                    null
                                ? Icon(
                                    EvaIcons.personOutline,
                                    size: 34,
                                  )
                                : ClipRRect(
                                    borderRadius: BorderRadius.circular(4),
                                    child: Image.memory(
                                      userContactDataState
                                          .userContactData.profileImg,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                          ),
                          title: Text(
                            userContactDataState.userContactData.nickname ?? '',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          subtitle: Text(
                            userContactDataState.userContactData.email ?? '',
                          ),
                        );
                      }
                      if (userContactDataState is ErrorUserContactDataState) {
                        return ErrorScreen(
                          errorMessage: userContactDataState.error.userMessage,
                          showTextToCheckInternet: false,
                          showIcon: false,
                          onTryAgain: () {
                            UserContactDataBloc().refreshUserContactData();
                          },
                        );
                      }

                      return Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: 14, vertical: 16),
                        child: Center(
                          child: DsCircularProgressIndicator(),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        SizedBox(height: 16),
        ListFadeInSlideStagger(
          index: 1,
          child: Card(
            margin: EdgeInsets.zero,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(kCardBorderRadius),
              child: Material(
                type: MaterialType.card,
                borderRadius: BorderRadius.circular(kCardBorderRadius),
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
                          androidAppId: "ru.utopicnarwhal.flibustabrowser",
                        );
                      },
                    ),
                    Divider(indent: 72),
                    ListTile(
                      leading: Icon(FontAwesomeIcons.shareSquare, size: 26.0),
                      title: Text('Поделиться ссылкой на приложение'),
                      trailing: kIconArrowForward,
                      onTap: () {
                        Share.share(
                            'https://play.google.com/store/apps/details?id=ru.utopicnarwhal.flibustabrowser');
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
          ),
        ),
      ],
    );
  }
}
