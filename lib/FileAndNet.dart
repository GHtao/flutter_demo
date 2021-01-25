



import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import 'models/User.dart';

void main(){
  runApp(FileAndNetApp());
}

class FileAndNetApp extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "file and net",
      theme: ThemeData(
        primaryColor: Colors.cyan
      ),
      home: NetPage(),
    );
  }
}
///文件操作
class FilePage extends StatefulWidget{
  @override
  State<StatefulWidget> createState() => _FileState();
}
class _FileState extends State{
  int _counter = 0;
  @override
  void reassemble() {
    super.reassemble();
//    _readCounter().then((value){
//      setState(() {
//        _counter = value.toInt() +100;
//      });
//    });

  }
  ///读取文件内容
  Future<int> _readCounter() async{
    try{
      File file = await _getLocalFile();
      String count = await file.readAsString();
      return int.parse(count);
    } on FileSystemException{
      return 0;
    }
  }
  ///将数据写入文件
  Future<Null> _increaseCounter() async{
    setState(() {
      _counter++;
    });
    File file = await _getLocalFile();
    await file.writeAsString("$_counter");
  }
  ///获取文件路径
  Future<File> _getLocalFile() async{
      String dir = (await getExternalStorageDirectory()).path;
      return File("$dir/counter.txt");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("file"),
      ),
      body: Container(
        alignment: Alignment.center,
        color: Colors.blue,
        child: Column(
          children: [
            Text("$_counter"),
            RaisedButton(
              onPressed: _increaseCounter,
              child: Text("增加"),
            )
          ],
        ),
      ),
    );
  }

}
///网络操作
class NetPage extends StatefulWidget{
  @override
  State<StatefulWidget> createState() => _NetState();
}
class _NetState extends State{
  Dio _dio = Dio();
  @override
  void reassemble() {
    super.reassemble();
    _dio.options.connectTimeout = 5000;//5s
    _dio.options.receiveTimeout = 10000;
    _dio.options.sendTimeout = 10000;

    User user = User();
    user.name = "gt";
    user.age = "30";
    Map<String,dynamic> userJson = user.toJson();
    print("aaa:${userJson.toString()}");


  }
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text("Net"),
      ),
      body: Container(
        alignment: Alignment.center,
        child: FutureBuilder(
          //get 请求
          future: _dio.get("http://www.baidu.com"),
          builder: (context,snapshot){
            if(snapshot.connectionState == ConnectionState.done){
              Response response = snapshot.data;
              if(snapshot.hasError){
                return Text(snapshot.error.toString());
              }
              return Scrollbar(
                child: SingleChildScrollView(
                  child: Text(response.data),
                ),
              );
            }
            return CircularProgressIndicator();
          },
        ),
      ),
    );
  }

}