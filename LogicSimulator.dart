//
// Happy Logic Simulator - (C)2012 Ryan C. Weaving
// http://HappyLogicSimulator.com
//

#import('dart:html');
#import('dart:json');
#import('dart:core');

#source('LogicDevice.dart');
#source('DeviceIO.dart');
#source('DeviceInput.dart');
#source('DeviceOutput.dart');
#source('LogicDeviceTypes.dart');
#source('Circuit.dart');
#source('Wire.dart');
#source('Wires.dart');
#source('DevicePin.dart');
#source('DeviceButton.dart');
#source('DeviceSelector.dart');

void main() {
  
  new Circuit(document.query('#canvas')).start();
 
}
