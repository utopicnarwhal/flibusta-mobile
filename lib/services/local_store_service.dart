import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

class LocalStore {
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  Future<bool> getIsDarkTheme() async {
    var prefs = await _prefs;
    try {
      var isDarkTheme = prefs.getBool("DarkTheme");
      if (isDarkTheme == null) {
        prefs.setBool("DarkTheme", false);
        isDarkTheme = false;
      }
      return isDarkTheme;
    } catch (e) {
      prefs.setBool("DarkTheme", false);
      return false;
    }
  }

  Future<bool> setIsDarkTheme(bool value) async {
    var prefs = await _prefs;
    return prefs.setBool("DarkTheme", value);
  }

  Future<bool> getIntroComplete() async {
    var prefs = await _prefs;
    try {
      var introComplete = prefs.getBool("IntroComplete");
      if (introComplete == null) {
        prefs.setBool("IntroComplete", false);
        introComplete = false;
      }
      return introComplete;
    } catch (e) {
      prefs.setBool("IntroComplete", false);
      return false;
    }
  }

  Future<bool> setIntroComplete() async {
    var prefs = await _prefs;
    return prefs.setBool("IntroComplete", true);
  }

  Future<bool> getUseFreeProxy() async {
    var prefs = await _prefs;
    try {
      var useFreeProxy = prefs.getBool("UseFreeProxy");
      if (useFreeProxy == null) {
        prefs.setBool("UseFreeProxy", true);
        useFreeProxy = true;
      }
      return useFreeProxy;
    } catch (e) {
      prefs.setBool("UseFreeProxy", true);
      return true;
    }
  }

  Future<bool> setUseFreeProxy(bool useFreeProxy) async {
    var prefs = await _prefs;
    return prefs.setBool("UseFreeProxy", useFreeProxy);
  }

  Future<String> getActualProxy() async { 
    var prefs = await _prefs;
    try {
      var useFreeProxy = prefs.getBool("UseFreeProxy");
      var actualProxy = "";
      if (useFreeProxy) {
        actualProxy = prefs.getString("ActualFreeProxy");
      } else {
        actualProxy = prefs.getString("ActualCustomProxy");
      }
      return actualProxy;
    } catch (e) {
      return "";
    }
  }

  Future<String> getActualCustomProxy() async {
    var prefs = await _prefs;
    try {
      var actualCustomProxy = prefs.getString("ActualCustomProxy");
      if (actualCustomProxy == null) {
        prefs.setString("ActualCustomProxy", "");
        actualCustomProxy = "";
      }
      return actualCustomProxy;
    } catch (e) {
      prefs.setString("ActualCustomProxy", "");
      return "";
    }
  }

  Future<bool> setActualCustomProxy(String ipPort) async {
    var prefs = await _prefs;
    return prefs.setString("ActualCustomProxy", ipPort);
  }

  Future<String> getActualFreeProxy() async {
    var prefs = await _prefs;
    try {
      var actualFreeProxy = prefs.getString("ActualFreeProxy");
      if (actualFreeProxy == null) {
        prefs.setString("ActualFreeProxy", "");
        actualFreeProxy = "";
      }
      return actualFreeProxy;
    } catch (e) {
      prefs.setString("ActualFreeProxy", "");
      return "";
    }
  }

  Future<bool> setActualFreeProxy(String ipPort) async {
    var prefs = await _prefs;
    return prefs.setString("ActualFreeProxy", ipPort);
  }

  Future<List<String>> getUserProxies() async {
    var prefs = await _prefs;
    try {
      var userProxies = prefs.getStringList("UserProxies");
      if (userProxies == null) {
        prefs.setStringList("UserProxies", List<String>());
        userProxies = List<String>();
      }
      return userProxies;
    } catch (e) {
      prefs.setStringList("UserProxies", List<String>());
      return List<String>();
    }
  }

  Future<bool> addUserProxy(String userProxy) async {
    var prefs = await _prefs;
    var userProxies = await getUserProxies();
    if (userProxies.contains(userProxy))
      return true;
    
    userProxies.add(userProxy);
    return prefs.setStringList("UserProxies", userProxies);
  }

  Future<bool> deleteUserProxy(String userProxy) async {
    var prefs = await _prefs;
    var userProxies = await getUserProxies();
    if (!userProxies.contains(userProxy))
      return true;

    userProxies.remove(userProxy);
    return prefs.setStringList("UserProxies", userProxies);
  }

  Future<String> getFlibustaHostAddress() async {
    var prefs = await _prefs;
    try {
      var flibustaHostAddress = prefs.getString("FlibustaHostAddress");
      if (flibustaHostAddress == null) {
        prefs.setString("FlibustaHostAddress", "flibusta.is");
        flibustaHostAddress = "flibusta.is";
      }
      return flibustaHostAddress;
    } catch (e) {
      prefs.setString("FlibustaHostAddress", "flibusta.is");
      return "";
    }
  }

  Future<bool> setFlibustaHostAddress(String hostAddress) async {
    var prefs = await _prefs;
    return prefs.setString("FlibustaHostAddress", hostAddress);
  }
}