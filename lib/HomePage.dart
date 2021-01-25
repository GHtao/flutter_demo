
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

void main(){
  runApp(MainPageApp());
}

class MainPageApp extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primaryColor: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      title: "main",
      home: MainPage(),
    );
  }
}

class MainPage extends StatefulWidget{
  @override
  State<StatefulWidget> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> with SingleTickerProviderStateMixin{
  List tabs = ["tab1","tab2","tab3"];
  TabController _tabCtrl;
  int _selIndex = 0;
  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: tabs.length,vsync: this);
  }

  @override
  void reassemble() {
    super.reassemble();
    if(_tabCtrl == null) _tabCtrl = TabController(length: tabs.length,vsync: this);
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "main"
        ),
        actions: [
          Container(
            child:  IconButton(
              onPressed: (){
                print("share");
              },
              icon: Icon(Icons.share),
            ),
          ),
        ],
        bottom: TabBar(
          controller: _tabCtrl,
          tabs: tabs.map((e) =>Tab(
            text: e,
          )).toList(),
        ),
      ),
      drawer: Drawer(
        child: MediaQuery.removePadding(
          removeTop: true,
            context: context,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  alignment: AlignmentDirectional.center,
                  padding: EdgeInsets.only(top: 30),
                  child: Icon(Icons.account_circle),
                ),
                Expanded(
                  child: ListView(
                    children: [
                      ListTile(
                        title: Text("add account"),
                        leading: Icon(Icons.add),
                      ),
                      ListTile(
                        title: Text("settings"),
                        leading: Icon(Icons.settings),
                      )
                    ],
                  ),
                ),
              ],
            )),
      ),
      //TabBarView和TabBar配合使用 使用同一个controller可以自己控制状态
      body: TabBarView(
        controller: _tabCtrl,
        children: tabs.map((e) =>
            Container(
              alignment: AlignmentDirectional.center,
              child: Text(
                e,
                textScaleFactor: 5,
              ),
            )
        ).toList(),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,

        currentIndex: _selIndex,
        onTap: (position){
          setState(() {
            _selIndex = position;
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            title: Text("home")
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.terrain),
            title: Text("news")
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.report_problem),
            title: Text("project")
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            title: Text("setting")
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: (){
          print("FloatingActionButton");
        },
      ),
    );
  }
}