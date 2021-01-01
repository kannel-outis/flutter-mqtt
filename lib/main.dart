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

  @override
  void dispose() {
    _mqttClass.dispose();
    super.dispose();
  }

  void add(data) {
    _messages.add(data);
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
              StreamBuilder<Map<String, dynamic>>(
                stream: _mqttClass.dataController.stream,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    add(snapshot.data);
                  }
                  return Container(
                    height: 150,
                    child: ListView(
                      shrinkWrap: true,
                      children: _messages.map(
                        (e) {
                          return Row(
                            children: [
                              Expanded(
                                child: Text(e['message']),
                              ),
                              Expanded(
                                child: Text(e['time_sent']),
                              ),
                            ],
                          );
                        },
                      ).toList(),
                      // return
                    ),
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
