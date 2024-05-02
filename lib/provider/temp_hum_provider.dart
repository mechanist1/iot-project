import 'package:flutter/cupertino.dart';

class  TempHumProvider extends ChangeNotifier{
   String temp ="50";
   String  humidity="40";

   void updateTemp(String newTemp){
     temp = newTemp;
     notifyListeners();
   }
   void updateHumidity(String newHumidity){
     humidity = newHumidity;
     notifyListeners();
   }
}