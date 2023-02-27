import 'package:flutter/cupertino.dart';

class TempHumProvider extends ChangeNotifier{
   String temp ="0";
   String  humidity="0";

   void updateTemp(String newTemp){
     temp = newTemp;
     notifyListeners();
   }
   void updateHumidity(String newHumidity){
     humidity = newHumidity;
     notifyListeners();
   }
}