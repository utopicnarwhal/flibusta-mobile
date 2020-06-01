part of 'user_contact_data_bloc.dart';

@immutable
abstract class UserContactDataState extends Equatable {
  final UserContactData userContactData;
  final List inProps;

  UserContactDataState({
    this.userContactData,
    this.inProps = const [],
  });

  @override
  List<Object> get props => inProps;

  UserContactDataState getStateCopy();
}

class LoadingUserContactDataState extends UserContactDataState {
  LoadingUserContactDataState({
    UserContactData userContactData,
  }) : super(
          userContactData: userContactData,
        );

  @override
  LoadingUserContactDataState getStateCopy() {
    return LoadingUserContactDataState(
      userContactData: userContactData,
    );
  }
}

class UnUserContactDataState extends UserContactDataState {
  @override
  UnUserContactDataState getStateCopy() {
    return UnUserContactDataState();
  }
}

class InUserContactDataState extends UserContactDataState {
  InUserContactDataState({
    UserContactData userContactData,
  }) : super(
          userContactData: userContactData,
        );

  @override
  InUserContactDataState getStateCopy() {
    return InUserContactDataState(
      userContactData: userContactData,
    );
  }
}

class ErrorUserContactDataState extends UserContactDataState {
  final DsError error;

  ErrorUserContactDataState({
    UserContactData userContactData,
    this.error,
  }) : super(
          userContactData: userContactData,
        );

  @override
  ErrorUserContactDataState getStateCopy() {
    return ErrorUserContactDataState(
      userContactData: userContactData,
      error: error,
    );
  }
}
