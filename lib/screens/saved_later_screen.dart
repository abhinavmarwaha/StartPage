import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:provider/provider.dart';
import 'package:start_page/models/saved_later_item.dart';
import 'package:start_page/providers/saved_later_items_provider.dart';
import 'package:start_page/utils/utilities.dart';

class SavedLaterScreen extends StatefulWidget {
  _SavedLaterScreenState createState() => _SavedLaterScreenState();
}

class _SavedLaterScreenState extends State<SavedLaterScreen> {
  String selectedCat = "All";
  int selectedCatIndex = 0;
  @override
  Widget build(BuildContext context) {
    return Consumer<SavedLaterItemsProvider>(
      builder: (context, provider, child) => Scaffold(
          floatingActionButton: buildSpeedDial(provider),
          body: !provider.initilised
              ? Center(
                  child: CircularProgressIndicator(),
                )
              : Padding(
                  padding: MediaQuery.of(context).padding,
                  child: Column(
                    children: [
                      SizedBox(
                          height: 60,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: ListView.builder(
                              itemBuilder: (context, index) => GestureDetector(
                                  onLongPressEnd:
                                      provider.cats[index].compareTo("All") == 0
                                          ? null
                                          : (details) {
                                              showDeleteCatDialog(
                                                  context,
                                                  provider,
                                                  provider.cats[index]);
                                            },
                                  onTap: () {
                                    setState(() {
                                      Utilities.vibrate();
                                      selectedCat = provider.cats[index];
                                      selectedCatIndex = index;
                                    });
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      provider.cats[index],
                                      style: TextStyle(
                                          fontSize: 18,
                                          color: selectedCat.compareTo(
                                                      provider.cats[index]) ==
                                                  0
                                              ? Colors.black
                                              : Colors.grey),
                                    ),
                                  )),
                              itemCount: provider.cats.length,
                              scrollDirection: Axis.horizontal,
                            ),
                          )),
                      Expanded(
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onPanEnd: (details) {
                            double xVel = details.velocity.pixelsPerSecond.dx;

                            if (xVel < 0) {
                              Utilities.vibrate();
                              print("right swipe");
                              if (selectedCatIndex !=
                                  provider.cats.length - 1) {
                                setState(() {
                                  selectedCatIndex++;
                                  selectedCat = provider.cats[selectedCatIndex];
                                });
                              }
                            } else if (xVel > 0) {
                              Utilities.vibrate();
                              print("left swipe");
                              if (selectedCatIndex != 0) {
                                setState(() {
                                  selectedCatIndex--;
                                  selectedCat = provider.cats[selectedCatIndex];
                                });
                              }
                            }
                          },
                          child: ListView.builder(
                            itemBuilder: (context, index) => GestureDetector(
                              onTap: () {
                                Utilities.launchUrl(provider
                                    .getSavedLaterItems(selectedCat)[index]
                                    .url);
                              },
                              child: SizedBox(
                                height: 60,
                                child: Card(
                                  child: Row(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: SizedBox(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              4 /
                                              5,
                                          child: Text(
                                            provider
                                                .getSavedLaterItems(
                                                    selectedCat)[index]
                                                .title,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ),
                                      Spacer(),
                                      GestureDetector(
                                          onTap: () {
                                            provider.deleteSavedLater(
                                                provider.getSavedLaterItems(
                                                    selectedCat)[index]);
                                          },
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Icon(Icons.delete),
                                          ))
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            itemCount:
                                provider.getSavedLaterItems(selectedCat).length,
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
    );
  }

  showDeleteCatDialog(
      BuildContext context, SavedLaterItemsProvider provider, String cat) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(builder: (context, setState) {
            return Dialog(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0)),
                child: Container(
                    height: 60,
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: RaisedButton(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20.0)),
                            color: Colors.blueAccent,
                            onPressed: () {
                              provider
                                  .deleteCategory(cat)
                                  .then((value) => Navigator.pop(context));
                            },
                            child: Text("Delete")),
                      ),
                    )));
          });
        });
  }

  SpeedDial buildSpeedDial(SavedLaterItemsProvider provider) {
    return SpeedDial(
      child: Icon(Icons.add),
      animatedIconTheme: IconThemeData(size: 22.0),
      curve: Curves.bounceIn,
      children: [
        SpeedDialChild(
          child: Icon(Icons.web, color: Colors.white),
          backgroundColor: Colors.green,
          onTap: () => showWebAddDialog(context, provider),
          label: 'url',
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
    );
  }

  showCatAddDialog(
    BuildContext context,
    SavedLaterItemsProvider provider,
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
                                  color: Colors.blueAccent,
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(15.0)),
                                  onPressed: () {
                                    if (catText.text.isNotEmpty) {
                                      provider
                                          .insertCategory(catText.text)
                                          .then((value) =>
                                              Navigator.pop(context));
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
    SavedLaterItemsProvider provider,
  ) {
    final websiteurlText = TextEditingController();

    String catgry = "All";

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
                            border: InputBorder.none, hintText: 'url'),
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
                            try {
                              if (websiteurlText.text.isNotEmpty) {
                                Utilities.showToast("Adding");
                                Utilities.getTitle(websiteurlText.text)
                                    .then((title) {
                                  if (title == null) {
                                    return;
                                  }

                                  provider
                                      .insertSavedLater(SavedLaterItem(
                                          cat: catgry,
                                          title: title,
                                          url: websiteurlText.text))
                                      .then((value) {
                                    selectedCat = catgry;
                                    Navigator.pop(context);
                                  });
                                });
                              } else {
                                Utilities.showToast("Url Can't be Empty.");
                              }
                            } catch (e) {
                              Utilities.showToast("Invalid URL");
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
