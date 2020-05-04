import 'dart:io';
import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:newchatapp/TestImageFiles/imagess.dart';
import 'package:photo_view/photo_view.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:story_view/story_view.dart';
import 'package:newchatapp/Custom_dialog/customDialog.dart' as customDialog;
import 'ViewStory.dart';
import 'const.dart';
import 'package:giphy_client/giphy_client.dart';
import 'package:giphy_picker/giphy_picker.dart';

class AddStory extends StatefulWidget {
  final currentUserId;

  AddStory(this.currentUserId);

  @override
  _AddStoryState createState() => _AddStoryState();
}

class _AddStoryState extends State<AddStory> {
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: new StoryScreen(widget.currentUserId),
    );
  }
}

class StoryScreen extends StatefulWidget {
  final currentUserId;

  StoryScreen(this.currentUserId);

  @override
  State createState() => new StoryScreenState();
}

class StoryScreenState extends State<StoryScreen> {
  Column MyItems(IconData icon, String heading, Color color) {
    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(4.0),
          child: Material(
            color: color,
            borderRadius: BorderRadius.circular(10.0),
            child: Padding(
              padding: EdgeInsets.all(4.0),
              child: Icon(
                icon,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.all(4.0),
          child: Text(
            heading,
            style: TextStyle(color: Colors.black),
          ),
        ),
      ],
    );
  }

  final storyController = StoryController();
  int mselectonIndex = 0;
  String imageUrl;
  File imageFile;
  bool isLoading;
  String storyUrl;
  List<String> stories;
  SharedPreferences prefs;
  int valuetime;
  var listMessage;
  var currentPage = imagess.length - 1.0;
  PageController _pageController;
  String photoUrl;
  int _current = 0;
  var rnd;
  String _gif;
  var length;
  static final  db = Firestore.instance;
  static var snapshots;

  var colors = [
    Colors.amber,
    Colors.blue,
    Colors.orange,
    Colors.yellow,
    Colors.red,
    Colors.purple,
    Colors.lightBlue,
    Colors.green,
    Colors.grey,
    Colors.pink,
    Colors.brown,
    Colors.cyan,
    Colors.deepPurple,
    Colors.teal,
    Colors.lime,
    Colors.indigo,
    Colors.blueGrey,
    Colors.lightGreenAccent,
    Colors.deepOrangeAccent,
    Colors.black54,
  ];
  var currentColor = Colors.black54;

  final TextEditingController textEditingController =
      new TextEditingController();
  final TextEditingController textEditingControllerGif =
      new TextEditingController();
  final TextEditingController textEditingControllertext =
//  new TextEditingController();
//  final TextEditingController textEditingControllernext =
      new TextEditingController();
  final ScrollController listScrollController = new ScrollController();

  void initState() {
    super.initState();

//    autodelete();
//    setRandomColor();
    isLoading = false;
    imageUrl = '';
    readlocal();
    _pageController = PageController(
      viewportFraction: 1,
      initialPage: mselectonIndex,
    );

//    getData();
  }

  setRandomColor() {
    rnd = Random().nextInt(colors.length);
    setState(() {
      currentColor = colors[rnd];
    });
  }

//  Future updateData() async{
//         snapshots= db
//        .collection('user')
//        .getDocuments();
//
//    await snapshots.forEach((document) async {
//      document.reference.updateData(<String, dynamic>{
//        'done': 'No'
//      });
//    });
//  }

  @override
  void dispose() {
    storyController.dispose();
    super.dispose();
  }

  readlocal() async {
    prefs = await SharedPreferences.getInstance();
    photoUrl = prefs.getString('photoUrl');
  }

  getText(context) {
    return showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Text'),
            content: Container(
              height: 100,
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      style: TextStyle(color: Colors.black, fontSize: 15.0),
                      controller: textEditingControllertext,
                      decoration: new InputDecoration(
                        focusedBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.greenAccent, width: 3.0),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.red, width: 3.0),
                        ),
                        hintText: 'Enter Your Text',
                        hintStyle: TextStyle(color: greyColor),
                      ),
                      autofocus: false,
                    ),
                  ),
