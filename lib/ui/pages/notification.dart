import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Notific extends StatefulWidget {
  @override
  _NotificState createState() => _NotificState();
}

class _NotificState extends State<Notific> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff27b56f),
      body: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 80.0),
              child: StreamBuilder<QuerySnapshot>(
                //recover data from firebase and shows in the listview
                stream:
                    Firestore.instance.collection('notifications').snapshots(),
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.hasError)
                    return new Text('Error: ${snapshot.error}');
                  switch (snapshot.connectionState) {
                    case ConnectionState.waiting:
                      return new CircularProgressIndicator();

                    default:
                      return new ListView(
                        children: snapshot.data.documents
                            .map((DocumentSnapshot document) {
                          return Padding(
                            padding: const EdgeInsets.only(
                                top: 8.0, left: 8, right: 8),
                            child: Row(
                              children: [
                                Image.asset('assets/chris.png',
                                    height: 55, width: 55),
                                Expanded(
                                  child: Container(
                                    decoration: BoxDecoration(
                                        color: Colors.white24,
                                        // border: Border.all(width: 1),
                                        borderRadius:
                                            BorderRadius.circular(20)),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Text(
                                                document['title'],
                                                style: TextStyle(
                                                    fontWeight: FontWeight.w800,
                                                    color: Colors.white,
                                                    fontSize: 22),
                                              ),
                                              Spacer(),
                                              Text(
                                                document['noti_date']
                                                    .toDate()
                                                    .day
                                                    .toString(),
                                                style: TextStyle(
                                                    color: Colors.white70,
                                                    fontSize: 14,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                              Text(
                                                "-",
                                                style: TextStyle(
                                                    color: Colors.white70,
                                                    fontSize: 14,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                              Text(
                                                document['noti_date']
                                                    .toDate()
                                                    .month
                                                    .toString(),
                                                style: TextStyle(
                                                    color: Colors.white70,
                                                    fontSize: 14,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                              Text(
                                                "-",
                                                style: TextStyle(
                                                    color: Colors.white70,
                                                    fontSize: 14,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                              Text(
                                                document['noti_date']
                                                    .toDate()
                                                    .year
                                                    .toString(),
                                                style: TextStyle(
                                                    color: Colors.white70,
                                                    fontSize: 14,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ],
                                          ),
                                          SizedBox(
                                            height: 2,
                                          ),
                                          Text(
                                            document['description'],
                                            maxLines: 5,
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black87,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      );
                  }
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8, right: 10, left: 10),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  //shape: BoxShape.circle,
                  color: Color(0xff27b56f),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.green[800],
                        offset: Offset(4.0, 4.0),
                        blurRadius: 20.0,
                        spreadRadius: 1.0),
                    BoxShadow(
                        color: Colors.black12,
                        offset: Offset(-4.0, -4.0),
                        blurRadius: 20.0,
                        spreadRadius: 1.0),
                  ],
                ),
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(2.0),
                      child: Image.asset('assets/christ.webp',
                          height: 50, width: 50),
                    ),
                    Text('  Notifications',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white70,
                          fontSize: 27,
                        )),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.grey[100],
        onPressed: () {
          Navigator.pop(context);
        },
        child: Icon(
          Icons.event,
          color: Color(0xff27b56f),
        ),
      ),
    );
  }
}
