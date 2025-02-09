// Flutter plugin imports
import 'package:dynamic_theme/dynamic_theme.dart';
import 'dart:io';

import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'dart:async';
import 'package:flutter/services.dart';

// Data imports
import 'package:devfest19/data/sessionResponse.dart';
// import 'package:devfest19/data/item.dart';

//pages import
import './error.dart';

// Utils imports
import './utils/sessionCard.dart';
import './utils/drawer.dart';
import './utils/drawerInfo.dart';

Future<List<SessionResponse>> fetchSessionResponse(
    http.Client client, BuildContext context) async {
  try {
    final response = await client.get(
        'https://raw.githubusercontent.com/Rimjhim28/Devfest-19-Data/master/schedule.json?t=timestamp');
    return compute(parseSessionResponse, response.body);
  } on SocketException catch (_) {
    selection(0);
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => ErrorPage(
                  message:
                      "Can't reach the servers, \n Please check your internet connection.",
                )));
  }
}

List<SessionResponse> parseSessionResponse(String responseBody) {
  final parsed = json.decode(responseBody).cast<Map<String, dynamic>>();

  return parsed
      .map<SessionResponse>((json) => SessionResponse.fromJson(json))
      .toList();
}

class Schedule extends StatefulWidget {
  @override
  _ScheduleState createState() => _ScheduleState();
}

class _ScheduleState extends State<Schedule> {
  //slot,title,speaker,tags,level,venue
  Color hexToColor(String code) {
    return new Color(int.parse(code.substring(1, 7), radix: 16) + 0xFF000000);
  }

  // Method which executes on pushing "Back Button"
  Future<bool> _willPopCallback() async {
    // Puts the flag up for "home", in drawer
    selection(0);
    // Pops until the last page remain
    Navigator.popUntil(context, ModalRoute.withName('/'));
    return false; // return true if the route to be popped
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Theme.of(context).backgroundColor == Colors.white
          ? Colors.white10
          : Colors.black, //top bar color
      systemNavigationBarColor:
          Theme.of(context).backgroundColor == Colors.white
              ? Colors.white10
              : Colors.black, //bottom bar color
      systemNavigationBarIconBrightness:
          Theme.of(context).backgroundColor == Colors.white
              ? Brightness.dark
              : Brightness.light,
    ));
    return WillPopScope(
      onWillPop: _willPopCallback,
      child: DefaultTabController(
        length: 2,
        child: Scaffold(
          backgroundColor: Theme.of(context).backgroundColor,
          appBar: AppBar(
            // Tabbar
            bottom: TabBar(
              // labelColor: hexToColor("#C7B7E4"),
              unselectedLabelColor: Colors.grey,
              indicatorColor: hexToColor("#673ab7"),
              tabs: <Widget>[
                Tab(
                  icon: Text(
                    "Eiffel Hall 1",
                    style: TextStyle(
                      color: Theme.of(context).backgroundColor == Colors.white
                          ? Colors.grey.shade600
                          : Colors.white,
                    ),
                  ),
                ),
                Tab(
                  icon: Text(
                    "Eiffel Hall 2",
                    style: TextStyle(
                      color: Theme.of(context).backgroundColor == Colors.white
                          ? Colors.grey.shade600
                          : Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            brightness: Theme.of(context).backgroundColor == Colors.white
                ? Brightness.light
                : Brightness.dark, //check
            backgroundColor: Theme.of(context).backgroundColor,
            iconTheme: new IconThemeData(
                color: Theme.of(context).backgroundColor == Colors.white
                    ? Colors.grey.shade600
                    : Colors.white),
            title: Text(
              'Schedule',
              style: TextStyle(
                color: Theme.of(context).backgroundColor == Colors.white
                    ? Colors.grey.shade600
                    : Colors.white,
              ),
            ),
            elevation: 5.0,
            actions: <Widget>[
              IconButton(
                icon: Icon(Icons.lightbulb_outline),
                iconSize: 20.0,
                onPressed: () {
                  DynamicTheme.of(context).setThemeData(new ThemeData(
                    backgroundColor:
                        Theme.of(context).backgroundColor == Colors.white
                            ? Colors.black
                            : Colors.white,
                  ));
                },
              )
            ],
          ),
          drawer: myDrawer(),
          body: TabBarView(
            children: <Widget>[
              // For Hall 1
              FutureBuilder<List<SessionResponse>>(
                future: fetchSessionResponse(http.Client(), context),
                builder: (context, snapshot) {
                  if (snapshot.hasError) print(snapshot.error);
                  return snapshot.hasData
                      ? SessionResponseItem1(sessionResponse: snapshot.data)
                      : Center(child: CircularProgressIndicator());
                },
              ),
              // For Hall 2
              FutureBuilder<List<SessionResponse>>(
                future: fetchSessionResponse(http.Client(), context),
                builder: (context, snapshot) {
                  if (snapshot.hasError) print(snapshot.error);
                  return snapshot.hasData
                      ? SessionResponseItem2(sessionResponse: snapshot.data)
                      : Center(child: CircularProgressIndicator());
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SessionResponseItem1 extends StatelessWidget {
  // Item i = new Item();
  final List<SessionResponse> sessionResponse;
  SessionResponseItem1({Key key, this.sessionResponse}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: sessionResponse[0].sessionsList.length,
      itemBuilder: (BuildContext context, int index) {
        return sessionResponse[0].sessionsList[index].roomId == 7132
            ? SessionCard(
                false,
                false,
                // Start Time
                sessionResponse[0].sessionsList[index].startsAt.toString(),
                // Title
                sessionResponse[0].sessionsList[index].title.toString(),
                // Speakers
                sessionResponse[0]
                    .sessionsList[index]
                    .speakers[0]
                    .name
                    .toString(),
                // "tags",
                sessionResponse[0]
                    .sessionsList[index]
                    .categories[1]
                    .categoryItems[0]
                    .name
                    .toString(),
                // hardness
                sessionResponse[0]
                    .sessionsList[index]
                    .categories[2]
                    .categoryItems[0]
                    .name
                    .toString(),
                // Room
                sessionResponse[0].sessionsList[index].room.toString(),
                //description
                sessionResponse[0].sessionsList[index].description.toString(),
              )
            : Container();
      },
    );
  }
}

class SessionResponseItem2 extends StatelessWidget {
  // Item i = new Item();
  final List<SessionResponse> sessionResponse;
  SessionResponseItem2({Key key, this.sessionResponse}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: sessionResponse[0].sessionsList.length,
      itemBuilder: (BuildContext context, int index) {
        return sessionResponse[0].sessionsList[index].roomId == 7133
            ? SessionCard(
                false,
                false,
                // Start Time
                sessionResponse[0].sessionsList[index].startsAt.toString(),
                // Title
                sessionResponse[0].sessionsList[index].title.toString(),
                // Speakers
                sessionResponse[0]
                    .sessionsList[index]
                    .speakers[0]
                    .name
                    .toString(),
                // "tags",
                sessionResponse[0]
                    .sessionsList[index]
                    .categories[1]
                    .categoryItems[0]
                    .name
                    .toString(),
                // hardness
                sessionResponse[0]
                    .sessionsList[index]
                    .categories[2]
                    .categoryItems[0]
                    .name
                    .toString(),
                // Room
                sessionResponse[0].sessionsList[index].room.toString(),
                //description
                sessionResponse[0].sessionsList[index].description.toString(),
              )
            : Container();
      },
    );
  }
}
