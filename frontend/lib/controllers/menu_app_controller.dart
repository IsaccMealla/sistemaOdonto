import 'package:flutter/material.dart';

class MenuAppController extends ChangeNotifier {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String _currentPage = 'dashboard';
  Map<String, dynamic>? _currentPageArgs;

  GlobalKey<ScaffoldState> get scaffoldKey => _scaffoldKey;
  String get currentPage => _currentPage;
  Map<String, dynamic>? get currentPageArgs => _currentPageArgs;

  void controlMenu() {
    if (!_scaffoldKey.currentState!.isDrawerOpen) {
      _scaffoldKey.currentState!.openDrawer();
    }
  }

  void setPage(String page) {
    _currentPage = page;
    _currentPageArgs = null;
    notifyListeners();
    // close drawer if open
    if (_scaffoldKey.currentState != null &&
        _scaffoldKey.currentState!.isDrawerOpen) {
      _scaffoldKey.currentState!.openEndDrawer();
    }
  }

  void setPageWithArgs(String page, Map<String, dynamic>? args) {
    _currentPage = page;
    _currentPageArgs = args;
    notifyListeners();
    if (_scaffoldKey.currentState != null &&
        _scaffoldKey.currentState!.isDrawerOpen) {
      _scaffoldKey.currentState!.openEndDrawer();
    }
  }
}
