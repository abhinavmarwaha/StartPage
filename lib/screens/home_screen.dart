import 'package:device_apps/device_apps.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:provider/provider.dart';
import 'package:start_page/constants/colors.dart';
import 'package:start_page/constants/dimensions.dart';
import 'package:start_page/models/start_app.dart';
import 'package:start_page/providers/start_apps_provider.dart';
import 'package:start_page/screens/saved_later_screen.dart';
import 'package:start_page/utils/ThemeChanger.dart';
import 'package:start_page/utils/custom_icons.dart';
import 'package:start_page/utils/utilities.dart';

class HomeScreen extends StatefulWidget {
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _darkMode = false;
  String title;

  @override
  void initState() {
    ThemeChanger.getDarkModePlainBool().then((value) {
      setState(() {
        _darkMode = value;
      });
    });
    Utilities.getStartPageTitle().then((value) => setState(() {
          title = value;
        }));
    super.initState();
  }

  GlobalKey<ScaffoldState> _globalKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Consumer<StartAppsProvider>(
        builder: (context, provider, child) => Scaffold(
              key: _globalKey,
              resizeToAvoidBottomInset: false,
              floatingActionButton: buildSpeedDial(provider),
              body: !provider.initilised
                  ? Center(
                      child: CircularProgressIndicator(),
                    )
                  : Padding(
                      padding: MediaQuery.of(context).padding,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(children: [
                              GestureDetector(
                                onLongPressEnd: (details) {
                                  showEditStartPageDialog();
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    title,
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                              Spacer(),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: GestureDetector(
                                    onTap: () {
                                      ThemeChanger _themeChanger =
                                          Provider.of<ThemeChanger>(context,
                                              listen: false);
                                      _darkMode = !_darkMode;
                                      _themeChanger.setDarkMode(_darkMode);
                                    },
                                    child: Icon(_darkMode
                                        ? CustomIcons.sun
                                        : CustomIcons.moon)),
                              )
                            ]),
                            SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 7 / 9,
                                child: ListView(
                                  children: provider.cats.map<Widget>((cat) {
                                    if (cat.compareTo("None") == 0) {
                                      return gridView(provider, cat);
                                    } else {
                                      return Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          GestureDetector(
                                            onLongPressEnd: (details) {
                                              showDeleteEditCatDialog(
                                                  context, provider, cat);
                                            },
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Text(
                                                cat,
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ),
                                          ),
                                          gridView(provider, cat)
                                        ],
                                      );
                                    }
                                  }).toList(),
                                )),
                            RaisedButton(
                              color: Colors.blueAccent,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15.0)),
                              onPressed: () {
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) => SavedLaterScreen()));
                              },
                              child: Center(
                                  child: Text(
                                "Saved For Later",
                                style: TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.w400),
                              )),
                            )
                          ],
                        ),
                      ),
                    ),
            ));
  }

  Widget gridView(StartAppsProvider provider, String cat) {
    if (provider.getStartApps(cat).length == 0) return Container();
    return GridView.builder(
      physics: NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: provider.getStartApps(cat).length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: MediaQuery.of(context).size.width /
              (MediaQuery.of(context).size.height / 5)),
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () {
            if (provider.getStartApps(cat)[index].app) {
              DeviceApps.openApp(provider.getStartApps(cat)[index].url);
            } else {
              Utilities.launchUrl(provider.getStartApps(cat)[index].url);
            }
          },
          onLongPressEnd: (details) {
            showDeleteDialog(
                context, provider, provider.getStartApps(cat)[index]);
          },
          child: Card(
            elevation: CARDELEVATION,
            color: appColors[provider.getStartApps(cat)[index].color],
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0)),
            child: Stack(children: [
              // Positioned.fill(
              //     child: Align(
              //   alignment: Alignment.topLeft,
              //   child: Padding(
              //     padding: const EdgeInsets.all(8.0),
              //     child: Icon(
              //       provider.getStartApps(cat)[index].app
              //           ? Icons.apps
              //           : Icons.web,
              //       size: 14,
              //     ),
              //   ),
              // )),
              Positioned.fill(
                child: Align(
                    alignment: Alignment.bottomRight,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        provider.getStartApps(cat)[index].title,
                        maxLines: 1,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )),
              ),
            ]),
          ),
        );
      },
    );
  }

  Widget buildSpeedDial(StartAppsProvider provider) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 60),
      child: SpeedDial(
        child: Icon(Icons.add),
        animatedIconTheme: IconThemeData(size: 22.0),
        curve: Curves.bounceIn,
        children: [
          SpeedDialChild(
            child: Icon(Icons.apps, color: Colors.white),
            backgroundColor: Colors.deepOrange,
            onTap: () => showAppAddDialog(context, provider),
            label: 'App',
            labelStyle: TextStyle(fontWeight: FontWeight.w500),
            labelBackgroundColor: Colors.deepOrangeAccent,
          ),
          SpeedDialChild(
            child: Icon(Icons.web, color: Colors.white),
            backgroundColor: Colors.green,
            onTap: () => showWebAddDialog(context, provider),
            label: 'Website',
            labelStyle: TextStyle(fontWeight: FontWeight.w500),
            labelBackgroundColor: Colors.green,
          ),
          SpeedDialChild(
            child: Icon(Icons.category, color: Colors.white),
            backgroundColor: Colors.blueAccent,
            onTap: () => showCatAddDialog(context, provider),
            label: 'Category',
            labelStyle: TextStyle(fontWeight: FontWeight.w500),
            labelBackgroundColor: Colors.blueAccent,
          ),
        ],
      ),
    );
  }

  showEditStartPageDialog() {
    TextEditingController _titleController = TextEditingController();
    _titleController.text = title;
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(builder: (context, setState) {
            return Dialog(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0)),
                child: Container(
                    height: 120,
                    width: 20,
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(children: [
                        TextField(
                          controller: _titleController,
                        ),
                        Center(
                          child: RaisedButton(
                              color: Colors.blueAccent,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15.0)),
                              onPressed: () {
                                if (_titleController.text.isNotEmpty) {
                                  Utilities.setStartPageTitle(
                                          _titleController.text)
                                      .then((value) {
                                    Navigator.pop(context);
                                    setState(() {
                                      title = _titleController.text;
                                    });
                                  });
                                } else {
                                  Utilities.showToast("Can't Be Empty.");
                                }
                              },
                              child: Text("Save")),
                        ),
                      ]),
                    )));
          });
        });
  }

  showDeleteEditCatDialog(
      BuildContext context, StartAppsProvider provider, String cat) {
    TextEditingController _catController = TextEditingController();
    _catController.text = cat;
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(builder: (context, setState) {
            return Dialog(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0)),
                child: Container(
                    height: 120,
                    width: 20,
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(children: [
                        TextField(
                          controller: _catController,
                        ),
                        Row(children: [
                          RaisedButton(
                              color: Colors.blueAccent,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15.0)),
                              onPressed: () {
                                if (_catController.text.isNotEmpty) {
                                  provider
                                      .editCategory(cat, _catController.text)
                                      .then((value) {
                                    Navigator.pop(context);
                                  });
                                } else {
                                  Utilities.showToast("Can't Be Empty.");
                                }
                              },
                              child: Text("Save")),
                          SizedBox(
                            width: 26,
                          ),
                          RaisedButton(
                              color: Colors.blueAccent,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15.0)),
                              onPressed: () {
                                provider.deleteCategory(cat).then((value) {
                                  Navigator.pop(context);
                                });
                              },
                              child: Text("Delete")),
                        ]),
                      ]),
                    )));
          });
        });
  }

  showDeleteDialog(
      BuildContext context, StartAppsProvider provider, StartApp startApp) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(builder: (context, setState) {
            return Dialog(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0)),
                child: Container(
                    height: 60,
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: RaisedButton(
                          color: Colors.blueAccent,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15.0)),
                          onPressed: () {
                            provider.deleteStartApp(startApp).then((value) {
                              Navigator.pop(context);
                            });
                          },
                          child: Center(child: Text("Delete"))),
                    )));
          });
        });
  }

  showAppAddDialog(
    BuildContext context,
    StartAppsProvider provider,
  ) {
    String catgry = "None";

    List<Application> selectedApps = [];
    TextEditingController _searchText = TextEditingController();

    List<Application> _searchResult = [];

    DeviceApps.getInstalledApplications(
            onlyAppsWithLaunchIntent: true, includeSystemApps: true)
        .then((apps) {
      // for (int i = 0; i < apps.length; i++) {
      //   apps[i].appName = apps[i].appName.toLowerCase();
      // }
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return StatefulBuilder(builder: (context, setState) {
              onSearchTextChanged(String text) async {
                print("DEBUG search String: " + text);
                _searchResult.clear();
                if (text.isEmpty) {
                  setState(() {});
                  return;
                }

                apps.forEach((app) {
                  if (app.appName.contains(text)) {
                    _searchResult.add(app);
                  }
                });

                print("Search Result: " + _searchResult.length.toString());

                setState(() {});
              }

              _searchText.addListener(() {
                onSearchTextChanged(_searchText.text);
              });
              return Dialog(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0)),
                  child: SingleChildScrollView(
                    child: Container(
                        height: 460,
                        child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              children: [
                                DropdownButton<String>(
                                  value: catgry,
                                  onChanged: (value) {
                                    setState(() {
                                      catgry = value;
                                    });
                                  },
                                  hint: Text("category"),
                                  items: provider.cats.map((String value) {
                                    return new DropdownMenuItem<String>(
                                      value: value,
                                      child: new Text(value),
                                    );
                                  }).toList(),
                                ),
                                SizedBox(
                                  height: 40,
                                  child: ListView.builder(
                                    itemCount: selectedApps.length,
                                    scrollDirection: Axis.horizontal,
                                    itemBuilder: (context, index) =>
                                        GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          selectedApps.removeAt(index);
                                        });
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Row(
                                          children: [
                                            Text(selectedApps[index].appName),
                                            Icon(
                                              Icons.cancel,
                                              size: 12,
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                ListTile(
                                  trailing: IconButton(
                                    icon: Icon(Icons.cancel),
                                    onPressed: () {
                                      _searchText.clear();
                                      onSearchTextChanged('');
                                    },
                                  ),
                                  leading: Icon(Icons.search),
                                  title: TextField(
                                    textCapitalization:
                                        TextCapitalization.words,
                                    // onChanged: onSearchTextChanged,
                                    controller: _searchText,
                                    decoration: InputDecoration(
                                        hintText: 'Search',
                                        border: InputBorder.none),
                                  ),
                                ),
                                SizedBox(
                                  height: 240,
                                  child: _searchResult.length != 0 ||
                                          _searchText.text.isNotEmpty
                                      ? ListView.builder(
                                          itemCount: _searchResult.length,
                                          itemBuilder: (context, index) =>
                                              GestureDetector(
                                            onTap: () {
                                              setState(() {
                                                selectedApps
                                                    .add(_searchResult[index]);
                                              });
                                            },
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Text(
                                                  _searchResult[index].appName),
                                            ),
                                          ),
                                        )
                                      : ListView.builder(
                                          itemCount: apps.length,
                                          itemBuilder: (context, index) =>
                                              GestureDetector(
                                            onTap: () {
                                              setState(() {
                                                selectedApps.add(apps[index]);
                                              });
                                            },
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Text(apps[index].appName),
                                            ),
                                          ),
                                        ),
                                ),
                                RaisedButton(
                                  onPressed: () {
                                    Future.wait(selectedApps.map((app) =>
                                            provider.insertStartApp(StartApp(
                                                app: true,
                                                cat: catgry,
                                                title: app.appName,
                                                url: app.packageName))))
                                        .then((value) {
                                      Navigator.of(context).pop();
                                    });
                                  },
                                  child: Text("Save"),
                                  color: Colors.blueAccent,
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(15.0)),
                                )
                              ],
                            ))),
                  ));
            });
          });
    });
  }

  showCatAddDialog(
    BuildContext context,
    StartAppsProvider provider,
  ) {
    final catText = TextEditingController();

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(builder: (context, setState) {
            return Dialog(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0)),
                child: Container(
                    height: 120,
                    child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          children: [
                            TextField(
                              controller: catText,
                              decoration: InputDecoration(
                                  border: InputBorder.none,
                                  hintText: 'Category'),
                            ),
                            SizedBox(
                                width: 320,
                                height: 40,
                                child: RaisedButton(
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(15.0)),
                                  color: Colors.blueAccent,
                                  onPressed: () {
                                    if (catText.text.isNotEmpty) {
                                      provider
                                          .insertCategory(catText.text)
                                          .then((value) {
                                        Navigator.pop(context);
                                      });
                                    } else {
                                      Utilities.showToast("Can't be empty");
                                    }
                                  },
                                  child: Text("Save"),
                                ))
                          ],
                        ))));
          });
        });
  }

  showWebAddDialog(
    BuildContext context,
    StartAppsProvider provider,
  ) {
    final websiteurlText = TextEditingController();

    String catgry = "None";

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0)),
              child: Container(
                height: 160,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                        controller: websiteurlText,
                        decoration: InputDecoration(
                            border: InputBorder.none, hintText: 'Website Link'),
                      ),
                      DropdownButton<String>(
                        value: catgry,
                        onChanged: (value) {
                          setState(() {
                            catgry = value;
                          });
                        },
                        hint: Text("category"),
                        items: provider.cats.map((String value) {
                          return new DropdownMenuItem<String>(
                            value: value,
                            child: new Text(value),
                          );
                        }).toList(),
                      ),
                      SizedBox(
                        width: 320,
                        height: 40,
                        child: RaisedButton(
                          color: Colors.blueAccent,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15.0)),
                          onPressed: () {
                            if (websiteurlText.text.isNotEmpty) {
                              Utilities.showToast("Adding");
                              if (!(websiteurlText.text.contains("https://") ||
                                  websiteurlText.text.contains("http://"))) {
                                print("Adding https");
                                websiteurlText.text =
                                    "https://" + websiteurlText.text;
                              }

                              Utilities.getTitle(websiteurlText.text)
                                  .then((title) {
                                if (title == null) {
                                  title =
                                      Utilities.parseTitle(websiteurlText.text);
                                  Utilities.showToast('Title Parsing Error');
                                }
                                provider
                                    .insertStartApp(StartApp(
                                        app: false,
                                        cat: catgry,
                                        title: title,
                                        url: websiteurlText.text))
                                    .then((value) {
                                  print("After adding");
                                  Navigator.pop(context);
                                });
                              });
                            } else {
                              Utilities.showToast("Url Can't be Empty.");
                            }
                          },
                          child: Text("Save"),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
