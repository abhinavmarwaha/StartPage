import 'dart:math';

import 'package:flutter/widgets.dart';
import 'package:start_page/constants/colors.dart';
import 'package:start_page/constants/strings.dart';
import 'package:start_page/models/start_app.dart';
import 'package:start_page/utils/db_helper.dart';

class StartAppsProvider with ChangeNotifier {
  static final StartAppsProvider instance = StartAppsProvider._internal();
  factory StartAppsProvider() {
    return instance;
  }
  StartAppsProvider._internal() {
    _init();
  }
  bool initilised = false;
  Random rng = new Random();

  DbHelper _dbHelper;
  Map<String, List<StartApp>> _startApps;
  List<String> _cats;

  List<String> get cats => _cats;

  Future _init() async {
    if (!initilised) {
      _dbHelper = DbHelper();
      _startApps = {};
      _cats = await _dbHelper.getCategories(APPCATEGORIES);
      List<StartApp> startApps = await _dbHelper.getStartApps();

      _cats.forEach((cat) {
        if (_startApps[cat] == null) _startApps[cat] = [];
        _startApps[cat].addAll(startApps
            .where((element) => element.cat.compareTo(cat) == 0)
            .toList());
      });
      initilised = true;
      notifyListeners();

      print("Init Data:  " +
          _cats.join(",") +
          "  Apps: " +
          _startApps.values
              .map((e) => e.map((e) => e.title + ":" + e.cat).join(","))
              .join(","));
    }
  }

  List<StartApp> getStartApps(String cat) => _startApps[cat];

  Future insertStartApp(StartApp startApp) async {
    startApp.color =
        appColors.keys.toList()[rng.nextInt(appColors.keys.length)];
    await _dbHelper.insertStartApp(startApp);
    if (_startApps[startApp.cat] == null) _startApps[startApp.cat] = [];
    _startApps[startApp.cat].add(startApp);
    notifyListeners();
  }

  Future insertCategory(String cat) async {
    await _dbHelper.insertCategory(cat, APPCATEGORIES);
    _startApps[cat] = [];
    _cats.add(cat);
    notifyListeners();
  }

  Future deleteStartApp(StartApp startApp) async {
    await _dbHelper.deleteStartApp(startApp.id);
    _startApps[startApp.cat].remove(startApp);
    notifyListeners();
  }

  Future deleteCategory(String cat) async {
    await _dbHelper.deleteCat(cat, APPCATEGORIES, STARTAPP);
    _cats.remove(cat);
    _startApps[cat].clear();
    notifyListeners();
  }

  Future editCategory(String catPrev, String catNew) async {
    await _dbHelper.editCategory(catPrev, catNew, APPCATEGORIES);
    int index = _cats.indexOf(catPrev);
    _cats[index] = catNew;
    _startApps[catNew] = [];
    for (int i = 0; i < _startApps[catPrev].length; i++) {
      final app = _startApps[catPrev][i];
      app.cat = catNew;
      _dbHelper.editStartApp(app);
      _startApps[catNew].add(app);
    }
    _startApps[catPrev].clear();
    _startApps[catPrev] = null;
    notifyListeners();
  }
}
