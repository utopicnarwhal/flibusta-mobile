import 'package:dio/dio.dart';

class DsError extends DioError {
  String userMessage;

  DsError({
    this.userMessage,
  });

  DsError.fromDioError({DioError dioError}) {
    var userMessage = '';
    this.error = dioError.error;
    this.request = dioError.request;
    this.response = dioError.response;
    this.type = dioError.type;

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
              userMessage = 'Ошибка подключения к серверу Росбанк ДомPro';
            }
            break;
          case 500:
            userMessage = 'Произошла внутренняя ошибка сервера Росбанк ДомPro';
            break;
          default:
            userMessage = 'Ошибка подключения к серверу Росбанк ДомPro';
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
    this.userMessage = userMessage;
  }

  @override
  String toString() {
    return userMessage;
  }
}
