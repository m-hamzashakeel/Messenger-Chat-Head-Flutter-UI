import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey _floatingKey = GlobalKey();
  bool chatHeadOpened = false;

  // getting size of chat head
  Size floatingSize;

  // Initial Location of Chat Head
  Offset floatingLocation = Offset(0, 20);

  void getFloatingSize() async {
    RenderBox _floatingBox = _floatingKey.currentContext.findRenderObject();
    floatingSize = _floatingBox.size;
  }

  void onDragUpdate(BuildContext context, DragUpdateDetails dragUpdateDetails) {
    setState(() {
      chatHeadOpened = false;
    });

    // Gesture location on screen
    final RenderBox box = context.findRenderObject();
    final Offset offset = box.globalToLocal(dragUpdateDetails.localPosition);

    // Screen Area
    final double startX = 0;
    final double endX = context.size.width - floatingSize.width;
    if (!chatHeadOpened) {}
    final double startY = MediaQuery.of(context).padding.top;
    final double endY = context.size.height - floatingSize.height;

    // Make sure the widget floats within screen area and keep updating its position, if changed
    if (startX < offset.dx && offset.dx < endX) {
      if (startY < offset.dy && offset.dy < endY) {
        setState(() {
          floatingLocation = Offset(offset.dx, offset.dy);
        });
      }
    }
  }

  void onDragEnd(BuildContext context, DragEndDetails dragEndDetails) {
    // Make sure to set the widget on left or right of the screen
    final double pointX = context.size.width / 2;

    if ((floatingLocation.dx + floatingSize.width / 2) < pointX) {
      setState(() {
        floatingLocation = Offset(0, floatingLocation.dy);
      });
    } else {
      setState(() {
        if (!chatHeadOpened) {
          floatingLocation = Offset(
              context.size.width - floatingSize.width, floatingLocation.dy);
        } else {
          floatingLocation =
              Offset(context.size.width * 0.35, floatingLocation.dy);
        }
      });
    }
  }

  @override
  void initState() {
    WidgetsBinding.instance
        .addPostFrameCallback((timeStamp) => getFloatingSize());
    super.initState();
  }

  _openChatHead() {
    setState(() {
      chatHeadOpened = !chatHeadOpened;
      if (chatHeadOpened) {
        floatingLocation = Offset(0, 20);
      } else {
        floatingLocation = Offset(MediaQuery.of(context).size.width * 0.8, 20);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xff4267B2),
        title: Text("Messenger Chat Head Example"),
      ),
      body: GestureDetector(
        onTap: _openChatHead,
        onVerticalDragUpdate: (DragUpdateDetails details) =>
            onDragUpdate(context, details),
        onHorizontalDragUpdate: (DragUpdateDetails details) =>
            onDragUpdate(context, details),
        onVerticalDragEnd: (DragEndDetails details) =>
            onDragEnd(context, details),
        onHorizontalDragEnd: (DragEndDetails details) =>
            onDragEnd(context, details),
        child: Stack(
          children: [
            AnimatedPositioned(
              duration: Duration(milliseconds: 100),
              left: floatingLocation.dx,
              top: floatingLocation.dy,
              child: chatHead(),
            ),
          ],
        ),
      ),
    );
  }

  Widget chatHead() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Row(
          children: [
            chatHeadOpened
                ? ChatHeadBtn(
                    iconData: Icons.play_arrow_rounded,
                    iconSize: MediaQuery.of(context).size.height * 0.08,
                  )
                : Container(),
            chatHeadOpened
                ? SizedBox(
                    width: 10,
                  )
                : SizedBox(),
            chatHeadOpened
                ? ChatHeadBtn(
                    iconData: Icons.message_rounded,
                    iconSize: MediaQuery.of(context).size.height * 0.055,
                  )
                : Container(),
            chatHeadOpened
                ? SizedBox(
                    width: 10,
                  )
                : SizedBox(),
            GestureDetector(
              key: _floatingKey,
              child: Container(
                height: 70,
                width: 70,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(360.0),
                    color: Color(0xff4267B2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 8.0,
                      )
                    ]),
                child: CircleAvatar(
                  backgroundImage: AssetImage('assets/hamza.jpeg'),
                ),
              ),
            )
          ],
        ),
        chatHeadOpened ? chatHeadBody() : Container()
      ],
    );
  }

  Widget chatHeadBody() {
    return Container(
      margin: EdgeInsets.fromLTRB(
          0, MediaQuery.of(context).size.height * 0.02, 0, 0),
      height: MediaQuery.of(context).size.height * 0.72,
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.0),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 8.0,
          )
        ],
      ),
      child: Column(
        children: [ChatHeadAppBar()],
      ),
    );
  }
}

class ChatHeadBtn extends StatelessWidget {
  final IconData iconData;
  final double iconSize;
  ChatHeadBtn({this.iconData, this.iconSize});
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      width: 70,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(360.0),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 8.0,
            )
          ]),
      child: Icon(
        iconData,
        size: iconSize,
        color: Colors.grey[400],
      ),
    );
  }
}

class ChatHeadAppBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height * 0.1,
      child: Card(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [chatHeadUserProfile(), chatHeadAppBarActions()],
        ),
      ),
    );
  }

  Widget chatHeadUserProfile() {
    return FlatButton(
        onPressed: () {},
        child: Row(
          children: [
            CircleAvatar(
              backgroundImage: AssetImage('assets/hamza.jpeg'),
              maxRadius: 20,
            ),
            SizedBox(
              width: 10,
            ),
            Text("Hamza")
          ],
        ));
  }

  Widget chatHeadAppBarActions() {
    return Row(
      children: [
        IconButton(icon: Icon(Icons.phone), onPressed: () {}),
        IconButton(icon: Icon(Icons.video_call), onPressed: () {}),
        IconButton(icon: Icon(Icons.info), onPressed: () {}),
      ],
    );
  }
}
