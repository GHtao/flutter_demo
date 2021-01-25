
import 'package:demo/EventBus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

void main(){
  runApp(EventApp());
}

class EventApp extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "事件处理",
      theme: ThemeData(
        primaryColor: Colors.blue,
        accentColor: Colors.yellow,
        visualDensity: VisualDensity.adaptivePlatformDensity
      ),
      home: NotificationPage(),
    );
  }
}
///组件的点击事件
class EventPage extends StatefulWidget{
  @override
  State<StatefulWidget> createState() => _EventState();
}
class _EventState extends State{
  PointerEvent _event;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("触摸事件"),
      ),
      body: Listener(
        onPointerDown: (event){
          setState(() {
            _event = event;
          });
        },
        onPointerCancel: (event){
          setState(() {
            _event = event;
          });
        },
        onPointerMove: (event){
          setState(() {
            _event = event;
          });
        },
        onPointerUp: (event){
          setState(() {
            _event = event;
          });
        },
        onPointerSignal: (event){

        },
        //deferToChild 从父级开始往下 逐级传递 child处理
        //opaque最终的效果相当于当前Widget的整个区域都是点击区域
        //translucent 从顶部组件往下传递 点击顶部 底部也会收到点击事件
        behavior: HitTestBehavior.translucent,
        child: Column(
          children: [
            Container(
              color: Colors.orange,
              width: 400,
              height: 100,
              alignment: Alignment.center,
              child: Text("event:${_event?.delta??""}",style: TextStyle(color: Colors.white),),
            ),
            Listener(
              //本来只有点击Box A才能响应事件，设置成opaque 点击整个ConstrainedBox区域都可以响应
              behavior: HitTestBehavior.opaque,
              child: ConstrainedBox(
                constraints: BoxConstraints.tightFor(width:400,height: 100),
                child: Center(
                 child: Text("Box A"),
                ),
              ),
              onPointerDown: (event){
                print("down A");
              },
            ),
            Stack(
              children: [
                Listener(
                  onPointerDown: (event){
                    print("down 0");
                  },
                  child: ConstrainedBox(
                    constraints: BoxConstraints.tightFor(width: 400,height: 100),
                    child: DecoratedBox(
                      decoration: BoxDecoration(color: Colors.red),
                    ),
                  ),
                ),
                Listener(
                  //点击文本内容外面的区域 才会往下传递
                  behavior: HitTestBehavior.translucent,
                  onPointerDown: (event){
                    print("down 1");
                  },
                  child: ConstrainedBox(
                    constraints: BoxConstraints.tightFor(width: 200,height: 50),
                    child: Align(
                      widthFactor: 1,
                      heightFactor: 1,
                      child: Container(
                        color: Colors.green,
                        child: Text("非文本区域"),
                      )
                    ),
                  ),
                ),
              ],
            ),
            Listener(
              onPointerDown: (event){
                print("AbsorbPointer 1");
              },
              //AbsorbPointer本身可以接收事件子组件不能接收，
              //IgnorePointer 本身和子组件都不会接收
              child: IgnorePointer(
                child: Listener(
                  onPointerDown: (event){
                    print("AbsorbPointer 2");
                  },
                  child: Container(
                    width: 400,
                    height: 100,
                    color: Colors.cyan,
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

}

///手势检测
///手势冲突只是手势级别的，而手势是对原始指针的语义化的识别，
///所以在遇到复杂的冲突场景时，都可以通过Listener直接识别原始指针事件来解决冲突
class GesturePage extends StatefulWidget{
  @override
  State<StatefulWidget> createState() => _GestureState();
}
class _GestureState extends State{
  TapGestureRecognizer _tapGestureRecognizer = TapGestureRecognizer();
  String _gesture = "";
  double _top = 0;
  double _left = 0;
  double _width = 200;
  double _height = 100;
  bool _toggleColor = false;
  @override
  void dispose() {
    _tapGestureRecognizer.dispose();
    super.dispose();
  }
  void updateGesture(String gesture){
    setState(() {
      _gesture = gesture;
    });
  }
  @override
  void reassemble() {
    super.reassemble();
    setState(() {
      _top = 0;
      _left = 0;

      _width = 200;
      _height = 100;
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("手势检测"),
      ),
      body: Stack(
        children: [
//          Container(
//            alignment: Alignment.center,
//            width: 200,
//            height: 100,
//            color: Colors.blue,
//            child: GestureDetector(
//              //单机和双击同时设置的时候会有200ms延时，因为要等待判断是不是双击
//              onTap: ()=>updateGesture("单机"),
//              onDoubleTap: ()=>updateGesture("双击"),
//              onLongPress: ()=>updateGesture("长按"),
//              child: Text(_gesture),
//            ),
//          ),
          Positioned(
            left: _left,
            top: _top,
            child: GestureDetector(
              child: CircleAvatar(child: Text("A"),),
              //屏幕按下的事件
              onPanDown: (DragDownDetails details){
                print("drag down:${details.globalPosition}");
              },
              //单一方向的更新
//              onVerticalDragUpdate: (DragUpdateDetails details){
//                setState(() {
//                  _top += details.delta.dy;
//                });
//              },
              //移动的时候会更新
              onPanUpdate: (DragUpdateDetails details){
                setState(() {
                  //水平和垂直的移动距离
                  _left += details.delta.dx;
                  _top += details.delta.dy;
                });
              },
              onPanEnd: (DragEndDetails details){
                //结束时在想x y上的速度
                print("drag end:${details.velocity}");
              },
            ),

          ),
//          Center(
//            child: GestureDetector(
//              child: Image.asset("assets/flash_four.jpg",width: _width,height: _height,),
//              onScaleUpdate: (ScaleUpdateDetails details){
//                setState(() {
//                  _width = 200 * details.verticalScale.clamp(0.8, 10);
//                  _height = 100 * details.horizontalScale.clamp(0.8, 10);
//                });
//              },
//            ),
//          ),
          Center(
            child: Text.rich(TextSpan(
                children: [
                  TextSpan(text: "hello  "),
                  TextSpan(
                    text: "www.baidu.com",
                    style: TextStyle(fontSize:32,color: _toggleColor ? Colors.blue: Colors.red),
                    recognizer: _tapGestureRecognizer..onTap = (){
                      setState(() {
                        _toggleColor = !_toggleColor;
                      });
                    },
                  )
                ]
            )),
          ),
        ],
      ),
    );
  }

}

///事件总线测试
class EventBusA extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    return _EventBusAState();
  }
}
class _EventBusAState extends State{
  @override
  void initState() {
    super.initState();
    bus.on("event",(arg){
      print("处理订阅事件:$arg");
    });
  }
  @override
  void dispose() {
    super.dispose();
    bus.off("event");
  }
  @override
  Widget build(BuildContext context) {
    return Center(
      child: RaisedButton(
        onPressed:(){
          Navigator.of(context).push(MaterialPageRoute(builder: (context){
            return EventBusB();
          }));
        } ,
        child:Text("订阅事件"),
      ),
    );
  }

}
class EventBusB extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return Center(
      child: RaisedButton(
        onPressed: (){
          bus.emit("event","测试");
          Navigator.of(context).pop();
        },
        child: Text("发送事件"),
      ),
    );
  }

}

//组件的事件通知
class NotificationPage extends StatefulWidget{
  @override
  State<StatefulWidget> createState() => _NotificationState();
}
class _NotificationState extends State{
  String _msg = "";
  bool customFlag = true;
  @override
  void reassemble() {
    super.reassemble();
    customFlag = true;
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("notification"),
      ),
      body: customFlag ? NotificationListener<MyNotification>(
          onNotification: (notifciation){
            setState(() {
              _msg += notifciation.msg;
            });
            //返回true停止向上传递 false继续向上传递
            return true;
          },
          child: Center(
            child: Column(
              children: [
                //不能发送notification
                //因为这个context是根Context，而NotificationListener是监听的子树，
                // 所以我们通过Builder来构建RaisedButton，来获得按钮位置的context
                RaisedButton(
                  onPressed: (){
                    MyNotification(" hello ").dispatch(context);
                  },
                  child: Text("send notification"),
                ),
                Builder(
                  builder: (context){
                    return RaisedButton(
                      onPressed: (){
                        MyNotification(" hello ").dispatch(context);
                      },
                      child: Text("send notification"),
                    );
                  },
                ),
                Text("mag:$_msg"),
              ],
            ),
          ),
        )
      :Center(
        child: NotificationListener(
          onNotification: (notification){
            switch(notification.runtimeType){
              case ScrollStartNotification:
                print("Scroll Start");
                break;
              case ScrollEndNotification:
                print("Scroll end");
                break;
              case ScrollUpdateNotification:
                print("Scroll update");
                break;
              case OverscrollNotification:
                //边界
                print("Scroll over");
                break;
            }
            return true;
          },
            //可滚动的组件才会往上发通知
          child: ListView.builder(
            itemExtent: 50,
            itemCount: 50,
            itemBuilder: (context,index){
              return Text("item $index");
            }
          )
        ),
      ),
    );
  }
}

class MyNotification extends Notification{
  MyNotification(this.msg);
  final String msg;
}