import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/material.dart';
import 'package:newchatapp/AddStory.dart';
import 'package:newchatapp/ViewStory.dart';
import 'package:newchatapp/chat.dart';
import 'package:newchatapp/const.dart';
import 'package:newchatapp/login.dart';
import 'package:newchatapp/settings.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'AddGroup.dart';

void main() => runApp(MyApp());

class MainScreen extends StatefulWidget {
  final String currentUserId;

  MainScreen({Key key, @required this.currentUserId}) : super(key: key);

  @override
  State createState() => MainScreenState(currentUserId: currentUserId);
}

class MainScreenState extends State<MainScreen> {
  MainScreenState({Key key, @required this.currentUserId});

  final String currentUserId;
  SharedPreferences prefs;
  String groupName;
  final TextEditingController textEditingControllergroupName =
      new TextEditingController();
  final FirebaseMessaging firebaseMessaging = new FirebaseMessaging();
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      new FlutterLocalNotificationsPlugin();
  final GoogleSignIn googleSignIn = GoogleSignIn();

  bool isLoading = false;
  List<Choice> choices = const <Choice>[
    const Choice(title: 'Profile', icon: Icons.person),
    const Choice(title: 'Add Story', icon: Icons.add),
    const Choice(title: 'Log out', icon: Icons.exit_to_app),
  ];

  @override
  void initState() {
    super.initState();
    registerNotification();
    configLocalNotification();
    readlocal();
    getData();
  }

  readlocal() async {
    prefs = await SharedPreferences.getInstance();
    groupName = prefs.getString('groupName');
    print('gname: $groupName');
    getData();
  }

  void registerNotification() {
    firebaseMessaging.requestNotificationPermissions();

    firebaseMessaging.configure(onMessage: (Map<String, dynamic> message) {
      print('onMessage: $message');
      showNotification(message['notification']);
      return;
    }, onResume: (Map<String, dynamic> message) {
      print('onResume: $message');
      return;
    }, onLaunch: (Map<String, dynamic> message) {
      print('onLaunch: $message');
      return;
    });

    firebaseMessaging.getToken().then((token) {
      print('token: $token');
      Firestore.instance
          .collection('users')
          .document(currentUserId)
          .updateData({'pushToken': token});
    }).catchError((err) {
      Fluttertoast.showToast(msg: err.message.toString());
    });
  }

