
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

void main(){
  runApp(AnimationApp());
}

class AnimationApp extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "animation",
      theme: ThemeData(
        primaryColor: Colors.cyan,
        visualDensity: VisualDensity.adaptivePlatformDensity
      ),
      home: StaggerPage(),
    );
  }
}

class AnimationPage extends StatefulWidget{
  @override
  State<StatefulWidget> createState() => _AnimationState();
}
class _AnimationState extends State<AnimationPage> with SingleTickerProviderStateMixin{
  Animation<double> _animation;
  AnimationController _controller;

  @override
  void dispose() {
    super.dispose();
    //路由销毁的时候 需要dispose
    _controller?.dispose();
  }
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(seconds: 3),
      vsync: this,
    );
    _animation = Tween(begin: 100.0,end: 400.0)
        .animate(_controller);
    //用AnimatedWidget封装 来代替下面的操作
//    _animation.addListener(() {
//      setState(() {});
//    });
    _animation.addStatusListener((status) {
      switch(status){
        case AnimationStatus.forward://动画正在正向执行
          break;
        case AnimationStatus.completed://动画在终点停止
              _controller.reverse();
          break;
        case AnimationStatus.dismissed://动画在起始点停止
              _controller.forward();
          break;
        case AnimationStatus.reverse://动画正在反向执行
          break;
      }
    });
    _controller.forward();
  }

  @override
  void reassemble() {
    super.reassemble();
    _animation = Tween(begin: 100.0,end: 400.0).animate(_controller);
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("animation"),
      ),
      body: AnimationCommon(
          animation:_animation,
          child:Image.asset("assets/flash_four.jpg")),
      //
//      AnimationImage(animation:_animation),
    //用AnimationImage 来封装
//        Center(
//          child: Image.asset("assets/flash_four.jpg",
//            width: animation.value,
//            height: animation.value,),
//        ),
    );
  }
}

class AnimationImage extends AnimatedWidget{
  AnimationImage({Key key,Animation<double> animation})
      :super(key:key,listenable:animation);

  @override
  Widget build(BuildContext context) {
    final Animation<double> animation = listenable;
    return Center(
      child: Image.asset("assets/flash_four.jpg",
        width: animation.value,
        height: animation.value,),
    );
  }
}
///动画的常用封装
///好处：不用显式的去添加帧监听器，然后再调用setState() 了，这个好处和AnimatedWidget是一样的。
///动画构建的范围缩小了，如果没有builder，setState()将会在父组件上下文中调用，
///这将会导致父组件的build方法重新调用；
///而有了builder之后，只会导致动画widget自身的build重新调用，避免不必要的rebuild。
class AnimationCommon extends StatelessWidget{
  AnimationCommon({this.animation,this.child});
  final Animation animation;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AnimatedBuilder(
        child: child,
        animation: animation,
        builder: (context,child){
          return Container(
            //可以定义动画的类型
            width: animation.value,
            height: animation.value,
            child: child,
          );
        },
      ),
    ) ;
  }

}

///两个route切换时候 点击一个图片的动画效果
class HeroPage extends StatefulWidget{
  @override
  State<StatefulWidget> createState() => _HeroState();
}
class _HeroState extends State<HeroPage>{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("hero animation"),
      ),
      body: Center(
        child: Container(
          child: InkWell(
            onTap: (){
              //页面动画 左右切换
//              Navigator.of(context).push(CupertinoPageRoute(builder: (context)=>HeroPageB()));
              //Hero切换时候的动画
              Navigator.of(context).push(
                  PageRouteBuilder(
                    pageBuilder: (BuildContext context,
                        Animation<double> animation,
                        Animation<double> secondaryAnimation){
                      return FadeTransition(opacity: animation,
                        child: HeroPageB(),
                      );
                    },
                  )
              );
            },
            child: Hero(
              tag: "hero_tag",
              child: ClipOval(
                child: Image.asset("assets/flash_four.jpg",width: 50,height: 50,),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class HeroPageB extends StatefulWidget{
  @override
  State<StatefulWidget> createState() => _HeroStateB();
}

class _HeroStateB extends State{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("原图"),
      ),
      body: Center(
        child: Hero(
          //Hero 控件的两个tag必须一致
          tag: "hero_tag",
          child: Image.asset("assets/flash_four.jpg"),
        ),
      ),
    );
  }

}
///组合动画
class StaggerPage extends StatefulWidget{

  @override
  State<StatefulWidget> createState() => _StaggerState();
}
class _StaggerState extends State with TickerProviderStateMixin{
  AnimationController _controller;

  @override
  void reassemble() {
    super.reassemble();
    if(_controller == null){
      _controller = AnimationController(duration: Duration(seconds: 3),vsync: this);
    }
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: Duration(seconds: 3),vsync: this);
  }


  Future<Null> _playAnimation() async{
      try{
        //先正向执行
        await _controller.forward().orCancel;
        //反向执行
        await _controller.reverse().orCancel;
      } on TickerCanceled{
        //动画取消
      }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Stagger组合动画"),
      ),
      body: GestureDetector(
        onTap: (){
          _playAnimation();
        },
        child: Center(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.1),
              border: Border.all(
                color: Colors.black.withOpacity(0.5)
              ),
            ),
            width: 400,
            height: 400,
            child: StaggerAnimation(controller: _controller,),
          ),
        ),
      ),
    );
  }
}
//创建一个组合动画
class StaggerAnimation extends StatelessWidget{
  StaggerAnimation({Key key,this.controller}):super(key:key){
    height = Tween<double>(begin: 0,end: 300).animate(
        CurvedAnimation(
          parent: controller,
          curve: Interval(0.0,0.6,curve: Curves.ease))
    );

    color = ColorTween(begin: Colors.green,end: Colors.red)
        .animate(CurvedAnimation(
      parent: controller,
      curve: Interval(0,0.6,curve: Curves.ease)
    ));

    padding = Tween<EdgeInsets>(begin: EdgeInsets.only(left: 0),
        end: EdgeInsets.only(left:100))
        .animate(CurvedAnimation(
      parent: controller,
      //动画的间隔（Interval）必须介于0.0和1.0之间
      curve: Interval(0.6,1.0,curve: Curves.ease),
    ));
  }
  final AnimationController controller;
  Animation<double> height;
  Animation<EdgeInsets> padding;
  Animation<Color> color;

  Widget _buildAnimation(BuildContext context,Widget child){
    return Container(
      alignment: Alignment.bottomCenter,
      padding: padding.value,
      child: Container(
        width: 50,
        height: height.value,
        color: color.value,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      builder: _buildAnimation,
      animation: controller,
    );
  }

}