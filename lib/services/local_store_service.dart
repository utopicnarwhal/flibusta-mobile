import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

class LocalStore {
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

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
        // TODO получать выбранный из списка, когда не бесплатный
      }
      return actualProxy;
    } catch (e) {
      return "";
    }
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
}