import 'package:dio/dio.dart';

class DsError extends DioError {
  String userMessage;

  DsError({
    this.userMessage,
  });

  DsError.fromDioError({DioError dioError}) {
    var userMessage = '';
    this.error = dioError.error;
    this.requestOptions = dioError.requestOptions;
    this.response = dioError.response;
    this.type = dioError.type;

    switch (this.type) {
      case DioErrorType.response:
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
          case 500:
            userMessage = 'Произошла внутренняя ошибка сервера';
            break;
          default:
            userMessage = 'Ошибка подключения к серверу';
            break;
        }
        break;
      case DioErrorType.connectTimeout:
        userMessage = 'Время подключения истекло';
        break;
      case DioErrorType.sendTimeout:
        userMessage = 'Время ожидания отправки запроса истекло';
        break;
      case DioErrorType.receiveTimeout:
        userMessage = 'Время получения данных от сервера истекло';
        break;
      case DioErrorType.cancel:
        if (this.error != null && this.error is String) {
          userMessage = this.error;
        } else {
          userMessage = 'Запрос отменён';
        }
        break;
      case DioErrorType.other:
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
