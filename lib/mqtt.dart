import 'dart:async';
import 'dart:convert';

import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

class MQTTClass {
  MqttServerClient _client;
  bool _alreadysubscribed = false;
  String _previousTopic = "";

  var dataController = StreamController<String>();
  // Subscribe to topic
  Future<bool> subscribe(String topic) async {
    try {
      if (await _checkConnectionToClient() == true) {
        _client.onConnected = () {
          print('connected');
        };
        _client.onDisconnected = () {
          print('Disconnected');
          // _client.disconnect();
        };
        _client.onSubscribed = _onSubscribe(topic);
        _subscribe(topic);
        return true;
      }
      return false;
    } catch (e) {
      print(e);
      return false;
    }
  }

  // connect to broker
  Future<MqttClient> login() async {
    _client =
        MqttServerClient.withPort('broker.emqx.io', 'flutter_client', 1883);
    // _client.websocketProtocols = ["mqttv3.11"];
    _client.logging(on: true);
    final MqttConnectMessage connMess = MqttConnectMessage()
        .authenticateAs("emirdilony", "emirdilonirity")
        .withClientIdentifier('flutter_client')
        .keepAliveFor(60)
        .withWillTopic('willtopic')
        .withWillMessage('My Will message')
        .withWillRetain()
        .startClean()
        .withWillQos(MqttQos.atLeastOnce);
    _client.connectionMessage = connMess;

    try {
      await _client.connect().then((value) {
        _client.updates.listen((event) {
          final MqttPublishMessage payLoad = event[0].payload;
          String data =
              MqttPublishPayload.bytesToStringAsString(payLoad.payload.message);
          // Map<String, dynamic> dataPayload = json.decode(data);
          dataController.add(data);
          return data;
        });
      });
    } on Exception catch (e) {
      print(e);
      _client.disconnect();
      _client = null;
      return _client;
    }

    if (_client.connectionStatus.state != MqttConnectionState.connected) {
      _client.disconnect();
      _client = null;
    }
    return _client;
  }

  Future<bool> _checkConnectionToClient() async {
    bool _isLogged;

    await login().then(
      (value) {
        if (value == null) {
          _isLogged = false;
          return;
        } else {
          _isLogged = true;
        }
      },
    );

    return _isLogged;
  }

  _onSubscribe(String topic) {
    this._alreadysubscribed = true;
    this._previousTopic = topic;
  }

  ///////////////////////////
  Future _subscribe(String topic) async {
    if (this._alreadysubscribed == true) {
      _client.unsubscribe(this._previousTopic);
    }
    _client.subscribe(topic, MqttQos.atLeastOnce);
  }

  void disconnect() {
    _client.disconnect();
  }

  // Publish to Topic
  Future<void> publish(String topic, String value) async {
    final MqttClientPayloadBuilder builder = MqttClientPayloadBuilder();
    // builder.
    Map<String, dynamic> _testing = {
      'message': value,
      'time_sent': DateTime.now().toString(),
    };
    builder.addString(json.encode(_testing));
    _client.publishMessage(topic, MqttQos.atLeastOnce, builder.payload);
  }

  void dispose() {
    dataController.close();
  }
}
