

//import 'dart:html';

import 'package:english_words/english_words.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;
void main(){
  runApp(WidgetTestApp());
}

class WidgetTestApp extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "widget test",
      theme: ThemeData(
        primarySwatch: Colors.amber,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: ScrollControllerPage(),
    );
  }
}
///计数器页面
class CountPage extends StatefulWidget{
  CountPage({Key key, @required this.initValue}):super(key:key);
  final int initValue;
  @override
  State<StatefulWidget> createState() {
    return _CountPageState();
  }
}
class _CountPageState extends State<CountPage>{
  int _count;
  ///当Widget第一次插入到Widget树时会被调用 只会被调用一次
  @override
  void initState() {
    //@mustCallSuper有这个注解的父类方法 在重写时必须先调用
    super.initState();
    _count = widget.initValue;
    print("state init");
  }

  void _changeCount(){
    setState(() {
      ++_count;
    });
  }
  /// 在调用initState()之后。
  /// 在调用didUpdateWidget()之后。
  /// 在调用setState()之后。
  /// 在调用didChangeDependencies()之后。
  /// 在State对象从树中一个位置移除后（会调用deactivate）又重新插入到树的其它位置之后
  @override
  Widget build(BuildContext context) {
    print("state build");
    return Scaffold(
      appBar: AppBar(
        title: Text("计数器"),
      ),
      body: Center(
        child: Column(
          children: [
            Text("数值:$_count"),
            RaisedButton(
              onPressed: (){
                Navigator.of(context).push(MaterialPageRoute(builder:(context){
                  return ParentPage();
                }));
                _changeCount();
              },
              child: Text("数值加"),
            )
          ],
        ),
      ),
    );
  }
  ///在widget重新构建时
  @override
  void didUpdateWidget(CountPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    print("state didUpdateWidget");
  }
  ///当State对象从树中被移除时，会调用此回调
  ///如果移除后没有重新插入到树中则紧接着会调用dispose()方法
  @override
  void deactivate() {
    super.deactivate();
    print("state deactivate");
  }

  @override
  void dispose() {
    super.dispose();
    print("state dispose");
  }
  ///此回调是专门为了开发调试而提供的，在热重载(hot reload)时会被调用，
  ///此回调在Release模式下永远不会被调用
  @override
  void reassemble() {
    super.reassemble();
    print("state reassemble");
  }

  ///当State对象的依赖发生变化时会被调用
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    print("state didChangeDependencies");
  }
}

///widget管理自己的状态
class TapBoxAPage extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    return _TapBoxAState();
  }
}
class _TapBoxAState extends State<TapBoxAPage>{
  bool _active = false;

  /// 处理触摸事件
  void _handleTap(){
    setState(() {
      _active = !_active;
    });
  }
  @override
  Widget build(BuildContext context) {
    //onTouch
    return GestureDetector(
      onTap: _handleTap,
      child: Container(
        width: 200,
        height: 200,
        decoration: BoxDecoration(
          color: _active ? Colors.lightGreen[700]:Colors.grey[600]
        ),
        child: Center(
          child: Text(
            _active ? "Active":"Inactive",
            style: TextStyle(fontSize: 32.0,color: Colors.white),
          ),
        ),
      ),
    );
  }

}

///父widget管理子widget的状态
///子widget是无状态的 通过回调函数来改变状态
class ParentPage extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    return _ParentPageState();
  }
}
class _ParentPageState extends State{
  bool _active = false;

  void _handleTap(bool newValue){
    setState(() {
      _active = newValue;
    });
  }
  @override
  Widget build(BuildContext context) {
    return Container(
      ///状态改变会从新调用这个build 会更新 _active
      child: TapBoxBPage(
        active: _active,
        onChange: _handleTap,
      ),
    );
  }

}
class TapBoxBPage extends StatelessWidget{
  TapBoxBPage({Key key,this.active:false, @required this.onChange})
      :super(key:key);
  final bool active;
  final ValueChanged<bool> onChange;
  void _handleTap(){
    onChange(!active);
  }
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      child: Container(
        width: 200,
        height: 200,
        decoration: BoxDecoration(
          color: active? Colors.red[800]:Colors.cyan[600]
        ),
        child: Center(
          child: Text(
            active ? "Active":"Inactive",
            style: TextStyle(fontSize: 32,color: Colors.white),
          ),
        ),
      ),
    );
  }
}


