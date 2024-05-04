import 'dart:convert';
import 'dart:io';
import'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'package:iot/WelcomePage.dart';
import 'SettingsPage.dart';
import 'login.dart';
import 'dart:async';
void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: MaterialApp(
        title: 'MyApp',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => LoginPage(),
          '/welcome':(context)=>WelcomePage(),
          '/settings': (context) => SettingsPage(),
          '/home': (context) => ChangeNotifierProvider<TempHumProvider>(
            create: (context) => TempHumProvider(),
            child: MyHomePage(),
          ),
        },
      ),
    );
  }
}

class TempHumProvider extends ChangeNotifier {
  String temp = '23';
  String hum = '15';

  void updateValues(String newTemp, String newHum) {
    temp = newTemp;
    hum = newHum;
    notifyListeners();
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}
class _MyHomePageState extends State<MyHomePage> {
  late WebSocket socket;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    connecttosocket();
    _startTimer();
  }

  void connecttosocket() {
    final serverAddress = "ws://192.168.0.1:81";
    print("work in progress please wait ");
    WebSocket.connect(serverAddress).then((WebSocket socket) {
      print('Connected to WebSocket server');
      this.socket = socket;

      socket.listen(
            (dynamic message) {
          print('Received message: $message');
          handleMessage(message);
        },
        onError: (error) {
          print('Error: $error');
        },
        onDone: () {
          print('WebSocket connection closed');
        },
      );

      final message = {'type': 'get_data'};
      socket.add(jsonEncode(message));
      print('Sent message: $message');
    }).catchError((error) {
      print('Failed to connect to WebSocket server: $error');
    });
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 5), (timer) {
      updateValues();
    });
  }

  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void handleMessage(dynamic message) {
    if (message == "connected") {
      print("connected");
    } else if (message.substring(0, 6) == "{'temp") {
      message = message.replaceAll(RegExp("'"), '"');
      Map<String, dynamic> jsondata = json.decode(message);
      final temp = jsondata["temp"];
      final hum = jsondata["humidity"];
      Provider.of<TempHumProvider>(context, listen: false).updateValues(temp, hum);
    }
  }

  void updateValues() {
    final tempProvider = Provider.of<TempHumProvider>(context, listen: false);
    tempProvider.updateValues(_getRandomTemperature(tempProvider.temp), _getRandomHumidity(tempProvider.hum));
  }

  String _getRandomTemperature(String currentTempStr) {
    double currentTemp = double.parse(currentTempStr);
    Random random = Random();
    double tempChange = (random.nextDouble() * 0.6) - 0.3; // Adjusted the range of temperature change
    double newTemp = (currentTemp + tempChange).clamp(0.0, 50.0);
    return newTemp.toStringAsFixed(2);
  }


  String _getRandomHumidity(String currentHumStr) {
    double currentHum = double.parse(currentHumStr);
    Random random = Random();
    double humChange = (random.nextDouble() * 0.06) - 0.008; // Adjusted the range of humidity change
    double newHum = (currentHum + humChange).clamp(0.0, 100.0);
    return newHum.toStringAsFixed(2);
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home"),
        backgroundColor: Colors.blueAccent,
      ),
      backgroundColor: Colors.white,
      body: Consumer<TempHumProvider>(
        builder: (context, value, child) {
          return Column(
            children: [
              SizedBox(
                height: 20,
              ),
              SfRadialGauge(
                enableLoadingAnimation: true,
                animationDuration: 2000,
                title: GaugeTitle(
                  text: "temperature",
                  textStyle: const TextStyle(fontSize: 23),
                ),
                axes: <RadialAxis>[
                  RadialAxis(
                    minimum: 0,
                    maximum: 50,
                    showTicks: false,
                    showLabels: false,
                    axisLineStyle: const AxisLineStyle(
                      thickness: 0.2,
                      thicknessUnit: GaugeSizeUnit.factor,
                    ),
                    pointers: <GaugePointer>[
                      RangePointer(
                        value: double.parse(value.temp),
                        width: 0.2,
                        sizeUnit: GaugeSizeUnit.factor,
                        color: colorChangeTemperature(value.temp),
                        enableAnimation: true,
                      )
                    ],
                    annotations: <GaugeAnnotation>[
                      GaugeAnnotation(
                        widget: Text(
                          '${value.temp} °C',
                          style: const TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                        ),
                        angle: 90,
                        positionFactor: 0,
                      )
                    ],
                  )
                ],
              ),
              SizedBox(
                height: 20,
              ),
              SfRadialGauge(
                enableLoadingAnimation: true,
                animationDuration: 2000,
                title: const GaugeTitle(
                  text: "humidity",
                  textStyle: TextStyle(fontSize: 23),
                ),
                axes: <RadialAxis>[
                  RadialAxis(
                    minimum: 0,
                    maximum: 100,
                    showTicks: false,
                    showLabels: false,
                    axisLineStyle: const AxisLineStyle(
                      thickness: 0.2,
                      thicknessUnit: GaugeSizeUnit.factor,
                    ),
                    pointers: <GaugePointer>[
                      RangePointer(
                        value: double.parse(value.hum),
                        width: 0.2,
                        sizeUnit: GaugeSizeUnit.factor,
                        color: colorChangeHumidity(value.hum),
                        enableAnimation: true,
                      )
                    ],
                    annotations: <GaugeAnnotation>[
                      GaugeAnnotation(
                        widget: Text(
                          '${value.hum} %',
                          style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                        ),
                        angle: 90,
                        positionFactor: 0,
                      )
                    ],
                  )
                ],
              ),
            ],
          );
        },
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: () {
            Navigator.pop(context); // Navigate back to the previous screen
          },
          child: Text('Go Back', style: TextStyle(color: Colors.black)),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blueAccent,
            disabledForegroundColor: Colors.black.withOpacity(0.7).withOpacity(0.38),
            disabledBackgroundColor: Colors.black.withOpacity(0.7).withOpacity(0.12),
          ),
        ),
      ),
    );
  }

  MaterialColor colorChangeHumidity(String humidityValue) {
    double hum = double.parse(humidityValue);
    if (hum < 40) {
      return Colors.orange;
    } else if (hum > 40 && hum < 65) {
      return Colors.green;
    } else {
      return Colors.blue;
    }
  }

  MaterialColor colorChangeTemperature(String tempValue) {
    double temp = double.parse(tempValue);
    if (temp < 15) {
      return Colors.blue;
    } else if (temp > 15 && temp < 25) {
      return Colors.green;
    } else {
      return Colors.red;
    }
  }
}
