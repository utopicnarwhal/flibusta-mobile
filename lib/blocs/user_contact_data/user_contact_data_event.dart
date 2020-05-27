part of 'user_contact_data_bloc.dart';

@immutable
abstract class UserContactDataEvent extends Equatable {
  final List inProps;

  UserContactDataEvent([this.inProps = const []]);

  @override
  List<Object> get props => inProps;

  Future<UserContactDataState> applyAsync(
      {UserContactDataState currentState, UserContactDataBloc bloc});

  final UserContactDataRepository _userContactDataRepository =
      UserContactDataRepository();
}

class FetchUserContactDataEvent extends UserContactDataEvent {
  @override
  String toString() => 'FetchUserContactDataEvent';

  @override
  Future<UserContactDataState> applyAsync(
      {UserContactDataState currentState, UserContactDataBloc bloc}) async {
    try {
      var userContactData =
          await _userContactDataRepository.getUserContactData();

      if (userContactData == null) {
        throw DsError(
          userMessage: 'Не удалось получить данные о пользователе',
        );
      }

      if (userContactData.profileImgSrc != null) {
        userContactData.profileImg = await _userContactDataRepository
            .getUserProfileImg(userContactData.profileImgSrc);
      }

      return InUserContactDataState(
        userContactData: userContactData,
      );
    } on DsError catch (dcError) {
      return ErrorUserContactDataState(
        userContactData: currentState.userContactData,
        error: dcError,
      );
    }
  }
}

class RefreshUserContactDataEvent extends UserContactDataEvent {
  @override
  String toString() => 'RefreshUserContactDataEvent';

  @override
  Future<UserContactDataState> applyAsync(
      {UserContactDataState currentState, UserContactDataBloc bloc}) async {
    try {
      var userContactData =
          await _userContactDataRepository.getUserContactData();

      if (userContactData == null) {
        throw DsError(
          userMessage: 'Не удалось получить данные о пользователе',
        );
      }

      if (userContactData.profileImgSrc != null) {
        userContactData.profileImg = await _userContactDataRepository
            .getUserProfileImg(userContactData.profileImgSrc);
      }

      return InUserContactDataState(
        userContactData: userContactData,
      );
    } on DsError catch (dcError) {
      return ErrorUserContactDataState(
        userContactData: currentState.userContactData,
        error: dcError,
      );
    }
  }
}
