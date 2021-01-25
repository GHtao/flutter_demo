//import 'dart:html';

///Dart中实现单例模式的标准做法就是使用static变量+工厂构造函数的方式
///事件总线  跨页面通知
class EventBus{
  //私有构造函数
  EventBus._internal();
  //保存单例
  static EventBus _singleton = EventBus._internal();
  //工厂构造函数
  factory EventBus()=> _singleton;

  var _emap = Map<Object,List<EventCallback>>();
  //添加订阅事件
  void on(eventName,EventCallback f){
    if(eventName == null || f == null) return;
    _emap[eventName] ??= List<EventCallback>();
    if(_emap[eventName].contains(f)) return;
    _emap[eventName].add(f);
  }
  //移除事件监听
  void off(eventName,[EventCallback f]){
    var list = _emap[eventName];
    if(eventName == null || list == null) return;
    if(f == null){
      _emap[eventName] = null;
    }else{
      list.remove(f);
    }
  }
  //发送事件
  void emit(eventName,[arg]){
    var list = _emap[eventName];
    if(list == null) return;
    //调用所有订阅事件
    for(var i=list.length-1;i>-1;i--){
      list[i](arg);
    }
  }
}
//定义全局变量 页面引入这个文件就可以使用了
var bus = EventBus();
//回调函数
typedef void EventCallback(arg);