/** Simple Logic Simulator for Google Dart Hackathon 4-27-2012   
/   By: Ryan C. Weaving  &  Arthur Liu                           */

#import('dart:html');
#import('dart:json');
#import('dart:core');

#source('Util.dart');
#source('LogicDevice.dart');
#source('DeviceIO.dart');
#source('LogicDeviceTypes.dart');
#source('Circuit.dart');
#source('Wire.dart');

void main() {
  
  new Circuit(document.query('#canvas')).start();
 
}
