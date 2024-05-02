import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'package:iot/WelcomePage.dart'; // Import the welcome page

void main() {
  runApp(const MyApp());
}

class TempHumProvider extends ChangeNotifier {
  String temp = '20'; // Set initial value to '20'
  String hum = '0'; // Set initial value to '0'

  void updateValues(String newTemp, String newHum) {
    temp = newTemp;
    hum = newHum;
    notifyListeners();
  }
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      // Define routes
      routes: {
        '/': (context) => ChangeNotifierProvider<TempHumProvider>(
          create: (context) => TempHumProvider(),
          child: MyHomePage(),
        ),
        '/welcome': (context) => WelcomePage(),
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late WebSocket socket;

  @override
  void initState() {
    super.initState();
    connecttosocket();
  }

  void connecttosocket() {
    final serverAddress = "ws://192.168.0.1:81";

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

      // Initial message to request temperature and humidity data
      final message = {'type': 'get_data'};
      socket.add(jsonEncode(message));
      print('Sent message: $message');
    }).catchError((error) {
      print('Failed to connect to WebSocket server: $error');
    });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home"),
      ),
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
                  text: "Home temperature",
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
                  text: "Home humidity",
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
              SizedBox(
                height: 20,
              ),
              ElevatedButton(
                onPressed: () {
                  // Navigate to the welcome page
                  Navigator.pushNamed(context, '/welcome');
                },
                child: Text('Welcome Page'),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // You can send a message here if needed
        },
        child: const Icon(Icons.refresh),
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
