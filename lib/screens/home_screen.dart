import 'dart:math';

import 'package:device_apps/device_apps.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:metadata_fetch/metadata_fetch.dart';
import 'package:provider/provider.dart';
import 'package:start_page/constants/colors.dart';
import 'package:start_page/constants/dimensions.dart';
import 'package:start_page/models/start_app.dart';
import 'package:start_page/providers/start_apps_provider.dart';
import 'package:start_page/screens/saved_later_screen.dart';
import 'package:start_page/utils/ThemeChanger.dart';
import 'package:start_page/utils/utilities.dart';

class HomeScreen extends StatefulWidget {
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _darkMode = false;

  @override
  void initState() {
    ThemeChanger.getDarkModePlainBool().then((value) {
      setState(() {
        _darkMode = value;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<StartAppsProvider>(
      builder: (context, provider, child) => Scaffold(
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
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            "StartPage",
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
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
                              child: Icon(Icons.chat_bubble)),
                        )
                      ]),
                      SizedBox(
                          height: MediaQuery.of(context).size.height * 7 / 9,
                          child: ListView(
                            children: provider.cats.map<Widget>((cat) {
                              if (cat.compareTo("None") == 0) {
                                return SizedBox(
                                    height: MediaQuery.of(context).size.height /
                                        5 *
                                        (provider.getStartApps(cat).length / 2),
                                    child: gridView(provider, cat));
                              } else {
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    GestureDetector(
                                      onLongPressEnd: (details) {
                                        showDeleteCatDialog(
                                            context, provider, cat);
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          cat,
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                        height: MediaQuery.of(context)
                                                .size
                                                .height /
                                            5 *
                                            (provider.getStartApps(cat).length /
                                                3),
                                        child: gridView(provider, cat))
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
      ),
    );
  }

  Widget gridView(StartAppsProvider provider, String cat) {
    if (provider.getStartApps(cat).length == 0) return Container();
    return GridView.builder(
      physics: NeverScrollableScrollPhysics(),
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
            color: appColors.values.toList()[Random().nextInt(4)],
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0)),
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
            backgroundColor: Colors.green,
            onTap: () => showCatAddDialog(context, provider),
            label: 'Category',
            labelStyle: TextStyle(fontWeight: FontWeight.w500),
            labelBackgroundColor: Colors.green,
          ),
        ],
      ),
    );
  }

  showDeleteCatDialog(
      BuildContext context, StartAppsProvider provider, String cat) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(builder: (context, setState) {
            return Dialog(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0)),
                child: Container(
                    height: 60,
                    width: 20,
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Center(
                          child: RaisedButton(
                              color: Colors.blueAccent,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15.0)),
                              onPressed: () {
                                provider.deleteCategory(cat).then((value) {
                                  Navigator.pop(context);
                                });
                              },
                              child: Text("Delete"))),
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
                        child: GestureDetector(
                          onTap: () {
                            provider.deleteStartApp(startApp).then((value) {
                              Navigator.pop(context);
                            });
                          },
                          child: Text("Delete"),
                        ))));
          });
        });
  }

  showAppAddDialog(
    BuildContext context,
    StartAppsProvider provider,
  ) {
    String catgry = "None";

    List<Application> selectedApps = [];

    DeviceApps.getInstalledApplications(
            onlyAppsWithLaunchIntent: true, includeSystemApps: true)
        .then((apps) {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return StatefulBuilder(builder: (context, setState) {
              return Dialog(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0)),
                  child: Container(
                      height: 400,
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
                                        apps.add(selectedApps[index]);
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
                              SizedBox(
                                height: 240,
                                child: ListView.builder(
                                  itemCount: apps.length,
                                  itemBuilder: (context, index) =>
                                      GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        selectedApps.add(apps[index]);
                                        apps.removeAt(index);
                                      });
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
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
                                    borderRadius: BorderRadius.circular(15.0)),
                              )
                            ],
                          ))));
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
                              extract(websiteurlText.text).then((doc) {
                                provider
                                    .insertStartApp(StartApp(
                                        app: false,
                                        cat: catgry,
                                        title: doc.title,
                                        url: websiteurlText.text))
                                    .then((value) {
                                  Navigator.pop(context);
                                });
                                ;
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