///父widget和子widget共同管理状态
///子widget能内部处理的就不需要暴露给父widget
class CommonPage extends StatefulWidget{
  @override
  State<StatefulWidget> createState() => _CommonPageState();
}
class _CommonPageState extends State{
  bool _active = false;

  void _handleActiveChange(bool newValue){
    setState(() {
      _active = newValue;
    });
  }
  @override
  Widget build(BuildContext context) {
    return Container(
      child: TapPageC(
          active:_active,
          onChange: _handleActiveChange
      ),
    );
  }
}

class TapPageC extends StatefulWidget{
  TapPageC({Key key,this.active:false,@required this.onChange}):super(key:key);
  final bool active;
  final ValueChanged<bool> onChange;
  @override
  State<StatefulWidget> createState() => _TapPageCState();
}
class _TapPageCState extends State<TapPageC>{
  bool _highLight = false;
  void _handleTapDown(TapDownDetails details){
    setState(() {
      _highLight = true;
    });
  }

  void _handleTapUp(TapUpDetails details){
    setState(() {
      _highLight = false;
    });
  }

  void _handleTapCancel(){
    setState(() {
      _highLight = false;
    });
  }

  void _handleOnChange(){
    //在这里使用widget能获取到onChange等属性
    widget.onChange(!widget.active);
  }
  @override
  Widget build(BuildContext context) {

    return GestureDetector(
      onTap: _handleOnChange,
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      child: Container(
        child:Center(
            child: Text(
              widget.active ? "Active":"Inactive",
              style: TextStyle(fontSize: 32,color: Colors.white),
            )
        ),
        width: 200,
        height: 200,
        decoration: BoxDecoration(
          color: widget.active? Colors.blueAccent:Colors.amber,
          border: _highLight? Border.all(
            color: Colors.brown,
            width: 10
          ):null
        ),
      ),
    );
  }

}

///文本 字体样式
class TextPage extends StatefulWidget{
  @override
  State<StatefulWidget> createState() => _TextPageState();
}
class _TextPageState extends State{

  void _handleClick(){
    print("点击 链接");
  }
  @override
  Widget build(BuildContext context) {
    return Center(
      child:Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "hello world "*3,
            textAlign: TextAlign.center,//相对于控件的位置
            maxLines: 4,
            textScaleFactor: 1,//当前文字大小的缩放
            style: TextStyle(
                fontSize: 24,
                color: Colors.brown,
                height: 1.2,//该属性用于指定行高，但它并不是一个绝对值，而是一个因子，具体的行高等于fontSize*height
                fontFamily: "Courier",//字体
                background: Paint()..color = Colors.yellow,
                decoration: TextDecoration.underline,//下划线
                decorationStyle: TextDecorationStyle.wavy
            )
          ),
          //Text.rich可以将TextSpan添加到Text中
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: "github: ",
                  style: TextStyle(
                    decoration: TextDecoration.none,
                    fontSize: 24,
                  )
                ),
                TextSpan(
                  text: "http://flutterchina.club",
                  recognizer: TapGestureRecognizer(//点击事件
                  ),
                  style: TextStyle(
                    inherit: false,//不继承默认的
                    color: Colors.blue,
                    fontSize: 24,
                    decoration: TextDecoration.underline,
                    decorationStyle: TextDecorationStyle.solid,
                    decorationColor: Colors.blue,
                  ),
                )
              ]
            ),
            maxLines: 2,
          ),
        ],
      ),
    );
  }

}
///button控件
class ButtonPage extends StatefulWidget{
  @override
  State<StatefulWidget> createState() => _ButtonPageState();
}
class _ButtonPageState extends State{
  void _handleClick(){
    print("button click");
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            //漂浮按钮，它默认带有阴影和灰色背景。按下后，阴影会变大
            RaisedButton(
              onPressed: _handleClick,
              child: Text("raised button"),
            ),
            //扁平按钮，默认背景透明并不带阴影。按下后，会有背景色
            FlatButton(
              onPressed: _handleClick,
              child: Text("flat button"),
            ),
            //默认有一个边框，不带阴影且背景透明。按下后，边框颜色会变亮、同时出现背景和阴影(较弱)
            OutlineButton(
              onPressed: _handleClick,
              child: Text("outline button"),
            ),
            //不包括文字，默认没有背景，点击后会出现背景
            IconButton(
              onPressed: _handleClick,
              icon: Icon(Icons.message),
            ),
            //默认使用带图标的的构造函数
            RaisedButton.icon(//默认有配置阴影
              color: Colors.blue,//Color(0x000000)背景色透明
              disabledColor: Colors.grey,
              highlightColor: Colors.red,
              splashColor: Colors.yellow,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0),

              ),
              //  this.color, //按钮背景颜色
              //  this.disabledColor,//按钮禁用时的背景颜色
              //  this.highlightColor, //按钮按下时的背景颜色
              //  this.splashColor, //点击时，水波动画中水波的颜色
              //  this.colorBrightness,//按钮主题，默认是浅色主题
              //  this.padding, //按钮的填充
              //  this.shape, //外形
              onPressed: _handleClick,
              icon: Icon(Icons.send),
              label: Text(
                "带图标的button",
                style: TextStyle(
                  color: Colors.white
                ),
              )
            )
          ],
        ),
      ),
    );
  }

}