//            Padding(
//              padding: const EdgeInsets.all(8.0),
//              child: TextField(
//                style: TextStyle(color: Colors.white, fontSize: 15.0),
//                controller: textEditingControllernext,
//                decoration: InputDecoration.collapsed(
//                  hintText: 'Enter Color (Generally Normal Colors)',
//                  hintStyle: TextStyle(color: greyColor),
//                ),
//                autofocus: true,
//              ),
//            ),
                ],
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
                            msg: "Adding Text",
                            toastLength: Toast.LENGTH_SHORT,
                            gravity: ToastGravity.BOTTOM,
                            backgroundColor: Colors.blueAccent,
                            timeInSecForIos: 1,
                            textColor: Colors.white,
                          );

                          if (textEditingControllertext.text.trim() != '') {
                            onSendMessage(
                                textEditingControllertext.text, 0, '');

                            Fluttertoast.showToast(
                              msg: "Text Added",
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.BOTTOM,
                              backgroundColor: Colors.blueAccent,
                              timeInSecForIos: 1,
                              textColor: Colors.white,
                            );
                            Navigator.of(context).pop();
                          } else {
                            Fluttertoast.showToast(
                              msg: "No Text",
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.BOTTOM,
                              backgroundColor: Colors.blueAccent,
                              timeInSecForIos: 1,
                              textColor: Colors.white,
                            );
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

  getGifCaption(context) {
    return showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Gif Caption'),
            content: Container(
              height: 100,
              child: TextField(
                style: TextStyle(color: Colors.black, fontSize: 15.0),
                controller: textEditingControllerGif,
                decoration: new InputDecoration(
                  focusedBorder: OutlineInputBorder(
                    borderSide:
                        BorderSide(color: Colors.greenAccent, width: 3.0),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.red, width: 3.0),
                  ),
                  hintText: 'Enter Your Caption (optional)',
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
                            msg: "Adding Gif Caption",
                            toastLength: Toast.LENGTH_SHORT,
                            gravity: ToastGravity.BOTTOM,
                            backgroundColor: Colors.blueAccent,
                            timeInSecForIos: 1,
                            textColor: Colors.white,
                          );

                          if (textEditingControllerGif.text.trim() != '') {
                            Navigator.of(context).pop();
                            getGif(textEditingControllerGif.text);
                            Fluttertoast.showToast(
                              msg: "Gif Caption Added",
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.BOTTOM,
                              backgroundColor: Colors.blueAccent,
                              timeInSecForIos: 1,
                              textColor: Colors.white,
                            );
                          } else {
                            Navigator.of(context).pop();
                            getGif(null);
                            Fluttertoast.showToast(
                              msg: "Gif Caption Not Added",
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

  Future getGif(String gifCaption) async {
    // request your Giphy API key at https://developers.giphy.com/
    final gif = await GiphyPicker.pickGif(
        context: context, apiKey: 'UGH5M9a0CWMymq4aYInGm4Zu3GDKL6So');

    if (gif != null) {
      setState(() => _gif = gif.images.original.url);
      onSendMessage(_gif, 1, gifCaption);
    }
  }

  getCaption(context) {
    return showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Image Caption'),
            content: Container(
              height: 100,
              child: TextField(
                style: TextStyle(color: Colors.black, fontSize: 15.0),
                controller: textEditingController,
                decoration: new InputDecoration(
                  focusedBorder: OutlineInputBorder(
                    borderSide:
                        BorderSide(color: Colors.greenAccent, width: 3.0),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.red, width: 3.0),
                  ),
                  hintText: 'Enter Your Caption',
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
                            msg: "Adding Caption",
                            toastLength: Toast.LENGTH_SHORT,
                            gravity: ToastGravity.BOTTOM,
                            backgroundColor: Colors.blueAccent,
                            timeInSecForIos: 1,
                            textColor: Colors.white,
                          );

                          if (textEditingController.text.trim() != '') {
                            Navigator.of(context).pop();
                            getImage(textEditingController.text);
                            Fluttertoast.showToast(
                              msg: "Caption Added",
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.BOTTOM,
                              backgroundColor: Colors.blueAccent,
                              timeInSecForIos: 1,
                              textColor: Colors.white,
                            );
                          } else {
                            Navigator.of(context).pop();
                            getImage(null);
                            Fluttertoast.showToast(
                              msg: "Caption Not Added",
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.BOTTOM,
                              backgroundColor: Colors.blueAccent,
                              timeInSecForIos: 1,
                              textColor: Colors.white,
                            );
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

  Future getImage(String caption) async {
    imageFile = await ImagePicker.pickImage(source: ImageSource.gallery);

    if (imageFile != null) {
      setState(() {
        isLoading = true;
      });
      uploadFile(caption);
    }
  }

  Future uploadFile(String caption) async {
    String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    StorageReference reference = FirebaseStorage.instance.ref().child(fileName);
    StorageUploadTask uploadTask = reference.putFile(imageFile);
    StorageTaskSnapshot storageTaskSnapshot = await uploadTask.onComplete;
    storageTaskSnapshot.ref.getDownloadURL().then((downloadUrl) {
      imageUrl = downloadUrl;
      setState(() {
        isLoading = false;
        onSendMessage(imageUrl, 1, caption);
      });
    }, onError: (err) {
      setState(() {
        isLoading = false;
      });
      Fluttertoast.showToast(msg: 'This file is not an image');
    });
  }

  void onSendMessage(String content, int type, String caption) async{
    // type: 0 = text, 1 = image, 2 = gif, 3 = video,
    if (content.trim() != '') {
      textEditingController.clear();
      textEditingControllertext.clear();
      textEditingControllerGif.clear();
//     textEditingControllernext.clear();

      var documentReference = Firestore.instance
          .collection('Stories')
          .document(widget.currentUserId)
          .collection(widget.currentUserId)
          .document(DateTime.now().millisecondsSinceEpoch.toString());

      Firestore.instance.runTransaction((transaction) async {
        await transaction.set(
          documentReference,
          {
            'userId': widget.currentUserId,
            'timestamp': DateTime.now().millisecondsSinceEpoch.toString(),
            'content': content,
            'caption': caption,
            'type': type,
          },
        );
      });

//      listScrollController.animateTo(0.0,
//          duration: Duration(milliseconds: 300), curve: Curves.easeOut);
//     _current = -1;
//     mselectonIndex = -1;

      Firestore.instance
          .collection('users')
          .document(widget.currentUserId)
          .updateData({'seenBy': null});

      Firestore.instance
          .collection('users')
          .document(widget.currentUserId)
          .updateData({'done': 'No'});

      setState(() {});

      Fluttertoast.showToast(msg: 'Story Uploaded Successfully !!');
      getData();
//      Navigator.push(context, MaterialPageRoute(builder: (context) => ViewStory(storyUrl)));
    } else {
      Fluttertoast.showToast(msg: 'Nothing to send');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(
        title: new Text(
          'Add Story',
          style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
        actions: <Widget>[
          Padding(
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
      body: Stack(
        children: <Widget>[
          Positioned(
            top: 0,
            right: 0,
            left: 0,
            child: Card(
              clipBehavior: Clip.antiAlias,
              color: Colors.white70,
              elevation: 8,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    InkWell(
                      splashColor: Colors.blue,
                      child: MyItems(Icons.image, "Image", Colors.red),
                      onTap: () => getCaption(context),
                    ),
                    InkWell(
                      splashColor: Colors.blue,
                      child: MyItems(Icons.gif, "Gifs", Colors.orange),
                      onTap: () => getGifCaption(context),
                    ),
                    InkWell(
                      splashColor: Colors.blue,
                      child: MyItems(Icons.text_format, "Texts", Colors.blue),
                      onTap: () => getText(context),
                    ),
                    MyItems(Icons.ondemand_video, "Videos", Colors.purple),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 5,
            child: getData(),
          ),
          buildLoading(),
        ],
      ),
    );
  }

  Widget getData() {
    return widget.currentUserId == ''
        ? Center(
            child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(themeColor)))
        : StreamBuilder<QuerySnapshot>(
            stream: Firestore.instance
                .collection('Stories')
                .document(widget.currentUserId)
                .collection(widget.currentUserId)
                .orderBy('timestamp', descending: true)
                .snapshots(),
            builder:
                (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (!snapshot.hasData) {
                return Center(
                    child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(themeColor)));
              } else {
//          listMessage = snapshot.data.documents;
//          print('listmessage:$listMessage');
//          print('length: ${snapshot.data.documents.length}');
                length = snapshot.data.documents.length;
                if (length == 0) {
                  return Container(
                    margin: EdgeInsets.only(bottom: 350),
                    child: Center(
                      child: Text(
                          "No any Story ! Please Upload with above Options",style: TextStyle(fontSize: 16,fontStyle: FontStyle.italic,letterSpacing: 1.0,fontWeight: FontWeight.bold),),
                    ),
                  );
                } else {
                  return CarouselSlider.builder(
                    height: MediaQuery.of(context).size.height - 160,
                    initialPage: mselectonIndex,
                    enlargeCenterPage: true,
                    autoPlay: true,
                    reverse: false,
                    enableInfiniteScroll: true,
                    autoPlayInterval: Duration(seconds: 2),
                    autoPlayAnimationDuration: Duration(milliseconds: 2000),
                    pauseAutoPlayOnTouch: Duration(seconds: 7),
                    scrollDirection: Axis.horizontal,
                    onPageChanged: (index) {
                      setState(() {
                        setRandomColor();
                        _current = index;
                      });
                    },
                    itemBuilder: (context, index) => buildItem(
                        index, snapshot.data.documents[index]),
                    itemCount: snapshot.data.documents.length
//          controller:_pageController,
//          onPageChanged: getnextpage(),
                  );
                }
              }
            },
          );
  }

//  Widget getData() {
//    return StreamBuilder<QuerySnapshot>(
//      stream: Firestore.instance
//          .collection('Stories')
//          .document(widget.currentUserId)
//          .collection(widget.currentUserId)
//          .orderBy('timestamp', descending: true)
//          .snapshots(),
//      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
//        if (!snapshot.hasData) {
//          return Center(
//              child: CircularProgressIndicator(
//                  valueColor:
//                  AlwaysStoppedAnimation<Color>(themeColor)));
//        }  else {
//          listMessage = snapshot.data.documents;
//          print('listmessage:$listMessage');
//          return CarouselSlider.builder(
//            height: MediaQuery.of(context).size.height - 200,
//            initialPage: mselectonIndex,
//            enlargeCenterPage: true,
//            autoPlay: true,
//            reverse: false,
//            enableInfiniteScroll: true,
//            autoPlayInterval: Duration(seconds: 2),
//            autoPlayAnimationDuration: Duration(milliseconds: 2000),
//            pauseAutoPlayOnTouch: Duration(seconds: 7),
//            scrollDirection: Axis.horizontal,
//            onPageChanged: (index) {
//              setState(() {
//                _current = index;
//              });
//            },
//            itemBuilder: (context, index) =>
//                buildItem(index, snapshot.data.documents[index]),
//            itemCount: snapshot.data.documents.length,
////          controller:_pageController,
////          onPageChanged: getnextpage(),
//          );
//        }
//
////        return new ListView(
////          reverse: true,
////          controller: listScrollController,
////          children: snapshot.data.documents.map((DocumentSnapshot document) {
////            if(DateTime.now().millisecondsSinceEpoch - int.parse(document['timestamp'])>2*60*60*60*1000){
////              int valuetime = (DateTime.now().millisecondsSinceEpoch - int.parse(document['timestamp']));
////              autodelete(valuetime);}else{
////              int value = (DateTime.now().millisecondsSinceEpoch - int.parse(document['timestamp']));
////              Fluttertoast.showToast(msg: "Not Ready To Delete");
////              Fluttertoast.showToast(msg: '$value');
////
////            }
////            var story = document['content'];
////            print('stories:$story');
////            return Container(
////              height: 350,
////              child: Card(
////                semanticContainer: true,
////                clipBehavior: Clip.antiAliasWithSaveLayer,
////                shape: RoundedRectangleBorder(
////                  borderRadius: BorderRadius.circular(10.0),
////                ),
////                elevation: 5,
////                margin: EdgeInsets.all(10),
////                child: StoryView(
////                  [
////
////                    if(document['type']== 0)
////                  StoryItem.text(
////                    document['content'],
////                    Colors.blue,
////                  ),
//////                  StoryItem.text(
//////                    "Nice!\n\nTap to continue.",
//////                    Colors.red,
//////                  ),
////                  if(document['type']==1)
////                    StoryItem.pageImage(
////                      NetworkImage(
////                          document['content']),
////                      caption: document['caption'],
////                    ),
////
//////                  StoryItem.pageGif(
//////                      "https://media.giphy.com/media/5GoVLqeAOo6PK/giphy.gif",
//////                      caption: "Working with gifs",
//////                      controller: storyController),
//////                  StoryItem.pageGif(
//////                    "https://media.giphy.com/media/XcA8krYsrEAYXKf4UQ/giphy.gif",
//////                    caption: "Hello, from the other side",
//////                    controller: storyController,
//////                  ),
//////                  StoryItem.pageGif(
//////                    "https://media.giphy.com/media/XcA8krYsrEAYXKf4UQ/giphy.gif",
//////                    caption: "Hello, from the other side2",
//////                    controller: storyController,
//////                  ),
////                  ],
////                  onStoryShow: (s) {
////                    print("Showing a story");
////                  },
////                  onComplete: () {
////                    if(document['type']==1){
////                      ImageDialogbox(document['content']);
////                    }
////                  },
////                  progressPosition: ProgressPosition.top,
////                  repeat: true,
////                  controller: storyController,
////
////                ),
////              ),
////            );
////          }).toList(),
////        );
//      },
//    );
//  }

  Widget ImageDialogbox(imgUrl) {
    showDialog(
      context: context,
      builder: (context) {
        return GestureDetector(
          onTap: () {
            Navigator.of(context).pop();
          },
          child: customDialog.Dialog(
            backgroundColor: Colors.transparent,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: PhotoView(
                imageProvider: CachedNetworkImageProvider(imgUrl),
                backgroundDecoration: BoxDecoration(color: Colors.transparent),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget buildLoading() {
    return Positioned(
      child: isLoading
          ? Container(
              child: Center(
                child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(themeColor)),
              ),
              color: Colors.white.withOpacity(0.8),
            )
          : Container(),
    );
  }

  buildItem(int index, DocumentSnapshot document) {
      if (DateTime.now().millisecondsSinceEpoch -
              int.parse(document['timestamp']) >
          24 * 60 * 60 * 1000) {
        Firestore.instance
            .collection('Stories')
            .document(widget.currentUserId)
            .collection(widget.currentUserId)
            .document(document.documentID)
            .delete();

        Fluttertoast.showToast(
          msg: "Story has been Expired",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.blueAccent,
          timeInSecForIos: 1,
          textColor: Colors.white,
        );
      } else {
        double value = (DateTime.now().millisecondsSinceEpoch -
                int.parse(document['timestamp'])) /
            60000;
        valuetime = value.round();

//                    int value = (DateTime.now().millisecondsSinceEpoch -
//                        int.parse(document['timestamp']));
//                    Fluttertoast.showToast(msg: "Not Ready To Delete");
//      Fluttertoast.showToast(msg: '$valuetime');
      }
      return Stack(
        children: <Widget>[
          Positioned(
              top: 5,
              right: 20,
              left: 0,
              bottom: 0,
              child: Container(
                margin: EdgeInsets.all(5),
                width: double.infinity,
                alignment: Alignment.topRight,
                child: Card(
                  elevation: 10,
                  clipBehavior: Clip.hardEdge,
                  color: Colors.black54,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      valuetime < 2
                          ? 'Just Now'
                          : valuetime >= 2 && valuetime < 60
                              ? valuetime.toString() + ' mins ago'
                              : valuetime >= 60 && valuetime < 2 * 60
                                  ? '1 hr ago'
                                  : valuetime >= 2 * 60 && valuetime < 3 * 60
                                      ? '2 hrs ago'
                                      : valuetime >= 3 * 60 && valuetime < 4 * 60
                                          ? '3 hrs ago'
                                          : valuetime >= 4 * 60 &&
                                                  valuetime < 5 * 60
                                              ? '4 hrs ago'
                                              : valuetime >= 5 * 60 &&
                                                      valuetime < 6 * 60
                                                  ? '5 hrs ago'
                                                  : valuetime >= 6 * 60 &&
                                                          valuetime < 7 * 60
                                                      ? '6 hrs ago'
                                                      : valuetime >= 7 * 60 &&
                                                              valuetime < 8 * 60
                                                          ? '7 hrs ago'
                                                          : valuetime >= 8 * 60 &&
                                                                  valuetime <
                                                                      9 * 60
                                                              ? '8 hrs ago'
                                                              : valuetime >= 9 * 60 && valuetime < 10 * 60
                                                                  ? '9 hrs ago'
                                                                  : valuetime >= 10 * 60 && valuetime < 11 * 60
                                                                      ? '10 hrs ago'
                                                                      : valuetime >= 11 * 60 && valuetime < 12 * 60
                                                                          ? '11 hrs ago'
                                                                          : valuetime >= 12 * 60 && valuetime < 13 * 60
                                                                              ? '12 hrs ago'
                                                                              : valuetime >= 13 * 60 && valuetime < 14 * 60 ? '13 hrs ago' : valuetime >= 14 * 60 && valuetime < 15 * 60 ? '14 hrs ago' : valuetime >= 15 * 60 && valuetime < 16 * 60 ? '15 hrs ago' : valuetime >= 16 * 60 && valuetime < 17 * 60 ? '16 hrs ago' : valuetime >= 17 * 60 && valuetime < 18 * 60 ? '17 hrs ago' : valuetime >= 18 * 60 && valuetime < 19 * 60 ? '18 hrs ago' : valuetime >= 19 * 60 && valuetime < 20 * 60 ? '19 hrs ago' : valuetime >= 20 * 60 && valuetime < 21 * 60 ? '20 hrs ago' : valuetime >= 21 * 60 && valuetime < 22 * 60 ? '21 hrs ago' : valuetime >= 22 * 60 && valuetime < 23 * 60 ? '22 hrs ago' : valuetime >= 23 * 60 && valuetime < 24 * 60 ? '23 hrs ago' : '24 hrs ago',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              )),
          Positioned(
              top: 0,
              right: 0,
              left: 0,
              bottom: 3,
              child: Container(
                margin:
                    EdgeInsets.only(top: 50.0, left: 15, right: 15, bottom: 15),
                decoration: BoxDecoration(
//                              border: Border.all(width : 10.0,color: Colors.transparent),
                  borderRadius: BorderRadius.circular(25.0),
                  boxShadow: [
                    BoxShadow(
                        color: Color.fromARGB(80, 0, 0, 0),
                        blurRadius: 5.0,
                        offset: Offset(5.0, 5.0))
                  ],
                ),
                height: 350,
                child: ClipRRect(
                  borderRadius: BorderRadius.all(Radius.circular(25)),
                  child: StoryView(
                    [
                      if (document['type'] == 0)
                        StoryItem.text(
                          document['content'],
                          currentColor,
                          fontSize: 30,
                        ),
//                    if (document['type'] == 0)
//                      StoryItem.text(
//                        "Nice!\n\nTap to continue.",
//                        Colors.red,
//                      ),

                      if (document['type'] == 1)
                        StoryItem.pageImage(
                          CachedNetworkImageProvider(document['content']),
                          imageFit: BoxFit.cover,
                          caption: document['caption'],
                        ),

//                StoryItem.pageImage(
//                  CachedNetworkImageProvider(document['content']),
//                  imageFit: BoxFit.cover,
//                  caption: document['caption'],
//                ),

                      if (document['type'] == 2)
                        StoryItem.pageGif(document['content'],
                            caption: document['caption'],
                            controller: storyController),
                    ],
                    onStoryShow: (s) {
                    },
                    onComplete: () {
                      if (document['type'] == 1) {
                        ImageDialogbox(document['content']);
                      }
                    },
                    progressPosition: ProgressPosition.top,
                    repeat: true,
                    controller: storyController,
                  ),
                ),
              )),
        ],
      );

    //  Second type Using Carasoul only

//    if (DateTime.now().millisecondsSinceEpoch -
//            int.parse(document['timestamp']) >
//        24 * 60 * 60 * 1000) {
//      Firestore.instance
//          .collection('Stories')
//          .document(widget.currentUserId)
//          .collection(widget.currentUserId)
//          .document(document.documentID)
//          .delete();
//
//      Fluttertoast.showToast(
//        msg: "Data Deletion Success",
//        toastLength: Toast.LENGTH_SHORT,
//        gravity: ToastGravity.BOTTOM,
//        backgroundColor: Colors.blueAccent,
//        timeInSecForIos: 1,
//        textColor: Colors.white,
//      );
//    } else {
//      double value = (DateTime.now().millisecondsSinceEpoch -
//              int.parse(document['timestamp'])) /
//          60000;
//      valuetime = value.round();
//
////                    int value = (DateTime.now().millisecondsSinceEpoch -
////                        int.parse(document['timestamp']));
////                    Fluttertoast.showToast(msg: "Not Ready To Delete");
////      Fluttertoast.showToast(msg: '$valuetime');
//    }
//
//    return document['type'] == 1
//        ? GestureDetector(
//            onTap: () {
//              ImageDialogbox(document['content']);
//            },
//            child: Container(
//              height: MediaQuery.of(context).size.height - 300,
//              margin:
//                  EdgeInsets.only(top: 50.0, left: 15, right: 15, bottom: 15),
//              decoration: BoxDecoration(
//                  color: currentColor,
////                              border: Border.all(width : 10.0,color: Colors.transparent),
//                  borderRadius: BorderRadius.circular(25.0),
//                  boxShadow: [
//                    BoxShadow(
//                        color: Color.fromARGB(80, 0, 0, 0),
//                        blurRadius: 5.0,
//                        offset: Offset(5.0, 5.0))
//                  ],
//                  image: DecorationImage(
//                      fit: BoxFit.contain,
//                      image: document['content'] != null
//                          ? CachedNetworkImageProvider(document['content'])
//                          : CircularProgressIndicator(backgroundColor: Colors.black,))),
//              width: MediaQuery.of(context).size.width,
//              child: Column(
//                mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                children: <Widget>[
//                  Container(
//                    margin: EdgeInsets.all(10),
//                    width: double.infinity,
//                    alignment: Alignment.topRight,
//                    child: Card(
//                      elevation: 10,
//                      clipBehavior: Clip.hardEdge,
//                      color: Colors.black54,
//                      child: Padding(
//                        padding: const EdgeInsets.all(8.0),
//                        child: Text(
//                          valuetime < 2
//                              ? 'Just Now'
//                              : valuetime >= 2 && valuetime < 60
//                                  ? valuetime.toString() + ' mins ago'
//                                  : valuetime >= 60 && valuetime < 2 * 60
//                                      ? '1 hr ago'
//                                      : valuetime >= 2 * 60 && valuetime < 3 * 60
//                                          ? '2 hrs ago'
//                                          : valuetime >= 3 * 60 && valuetime < 4 * 60
//                                              ? '3 hrs ago'
//                                              : valuetime >= 4 * 60 &&
//                                                      valuetime < 5 * 60
//                                                  ? '4 hrs ago'
//                                                  : valuetime >= 5 * 60 &&
//                                                          valuetime < 6 * 60
//                                                      ? '5 hrs ago'
//                                                      : valuetime >= 6 * 60 &&
//                                                              valuetime < 7 * 60
//                                                          ? '6 hrs ago'
//                                                          : valuetime >= 7 * 60 &&
//                                                                  valuetime <
//                                                                      8 * 60
//                                                              ? '7 hrs ago'
//                                                              : valuetime >= 8 * 60 &&
//                                                                      valuetime <
//                                                                          9 * 60
//                                                                  ? '8 hrs ago'
//                                                                  : valuetime >= 9 * 60 && valuetime < 10 * 60
//                                                                      ? '9 hrs ago'
//                                                                      : valuetime >= 10 * 60 && valuetime < 11 * 60
//                                                                          ? '10 hrs ago'
//                                                                          : valuetime >= 11 * 60 && valuetime < 12 * 60 ? '11 hrs ago' : valuetime >= 12 * 60 && valuetime < 13 * 60 ? '12 hrs ago' : valuetime >= 13 * 60 && valuetime < 14 * 60 ? '13 hrs ago' : valuetime >= 14 * 60 && valuetime < 15 * 60 ? '14 hrs ago' : valuetime >= 15 * 60 && valuetime < 16 * 60 ? '15 hrs ago' : valuetime >= 16 * 60 && valuetime < 17 * 60 ? '16 hrs ago' : valuetime >= 17 * 60 && valuetime < 18 * 60 ? '17 hrs ago' : valuetime >= 18 * 60 && valuetime < 19 * 60 ? '18 hrs ago' : valuetime >= 19 * 60 && valuetime < 20 * 60 ? '19 hrs ago' : valuetime >= 20 * 60 && valuetime < 21 * 60 ? '20 hrs ago' : valuetime >= 21 * 60 && valuetime < 22 * 60 ? '21 hrs ago' : valuetime >= 22 * 60 && valuetime < 23 * 60 ? '22 hrs ago' : valuetime >= 23 * 60 && valuetime < 24 * 60 ? '23 hrs ago' : '24 hrs ago',
//                          style: TextStyle(color: Colors.white),
//                        ),
//                      ),
//                    ),
//                  ),
//                  document['caption']!=null?Container(
//                    margin: EdgeInsets.all(10),
//                    width: double.infinity,
//                    alignment: Alignment.bottomCenter,
//                    child: Card(
//                      elevation: 10,
//                      clipBehavior: Clip.hardEdge,
//                      color: Colors.black54,
//                      child: Padding(
//                        padding: const EdgeInsets.all(8.0),
//                        child: Text(
//                          document['caption'],
//                          style: TextStyle(color: Colors.white),
//                        ),
//                      ),
//                    ),
//                  ):Container(),
//                ],
//              ),
//            ),
//          )
//        : document['type'] == 0
//            ? Container(
//                height: MediaQuery.of(context).size.height - 300,
//                margin:
//                    EdgeInsets.only(top: 50.0, left: 15, right: 15, bottom: 15),
////                color: Colors.blue,
//                decoration: BoxDecoration(
//                  borderRadius: BorderRadius.circular(25),
////                    color: currentColor,
//                    gradient: LinearGradient(
//                        begin: FractionalOffset.bottomCenter,
//                        end: FractionalOffset.topCenter,
//                        colors: [
//                          Colors.black.withOpacity(0.0),
//                          currentColor,
//                        ],
//                        stops: [
//                          0.0,
//                          1.0
//                        ]),
////                  color: currentColor,
//                  boxShadow: [
//                    BoxShadow(
//                        color: Color.fromARGB(80, 0, 0, 0),
//                        blurRadius: 5.0,
//                        offset: Offset(5.0, 5.0))
//                  ],
//                ),
//                child: Column(
////                  mainAxisAlignment: MainAxisAlignment.spaceAround,
////                crossAxisAlignment: CrossAxisAlignment.start,
//                  children: <Widget>[
//                    Container(
//                      margin: EdgeInsets.all(10),
//                      width: double.infinity,
//                      alignment: Alignment.topRight,
//                      child: Card(
//                        elevation: 10,
//                        clipBehavior: Clip.hardEdge,
//                        color: Colors.black54,
//                        child: Padding(
//                          padding: const EdgeInsets.all(8.0),
//                          child: Text(
//                            valuetime < 2
//                                ? 'Just Now'
//                                : valuetime >= 2 && valuetime < 60
//                                    ? valuetime.toString() + ' mins ago'
//                                    : valuetime >= 60 && valuetime < 2 * 60
//                                        ? '1 hr ago'
//                                        : valuetime >= 2 * 60 &&
//                                                valuetime < 3 * 60
//                                            ? '2 hrs ago'
//                                            : valuetime >= 3 * 60 &&
//                                                    valuetime < 4 * 60
//                                                ? '3 hrs ago'
//                                                : valuetime >= 4 * 60 &&
//                                                        valuetime < 5 * 60
//                                                    ? '4 hrs ago'
//                                                    : valuetime >= 5 * 60 &&
//                                                            valuetime < 6 * 60
//                                                        ? '5 hrs ago'
//                                                        : valuetime >= 6 * 60 &&
//                                                                valuetime <
//                                                                    7 * 60
//                                                            ? '6 hrs ago'
//                                                            : valuetime >= 7 * 60 &&
//                                                                    valuetime <
//                                                                        8 * 60
//                                                                ? '7 hrs ago'
//                                                                : valuetime >= 8 * 60 && valuetime < 9 * 60
//                                                                    ? '8 hrs ago'
//                                                                    : valuetime >= 9 * 60 && valuetime < 10 * 60
//                                                                        ? '9 hrs ago'
//                                                                        : valuetime >= 10 * 60 && valuetime < 11 * 60
//                                                                            ? '10 hrs ago'
//                                                                            : valuetime >= 11 * 60 && valuetime < 12 * 60 ? '11 hrs ago' : valuetime >= 12 * 60 && valuetime < 13 * 60 ? '12 hrs ago' : valuetime >= 13 * 60 && valuetime < 14 * 60 ? '13 hrs ago' : valuetime >= 14 * 60 && valuetime < 15 * 60 ? '14 hrs ago' : valuetime >= 15 * 60 && valuetime < 16 * 60 ? '15 hrs ago' : valuetime >= 16 * 60 && valuetime < 17 * 60 ? '16 hrs ago' : valuetime >= 17 * 60 && valuetime < 18 * 60 ? '17 hrs ago' : valuetime >= 18 * 60 && valuetime < 19 * 60 ? '18 hrs ago' : valuetime >= 19 * 60 && valuetime < 20 * 60 ? '19 hrs ago' : valuetime >= 20 * 60 && valuetime < 21 * 60 ? '20 hrs ago' : valuetime >= 21 * 60 && valuetime < 22 * 60 ? '21 hrs ago' : valuetime >= 22 * 60 && valuetime < 23 * 60 ? '22 hrs ago' : valuetime >= 23 * 60 && valuetime < 24 * 60 ? '23 hrs ago' : '24 hrs ago',
//                            style: TextStyle(color: Colors.white),
//                          ),
//                        ),
//                      ),
//                    ),
//                    Center(
//                      child: Container(
//                          margin: EdgeInsets.only(top: 170),
//                          alignment: Alignment.center,
//                          child: Text(
//                            document['content'],
//                            style: TextStyle(fontSize: 30, color: Colors.white),
//                          )),
//                    ),
//                  ],
//                ))
//            : Container();
  }
}
