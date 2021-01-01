import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_messenger/mqtt.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final MQTTClass _mqttClass = MQTTClass();
  TextEditingController _topicController;
  TextEditingController _messageController;
  List<Map<String, dynamic>> _messages = [];

  @override
  void initState() {
    super.initState();
    _topicController = TextEditingController();
    _messageController = TextEditingController();
  }

  // @override
  // void didChangeDependencies() {
  //   // _mqttClass.login();
  //   super.didChangeDependencies();
  // }

  @override
  void dispose() {
    _mqttClass.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('MQTT FreeStyle app'),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 50, horizontal: 20),
          child: Column(
            children: [
              TextField(
                controller: _topicController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Enter topic',
                ),
              ),
              SizedBox(height: 20),
              FlatButton(
                color: Colors.blue,
                textColor: Colors.white,
                hoverColor: Colors.lightBlue,
                height: 50,
                onPressed: () {
                  _mqttClass.subscribe(_topicController.text);
                },
                child: Text('SubScribe to Topic'),
              ),
              SizedBox(height: 20),
              TextField(
                controller: _messageController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Send Message',
                ),
              ),
              SizedBox(height: 20),
              FlatButton(
                color: Colors.blue,
                textColor: Colors.white,
                hoverColor: Colors.lightBlue,
                height: 50,
                onPressed: () {
                  _mqttClass.publish(
                      _topicController.text, _messageController.text);
                },
                child: Text('Send Message'),
              ),
              SizedBox(height: 20),
              StreamBuilder<String>(
                stream: _mqttClass.dataController.stream,
                builder: (context, snapshot) {
                  _messages.add(json.decode(snapshot.data));
                  return Container(
                    height: 150,
                    child: _messages.length != 0
                        ? ListView.builder(
                            shrinkWrap: true,
                            itemCount: _messages.length,
                            itemBuilder: (context, index) {
                              return Row(
                                children: [
                                  Expanded(
                                    child: Text(_messages.reversed
                                        .toList()[index]['message']),
                                  ),
                                  Expanded(
                                    child: Text(_messages.reversed
                                        .toList()[index]['time_sent']),
                                  ),
                                ],
                              );
                            },
                          )
                        : Container(),
                  );
                },
              ),
              SizedBox(height: 40),
              Row(
                children: [
                  FlatButton(
                    color: Colors.blue,
                    textColor: Colors.white,
                    hoverColor: Colors.lightBlue,
                    height: 50,
                    onPressed: () {
                      _mqttClass.login();
                    },
                    child: Text('Connect To broker'),
                  ),
                  SizedBox(width: 50),
                  FlatButton(
                    color: Colors.blue,
                    textColor: Colors.white,
                    hoverColor: Colors.lightBlue,
                    height: 50,
                    onPressed: () {
                      _mqttClass.disconnect();
                    },
                    child: Text('Disconnect From broker'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