///图片控件
class ImagePage extends StatefulWidget{
  @override
  State<StatefulWidget> createState()=> _ImagePageState();
}
class _ImagePageState extends State{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          children: [
            //加载本地图片
            Image.asset(
              "assets/flash_four.jpg",
              //当不指定宽高时，图片会根据当前父容器的限制，尽可能的显示其原始大小，
              // 如果只设置width、height的其中一个，那么另一个属性默认会按比例缩放，
              // 可以通过fit属性来指定适应规则
              width: 500,
              height: 500,
              //在图片绘制时可以对每一个像素进行颜色混合处理，color指定混合色，
              // 而colorBlendMode指定混合模式
//              color: Colors.grey,
//              colorBlendMode: BlendMode.clear,
              fit: BoxFit.contain,
              alignment: Alignment.center,
              //当图片本身大小小于显示空间时，指定图片的重复规则
              repeat: ImageRepeat.repeatY,
            ),
            //加载网络图片
//            Image.network("")
          ],
        ),
      ),
    );
  }

}

///单选框和复选框
class CheckBoxPage extends StatefulWidget{
  @override
  State<StatefulWidget> createState()=>_CheckBoxPageState();
}
class _CheckBoxPageState extends State{
  bool _checkBoxValue = true;
  bool _switchValue = true;
  void switchChange(bool value){
    print("switch:$value");
    setState(() {
      _switchValue = value;
    });
  }
  void onChange(bool value){
    print("value:$value");
    setState(() {
      _checkBoxValue = value;
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(

          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Checkbox(
              activeColor: Colors.blue,//选中时的颜色
              value: _checkBoxValue,
              onChanged: onChange,
            ),
            Switch(
              activeColor: Colors.red,
              value: _switchValue,
              onChanged: switchChange,
            )
          ],
        ),
      ),
    );
  }

}

///输入框
class TextFieldPage extends StatefulWidget{
  @override
  State<StatefulWidget> createState() => _TextFieldState();

}
class _TextFieldState extends State{
  TextEditingController userController = TextEditingController();
  FocusNode nameFocusNode = FocusNode();
  FocusNode passwordFocusNode = FocusNode();
  GlobalKey _formKey = GlobalKey<FormState>();
  void _nameOnChange(String name){
    print("name:$name");
  }

