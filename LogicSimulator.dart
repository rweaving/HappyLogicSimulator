//
// Happy Logic Simulator - (C)2012 Ryan C. Weaving
// http://HappyLogicSimulator.com
//

#import('dart:html');
#import('dart:json');
#import('dart:core');

#source('Circuit.dart');
#source('CircuitDraw.dart');
#source('CircuitView.dart');
#source('DeviceButton.dart');
#source('DeviceInput.dart');
#source('DeviceIO.dart');
#source('DeviceOutput.dart');
#source('DevicePin.dart');
#source('DeviceSelector.dart');
#source('LogicDevice.dart');
#source('LogicDeviceTypes.dart');
#source('LogicStyle.dart');
#source('Wire.dart');
#source('Wires.dart');

void main() {
  
  new CircuitView(document.query('#canvas')).start();
 
}
