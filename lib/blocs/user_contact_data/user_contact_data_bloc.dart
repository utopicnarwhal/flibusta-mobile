import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:flibusta/model/extension_methods/dio_error_extension.dart';
import 'package:flibusta/model/userContactData.dart';
import 'package:flibusta/services/http_client/http_client.dart';
import 'package:flibusta/utils/html_parsers.dart';
import 'package:flutter/material.dart';

part 'user_contact_data_event.dart';
part 'user_contact_data_state.dart';
part 'user_contact_data_repository.dart';

class UserContactDataBloc
    extends Bloc<UserContactDataEvent, UserContactDataState> {
  static final UserContactDataBloc _userContactDataBlocSingleton =
      UserContactDataBloc._internal();

  factory UserContactDataBloc() {
    return _userContactDataBlocSingleton;
  }
  UserContactDataBloc._internal() : super(UnUserContactDataState());

  Future<void> fetchUserContactData() async {
    if (state is LoadingUserContactDataState ||
        !ProxyHttpClient().isAuthorized()) {
      return;
    }
    _userContactDataBlocSingleton.add(FetchUserContactDataEvent());
  }

  void refreshUserContactData() {
    if (state is LoadingUserContactDataState ||
        !ProxyHttpClient().isAuthorized()) {
      return;
    }
    _userContactDataBlocSingleton.add(RefreshUserContactDataEvent());
  }

  void signOutUserContactData() {
    if (state is UnUserContactDataState) {
      return;
    }
    _userContactDataBlocSingleton.add(SignOutUserContactDataEvent());
  }

  @override
  Stream<UserContactDataState> mapEventToState(
    UserContactDataEvent event,
  ) async* {
    try {
      yield LoadingUserContactDataState(
        userContactData: state.userContactData,
      );
      yield await event.applyAsync(currentState: state, bloc: this);
    } catch (e) {
      print(e);
      yield ErrorUserContactDataState(
        userContactData: state.userContactData,
        error: DsError(userMessage: 'Необработанная ошибка в mapEventToState'),
      );
    }
  }
}