  void _passwordChange(String password){
    print("password:$password");
  }
  @override
  void initState() {
    super.initState();
    nameFocusNode.addListener(() {
      print(nameFocusNode.hasFocus);
    });
  }
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("login"),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(vertical:16.0,horizontal:24.0),
        child: Column(
          children: [
            TextField(
              focusNode: nameFocusNode,
              onChanged: _nameOnChange,
              autofocus: true,
              //控制输入的显示样式
              decoration: InputDecoration(
                //不显示下划线 通过控件组合来自定义下划线
                border: InputBorder.none,
                prefixIcon: Icon(Icons.account_box),
                labelText: "用户名",
                hintText: "请输入用户名",
                //为获取焦点下划线颜色
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue)
                ),
                //获取焦点时下划线颜色
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.red)
                )
              ),
              //输入内容的密码 邮箱...
              keyboardType: TextInputType.name,
              //键盘的动作 完成 搜索 前进等
              textInputAction: TextInputAction.done,
              controller: userController,
            ),
            TextField(
              autofocus: true,
              onChanged: _passwordChange,
              focusNode: passwordFocusNode,
              //控制输入的显示样式
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.lock),
                labelText: "密码",
                hintText: "请输入密码",
              ),
              //输入内容的密码 邮箱...
              keyboardType: TextInputType.visiblePassword,
              //键盘的动作 完成 搜索 前进等
              textInputAction: TextInputAction.done,
              obscureText: true,
            ),
            RaisedButton(
              onPressed: (){
                //获取数值
                print("value:${userController.text}");
                if(nameFocusNode.hasFocus){
                  FocusScope.of(context).requestFocus(passwordFocusNode);
                }else{
                  FocusScope.of(context).requestFocus(nameFocusNode);
                }
              },
              child: Text("焦点移动"),
            ),
            RaisedButton(
              onPressed: (){
                //焦点都取消时 键盘就隐藏了
                nameFocusNode.unfocus();
                passwordFocusNode.unfocus();
              },
              child: Text("取消键盘"),
            ),

            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.people),
                      hintText: "name",
                    ),
                    validator: (v){
                      return v.trim().length != 0? null:"name not null";
                    },
                  ),
                  TextFormField(
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.lock),
                      hintText: "password",
                    ),
                    validator: (v){
                      return v.trim().length != 0? null:"password not null";
                    },
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 28),
                    child: Row(
                      children: [
                        Expanded(
                          child: RaisedButton(
                            color: Colors.blue,
                            textColor: Colors.white,
                            padding: EdgeInsets.all(15),
                            onPressed: (){
                              //在这里不能通过此方式获取FormState，context不对
                              //print(Form.of(context));
                              if((_formKey.currentState as FormState).validate()){
                                //验证通过
                                print("验证通过");
                              }
                            },
                            child: Text("验证",),
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

}

///进度条指示器
class ProgressBarPage extends StatefulWidget{
  @override
  State<StatefulWidget> createState() => _ProgressBarState();

}
class _ProgressBarState extends State{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("进度条"),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            height: 10,
            child:LinearProgressIndicator(
              backgroundColor: Colors.grey,
              //不设置value值的时候 是一个滑动的进度条
              value: 0.1,
              //不需要进度条颜色变化
              valueColor: AlwaysStoppedAnimation(Colors.blue),
            )
          ),
          SizedBox(
            //宽高如果不相等 就是椭圆
           height: 100,
           width: 100,
           child: CircularProgressIndicator(
             backgroundColor: Colors.grey,
             value: 0.4,
             valueColor: AlwaysStoppedAnimation(Colors.yellow),
           ),
          ),
        ],
      ),
    );
  }
}

///线性布局  超出屏幕空间会报错
class LineLayoutPage extends StatefulWidget{
  @override
  State<StatefulWidget> createState() => _LineLayoutState();
}
class _LineLayoutState extends State{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "线性布局",
          style: TextStyle(
            color: Colors.white,
          ),
        ),
      ),
      body: Column(
        //默认居中
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            //主轴的大小 min是子控价宽度和 max就是全屏 高度就是子控件中最高的那个
            mainAxisSize: MainAxisSize.max,
            //主轴对齐方式 row是横向 Column纵向向
            mainAxisAlignment: MainAxisAlignment.start,
            //row是垂直方向  Column是水平方向
            crossAxisAlignment: CrossAxisAlignment.start,
            //布局的方向 从左到右还是从右到左
            // 会影响mainAxisAlignment的对齐方式
            textDirection: TextDirection.ltr,
            //会影响垂直方向的对齐方式 down就是从上往下 up就是从下往上
            verticalDirection: VerticalDirection.up,
            children: [
              Text(
                "---flutter row---"*100,
                style: TextStyle(
                  fontSize: 32,
                ),
              ),
              Text("test fw"),
            ],
          ),
          //布局嵌套 只有最外层的才会占最大空间 ，里面的布局都是实际的大小
          Expanded(//可以让子控件占满屏幕
            child:  Container(
              color: Colors.red,
              child:  Column(
                //默认max min就是两个控件高度和，宽度就是最宽的子控件宽度
                mainAxisSize: MainAxisSize.max,
                //子控件从下往上还是从上往下
                verticalDirection: VerticalDirection.down,
                //文本内容的对齐方式
                textDirection: TextDirection.ltr,
                crossAxisAlignment: CrossAxisAlignment.start,
                //垂直方向的对齐方式
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                      "---flutter column---"
                  ),
                  Text(
                      "test aaa"
                  ),
                ],
              ),
            ),
          ),
        ],
      ),

    );
  }

}

