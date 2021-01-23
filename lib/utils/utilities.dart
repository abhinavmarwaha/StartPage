import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:start_page/constants/strings.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'package:metadata_fetch/metadata_fetch.dart';
import 'package:vibration/vibration.dart';

class Utilities {
  static void launchUrl(String url) {
    if (url == null || url.compareTo("") == 0)
      showToast("Link Not Available");
    else {
      launch(url);
    }
  }

  static showToast(String msg) {
    Fluttertoast.showToast(
        msg: msg,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0);
  }

  static Future<String> getTitle(String url) async {
    try {
      url = url.trim();
      if (!(url.contains("https://") || url.contains("http://"))) {
        print("Adding https");
        url = "https://" + url;
      }
      print(url);
      print("Finding Title");
      var response = await http.get(url);
      print("Found Title1");
      var document = responseToDocument(response);
      print("Found Title2");
      var data = MetadataParser.parse(document);
      print("Found Titl3 " + data.title.toString());
      return data.title;
    } catch (e) {
      Utilities.showToast("Invalid url");
      return null;
    }
  }

  static void vibrate() async {
    if (await Vibration.hasVibrator()) {
      Vibration.vibrate(duration: 70, amplitude: 10);
    }
  }

  static Future<String> getStartPageTitle() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String title;
    if (prefs.containsKey(TITLE))
      title = prefs.getString(TITLE);
    else {
      await prefs.setString(TITLE, 'StartPage');
      title = 'StartPage';
    }
    return title;
  }

  static Future<void> setStartPageTitle(String title) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(TITLE, title);
    title = title;
  }
}
