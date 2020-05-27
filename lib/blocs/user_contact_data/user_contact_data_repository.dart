part of 'user_contact_data_bloc.dart';

class UserContactDataRepository {
  Future<UserContactData> getUserContactData() async {
    var profileUrl = Uri.https(
      ProxyHttpClient().getHostAddress(),
      '/user/me/edit',
    );

    var response = await ProxyHttpClient().getDio().getUri(profileUrl);

    if (response != null && response.data != null && response.data is String) {
      var userData = parseHtmlFromUserMeEdit(response.data);

      return userData;
    }
    return null;
  }

  Future<List<int>> getUserProfileImg(String profileImgSrc) async {
    var profileImgUrl = Uri.https(
      ProxyHttpClient().getHostAddress(),
      profileImgSrc,
    );

    var response = await ProxyHttpClient().getDio().getUri<List<int>>(
          profileImgUrl,
          options: Options(
            sendTimeout: 15000,
            receiveTimeout: 8000,
            responseType: ResponseType.bytes,
          ),
        );

    return response.data;
  }
}