///弹性布局 权重
class FlexLayoutPage extends StatefulWidget{
  @override
  State<StatefulWidget> createState() => _FlexLayoutState();
}
class _FlexLayoutState extends State{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "弹性布局,权重",
          style: TextStyle(
            color: Colors.white
          ),
        ),
      ),
      //row column 都是继承flex
      body: Flex(
        direction: Axis.horizontal,
        mainAxisAlignment: MainAxisAlignment.center,
        textDirection: TextDirection.ltr,
        children: [
          Expanded(
            flex: 2,
            child: Container(
              color: Colors.yellow,
              child: Text(
                "yellow 2"*20,
                textAlign: TextAlign.center,
              ),
            ),
          ),
          //占用指定比例的空间 是expanded的包装类
          Spacer(
            flex: 1,
          ),
          Expanded(
            flex: 1,
            child: Container(
              color: Colors.blue,
              child: Text(
                "blue 1",
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }

}

///流布局 在row等超出之后使用这个会自动换行
class WrapLayoutPage extends StatefulWidget{
  @override
  State<StatefulWidget> createState() => _WrapLayoutState();

}
class _WrapLayoutState extends State{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "流式布局",
          style: TextStyle(
            color: Colors.white,
          ),
        ),
      ),
      body: Container(
        color: Colors.cyan,
        width: double.infinity,
        child:  Wrap(
          direction: Axis.horizontal,
          //主轴控件间距
          spacing: 10,
          //纵轴间距
          runSpacing: 20,
          //纵轴对齐方式
          runAlignment: WrapAlignment.center,
          //主轴对齐方式
          alignment: WrapAlignment.center,
          children: [
            Chip(
              avatar: CircleAvatar(
                backgroundColor: Colors.blue,
                child: Text("A"),
              ),
              label: Text("aaaaa"),
            ),
            Chip(
              avatar: CircleAvatar(
                backgroundColor: Colors.yellow,
                child: Text("B"),
              ),
              label: Text("bbbbb"),
            ),
            Chip(
              avatar: CircleAvatar(
                backgroundColor: Colors.grey,
                child: Text("C"),
              ),
              label: Text("ccccc"),
            ),
            Chip(
              avatar: CircleAvatar(
                backgroundColor: Colors.red,
                child: Text("D"),
              ),
              label: Text("ddddd"),
            ),
            Chip(
              avatar: CircleAvatar(
                backgroundColor: Colors.brown,
                child: Text("E"),
              ),
              label: Text("eeee"),
            ),
          ],
        ),
      )

    );
  }

}

