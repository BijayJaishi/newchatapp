import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:photo_view/photo_view.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:story_view/story_view.dart';
import 'package:newchatapp/Custom_dialog/customDialog.dart' as customDialog;

import 'const.dart';

class ViewStory extends StatefulWidget {

  final String peerId;
  final String peerAvatar;

  ViewStory({Key key, @required this.peerId, @required this.peerAvatar})
      : super(key: key);

  @override
  _ViewStoryState createState() => _ViewStoryState();
}

class _ViewStoryState extends State<ViewStory> {

  final storyController = StoryController();
  int mselectonIndex = 0;
  bool isLoading;

  int valuetime;
  int _current = 0;
  var rnd;
  String _gif;
  var length;

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
  SharedPreferences prefs;
  String id;
  String newId;
  var currentColor = Colors.black54;
  final ScrollController listScrollController = new ScrollController();

  @override
  void initState() {
    // TODO: implement initState
    isLoading = false;
    super.initState();
    readLocal();
  }

  readLocal() async {
    prefs = await SharedPreferences.getInstance();
    id = prefs.getString('id') ?? '';
      Firestore.instance
          .collection('users')
          .document(widget.peerId)
          .updateData({'seenBy': id});

    Firestore.instance
        .collection('users')
        .document(widget.peerId)
        .updateData({'done': 'yes'});
  }



  setRandomColor() {
    rnd = Random().nextInt(colors.length);
    setState(() {
      currentColor = colors[rnd];
    });
  }
  @override
  void dispose() {
    storyController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(
        title: new Text(
          'View Story',
          style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: CircleAvatar(
              radius: 40,
              child: Material(
                child: widget.peerAvatar != null
                    ? CachedNetworkImage(
                  placeholder: (context, url) => Container(
                    child: CircularProgressIndicator(
                      strokeWidth: 0.5,
                      valueColor: AlwaysStoppedAnimation<Color>(themeColor),
                    ),
                    width: 40.0,
                    height: 40.0,
                    padding: EdgeInsets.all(15.0),
                  ),
                  imageUrl:widget.peerAvatar,
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
        child: Stack(
          children: <Widget>[
            Positioned(top:20,left:0,right: 0,child: getData()),
//          GridView.count(
//            crossAxisCount: 2,
//            crossAxisSpacing: 12.0,
//            mainAxisSpacing: 12.0,
//            padding: EdgeInsets.symmetric(horizontal: 16.0,vertical: 8.0),
//            children: <Widget>[
//              GestureDetector(child: MyItems(Icons.image,"Image",Colors.red),onTap: ()=> getImage(),),
//              MyItems(Icons.gif,"Gifs",Colors.orange),
//              MyItems(Icons.text_format,"Texts",Colors.blue),
//              MyItems(Icons.ondemand_video,"Videos",Colors.purple),
//            ],
//
//          ),
////
            buildLoading(),
          ],
        ),
        onWillPop: onBackPress,
      ),
    );
  }

//  Widget getData()  {
//    return StreamBuilder<QuerySnapshot>(
//      stream: Firestore.instance.collection('Stories')
//          .document(widget.peerId)
//          .collection(widget.peerId).orderBy('timestamp', descending: true).snapshots(),
//      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
//
//        if (!snapshot.hasData) {return new Text('Loading...');}
//        else{
////          print('data:${snapshot.data}');
//          return new ListView(
//            reverse: true,
//            controller: listScrollController,
//            children: snapshot.data.documents.map((DocumentSnapshot document) {
////            if(DateTime.now().millisecondsSinceEpoch - int.parse(document['timestamp'])>2*60*60*60*1000){
////              int valuetime = (DateTime.now().millisecondsSinceEpoch - int.parse(document['timestamp']));
////              autodelete(valuetime);}else{
////              int value = (DateTime.now().millisecondsSinceEpoch - int.parse(document['timestamp']));
////              Fluttertoast.showToast(msg: "Not Ready To Delete");
////              Fluttertoast.showToast(msg: '$value');
////
////            }
//              var story = document['content'];
//              print('stories:$story');
//
//              return Container(
//                height: 350,
//                child: Card(
//                  semanticContainer: true,
//                  clipBehavior: Clip.antiAliasWithSaveLayer,
//                  shape: RoundedRectangleBorder(
//                    borderRadius: BorderRadius.circular(10.0),
//                  ),
//                  elevation: 5,
//                  margin: EdgeInsets.all(10),
//                  child: StoryView(
//                    [
//
//                      if(document['type']== 0)
//                        StoryItem.text(
//                          document['content'],
//                          Colors.blue,
//                        ),
////                  StoryItem.text(
////                    "Nice!\n\nTap to continue.",
////                    Colors.red,
////                  ),
//                      if(document['type']==1)
//                        StoryItem.pageImage(
//                          NetworkImage(
//                              document['content']),
//                          caption: document['caption'],
//                        ),
//
//
//                  if(document['type']==2)
//                  StoryItem.pageGif(
//                      document['content'],
//                      caption: document['caption'],
//                      controller: storyController),
////                  StoryItem.pageGif(
////                    "https://media.giphy.com/media/XcA8krYsrEAYXKf4UQ/giphy.gif",
////                    caption: "Hello, from the other side",
////                    controller: storyController,
////                  ),
////                  StoryItem.pageGif(
////                    "https://media.giphy.com/media/XcA8krYsrEAYXKf4UQ/giphy.gif",
////                    caption: "Hello, from the other side2",
////                    controller: storyController,
////                  ),
//                    ],
//                    onStoryShow: (s) {
//                      print("Showing a story");
//                    },
//                    onComplete: () {
//                      if(document['type']==1){
//                        ImageDialogbox(document['content']);
//                      }
//                    },
//                    progressPosition: ProgressPosition.top,
//                    repeat: true,
//                    controller: storyController,
//
//                  ),
//                ),
//              );
//            }).toList(),
//          );
//        }
//
//      },
//    );
//  }

  Widget getData() {
    return widget.peerId == ''
        ? Center(
        child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(themeColor)))
        : StreamBuilder<QuerySnapshot>(
      stream: Firestore.instance
          .collection('Stories')
          .document(widget.peerId)
          .collection(widget.peerId)
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder:
          (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData) {
          return Container(
            margin: EdgeInsets.only(top:310),
            child: Center(
                child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(themeColor))),
          );
        } else {
//          listMessage = snapshot.data.documents;
//          print('listmessage:$listMessage');
//          print('length: ${snapshot.data.documents.length}');
          length = snapshot.data.documents.length;
          if (length == 0) {
            return Container(
              margin: EdgeInsets.only(top:310),
              child: Center(

                child: Text(
                  "No any Story To View",style: TextStyle(fontSize: 16,fontStyle: FontStyle.italic,letterSpacing: 1.0,fontWeight: FontWeight.bold),),
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
    newId =document['seenBy'];
    if (DateTime.now().millisecondsSinceEpoch -
        int.parse(document['timestamp']) >
        24 * 60 * 60 * 1000) {
      Firestore.instance
          .collection('Stories')
          .document(widget.peerId)
          .collection(widget.peerId)
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
            bottom: 0,
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

  }

  Future<bool> onBackPress() {
    if(id == widget.peerId) {
      Firestore.instance
          .collection('users')
          .document(id)
          .updateData({'done': 'No'});
    }else{
      Firestore.instance
          .collection('users')
          .document(id)
          .updateData({'done': 'yes'});
    }

      Firestore.instance
          .collection('users')
          .document(widget.peerId)
          .updateData({'done': 'yes'});
      Navigator.pop(context);

    return Future.value(false);
  }
}
