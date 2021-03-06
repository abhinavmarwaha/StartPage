import 'package:flutter/widgets.dart';
import 'package:start_page/constants/strings.dart';
import 'package:start_page/models/saved_later_item.dart';
import 'package:start_page/utils/db_helper.dart';

class SavedLaterItemsProvider with ChangeNotifier {
  static final SavedLaterItemsProvider instance =
      SavedLaterItemsProvider._internal();
  factory SavedLaterItemsProvider() {
    return instance;
  }
  SavedLaterItemsProvider._internal() {
    _init();
  }
  bool initilised = false;

  DbHelper _dbHelper;
  Map<String, List<SavedLaterItem>> _savedLaterItems;
  List<SavedLaterItem> _savedLaterItemsAll;
  List<String> _cats;

  List<String> get cats => _cats;

  Future _init() async {
    if (!initilised) {
      _dbHelper = DbHelper();
      _savedLaterItems = {};
      _cats = await _dbHelper.getCategories(SAVEDLATERCATEGORIES);
      List<SavedLaterItem> savedLaterItems =
          await _dbHelper.getSavedLaterItems();
      _savedLaterItemsAll = [];
      _savedLaterItemsAll.addAll(savedLaterItems);

      _cats.forEach((cat) {
        if (_savedLaterItems[cat] == null) _savedLaterItems[cat] = [];
        _savedLaterItems[cat].addAll(savedLaterItems
            .where((element) => element.cat.compareTo(cat) == 0)
            .toList());
      });
      initilised = true;
      notifyListeners();

      print("Saved Later Init Data:  " +
          _cats.join(",") +
          "  Apps: " +
          _savedLaterItems.values
              .map((e) => e.map((e) => e.title + ":" + e.cat).join(","))
              .join(","));
    }
  }

  List<SavedLaterItem> getSavedLaterItems(String cat) =>
      cat.compareTo("All") == 0 ? _savedLaterItemsAll : _savedLaterItems[cat];

  Future insertSavedLater(SavedLaterItem savedLaterItem) async {
    await _dbHelper.insertSavedLaterItem(savedLaterItem);
    if (_savedLaterItems[savedLaterItem.cat] == null)
      _savedLaterItems[savedLaterItem.cat] = [];
    _savedLaterItems[savedLaterItem.cat].add(savedLaterItem);
    _savedLaterItemsAll.add(savedLaterItem);
    notifyListeners();
  }

  Future deleteSavedLater(SavedLaterItem savedLaterItem) async {
    await _dbHelper.deleteSavedLater(savedLaterItem.id);
    _savedLaterItems[savedLaterItem.cat].remove(savedLaterItem);
    _savedLaterItemsAll.remove(savedLaterItem);
    notifyListeners();
  }

  Future insertCategory(String cat) async {
    await _dbHelper.insertCategory(cat, SAVEDLATERCATEGORIES);
    _savedLaterItems[cat] = [];
    _cats.add(cat);
    notifyListeners();
  }

  Future deleteCategory(String cat) async {
    await _dbHelper.deleteCat(cat, SAVEDLATERCATEGORIES, SAVEDLATERITEM);
    _cats.remove(cat);
    _savedLaterItems[cat].clear();
    _savedLaterItemsAll
        .removeWhere((element) => element.cat.compareTo(cat) == 0);
    notifyListeners();
  }

  Future editCategory(String catPrev, String catNew) async {
    await _dbHelper.editCategory(catPrev, catNew, SAVEDLATERCATEGORIES);
    int index = _cats.indexOf(catPrev);
    _cats[index] = catNew;
    _savedLaterItems[catNew] = [];
    for (int i = 0; i < _savedLaterItems[catPrev].length; i++) {
      final savedLaterItem = _savedLaterItems[catPrev][i];
      savedLaterItem.cat = catNew;
      _dbHelper.editSavedLater(savedLaterItem);
      _savedLaterItems[catNew].add(savedLaterItem);
    }
    _savedLaterItems[catPrev].clear();
    // _savedLaterItems[catPrev] = null;
    notifyListeners();
  }

  // Future editCategory(String catPrev, String catNew) async {
  //   await _dbHelper.editCategory(catPrev, catNew, APPCATEGORIES);
  //   int index = _cats.indexOf(catPrev);
  //   _cats[index] = catNew;
  //   _startApps[catNew] = [];
  //   for (int i = 0; i < _startApps[catPrev].length; i++) {
  //     final app = _startApps[catPrev][i];
  //     app.cat = catNew;
  //
  //   }
  //
  //   notifyListeners();
  // }
}