///层叠布局 相当于FrameLayout
class StackLayoutPage extends StatefulWidget{
  @override
  State<StatefulWidget> createState() =>_StackLayoutState();
}
class _StackLayoutState extends State{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "层叠布局",
          style: TextStyle(
            color: Colors.white
          ),
        ),
      ),
      body: Container(
        color: Colors.blue,
        width: double.infinity,
        height: double.infinity,
        child: Stack(
          //指定未定位或部分定位widget的对齐方式
          alignment: AlignmentDirectional.center,
          //未定位widget占满Stack整个空间
          fit: StackFit.expand,
          //对齐方式的参考
          textDirection: TextDirection.rtl,
          //clip超出Stack显示空间的子组件会被裁剪
          //visible超出部分显示
          overflow: Overflow.clip,
          children: [
            Positioned(
              //指定了左右，所以未指定上下位置居中
              left: 30,
              child: Text(
                "child two"
              ),
            ),
            Container(
              color: Colors.red,
              child: Text(
                "child one",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 32,
                ),
              ),
            ),
            Positioned(
              //不能同时指定top、bottom和height因为三个想关联 左右和宽度同理
              //指定了上下，未指定左右位置居中
              bottom: 100,
              height: 200,
//              top: 100,
              child: Container(
                color: Colors.cyan,
                alignment: AlignmentDirectional.center,
                child: Text(
                  "child three",
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

///可以指定控件的位置 center也是一个Align
class AlignLayoutPage extends StatefulWidget{
  @override
  State<StatefulWidget> createState() => _AlignLayoutState();
}
class _AlignLayoutState extends State{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "对齐，相对定位",
          style: TextStyle(
            color: Colors.white
          ),
        ),
      ),
      body: Container(

        color: Colors.red,
        child: Align(
          //子控件大小的2倍
          widthFactor: 2,
          heightFactor: 2,
          //FractionalOffset相对于左上角为顶点坐标从左到右为（0，1）
          //AlignmentDirectional 控件中心为原点从左到右为（-1,1）
          alignment: FractionalOffset.topLeft,
          child: FlutterLogo(
            size: 60,
          ),
        ),
      ),
    );
  }

}

///限制子控件大小的容器
class SizeLimitPage extends StatefulWidget{
  @override
  State<StatefulWidget> createState() => SizeLimitState();

}
class SizeLimitState extends State{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "限制控件大小的容器",
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          //Appbar使用了指定的大小 所以需要使用
          UnconstrainedBox(//子类使用自己的大小
            child: CircularProgressIndicator(
              value: 0.5,
              backgroundColor: Colors.grey,
            ),
          ),
          UnconstrainedBox(
            child: FlatButton(
              onPressed: (){
                print("click more");
              },
              child: Icon(Icons.more_vert),
            ),
          )
        ],
      ),
      body: Wrap(
        direction: Axis.vertical,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          //可以对大小做限制  当有多重限制的时候 取多个限制里面最大的数
          ConstrainedBox(
            constraints: BoxConstraints(minWidth: 100,minHeight: 100,maxHeight: 200,maxWidth: 200),
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Container(
                //上面已经限制了大小 所以这边最大就是200
                width: 300,
                height: 300,
                color: Colors.red,
                alignment: AlignmentDirectional.center,
                child: Text(
                    "限制大小"
                ),
              ),
            ),
          ),
          //对ConstrainedBox的一个订制 指定大小
          SizedBox(
            width: 200,
            height: 200,
            child: Container(
              alignment: AlignmentDirectional.center,
              color: Colors.green,
              child: Text(
                "bbb"
              ),
            ),
          ),
          //子组件绘制前(或后)绘制一些装饰Decoration，如背景、边框、渐变等
          DecoratedBox(
            position: DecorationPosition.background,
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 10,horizontal: 10),
              child: Text(
                "login",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24
                ),
              ),
            ),
            decoration: BoxDecoration(
              //渐变色
              gradient: LinearGradient(colors: [Colors.red,Colors.orange]),
              //圆角
              borderRadius: BorderRadius.circular(3),
              boxShadow: [
                BoxShadow(
                  color: Colors.black45,
                  offset: Offset(2.0,2.0),
                  blurRadius: 4.0
                )
              ],
            ),
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.cyan,
            ),
            child: Column(
              children: [
                ///变换是应用在绘制阶段，而并不是应用在布局(layout)阶段，
                ///所以无论对子组件应用何种变化，其占用空间的大小和在屏幕上的位置都是固定不变的，
                ///因为这些是在布局阶段就确定的
                Transform.scale(
                  scale: 2,
                  child: Text("scale"),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 10),
                ),
                Transform.rotate(
                  angle: math.pi,
                  child: FlutterLogo(),
                ),
                Transform.translate(
                    offset: Offset(
                      10,10
                    ),
                  child: Text("translate"),
                ),
                //实际改变了位置
                RotatedBox(
                  quarterTurns: 1,//90度 1/4圈
                  child: Text("rotate box"),
                ),

              ],
            )
          ),
        ],
      ),
    );
  }

}

