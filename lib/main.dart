import 'dart:convert';

import 'package:CCEcalendar/model/event.dart';
import 'package:CCEcalendar/res/event_firestore_service.dart';
import 'package:CCEcalendar/ui/pages/notification.dart';
import 'package:page_transition/page_transition.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_calendar/table_calendar.dart';

import 'package:firebase_messaging/firebase_messaging.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Calendar',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(),
    );
  }
}

Future<dynamic> myBackgroundMessageHandler(Map<String, dynamic> message) async {
  if (message.containsKey('data')) {
    // Handle data message
    final dynamic data = message['data'];
  }

  if (message.containsKey('notification')) {
    // Handle notification message
    final dynamic notification = message['notification'];
    print(notification);
  }

  // Or do other work.
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  CalendarController _controller;
  Map<DateTime, List<dynamic>> _events;
  List<dynamic> _selectedEvents;
  TextEditingController _eventController;
  SharedPreferences prefs;
  FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

  @override
  void initState() {
    super.initState();
    _controller = CalendarController();
    _eventController = TextEditingController();
    _events = {};
    _selectedEvents = [];

    initPrefs();
    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        print("onMessage: $message");
        //   _showItemDialog(message);
      },
      onBackgroundMessage: myBackgroundMessageHandler,
      onLaunch: (Map<String, dynamic> message) async {
        print("onLaunch: $message");
      },
      onResume: (Map<String, dynamic> message) async {
        print("onResume: $message");
      },
    );
    _firebaseMessaging.requestNotificationPermissions(
        const IosNotificationSettings(sound: true, badge: true, alert: true));
    _firebaseMessaging.onIosSettingsRegistered
        .listen((IosNotificationSettings settings) {
      print("Settings registered: $settings");
    });
  }

  Map<DateTime, List<dynamic>> _groupEvents(List<EventModel> events) {
    Map<DateTime, List<dynamic>> data = {};
    events.forEach((event) {
      DateTime date = DateTime(
          event.eventDate.year, event.eventDate.month, event.eventDate.day, 12);
      if (data[date] == null) data[date] = [];
      data[date].add(event);
    });
    return data;
  }

  initPrefs() async {
    prefs = await SharedPreferences.getInstance();
    setState(() {
      _events = Map<DateTime, List<dynamic>>.from(
          decodeMap(json.decode(prefs.getString("events") ?? "{}")));
    });
  }

  Map<String, dynamic> encodeMap(Map<DateTime, dynamic> map) {
    Map<String, dynamic> newMap = {};
    map.forEach((key, value) {
      newMap[key.toString()] = map[key];
    });
    return newMap;
  }

  Map<DateTime, dynamic> decodeMap(Map<String, dynamic> map) {
    Map<DateTime, dynamic> newMap = {};
    map.forEach((key, value) {
      newMap[DateTime.parse(key)] = map[key];
    });
    return newMap;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<List<EventModel>>(
          stream: eventDBS.streamList(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              List<EventModel> allEvents = snapshot.data;
              if (allEvents.isNotEmpty) {
                _events = _groupEvents(allEvents);
              }
            }
            return Container(
              height: MediaQuery.of(context).size.height,
              color: Colors.white,
              child: SingleChildScrollView(
                physics: ScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: SafeArea(
                    child: Column(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            //shape: BoxShape.circle,
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.grey[600],
                                  offset: Offset(4.0, 4.0),
                                  blurRadius: 10.0,
                                  spreadRadius: 1.0),
                              BoxShadow(
                                  color: Colors.black12,
                                  offset: Offset(-4.0, -4.0),
                                  blurRadius: 20.0,
                                  spreadRadius: 1.0),
                            ],
                          ),
                          child: Column(
                            children: [
                              SizedBox(
                                height: 7,
                              ),
                              Row(children: <Widget>[
                                SizedBox(
                                  width: 3,
                                ),
                                Image.asset('assets/christ.webp',
                                    height: 35, width: 35),
                                RichText(
                                  text: TextSpan(
                                    children: <TextSpan>[
                                      TextSpan(
                                          text: '  CCE ',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 27,
                                              color: Colors.black54)),
                                      TextSpan(
                                          text: 'Holistic Calendar',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black54,
                                              fontSize: 23)),
                                    ],
                                  ),
                                ),
                              ]),
                              SizedBox(
                                height: 7,
                              )
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            TableCalendar(
                              events: _events,
                              initialCalendarFormat: CalendarFormat.month,
                              calendarStyle: CalendarStyle(
                                  canEventMarkersOverflow: true,
                                  todayColor: Colors.orange,
                                  selectedColor: Theme.of(context).primaryColor,
                                  todayStyle: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18.0,
                                      color: Colors.white)),
                              headerStyle: HeaderStyle(
                                  centerHeaderTitle: true,
                                  formatButtonVisible: false),
                              startingDayOfWeek: StartingDayOfWeek.monday,
                              onDaySelected: (date, events, holidays) {
                                setState(() {
                                  _selectedEvents = events.isEmpty
                                      ? [
                                          EventModel(
                                              title: "No Events",
                                              description: "")
                                        ]
                                      : events;
                                });
                              },
                              builders: CalendarBuilders(
                                selectedDayBuilder: (context, date, events) =>
                                    Container(
                                        margin: const EdgeInsets.all(4.0),
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                            color: Colors.grey[700],
                                            borderRadius:
                                                BorderRadius.circular(20.0)),
                                        child: Text(
                                          date.day.toString(),
                                          style: TextStyle(color: Colors.white),
                                        )),
                                todayDayBuilder: (context, date, events) =>
                                    Container(
                                        margin: const EdgeInsets.all(4.0),
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                            color: Colors.grey[400],
                                            borderRadius:
                                                BorderRadius.circular(20.0)),
                                        child: Text(
                                          date.day.toString(),
                                          style: TextStyle(color: Colors.white),
                                        )),
                              ),
                              calendarController: _controller,
                            ),
                            Text(
                              '   Events',
                              style: TextStyle(
                                color: Colors.grey[800],
                                fontSize: 32,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            ..._selectedEvents.map((event) => Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: SingleChildScrollView(
                                    child: Container(
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                          border: Border.all(width: 2),
                                          borderRadius:
                                              BorderRadius.circular(20)),
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Column(
                                          children: [
                                            Text(
                                              event.title,
                                              style: TextStyle(
                                                color: Colors.grey[700],
                                                fontSize: 28,
                                                fontWeight: FontWeight.w800,
                                              ),
                                            ),
                                            Text(
                                              event.description,
                                              maxLines: 3,
                                              style: TextStyle(
                                                color: Colors.grey[500],
                                                fontSize: 16,
                                                fontWeight: FontWeight.w800,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                )),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Color(0xff27b56f),
        onPressed: () {
          Navigator.push(
              context,
              PageTransition(
                  type: PageTransitionType.rightToLeft, child: Notific()));
        },
        child: Icon(
          Icons.notifications,
          color: Colors.grey[200],
        ),
      ),
    );
  }
}
