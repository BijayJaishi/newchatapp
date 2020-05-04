import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:newchatapp/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'const.dart';

class AddGroup extends StatefulWidget {
  final currentUserId,groupName;

  AddGroup(this.currentUserId,this.groupName);

  @override
  _AddGroupState createState() => _AddGroupState();
}

class _AddGroupState extends State<AddGroup> {
  SharedPreferences prefs;
  String photoUrl;
  String dId;
  String pUrl;
  String groupName;
  @override
  void initState() {
    // TODO: implement initState
    readlocal();
    pUrl = '';
    dId = null;
    groupName = null;
    super.initState();

  }

  readlocal() async {
    prefs = await SharedPreferences.getInstance();
    photoUrl = prefs.getString('photoUrl');
    await prefs.setString('groupName', widget.groupName);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: new AppBar(
          title: new Text(
            'Add Group',
            style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold),
          ),
          centerTitle: false,
          actions: <Widget>[
            dId != null
                ? Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CircleAvatar(
                   backgroundColor: Colors.blue,
                   radius: 20,
                    child: IconButton(
                        icon: Icon(
                          Icons.check,
                          size: 25,
                          color: Colors.white,
                        ), onPressed: () async {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => MainScreen(currentUserId: widget.currentUserId)));
                          saveInLocal();
                      Fluttertoast.showToast(
                        msg: "New Group ${widget.groupName}  Added",
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.BOTTOM,
                        backgroundColor: Colors.blueAccent,
                        timeInSecForIos: 1,
                        textColor: Colors.white,
                      );
                    },),
                  ),
                )
                :  Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircleAvatar(
                radius: 40,
                child: Material(
                  child: photoUrl != null
                      ? CachedNetworkImage(
                    placeholder: (context, url) => Container(
                      child: CircularProgressIndicator(
                        strokeWidth: 0.5,
                        valueColor:
                        AlwaysStoppedAnimation<Color>(themeColor),
                      ),
                      width: 40.0,
                      height: 40.0,
                      padding: EdgeInsets.all(15.0),
                    ),
                    imageUrl: photoUrl,
                    width: 40.0,
                    height: 40.0,
                    fit: BoxFit.cover,
                  )
                      : Icon(
                    Icons.account_circle,
                    size: 30.0,
                    color: greyColor,
                  ),
                  borderRadius: BorderRadius.all(Radius.circular(25.0)),
                  clipBehavior: Clip.hardEdge,
                ),
              ),
            ),
          ],
        ),
        body: WillPopScope(
          onWillPop: onBackPress,
          child: Stack(
            children: <Widget>[
              dId == null
                  ? Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: Stack(
                        children: <Widget>[
                          Positioned(top: 8,left: 0,right: 0,bottom: 0,
                          child: Align(alignment:Alignment.topCenter,child: Text('Select Friends',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 18),)),),
                          Positioned(top:25,left: 0,right: 0,bottom:0,child: Container(
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
                          ),)
                        ],
                      )
                    )
                  : Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      top: 0,
                      child: Stack(
                        children: <Widget>[
                          Positioned(
                            top: 8,left: 10,right: 10,
                            child: Text('Group Name :'+'  '+widget.groupName,style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold),)
                          ),
                          Positioned(left: 0, right: 0, top: 20, child: Container(
                            height: 150,

                            child: StreamBuilder(
                              stream: Firestore.instance
                                  .collection('GroupUsers').document(widget.groupName).collection('users')
                                  .snapshots(),
                              builder: (context, snapshot) {
                                if (!snapshot.hasData) {
                                  return Center(
                                    child: CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          themeColor),
                                    ),
                                  );
                                } else {
                                  return ListView.builder(
                                    padding: EdgeInsets.all(10.0),
                                    scrollDirection: Axis.horizontal,
                                    itemBuilder: (context, index) => addUser(
                                        context,
                                        snapshot.data.documents[index],snapshot.data.documents.length),
                                    itemCount: snapshot.data.documents.length,
                                  );
                                }
                              },
                            ),

                          // previous before edit

//                            child: StreamBuilder(
//                              stream: Firestore.instance
//                                  .collection('Group')
//                              .document(widget.currentUserId).collection('GroupName').document(widget.groupName).collection('users')
//                                  .snapshots(),
//                              builder: (context, snapshot) {
//                                if (!snapshot.hasData) {
//                                  return Center(
//                                    child: CircularProgressIndicator(
//                                      valueColor: AlwaysStoppedAnimation<Color>(
//                                          themeColor),
//                                    ),
//                                  );
//                                } else {
//                                  return ListView.builder(
//                                    padding: EdgeInsets.all(10.0),
//                                    scrollDirection: Axis.horizontal,
//                                    itemBuilder: (context, index) => addUser(
//                                        context,
//                                        snapshot.data.documents[index],snapshot.data.documents.length),
//                                    itemCount: snapshot.data.documents.length,
//                                  );
//                                }
//                              },
//                            ),
                          ),),
                          Positioned(
                            left: 0,
                            right: 0,
                            bottom: 10,
                            top: 180,
                            child: Container(
                              child: StreamBuilder(
                                stream: Firestore.instance
                                    .collection('users')
                                    .snapshots(),
                                builder: (context, snapshot) {
                                  if (!snapshot.hasData) {
                                    return Center(
                                      child: CircularProgressIndicator(
                                        valueColor: AlwaysStoppedAnimation<Color>(
                                            themeColor),
                                      ),
                                    );
                                  } else {
                                    return ListView.builder(
                                      padding: EdgeInsets.all(10.0),
                                      itemBuilder: (context, index) => buildItem(
                                          context,
                                          snapshot.data.documents[index]),
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
            ],
          ),
        ));
  }

  Widget buildItem(BuildContext context, DocumentSnapshot document) {
    if (document['id'] == widget.currentUserId) {
      return Container();
    } else {
      return GestureDetector(
        onLongPress: () {},
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
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(themeColor),
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
                          margin: EdgeInsets.fromLTRB(10.0, 0.0, 0.0, 5.0),
                        ),
                        Container(
                          child: Text(
                            'About me: ${document['aboutMe'] ?? 'Not available'}',
                            style: TextStyle(color: primaryColor),
                          ),
                          alignment: Alignment.centerLeft,
                          margin: EdgeInsets.fromLTRB(10.0, 0.0, 0.0, 0.0),
                        ),
                      ],
                    ),
                    margin: EdgeInsets.only(left: 20.0),
                  ),
                ),
              ],
            ),
            onPressed: () {
              setState(() {
                dId = document.documentID;
                pUrl = document['photoUrl'];
              });
              saveUserInDatabase(dId);
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

  Widget addUser(BuildContext context, DocumentSnapshot document,int count) {
    print('count$count');
    print('id:${document['did']}');
    print('purl:${document['imageUrl']}');
    if (document['did']==null) {
      return Container();
    } else {
      return Column(
        children: <Widget>[
          Expanded(
            child: Padding(
              padding: EdgeInsets.fromLTRB(10.0, 15.0, 10.0, 15.0),
              child: Padding(
                padding: EdgeInsets.only(top: 15),
                child: CircleAvatar(
                  radius: 45,
                  child: Stack(
                    children: <Widget>[
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        bottom: 0,
                        child: Material(
                          child: document['imageUrl']!= null
                              ? CachedNetworkImage(
                                  placeholder: (context, url) => Container(
                                    child: CircularProgressIndicator(
                                      strokeWidth: 1.0,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          themeColor),
                                    ),
                                    width: 100.0,
                                    height: 100.0,
                                    padding: EdgeInsets.all(15.0),
                                  ),
                                  imageUrl: document['imageUrl'],
                                  width: 50.0,
                                  height: 50.0,
                                  fit: BoxFit.cover,
                                )
                              : Icon(
                                  Icons.account_circle,
                                  size: 50.0,
                                  color: greyColor,
                                ),
                          borderRadius: BorderRadius.all(Radius.circular(40.0)),
                          clipBehavior: Clip.hardEdge,
                        ),
                      ),
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        child: Align(
                            alignment: Alignment.topRight,
                            child: CircleAvatar(
                              radius: 15,
                              backgroundColor: Colors.black,
                              child: IconButton(
                                splashColor: Colors.red,
                                highlightColor: Colors.red,
                                icon: Icon(
                                  Icons.clear,
                                  size: 15,
                                  color: Colors.white,
                                ),
                                onPressed: () {

                                  Firestore.instance
                                      .collection('Group').document(widget.currentUserId).collection('GroupName')
                                      .document(document.documentID)
                                      .delete();

                                  Firestore.instance
                                      .collection('GroupUsers').document(widget.groupName).collection('users')
                                      .document(document.documentID)
                                      .delete();

                                  //previous before edit
//                                    Firestore.instance
//                                        .collection('Group')
//                                        .document(widget.currentUserId)
//                                        .collection('GroupName').document(widget.groupName).collection('users')
//                                        .document(document.documentID)
//                                        .delete();
                                    setState(() {
                                      if(count ==1){
                                        dId = null;
                                      }
                                    });

                                },
                              ),
                            )),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    }
  }
  Future<bool> onBackPress() {
    openDialog(context);
    return Future.value(false);
  }

  openDialog(context) {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Do you want to quit ?'),
        content: Container(
          height: 80,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(right:8.0),
                child: Icon(Icons.error,color: Colors.red,size:35,),
              ),
              Expanded(child: Text('You will lose all these progress !!!',style: TextStyle(fontWeight: FontWeight.w500),)),
            ],
          )
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


                      Firestore.instance
                          .collection('GroupUsers').document(widget.groupName).collection('users')
                          .getDocuments()
                          .then((snapshot) {
                        for (DocumentSnapshot ds in snapshot.documents) {
                          ds.reference.delete();
                        }
                      });

                      Firestore.instance
                          .collection('Group').document(widget.currentUserId).collection('GroupName')
                          .getDocuments()
                          .then((snapshot) {
                        for (DocumentSnapshot ds in snapshot.documents) {
                          ds.reference.delete();
                        }
                        Navigator.push(context, MaterialPageRoute(builder: (context) => MainScreen(currentUserId: widget.currentUserId)));
                        Fluttertoast.showToast(
                          msg: "No Group Added",
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.BOTTOM,
                          backgroundColor: Colors.blueAccent,
                          timeInSecForIos: 1,
                          textColor: Colors.white,
                        );
                      });

                      //previous before edit

//                      Firestore.instance
//                          .collection('Group')
//                          .document(widget.currentUserId)
//                          .collection('GroupName').document(widget.groupName).collection('users')
//                          .getDocuments()
//                          .then((snapshot) {
//                        for (DocumentSnapshot ds in snapshot.documents) {
//                          ds.reference.delete();
//                        }
//                        Navigator.push(context, MaterialPageRoute(builder: (context) => MainScreen(currentUserId: widget.currentUserId)));
//                        Fluttertoast.showToast(
//                          msg: "No Group Added",
//                          toastLength: Toast.LENGTH_SHORT,
//                          gravity: ToastGravity.BOTTOM,
//                          backgroundColor: Colors.blueAccent,
//                          timeInSecForIos: 1,
//                          textColor: Colors.white,
//                        );
//                      });
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

  void saveUserInDatabase(String dId) {

    var documentReference2 = Firestore.instance
        .collection('Group').document(widget.currentUserId).collection('GroupName').document(widget.groupName).setData({
      'groupName':widget.groupName
    });


    //previous before edit
//    var documentReference = Firestore.instance
//        .collection('Group').document(widget.currentUserId).collection('GroupName').document(widget.groupName).collection('users').document(dId).setData({
//      'did': dId,
//      'imageUrl':pUrl,
//      'groupName':widget.groupName
//    });

    var documentReference = Firestore.instance
        .collection('GroupUsers').document(widget.groupName).collection('users').document(dId).setData({
      'did': dId,
      'imageUrl':pUrl,
      'groupName':widget.groupName
    });
//        .document(dId);
//    Firestore.instance.runTransaction((transaction) async {
//      await transaction.set(
//        documentReference,
//        {
//          'userId': dId,
//          'timestamp': DateTime.now().millisecondsSinceEpoch.toString(),
//        },
//      );
//    });
//
//    print('userSaved:$dId');
  }

  void saveInLocal() async {
    prefs = await SharedPreferences.getInstance();
    await prefs.setString('groupName', widget.groupName);
//    Navigator.push(context, MaterialPageRoute(builder: (context) => GroupList(widget.currentUserId,groupName)));
  }

}
