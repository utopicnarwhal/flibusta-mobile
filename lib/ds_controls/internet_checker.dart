import 'dart:async';
import 'dart:io';

import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:data_connection_checker/data_connection_checker.dart';
import 'package:rxdart/subjects.dart';
import 'package:utopic_toast/utopic_toast.dart';

class InternetChecker extends StatefulWidget {
  final Widget child;

  const InternetChecker({Key key, this.child}) : super(key: key);

  static InternetCheckerState of(BuildContext context) {
    assert(context != null);
    final InternetCheckerState result =
        context.findAncestorStateOfType<InternetCheckerState>();

    return result;
  }

  @override
  InternetCheckerState createState() => InternetCheckerState();
}

class InternetCheckerState extends State<InternetChecker> {
  StreamSubscription<ConnectivityResult> _connectivitySubscription;
  StreamSubscription<DataConnectionStatus> _dataConnectionSubscription;
  BehaviorSubject<bool> isInternetAvailableController;
  DataConnectionChecker _dataConnectionChecker;

  @override
  void initState() {
    super.initState();

    isInternetAvailableController = BehaviorSubject<bool>.seeded(true);

    _dataConnectionChecker = DataConnectionChecker();
    _dataConnectionChecker.checkInterval = Duration(seconds: 6);
    _dataConnectionChecker.addresses = List.unmodifiable([
      AddressCheckOptions(
        InternetAddress('8.8.4.4'),
      ),
    ]);

    _connectivitySubscription =
        Connectivity().onConnectivityChanged.listen((result) async {
      _onConnectionChange(await _dataConnectionChecker.connectionStatus);
    });

    _dataConnectionSubscription =
        _dataConnectionChecker.onStatusChange.listen(_onConnectionChange);
  }

  void _onConnectionChange(DataConnectionStatus status) {
    switch (status) {
      case DataConnectionStatus.connected:
        if (!isInternetAvailableController.value) {
          ToastManager().showToast(
            'Соединение с интернетом восстановлено',
            type: ToastType.success,
          );
          isInternetAvailableController.add(true);
        }
        break;
      case DataConnectionStatus.disconnected:
        if (isInternetAvailableController.value) {
          ToastManager().showToast(
            'Отсутствует соединение с интернетом',
            type: ToastType.warning,
          );
          isInternetAvailableController.add(false);
        }
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }

  @override
  void dispose() {
    isInternetAvailableController?.close();
    _dataConnectionSubscription?.cancel();
    _connectivitySubscription?.cancel();
    super.dispose();
  }
}
