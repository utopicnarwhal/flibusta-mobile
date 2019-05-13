import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

class LocalStorage {
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  Future<List<String>> getPreviousBookSearches() async {
    var prefs = await _prefs;
    try {
      var previousBookSearches = prefs.getStringList('previousBookSearches');
      return previousBookSearches ?? [];
    } catch (e) {
      print('getPreviousBookSearches Error: ' + e);
      return [];
    }
  }

  Future<bool> setPreviousBookSearches(List<String> previousBookSearches) async {
    var prefs = await _prefs;
    try {
      return prefs.setStringList('previousBookSearches', previousBookSearches ?? []);
    } catch (e) {
      print('setPreviousBookSearches Error: ' + e);
      return false;
    }
  }

  Future<bool> getIntroCompleted() async {
    var prefs = await _prefs;
    try {
      var introCompleted = prefs.getBool('IntroCompleted');
      if (introCompleted == null) {
        prefs.setBool('IntroCompleted', false);
        introCompleted = false;
      }
      return introCompleted;
    } catch (e) {
      prefs.setBool('IntroCompleted', false);
      return false;
    }
  }

  Future<bool> setIntroCompleted() async {
    var prefs = await _prefs;
    return prefs.setBool('IntroCompleted', true);
  }

  Future<bool> getUseFreeProxy() async {
    var prefs = await _prefs;
    try {
      var useFreeProxy = prefs.getBool('UseFreeProxy');
      if (useFreeProxy == null) {
        prefs.setBool('UseFreeProxy', true);
        useFreeProxy = true;
      }
      return useFreeProxy;
    } catch (e) {
      prefs.setBool('UseFreeProxy', true);
      return true;
    }
  }

  Future<bool> setUseFreeProxy(bool useFreeProxy) async {
    var prefs = await _prefs;
    return prefs.setBool('UseFreeProxy', useFreeProxy);
  }

  Future<String> getActualProxy() async { 
    var prefs = await _prefs;
    try {
      var useFreeProxy = prefs.getBool('UseFreeProxy');
      var actualProxy = '';
      if (useFreeProxy) {
        actualProxy = prefs.getString('ActualFreeProxy');
      } else {
        actualProxy = prefs.getString('ActualCustomProxy');
      }
      return actualProxy;
    } catch (e) {
      return '';
    }
  }

  Future<String> getActualCustomProxy() async {
    var prefs = await _prefs;
    try {
      var actualCustomProxy = prefs.getString('ActualCustomProxy');
      if (actualCustomProxy == null) {
        prefs.setString('ActualCustomProxy', '');
        actualCustomProxy = '';
      }
      return actualCustomProxy;
    } catch (e) {
      prefs.setString('ActualCustomProxy', '');
      return '';
    }
  }

  Future<bool> setActualCustomProxy(String ipPort) async {
    var prefs = await _prefs;
    return prefs.setString('ActualCustomProxy', ipPort);
  }

  Future<String> getActualFreeProxy() async {
    var prefs = await _prefs;
    try {
      var actualFreeProxy = prefs.getString('ActualFreeProxy');
      if (actualFreeProxy == null) {
        prefs.setString('ActualFreeProxy', '');
        actualFreeProxy = '';
      }
      return actualFreeProxy;
    } catch (e) {
      prefs.setString('ActualFreeProxy', '');
      return '';
    }
  }

  Future<bool> setActualFreeProxy(String ipPort) async {
    var prefs = await _prefs;
    return prefs.setString('ActualFreeProxy', ipPort);
  }

  Future<List<String>> getUserProxies() async {
    var prefs = await _prefs;
    try {
      var userProxies = prefs.getStringList('UserProxies');
      if (userProxies == null) {
        prefs.setStringList('UserProxies', List<String>());
        userProxies = List<String>();
      }
      return userProxies;
    } catch (e) {
      prefs.setStringList('UserProxies', List<String>());
      return List<String>();
    }
  }

  Future<bool> addUserProxy(String userProxy) async {
    var prefs = await _prefs;
    var userProxies = await getUserProxies();
    if (userProxies.contains(userProxy))
      return true;
    
    userProxies.add(userProxy);
    return prefs.setStringList('UserProxies', userProxies);
  }

  Future<bool> deleteUserProxy(String userProxy) async {
    var prefs = await _prefs;
    var userProxies = await getUserProxies();
    if (!userProxies.contains(userProxy))
      return true;

    userProxies.remove(userProxy);
    return prefs.setStringList('UserProxies', userProxies);
  }

  Future<String> getFlibustaHostAddress() async {
    var prefs = await _prefs;
    try {
      var flibustaHostAddress = prefs.getString('FlibustaHostAddress');
      if (flibustaHostAddress == null) {
        prefs.setString('FlibustaHostAddress', 'flibusta.is');
        flibustaHostAddress = 'flibusta.is';
      }
      return flibustaHostAddress;
    } catch (e) {
      prefs.setString('FlibustaHostAddress', 'flibusta.is');
      return '';
    }
  }

  Future<bool> setFlibustaHostAddress(String hostAddress) async {
    var prefs = await _prefs;
    return prefs.setString('FlibustaHostAddress', hostAddress);
  }
}