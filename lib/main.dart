import 'package:flutter/material.dart';
import 'package:iot/mqtt.dart';
import 'package:iot/provider/temp_hum_provider.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ChangeNotifierProvider<TempHumProvider>(create: (context)=>TempHumProvider(),
          child: const MyHomePage()
      ),
    );
  }
}
class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Home"),

      ),
      body: Column(
        children: [
          Consumer<TempHumProvider>(
              builder: (context,value,child){
                return  SfRadialGauge(
                    enableLoadingAnimation: true,
                    animationDuration: 2000,
                    title: GaugeTitle(text: "Home temperature",textStyle: TextStyle(fontSize: 23)),
                    axes: <RadialAxis>[
                      RadialAxis(minimum: 0, maximum: 50,
                          showTicks: false,
                          showLabels: false,
                          axisLineStyle:const AxisLineStyle(
                              thickness: 0.2,
                              thicknessUnit: GaugeSizeUnit.factor),

                          pointers: <GaugePointer>[
                            RangePointer(
                              value: double.parse(value.temp), width: 0.2, sizeUnit: GaugeSizeUnit.factor,
                              color: colorChangeTemperature(value.temp),
                              enableAnimation: true,
                            )
                          ],
                          annotations:  <GaugeAnnotation>[
                            GaugeAnnotation(widget: Text('${value.temp} C°',style:const TextStyle(fontSize: 25,fontWeight: FontWeight.bold)),
                                angle: 90, positionFactor: 0
                            )]
                      )]);
              }
          ),

          SfRadialGauge(
              enableLoadingAnimation: true,
              animationDuration: 2000,
              title:const GaugeTitle(text: "Home humidity",textStyle: TextStyle(fontSize: 23)),
              axes: <RadialAxis>[
                RadialAxis(minimum: 0, maximum: 100,
                    showTicks: false,
                    showLabels: false,
                    axisLineStyle:const AxisLineStyle(
                        thickness: 0.2,
                        thicknessUnit: GaugeSizeUnit.factor),

                    pointers:   <GaugePointer>[
                      RangePointer(
                        value: 56, width: 0.2, sizeUnit: GaugeSizeUnit.factor,
                        color:colorChangeHumidity("80"),
                      )
                    ],
                    annotations: const <GaugeAnnotation>[
                      GaugeAnnotation(widget: Text('56%',style: TextStyle(fontSize: 25,fontWeight: FontWeight.bold)),
                          angle: 90, positionFactor: 0
                      )]
                )])

        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          setup();
          await connect();
          subscribeToTopic("temp");
          //subscribeToTopic("hum");
          listen();
        },
      ),
    );
  }

  void listen() {

    client.updates!.listen((List<MqttReceivedMessage<MqttMessage?>>? c) {
      final recMess = c![0].payload as MqttPublishMessage;
      final pt = MqttPublishPayload.bytesToStringAsString(
          recMess.payload.message);
      final temp =Provider.of<TempHumProvider>(context,listen:false);
      temp.updateTemp(pt);
    });

  }
  MaterialColor colorChangeHumidity(String humidityValue){
    double hum = double.parse(humidityValue);
    if(hum <40){
      return Colors.orange;
    }else if(hum>40 && hum<65){
      return Colors.green;
    }else{
      return Colors.blue;
    }
  }
  MaterialColor colorChangeTemperature(String tempValue){
    double temp = double.parse(tempValue);
    if(temp <15){
      return Colors.blue;
    }else if(temp>15 && temp<25){
      return Colors.green;
    }else{
      return Colors.red;
    }
  }
}
