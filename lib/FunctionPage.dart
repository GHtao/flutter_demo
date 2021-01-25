
import 'dart:ffi';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

void main(){
  runApp(FunctionApp());
}
///功能性组件
class FunctionApp extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Function Page",
      theme: ThemeData(
        primaryColor: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity
      ),
      home: DialogPage(),
    );
  }
}
///拦截点击事件
class WillPopScopePage extends StatefulWidget{
  @override
  State<StatefulWidget> createState() => _WillPopScopeState();
}
class _WillPopScopeState extends State{
  @override
  void reassemble() {
    super.reassemble();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Will Pop Scope"),
      ),
      body: Container(
          alignment: Alignment.center,
          child: RaisedButton(
            child: Text("button"),
            onPressed: (){
              Navigator.of(context).push(MaterialPageRoute(builder: (context){
                return BackPage();
              }));
            },
          ),
        ),
    );
  }
}

class BackPage extends StatefulWidget{
  @override
  State<StatefulWidget> createState() => _BackState();
  
}
class _BackState extends State{
  DateTime _lastClick;
  Future<bool> _quickClick(){
    if(_lastClick == null ||
        DateTime.now().difference(_lastClick) > Duration(seconds: 1)){
      _lastClick = DateTime.now();
      print("点击时间小于1s");
      return Future.value(false);
    }
    return Future.value(true);
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("back"),
      ),
      body: Container(
        alignment: Alignment.center,
        //只能作用于 导航返回和物理返回键
        child: WillPopScope(
          onWillPop: _quickClick,
          child: Text("aaa"),
        ),
      ),
    );
  }
  
}
///数据共享
class InheritedPage extends StatefulWidget{
  @override
  State<StatefulWidget> createState() => _InheritedState();

}
class _InheritedState extends State{
  int _count = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Inherited"),
      ),
      body: Center(
        child: SharedDataWidget(
            data: _count,
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.all(8),
                  child:TestWidget(),
                ),
                RaisedButton(
                  onPressed: (){
                    setState(() {
                      _count++;
                    });
                  },
                  child: Text("press"),
                )
              ],
            ),
        ),
      ),
    );
  }
}

class SharedDataWidget extends InheritedWidget{

  SharedDataWidget({@required this.data,Widget child}):super(child:child);
  //需要在子树中共享的数据，保存点击次数
  final int data;

  //定义一个便捷方法，方便子树中的widget获取共享数据
  static SharedDataWidget of(BuildContext context){
    //这个方法返回的SharedDataWidget就不会调用didChangeDependencies方法了
//    context.getElementForInheritedWidgetOfExactType<ShareDataWidget>().widget;
    return context.dependOnInheritedWidgetOfExactType<SharedDataWidget>();
  }

  //该回调决定当data发生变化时，是否通知子树中依赖data的Widget
  @override
  bool updateShouldNotify(SharedDataWidget oldWidget) {
    //如果返回true，则子树中依赖(build函数中有调用)本widget
    //的子widget的`state.didChangeDependencies`会被调用
    return oldWidget.data != data;
  }
}

class TestWidget extends StatefulWidget{
  @override
  State<StatefulWidget> createState() => _TestState();
}
class _TestState extends State{
  @override
  Widget build(BuildContext context) {
    //这里不使用SharedDataWidget数据的话，didChangeDependencies不会调用
    return Text(SharedDataWidget.of(context).data.toString());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    //父或祖先widget中的InheritedWidget改变(updateShouldNotify返回true)时会被调用。
    //如果build中没有依赖InheritedWidget，则此回调不会被调用。
    print("Dependencies change");
  }
}
///对话框
class DialogPage extends StatefulWidget{
  @override
  State<StatefulWidget> createState() => _DialogState();
}
class _DialogState extends State{
  ///异步获取数据之后更新UI
  Future<String> loadData(){
    return Future.delayed(Duration(seconds: 2)).then((value) => "load data");
  }
  ///显示dialog
  Future<bool> showDialog1() {
    return showDialog<bool>(context:context,
        //点击屏幕不消失
        barrierDismissible: false,
        //背景色
//        barrierColor: Colors.grey,
        builder:(context){
          return AlertDialog(
            title: Text("提示"),
            content: Text("普通的dialog"),
            actions: [
              FlatButton(
                onPressed: (){
                  Navigator.of(context).pop(false);
                },
                child: Text("取消"),
              ),
              FlatButton(
                onPressed: (){
                  Navigator.of(context).pop(true);
                },
                child: Text("确定"),
              ),
            ],
          );
        });
  }
  ///显示简单列表dialog
  Future<String> showSimpleDialog(){
    return showDialog<String>(
        context: context,
        builder: (context){
          return SimpleDialog(
            title: Text("选择语言"),
            children: [
              SimpleDialogOption(
                onPressed: (){
                  print("简体中文");
                  Navigator.of(context).pop("简体中文");
                },
                child: Padding(
                  padding: EdgeInsets.only(left: 8),
                  child: Text("简体中文"),
                ),
              ),
              SimpleDialogOption(
                onPressed: (){
                  print("English");
                  Navigator.of(context).pop("English");
                },
                child: Padding(
                  padding: EdgeInsets.only(left: 8),
                  child: Text("English"),
                ),
              )
            ],
          );
        }
    );
  }
  ///列表dialog
  void listDialog() async {
    int i = await showDialog<int>(context: context,
      builder: (context){
        var list = Column(
          children: [
            ListTile(
              title: Text("请选择"),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: 30,
                itemBuilder: (context,index){
                  return ListTile(
                    title: Text("item $index"),
                    onTap: (){
                      Navigator.of(context).pop(index);
                    },
                  );
                }
              ),
            )
          ],
        );
        return Dialog(child: list);
      }
    );
    print("index:$i");
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("dialog"),
      ),
      body: Container(
        //可以覆盖上级控件的主题
        child: Theme(
          data: ThemeData(
            buttonTheme: ButtonThemeData(
              buttonColor: Color(0x105732)
            )
          ),
          child: Center(
            child: Column(
              children: [
                FutureBuilder<String>(
                    future: loadData(),
                    builder: (context, snapshot){
                      String data = "";
                      switch(snapshot.connectionState){
                        case ConnectionState.done:
                          print("future done");
                          if(snapshot.hasError){
                            print("future error");
                          }else{
                            print("future data");
                            data = snapshot.data;
                          }
                          break;
                        case ConnectionState.none:
                          print("future none");
                          break;
                        case ConnectionState.active:
                          print("future active");
                          break;
                        case ConnectionState.waiting:
                          print("future waiting");
                          return CircularProgressIndicator();
                      }

                    return Text(data);
                  },
                ),
                RaisedButton(
                  child: Text("dialog"),
                  onPressed: () async{
                    bool result = await showDialog1();
                    result ? print("确定") :print("取消");
                  },
                ),
                RaisedButton(
                  onPressed: () async {
                    String result = await showSimpleDialog();
                  },
                  child: Text("simple dialog"),
                ),
                RaisedButton(
                  onPressed: () {
                    listDialog();
                  },
                  child: Text("list dialog"),
                )
              ],
            ),
          ),
        )
      ),
    );
  }

}