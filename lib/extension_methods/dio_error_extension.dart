import 'package:dio/dio.dart';

class DsError {
  final String userMessage;
  final DioError dioError;

  DsError({
    this.userMessage,
    this.dioError,
  });

  @override
  String toString() {
    return userMessage;
  }
}

extension DioErrorExtension on DioError {
  DsError handleHttpError() {
    var userMessage = '';
    switch (this.type) {
      case DioErrorType.RESPONSE:
        switch (this.response.statusCode) {
          case 401:
            userMessage = 'Необходима авторизация';
            break;
          case 400:
            if (this?.response?.data != null &&
                this.response.data is Map<String, dynamic> &&
                this.response.data['Message'] != null) {
              userMessage = '${this.response.data['Message'].toString()}';
            } else {
              userMessage = 'Ошибка подключения к серверу';
            }
            break;
          default:
            userMessage = 'Ошибка подключения к серверу';
            break;
        }
        break;
      case DioErrorType.CONNECT_TIMEOUT:
        userMessage = 'Время подключения истекло';
        break;
      case DioErrorType.SEND_TIMEOUT:
        userMessage = 'Время ожидания отправки запроса истекло';
        break;
      case DioErrorType.RECEIVE_TIMEOUT:
        userMessage = 'Время ожидания отклика сервера истекло';
        break;
      case DioErrorType.CANCEL:
        if (this.error != null && this.error is String) {
          userMessage = this.error;
        } else {
          userMessage = 'Запрос отменён';
        }
        break;
      case DioErrorType.DEFAULT:
        userMessage = 'Ошибка подключения к серверу';
        break;
    }
    return DsError(
      userMessage: userMessage,
      dioError: this,
    );
  }
}
