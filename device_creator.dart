//  (c) Copyright 2012 - Ryan C. Weaving
//  https://plus.google.com/111607634508834917317
//
//  This file is part of Happy Logic Simulator.
//  http://HappyLogicSimulator.com 
//
//  Happy Logic Simulator is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//  
//  Happy Logic Simulator is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//  
//  You should have received a copy of the GNU General Public License
//  along with Happy Logic Simulator.  If not, see <http://www.gnu.org/licenses/>.

#library('device_creator');

#import('dart:html');
#import('logic_device.dart');
#import('device_input.dart');
#import('device_output.dart');

/** This class is fore creating deritive devices */
class DeviceCreator {
  
  DeviceCreator();
  
  // Creates the device in the DOM
  void createDevice(List<LogicDevice> logicDevices) {

    var element = new Element.tag('device');
    element.attributes['name'] = "AND";
    element.attributes['image'] = "images/125dpi/and.png";
    element.attributes['icon'] = "images/125dpi/and_d.png";

    for (LogicDevice d in logicDevices) {
      var e = new Element.tag('gate');
      var type = d.deviceType.type;
      e.attributes['type'] = type;
      e.attributes['id'] = logicDevices.indexOf(d).toString();
      
      for(DeviceInput i in d.inputs) {
        if(i.connected == true) {
          e.attributes['i${d.inputs.indexOf(i)}'] = logicDevices.indexOf(i.connectedWire.output.device).toString();
        }
      }
      // Add x and y locations for io pin offsets
      if (type == "INPUT" || type == "OUTPUT") { 
        e.attributes['x'] = '0';
        e.attributes['y'] = '0';
      }
      element.nodes.add(e);  
    }
    document.body.nodes.add(element);
  }
}
    
    
    
//    var device = new JsonObject();
//    
//    device.name = "Default";
//    device.base = "images/125dpi/and.png";
//    device.icon = "images/125dpi/and_d.png";
//    
//    device.inputs = new List();
//    device.outputs = new List();
//    //device.connections = new List();
//    device.subdevices = new List();

    // Map our device inputs and outputs
//    int inCount = 0;
//    int outCount = 0;
//    
//    for (LogicDevice d in logicDevices) {
//      if (d.deviceType.type == 'INPUT') {
//        var input = new JsonObject();
//        //input.id = inCount;
//        input.id = logicDevices.indexOf(d);
//        input.x = 0;
//        input.y = 10 * inCount;
//        inCount++;
//        device.inputs.add(input);
//      }
//      if (d.deviceType.type == 'OUTPUT') {
//        var output = new JsonObject();
//        //output.i = outCount;
//        output.id = logicDevices.indexOf(d);
//        output.x = 20;
//        output.y = 10 * outCount;
//        outCount++;
//        device.outputs.add(output);
//      }
//    }
//    
//    // Build connections list
//    int inputCount = 0;
//    int outputCount = 0;
//    
//    for (LogicDevice d in logicDevices) {
//      var logic = new JsonObject();
//      logic.id = logicDevices.indexOf(d);
//      logic.type = d.deviceType.type;
//      
//      logic.c1 = -1;
//      logic.c2 = -1;
//      
//      if(logic.type == "INPUT") {
//        logic.c2 = inputCount;  
//        logic.type = "IN";
//        inputCount++;
//      }
//      
//      if(logic.type == "OUTPUT") {
//        logic.c2 = outputCount;  
//        logic.type = "OUT";
//        outputCount++;
//      }
//      
//      for(DeviceInput i in d.inputs) {
//        if(i.connected == true) {
//          if(d.inputs.indexOf(i) == 0) {
//            logic.c1 = logicDevices.indexOf(i.connectedWire.output.device); 
//          }
//          if(d.inputs.indexOf(i) == 1) {
//            logic.c2 = logicDevices.indexOf(i.connectedWire.output.device); 
//          }
//        }
//      }
//      device.subdevices.add(logic);
//    }
//    var jsonT = JSON.stringify(device);
//    print("${jsonT}");

//
///** This class is fore creating deritive devices */
//class DeviceCreator {
//  
//  DeviceCreator();
//  
//  String createDevice(List<LogicDevice> logicDevices) {
//
//    var device = new JsonObject();
//    
//    device.name = "Default";
//    device.base = "images/125dpi/and.png";
//    device.icon = "images/125dpi/and_d.png";
//    
//    device.inputs = new List();
//    device.outputs = new List();
//    //device.connections = new List();
//    device.subdevices = new List();
//
//    // Map our device inputs and outputs
//    int inCount = 0;
//    int outCount = 0;
//    
//    for (LogicDevice d in logicDevices) {
//      if (d.deviceType.type == 'INPUT') {
//        var input = new JsonObject();
//        input.id = logicDevices.indexOf(d);
//        input.x = 0;
//        input.y = 10 * inCount;
//        inCount++;
//        device.inputs.add(input);
//      }
//      if (d.deviceType.type == 'OUTPUT') {
//        var output = new JsonObject();
//        output.id = logicDevices.indexOf(d);
//        output.x = 20;
//        output.y = 10 * outCount;
//        outCount++;
//        device.outputs.add(output);
//      }
//    }
//    
//    // Build connections list
//    int inputCount = 0;
//    int outputCount = 0;
//    
//    for (LogicDevice d in logicDevices) {
//      var logic = new JsonObject();
//      logic.id = logicDevices.indexOf(d);
//      logic.type = d.deviceType.type;
//      
//      logic.c1 = -1;
//      logic.c2 = -1;
//      
//      if(logic.type == "INPUT") {
//        logic.c2 = inputCount;  
//        logic.type = "IN";
//        inputCount++;
//      }
//      
//      if(logic.type == "OUTPUT") {
//        logic.c2 = outputCount;  
//        logic.type = "OUT";
//        outputCount++;
//      }
//      
//      for(DeviceInput i in d.inputs) {
//        if(i.connected == true) {
//          if(d.inputs.indexOf(i) == 0) {
//            logic.c1 = logicDevices.indexOf(i.connectedWire.output.device); 
//          }
//          if(d.inputs.indexOf(i) == 1) {
//            logic.c2 = logicDevices.indexOf(i.connectedWire.output.device); 
//          }
//        }
//      }
//      
//      device.subdevices.add(logic);
//    }
  
//   
//    var jsonT = JSON.stringify(device);
//    print("${jsonT}");
//  }
//}
//  

