import 'dart:async';
import 'dart:io';
import 'dart:convert';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(DateTimePicker());

class DateTimePicker extends StatefulWidget {
  @override
  _DateTimePickerState createState() => _DateTimePickerState();
}

class _DateTimePickerState extends State<DateTimePicker> {
  static FirebaseAnalytics analytics = FirebaseAnalytics();
  static FirebaseAnalyticsObserver observer = FirebaseAnalyticsObserver(analytics: analytics);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      navigatorObservers: <NavigatorObserver>[observer],
      home: MyHomePage(
        analytics: analytics,
        observer: observer,
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.analytics, this.observer}) : super(key: key);

  final FirebaseAnalytics analytics;
  final FirebaseAnalyticsObserver observer;

  @override
  _MyHomePageState createState() => _MyHomePageState(analytics, observer);
}

class _MyHomePageState extends State<MyHomePage> {
  _MyHomePageState(this.analytics, this.observer);

  final FirebaseAnalyticsObserver observer;
  final FirebaseAnalytics analytics;
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

  String _token;

  DateTime _datetime;
  String _datetime_show;
  String _datetime_josa;
  String _number;
  String _number_josa;
  String _okButtonText = "가자!";

  bool _buttonDisabled = false;
  bool _okButtonLoading = true;

  @override
  void initState() {
    super.initState();

    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        print("onMessage: $message");
      },
      onLaunch: (Map<String, dynamic> message) async {
        print("onLaunch: $message");
      },
      onResume: (Map<String, dynamic> message) async {
        print("onResume: $message");
      },
    );

    _firebaseMessaging.requestNotificationPermissions(
        const IosNotificationSettings(sound: true, badge: true, alert: true, provisional: false));

    _firebaseMessaging.onIosSettingsRegistered.listen((IosNotificationSettings settings) {
      print("Settings registered: $settings");
    });

    _firebaseMessaging.getToken().then((String token) {
      assert(token != null);
      this._saveToken(token);
      setState(() {
        _token = token;
      });
      print('token: $token');
    });

    _loadInformation();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('셀럽이 되고싶어'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Container(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              RaisedButton(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5.0)
                ),
                elevation: 4.0,
                onPressed: () {
                  if (_buttonDisabled) {
                    return null;
                  }

                  DatePicker.showDateTimePicker(
                      context,
                      theme: DatePickerTheme(
                        containerHeight: 210.0,
                      ),
                      showTitleActions: true,
                      onConfirm: (date) {
                        print('confirm $date');

                        _datetime = date;
                        _datetime_show = '${date.month}월 ${date.day}일 ${date.hour}시 ${date.minute}분';
                        _datetime_josa = '에!';
                        setState(() {});
                      },
                      currentTime: DateTime.now(),
                      locale: LocaleType.ko
                  );
                  setState(() {});
                },
                child: Container(
                  alignment: Alignment.center,
                  height: 50.0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Container(
                            child: Row(
                              children: <Widget>[
//                                Icon(
//                                  Icons.access_time,
//                                  size: 18.0,
//                                  color: Colors.teal,
//                                ),
                                Text(
                                  " $_datetime_show",
                                  style: TextStyle(
                                      color: Colors.teal,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18.0),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                      Text(
                        "  $_datetime_josa",
                        style: TextStyle(
                            color: Colors.teal,
                            fontWeight: FontWeight.bold,
                            fontSize: 18.0),
                      ),
                    ],
                  ),
                ),
                color: Colors.white,
              ),
              SizedBox(
                height: 10.0,
              ),
              RaisedButton(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5.0)),
                elevation: 4.0,
                onPressed: () {
                  if (_buttonDisabled) {
                    return null;
                  }

                  showDialog<int>(
                    context: context,
                    builder: (BuildContext context) {
                      return new NumberPickerDialog.integer(
                        minValue: 0,
                        maxValue: 100,
                        step: 1,
                        initialIntegerValue: 0,
                        title: new Text("몇 번이나?"),
                      );
                    },
                  ).then((num value) {
                    print('confirm $value');
                    if (value != null) {

                      setState(() {
                        _number = value.toString();
                        _number_josa = "번!";
                      });
                    }
                  });
                },
                child: Container(
                  alignment: Alignment.center,
                  height: 50.0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Container(
                            child: Row(
                              children: <Widget>[
//                                Icon(
//                                  Icons.access_time,
//                                  size: 18.0,
//                                  color: Colors.teal,
//                                ),
                                Text(
                                  " $_number",
                                  style: TextStyle(
                                      color: Colors.teal,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18.0),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                      Text(
                        "  $_number_josa",
                        style: TextStyle(
                            color: Colors.teal,
                            fontWeight: FontWeight.bold,
                            fontSize: 18.0),
                      ),
                    ],
                  ),
                ),
                color: Colors.white,
              ),
              SizedBox(
                height: 10.0,
              ),
              RaisedButton(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5.0)),
                elevation: 4.0,
                onPressed: () {
                  if (_datetime_josa.isEmpty || _number_josa.isEmpty) {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: new Text("저기..."),
                          content: new Text("입력을 안해줬는데요?"),
                          actions: <Widget>[
                            new FlatButton(
                              child: new Text("네.."),
                              onPressed: () {
                                Navigator.pop(context);
                              },
                            ),
                          ],
                        );
                      },
                    );
                  }
                  else {
                    _saveInformation();
                  }
                },
                child: Container(
                  alignment: Alignment.center,
                  height: 50.0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      if (_okButtonLoading) ...[
                        CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.teal),
                        )
                      ]
                      else ...[
                        Text(
                          _okButtonText,
                          style: TextStyle(
                              color: Colors.teal,
                              fontWeight: FontWeight.bold,
                              fontSize: 18.0),
                        ),
                      ]
                    ],
                  ),
                ),
                color: Colors.white,
              ),
            ],
          ),
        ),
      ),
    );
  }

  _loadInformation() async {
    print('_loadInformation()');

    SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      _token = prefs.getString('token') ?? "";
      int timestamp = prefs.getInt('datetime') ?? 0;
      _datetime_show = prefs.getString('datetime_show') ?? "언제?";
      _datetime_josa = prefs.getString('datetime_josa') ?? "";
      _number = prefs.getString('number') ?? "몇 번?";
      _number_josa = prefs.getString('number_josa') ?? "";

      _datetime = DateTime.fromMillisecondsSinceEpoch(timestamp);
    });

    _okButtonLoading = false;
  }

  _saveInformation() async {
    print('_saveInformation()');

    SharedPreferences prefs = await SharedPreferences.getInstance();

    await prefs.setInt('datetime', _datetime.millisecondsSinceEpoch);
    await prefs.setString('datetime_show', _datetime_show);
    await prefs.setString('datetime_josa', _datetime_josa);
    await prefs.setString('number', _number);
    await prefs.setString('number_josa', _number_josa);

//    if (true) {
//      setState(() {
//        _okButtonText = "취소";
//
//        _buttonDisabled = true;
//      });
//    }

    var url = Uri.encodeFull(DotEnv().env['apiUrl'] + '/api/celebspush/add');

    var responseJson = await http.post(url, body: {
      'send_date': _datetime.toString(),
      'send_number': _number,
      'send_message': 'blank',
      'device_id': _token
    }, headers: {
        HttpHeaders.authorizationHeader: "Bearer " + DotEnv().env['token']
    });

    Map<String, dynamic> response = jsonDecode(responseJson.body);
    print(response);
    
  }

  _saveToken(String token) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    await prefs.setString('token', token);
  }
}