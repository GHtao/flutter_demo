//import 'dart:html';

import 'dart:async';

import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
///自己处理上报的异常
void reportError(FlutterErrorDetails details){
  print(details);
}
///收集日志信息
void collectLog(String line){

}
///构建错误信息
FlutterErrorDetails makeDetails(Object object,StackTrace trace){
    return FlutterErrorDetails();
}

void main() {
  ///flutter 代码的异常可以这样捕获 复写框架的onError
  FlutterError.onError = (FlutterErrorDetails details){
    reportError(details);
  };
  ///Flutter没有为我们捕获的异常，如调用空对象方法异常、Future中的异常
  ///通过runZoned来捕获这些flutter没有捕获的异常
  runZoned(
    //runZoned 相当于沙箱 不同的沙箱代码隔离 沙箱可以捕获拦截一些代码行为
      ()=>runApp(MyApp()),
      zoneSpecification: ZoneSpecification(
        //Zone的一些配置，可以自定义一些代码行为，比如拦截日志输出行为等
        print: (Zone self,ZoneDelegate parent, Zone zone, String line){
          //拦截应用中所有调用print输出日志的行为
          collectLog(line);
        }
      ),
      onError: (Object object,StackTrace trace){
        var detail = makeDetails(object,trace);
        reportError(detail);
      }
  );
}
/// 相当于application
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.cyan,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
      //有名字的路由
//      routes: {
//        //相当于key value的形式
//        "route_page":(context)=>RoutePage(),
//        "named_page":(context)=>NamedPage(),
//        //命名路由不能通过构造函数传递数值 只能转换成argument
//        "tip_page":(context)=>TipRoutePage(message: ModalRoute.of(context).settings.arguments,)
//      },
      ///打开命名路由时，如果指定的路由名在路由表中已注册，则会调用路由表中的builder函数来生成路由组件；
      ///如果路由表中没有注册，才会调用onGenerateRoute来生成路由
      onGenerateRoute: (RouteSettings settings){
        String routeName = settings.name;
        switch(routeName){
          case "route_page":
            return MaterialPageRoute(builder: (context){
              return RoutePage();
            });
          case "named_page":
            return MaterialPageRoute(builder: (context){
              return NamedPage(message:settings.arguments);
            });
          case "tip_page": return MaterialPageRoute(builder: (context){
            return TipRoutePage(message: ModalRoute.of(context).settings.arguments,);
          });
          default :
            return MaterialPageRoute(builder: (context){
              return Scaffold(
                body: Center(
                  child: Text("page not found"),
                ),
              );
            });
        }
      });
  }
}

///相当于页面
class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}
class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }
  ///每次热更新 都会从新调用build方法
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Align(
        alignment: Alignment.topCenter,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('You have pushed the button this many times:'),
            Text('$_counter', style: Theme.of(context).textTheme.headline4),
            FlatButton(
              child: Text("open new page"),
              textColor: Colors.red,
              onPressed: () async {
                //使用async和await会等待返回结果
                var result = await Navigator.of(context).push(MaterialPageRoute(builder: (context){
                  return TipRoutePage(message: "测试数据传输",);
                }));
                //点击返回箭头不会有返回值
                print("result:$result");
              },
            ),
            FlatButton(
              child: Text("open named page"),
              onPressed: (){
                Navigator.of(context).pushNamed("named_page",arguments: "named page");
              },
            ),
            RandomWeight(),
            Image(
              width: 100,
              height: 100,
              image: AssetImage("assets/flash_four.jpg"),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

/// 定义路由跳转页面
class RoutePage extends StatefulWidget{
  RoutePage({Key key}) :super(key:key);

  @override
  State<StatefulWidget> createState() => _RoutePageState();
}
class _RoutePageState extends State{

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("route page"),
      ),
      body: Center(
        child: Text("new route page"),
      ),
    );
  }
}

///消息提示页面
class TipRoutePage extends StatefulWidget{
  TipRoutePage({Key key,@required this.message}):super(key:key);

  final String message;
  @override
  State<StatefulWidget> createState() {
    return _TipState(this.message);
  }
}
class _TipState extends State{
  _TipState(this.message);
  final String message;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("提示"),
      ),
      body: Padding(
        padding: EdgeInsets.all(18),
        child: Center(
          child: Column(
            children: [
              Text(message),
              RaisedButton(
                onPressed: ()=>{
                  Navigator.pop(context,"10086")
                },
                child: Text("返回"),
              )
            ],
          ),
        ),
      ),
    );
  }
}

///命名路由页面
class NamedPage extends StatefulWidget{
  NamedPage({Key key,this.message}):super(key:key);
  final String message;
  @override
  State<StatefulWidget> createState() {
    return _NamedPageState(message);
  }
}
class _NamedPageState extends State{
  _NamedPageState(this.message);
  final String message;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(message),
      ),
      body: Center(
        child: Text(message),
      ),
    ) ;
  }
}


class RandomWeight extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    final word = new WordPair.random();
    return Padding(
      padding: EdgeInsets.all(8),
      child: new Text(word.toString()),
    );
  }

}