  void configLocalNotification() {
    var initializationSettingsAndroid =
        new AndroidInitializationSettings('app_icon');
    var initializationSettingsIOS = new IOSInitializationSettings();
    var initializationSettings = new InitializationSettings(
        initializationSettingsAndroid, initializationSettingsIOS);
    flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  void onItemMenuPress(Choice choice) {
    if (choice.title == 'Log out') {
      handleSignOut();
    } else if (choice.title == 'Profile') {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => Settings()));
    } else {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => AddStory(widget.currentUserId)));
    }
  }

  void showNotification(message) async {
    var androidPlatformChannelSpecifics = new AndroidNotificationDetails(
      Platform.isAndroid
          ? 'com.kandktech.newchatapp'
          : 'com.kandktech.newchatapp',
      'Flutter chat demo',
      'your channel description',
      playSound: true,
      enableVibration: true,
      importance: Importance.Max,
      priority: Priority.High,
    );
    var iOSPlatformChannelSpecifics = new IOSNotificationDetails();
    var platformChannelSpecifics = new NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(0, message['title'].toString(),
        message['body'].toString(), platformChannelSpecifics,
        payload: json.encode(message));
  }

  Future<bool> onBackPress() {
    openDialog();
    return Future.value(false);
  }

  Future<Null> openDialog() async {
    switch (await showDialog(
        context: context,
        builder: (BuildContext context) {
          return SimpleDialog(
            contentPadding:
                EdgeInsets.only(left: 0.0, right: 0.0, top: 0.0, bottom: 0.0),
            children: <Widget>[
              Container(
                color: themeColor,
                margin: EdgeInsets.all(0.0),
                padding: EdgeInsets.only(bottom: 10.0, top: 10.0),
                height: 100.0,
                child: Column(
                  children: <Widget>[
                    Container(
                      child: Icon(
                        Icons.exit_to_app,
                        size: 30.0,
                        color: Colors.white,
                      ),
                      margin: EdgeInsets.only(bottom: 10.0),
                    ),
                    Text(
                      'Exit app',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Are you sure to exit app?',
                      style: TextStyle(color: Colors.white70, fontSize: 14.0),
                    ),
                  ],
                ),
              ),
              SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context, 0);
                },
                child: Row(
                  children: <Widget>[
                    Container(
                      child: Icon(
                        Icons.cancel,
                        color: primaryColor,
                      ),
                      margin: EdgeInsets.only(right: 10.0),
                    ),
                    Text(
                      'CANCEL',
                      style: TextStyle(
                          color: primaryColor, fontWeight: FontWeight.bold),
                    )
                  ],
                ),
              ),
              SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context, 1);
                },
                child: Row(
                  children: <Widget>[
                    Container(
                      child: Icon(
                        Icons.check_circle,
                        color: primaryColor,
                      ),
                      margin: EdgeInsets.only(right: 10.0),
                    ),
                    Text(
                      'YES',
                      style: TextStyle(
                          color: primaryColor, fontWeight: FontWeight.bold),
                    )
                  ],
                ),
              ),
            ],
          );
        })) {
      case 0:
        break;
      case 1:
        exit(0);
        break;
    }
  }

  Future<Null> handleSignOut() async {
    this.setState(() {
      isLoading = true;
    });

    await FirebaseAuth.instance.signOut();
    await googleSignIn.disconnect();
    await googleSignIn.signOut();

    this.setState(() {
      isLoading = false;
    });

    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => MyApp()),
        (Route<dynamic> route) => false);
  }

  void getData() {
    Firestore.instance
        .collection('Group').document(widget.currentUserId).collection('GroupName')
        .getDocuments()
        .then((QuerySnapshot snapshot) {
      snapshot.documents.forEach((f) => print('data: ${f.data}}'));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'HomePage',
          style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.group_add),
            onPressed: () {
              groupnameDialog(context);
            },
          ),

//          IconButton(icon: Icon(Icons.group),onPressed:(){
//            Navigator.push(context, MaterialPageRoute(builder: (context) => GroupList(widget.currentUserId,groupName)));
//          },),
          PopupMenuButton<Choice>(
            onSelected: onItemMenuPress,
            itemBuilder: (BuildContext context) {
              return choices.map((Choice choice) {
                return PopupMenuItem<Choice>(
                    value: choice,
                    child: Row(
                      children: <Widget>[
                        Icon(
                          choice.icon,
                          color: primaryColor,
                        ),
                        Container(
                          width: 10.0,
                        ),
                        Text(
                          choice.title,
                          style: TextStyle(color: primaryColor),
                        ),
                      ],
                    ));
              }).toList();
            },
          ),
        ],
      ),
      body: WillPopScope(
        child: Stack(
          children: <Widget>[
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              bottom: 0,
              child: Stack(
                children: <Widget>[
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: Padding(
                      padding: const EdgeInsets.only(left:8.0),
                      child: Text('Groups',style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold),),
                    ),
                  ),
                  Positioned(
                    top: 20,
                    left: 0,
                    right: 0,
                    bottom: 370,
                    child: Container(

                      child: StreamBuilder(
                        stream:
                        Firestore.instance.collection('Group').document(widget.currentUserId).collection('GroupName').snapshots(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {

                            return Center(
                              child: CircularProgressIndicator(
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(themeColor),
                              ),
                            );
                          } else {
                            if(snapshot.data.documents.length == 0){
                              return Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Center(child: (Text('No Any Groups Yet',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20),))),
                              );
                            }
                            else{
                              Fluttertoast.showToast(msg: 'count:${snapshot.data.documents.length}');
                              print('count:${snapshot.data.documents.length}');
                              getData();
                              return ListView.builder(
                                padding: EdgeInsets.all(10.0),
                                itemBuilder: (context, index) => buildItemGroup(
                                    context, snapshot.data.documents[index]),
                                itemCount: snapshot.data.documents.length,
                              );
                            }
                          }
                        },
                      ),

                      //previous before edit
//                      child: StreamBuilder(
//                        stream:
//                            Firestore.instance.collection('Group').document(widget.currentUserId).collection('GroupName').document(groupName).collection('users').snapshots(),
//                        builder: (context, snapshot) {
//                          if (!snapshot.hasData) {
//                            return Text('No Any Group');
////                            return Center(
////                              child: CircularProgressIndicator(
////                                valueColor:
////                                    AlwaysStoppedAnimation<Color>(themeColor),
////                              ),
////                            );
//                          } else {
//                            Fluttertoast.showToast(msg: 'count:${snapshot.data.documents.length}');
//                            print('count:${snapshot.data.documents.length}');
//                            getData();
//                            return ListView.builder(
//                              padding: EdgeInsets.all(10.0),
//                              itemBuilder: (context, index) => buildItemGroup(
//                                  context, snapshot.data.documents[index]),
//                              itemCount: snapshot.data.documents.length,
//                            );
//                          }
//                        },
//                      ),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              top: 250,
              left: 0,
              right: 0,
              bottom: 0,
              child: Stack(
                children: <Widget>[
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: Padding(
                      padding: const EdgeInsets.only(left:8.0),
                      child: Text('Friends',style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold),),
                    ),
                  ),
                  Positioned(
                    top: 20,
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: Container(
                      child: StreamBuilder(
                        stream:
                            Firestore.instance.collection('users').snapshots(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return Center(
                              child: CircularProgressIndicator(
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(themeColor),
                              ),
                            );
                          } else {
                            return ListView.builder(
                              padding: EdgeInsets.all(10.0),
                              itemBuilder: (context, index) => buildItem(
                                  context, snapshot.data.documents[index]),
                              itemCount: snapshot.data.documents.length,
                            );
                          }
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Loading
            Positioned(
              child: isLoading
                  ? Container(
                      child: Center(
                        child: CircularProgressIndicator(
                            valueColor:
                                AlwaysStoppedAnimation<Color>(themeColor)),
                      ),
                      color: Colors.white.withOpacity(0.8),
                    )
                  : Container(),
            )
          ],
        ),
        onWillPop: onBackPress,
      ),
    );
  }

  Widget buildItemGroup(BuildContext context, DocumentSnapshot document) {
    if (document['id'] == currentUserId) {
      return Container();
    } else {
//      print('currentUserID:$currentUserId');
//      print('peer: ${document.documentID}');
//      print('peernext: ${document['seenBy']}');
      return Padding(
        padding: const EdgeInsets.only(top: 8.0),
        child: FlatButton(
          child: Row(
            children: <Widget>[
              Material(
                child: document['imageUrl'] != null
                    ? CachedNetworkImage(
                        placeholder: (context, url) => Container(
                          child: CircularProgressIndicator(
                            strokeWidth: 1.0,
                            valueColor: AlwaysStoppedAnimation<Color>(
                                themeColor),
                          ),
                          width: 50.0,
                          height: 50.0,
                          padding: EdgeInsets.all(15.0),
                        ),
                        imageUrl: document['photoUrl'],
                        width: 50.0,
                        height: 50.0,
                        fit: BoxFit.cover,
                      )
                    : Icon(
                        Icons.account_circle,
                        size: 50.0,
                        color: greyColor,
                      ),
                borderRadius: BorderRadius.all(Radius.circular(25.0)),
                clipBehavior: Clip.hardEdge,
              ),
              Flexible(
                child: Container(
                  child: Column(
                    children: <Widget>[
                      Container(
                        child: Text(
                          'GroupName: ${document['groupName']}',
                          style: TextStyle(color: primaryColor),
                        ),
                        alignment: Alignment.centerLeft,
                        margin:
                            EdgeInsets.fromLTRB(10.0, 0.0, 0.0, 5.0),
                      ),
                      Container(
                        child: Text(
                          'About Group: ${document['aboutMe'] ?? 'Not available'}',
                          style: TextStyle(color: primaryColor),
                        ),
                        alignment: Alignment.centerLeft,
                        margin:
                            EdgeInsets.fromLTRB(10.0, 0.0, 0.0, 0.0),
                      ),
                    ],
                  ),
                  margin: EdgeInsets.only(left: 20.0),
                ),
              ),
            ],
          ),
          onPressed: () {
//            Navigator.push(
//                context,
//                MaterialPageRoute(
//                    builder: (context) => Chat(
//                          peerId: document.documentID,
//                          peerAvatar: document['photoUrl'],
//                        )));
          },
          color: greyColor2,
          padding: EdgeInsets.fromLTRB(25.0, 10.0, 25.0, 10.0),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0)),
        ),
      );
    }
  }

  Widget buildItem(BuildContext context, DocumentSnapshot document) {
    if (document['id'] == currentUserId) {
      return Container();
    } else {
//      print('currentUserID:$currentUserId');
//      print('peer: ${document.documentID}');
//      print('peernext: ${document['seenBy']}');
      return /*(document['seenBy']!=currentUserId && document['done']=='No')*/ (document[
                  'seenBy'] ==
              null)
          ? GestureDetector(
              onLongPress: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ViewStory(
                              peerId: document.documentID,
                              peerAvatar: document['photoUrl'],
                            )));
              },
              child: Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: FlatButton(
                  child: Row(
                    children: <Widget>[
                      Material(
                        child: document['photoUrl'] != null
                            ? CachedNetworkImage(
                                placeholder: (context, url) => Container(
                                  child: CircularProgressIndicator(
                                    strokeWidth: 1.0,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        themeColor),
                                  ),
                                  width: 50.0,
                                  height: 50.0,
                                  padding: EdgeInsets.all(15.0),
                                ),
                                imageUrl: document['photoUrl'],
                                width: 50.0,
                                height: 50.0,
                                fit: BoxFit.cover,
                              )
                            : Icon(
                                Icons.account_circle,
                                size: 50.0,
                                color: greyColor,
                              ),
                        borderRadius: BorderRadius.all(Radius.circular(25.0)),
                        clipBehavior: Clip.hardEdge,
                      ),
                      Flexible(
                        child: Container(
                          child: Column(
                            children: <Widget>[
                              Container(
                                child: Text(
                                  'Nickname: ${document['nickname']}',
                                  style: TextStyle(color: primaryColor),
                                ),
                                alignment: Alignment.centerLeft,
                                margin:
                                    EdgeInsets.fromLTRB(10.0, 0.0, 0.0, 5.0),
                              ),
                              Container(
                                child: Text(
                                  'About me: ${document['aboutMe'] ?? 'Not available'}',
                                  style: TextStyle(color: primaryColor),
                                ),
                                alignment: Alignment.centerLeft,
                                margin:
                                    EdgeInsets.fromLTRB(10.0, 0.0, 0.0, 0.0),
                              ),
                            ],
                          ),
                          margin: EdgeInsets.only(left: 20.0),
                        ),
                      ),
                      Container(
                        width: 15,
                        height: 15,
                        child: Icon(
                          Icons.info,
                          size: 5,
                        ),
                        decoration: BoxDecoration(
                            shape: BoxShape.circle, color: Colors.green),
                      )
                    ],
                  ),
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => Chat(
                                  peerId: document.documentID,
                                  peerAvatar: document['photoUrl'],
                                )));
                  },
                  color: greyColor2,
                  padding: EdgeInsets.fromLTRB(25.0, 10.0, 25.0, 10.0),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0)),
                ),
              ),
            )
          : GestureDetector(
              onLongPress: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ViewStory(
                              peerId: document.documentID,
                              peerAvatar: document['photoUrl'],
                            )));
              },
              child: Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: FlatButton(
                  child: Row(
                    children: <Widget>[
                      Material(
                        child: document['photoUrl'] != null
                            ? CachedNetworkImage(
                                placeholder: (context, url) => Container(
                                  child: CircularProgressIndicator(
                                    strokeWidth: 1.0,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        themeColor),
                                  ),
                                  width: 50.0,
                                  height: 50.0,
                                  padding: EdgeInsets.all(15.0),
                                ),
                                imageUrl: document['photoUrl'],
                                width: 50.0,
                                height: 50.0,
                                fit: BoxFit.cover,
                              )
                            : Icon(
                                Icons.account_circle,
                                size: 50.0,
                                color: greyColor,
                              ),
                        borderRadius: BorderRadius.all(Radius.circular(25.0)),
                        clipBehavior: Clip.hardEdge,
                      ),
                      Flexible(
                        child: Container(
                          child: Column(
                            children: <Widget>[
                              Container(
                                child: Text(
                                  'Nickname: ${document['nickname']}',
                                  style: TextStyle(color: primaryColor),
                                ),
                                alignment: Alignment.centerLeft,
                                margin:
                                    EdgeInsets.fromLTRB(10.0, 0.0, 0.0, 5.0),
                              ),
                              Container(
                                child: Text(
                                  'About me: ${document['aboutMe'] ?? 'Not available'}',
                                  style: TextStyle(color: primaryColor),
                                ),
                                alignment: Alignment.centerLeft,
                                margin:
                                    EdgeInsets.fromLTRB(10.0, 0.0, 0.0, 0.0),
                              ),
                            ],
                          ),
                          margin: EdgeInsets.only(left: 20.0),
                        ),
                      ),
                    ],
                  ),
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => Chat(
                                  peerId: document.documentID,
                                  peerAvatar: document['photoUrl'],
                                )));
                  },
                  color: greyColor2,
                  padding: EdgeInsets.fromLTRB(25.0, 10.0, 25.0, 10.0),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0)),
                ),
              ),
            );
    }
  }

  groupnameDialog(context) {
    return showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Group Name'),
            content: Container(
              height: 100,
              child: TextField(
                style: TextStyle(color: Colors.black, fontSize: 15.0),
                controller: textEditingControllergroupName,
                decoration: new InputDecoration(
                  focusedBorder: OutlineInputBorder(
                    borderSide:
                        BorderSide(color: Colors.greenAccent, width: 3.0),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.red, width: 3.0),
                  ),
                  hintText: 'Enter Group Name',
                  hintStyle: TextStyle(color: greyColor),
                ),
                autofocus: false,
              ),
            ),
            actions: <Widget>[
              FlatButton(
                splashColor: Colors.teal,
                child: InkWell(
                  child: Container(
                    width: 80,
                    height: 40,
                    decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [
                          Colors.orange,
                          Colors.deepOrangeAccent,
                        ]),
                        borderRadius: BorderRadius.circular(6.0),
                        border: Border.all(color: Colors.black, width: 1.5),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.red.withOpacity(.3),
                              offset: Offset(0.0, 8.0),
                              blurRadius: 8.0)
                        ]),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          textEditingControllergroupName.clear();
                          Navigator.of(context).pop(false);
                        },
                        child: Center(
                          child: Text("No",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontFamily: "Poppins-Bold",
                                  fontSize: 12,
                                  letterSpacing: 1.0)),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              FlatButton(
                splashColor: Colors.teal,
                child: InkWell(
                  child: Container(
                    width: 80,
                    height: 40,
                    decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [
                          Colors.orange,
                          Colors.deepOrangeAccent,
                        ]),
                        borderRadius: BorderRadius.circular(6.0),
                        border: Border.all(color: Colors.black, width: 1.5),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.red.withOpacity(.3),
                              offset: Offset(0.0, 8.0),
                              blurRadius: 8.0)
                        ]),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          Fluttertoast.showToast(
                            msg: "Adding GroupName",
                            toastLength: Toast.LENGTH_SHORT,
                            gravity: ToastGravity.BOTTOM,
                            backgroundColor: Colors.blueAccent,
                            timeInSecForIos: 1,
                            textColor: Colors.white,
                          );

                          if (textEditingControllergroupName.text.trim() !=
                              '') {
                            Navigator.of(context).pop();
                            String title = textEditingControllergroupName.text;

                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        AddGroup(currentUserId, title)));
                            Fluttertoast.showToast(
                              msg: "Group Name Added",
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.BOTTOM,
                              backgroundColor: Colors.blueAccent,
                              timeInSecForIos: 1,
                              textColor: Colors.white,
                            );
                            textEditingControllergroupName.clear();
                          } else {
                            Fluttertoast.showToast(
                              msg: "Group Name Is Empty",
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.BOTTOM,
                              backgroundColor: Colors.blueAccent,
                              timeInSecForIos: 1,
                              textColor: Colors.white,
                            );
                            //
                          }
                        },
                        child: Center(
                          child: Text("Yes",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontFamily: "Poppins-Bold",
                                  fontSize: 12,
                                  letterSpacing: 1.0)),
                        ),
                      ),
                    ),
                  ),
                ),
                /*Navigator.of(context).pop(true)*/
              ),
            ],
          ),
        ) ??
        false;
  }
}

class Choice {
  const Choice({this.title, this.icon});

  final String title;
  final IconData icon;
}