///可以滚动的容器
class ScrollPage extends StatefulWidget{
  @override
  State<StatefulWidget> createState() => _ScrollState();
}
class _ScrollState extends State{
  String str = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("滚动的view"),
      ),
      body: Container(
        child: Scrollbar(
          //将数据全部加载  性能差
          child: SingleChildScrollView(
            reverse: true,
            scrollDirection: Axis.vertical,
            padding: EdgeInsets.all(16),
            child: Column(
              children: str.split("").map((e) =>
                Text(e,textScaleFactor: 7,)
              ).toList(),
            ),
          ),
        ),
      ),
    );
  }

}
///ListView
class ListViewPage extends StatefulWidget{
  @override
  State<StatefulWidget> createState() => _ListViewState();
}
class _ListViewState extends State{
  static const loading = "##loading##";
  var _words = <String>[loading];
  @override
  void reassemble() {
    super.reassemble();
    _words = <String>[loading];
  }
  ///加载更多数据
  void addWords(){
    Future.delayed(Duration(seconds: 3))
        .then((value) => {
          setState(() {
            _words.insertAll(_words.length-1,
              generateWordPairs().take(20).map((e) => e.asPascalCase).toList());
          })
        }
    );
  }
  @override
  Widget build(BuildContext context) {
    Divider dividerRed = Divider(color: Colors.red,);
    Divider dividerBlue = Divider(color: Colors.blue,);
    Divider dividerGrey = Divider(color: Colors.grey,);
    return Scaffold(
      appBar: AppBar(
        title: Text("ListView"),
      ),
      body: Container(
        child: Column(
          children: [
            ListTile(title: Text("标题"),),
            //在列表上面有控件 Column需要知道列表的高度，所以使用Expanded来确定高度
            Expanded(
              child: ListView.separated(
                padding: EdgeInsets.all(20),
                //数量 不设置就是无限列表
                itemCount: _words.length,
                //item高度
//          itemExtent: 30,
                itemBuilder:(context,index){
                  if(_words[index] == loading){//到达结尾
                    if(_words.length -1 < 30){//加载更多
                      addWords();
                      return Container(
                        alignment: AlignmentDirectional.center,
                        padding: EdgeInsets.all(16),
                        child: SizedBox(
                          width: 50,
                          height: 50,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        ),
                      );
                    }else{//没有更多数据
                      return Container(
                        alignment: Alignment.center,
                        padding: EdgeInsets.all(16),
                        child: Text("没有更多数据了"),
                      );
                    }
                  }
                  return ListTile(title: Text(_words[index]),);
                },
                //分割线
                separatorBuilder: (context,index){
                  return dividerGrey;
                },
              ),
            ),
          ],

        ),

      ),
    );
  }

}

///GridView
class GridViewPage extends StatefulWidget{
  @override
  State<StatefulWidget> createState() => _GridViewState();
}
class _GridViewState extends State{
  List<IconData> icons;
  @override
  void reassemble() {
    super.reassemble();
    icons = [];
    loadIcon();
  }
  void loadIcon(){
    Future.delayed(Duration(seconds: 2))
        .then((value) => {
        setState(() {
          icons.addAll([
            Icons.ac_unit,
            Icons.airport_shuttle,
            Icons.all_inclusive,
            Icons.beach_access,
            Icons.cake,
            Icons.free_breakfast
          ]);
        })
    });
  }
  @override
  void initState() {
    super.initState();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Grid View"),
      ),
      body: Container(
        color: Colors.red,
        child: Column(
          children: [
            Expanded(
              child: GridView.count(
                crossAxisCount: 3,
                //子控件的宽高比
                childAspectRatio: 2,
                children: [
                  Icon(Icons.ac_unit),
                  Icon(Icons.airport_shuttle),
                  Icon(Icons.all_inclusive),
                  Icon(Icons.beach_access),
                  Icon(Icons.cake),
                  Icon(Icons.free_breakfast)
                ],
              ),
            ),
            Expanded(
              child: GridView.builder(
                itemCount: icons.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 1
                ),
                itemBuilder: (context,index){
                  if(icons.length - 1 == index && index < 50){
                    loadIcon();
                  }
                  return Icon(icons[index]);
                }),
            ),
          ],
        )

      ),
    );
  }

}

///滚动联动控件 可以将几个滚动控件组合
class CustomScrollViewPage extends StatefulWidget{
  @override
  State<StatefulWidget> createState() => _CustomScrollViewState();
}
class _CustomScrollViewState extends State{
  @override
  Widget build(BuildContext context) {
    //不使用Scaffold 还要使用material风格 就用Material
    return Material(
      //CustomScrollView的子组件必须都是Sliver
      child: CustomScrollView(
        slivers: [
          SliverAppBar(
            //控制滚动时是否显示标题
            pinned: true,
            //扩展头的高度
            expandedHeight: 200,
            //实现Material Design中头部伸缩
            leading: Icon(Icons.arrow_back),
            flexibleSpace: FlexibleSpaceBar(
              title: Text("Custom Scroll View"),
              background: Icon(Icons.add),
            ),
          ),
          SliverPadding(
            padding: EdgeInsets.all(8),
            sliver: SliverGrid(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 4
              ),
              delegate: SliverChildBuilderDelegate(
                  (BuildContext context, int index){
                    return Container(
                      alignment: Alignment.center,
                      color: Colors.orange[100 * (index % 9)],
                      child: Text("grid item$index"),
                    );
                  },
                childCount: 10,
              ),
            ),
          ),
          SliverFixedExtentList(
            itemExtent: 30,//每一项高度
            delegate: SliverChildBuilderDelegate(
                (context, index){
                  return Container(
                    alignment: Alignment.center,
                    color: Colors.blue[100 * (index % 9)],
                    child: Text("grid item$index"),
                  );
                }
            ),
          ),
        ],
      ),
    );
  }

}

class ScrollControllerPage extends StatefulWidget{
  @override
  State<StatefulWidget> createState() => _ScrollerControllerState();
}
class _ScrollerControllerState extends State{
  bool _showFloat = false;
  ScrollController _scrollController = ScrollController();
  String _progress = "0%";
  @override
  void reassemble() {
    super.reassemble();
    if(!_scrollController.hasListeners){
      _scrollController.addListener(() {
        if(_scrollController.offset > 1000 && !_showFloat){
          setState(() {
            _showFloat = true;
          });
        }else if(_scrollController.offset < 1000 && _showFloat){
          setState(() {
            _showFloat = false;
          });
        }
      });
    }
  }
  //而这个依赖指的就是子widget是否使用了父widget中InheritedWidget的数据
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

  }
  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("滚动控制"),
      ),
      body: Container(
        padding: EdgeInsets.all(15),
        alignment: Alignment.center,
        color: Colors.white,
        child: NotificationListener<ScrollNotification>(
          onNotification: (notification){
//            pixels：当前滚动位置。
//            maxScrollExtent：最大可滚动长度。
//            extentBefore：滑出ViewPort顶部的长度；此示例中相当于顶部滑出屏幕上方的列表长度。
//            extentInside：ViewPort内部长度；此示例中屏幕显示的列表部分的长度。
//            extentAfter：列表中未滑入ViewPort部分的长度；此示例中列表底部未显示到屏幕范围部分的长度。
//            atEdge：是否滑到了可滚动组件的边界（此示例中相当于列表顶或底部）
            double progress = notification.metrics.pixels /
                notification.metrics.maxScrollExtent;
            setState(() {
              _progress = "${(progress*100).toInt()}%";
            });
            //false继续传递 true停止传递
            return true;
          },
          child:  ListView.builder(
              controller: _scrollController,
              itemCount: 50,
              itemExtent: 50,
              itemBuilder: (context, index){
                return Container(
                  alignment: Alignment.center,
                  child: Text("item $index") ,
                );
              }
          ),
        ),

      ),
      floatingActionButton: !_showFloat ? null: FloatingActionButton(
        onPressed: (){
          _scrollController.animateTo(0, duration: Duration(seconds: 3),
              curve: Curves.fastLinearToSlowEaseIn);
        },
        child: Text(_progress),
      ),
    );
  }

}