//  (c) Copyright 2012 - Ryan C. Weaving    
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
   
/** There is one instance of the logic device for each logic device that is displayed */
class LogicDevice {

  //var id;
  Point position;
  //int xPosition;
  //int yPosition;
    
  bool selected;
  bool selectable;
  bool enabled;
  bool calculated; 
  bool updated;
  bool visible;
  bool updateable;

  List<DeviceInput> inputs;
  List<DeviceOutput> outputs;
  
  LogicDeviceType deviceType;

  int acc=0;
  int rset=4;
 
  LogicDevice(this.deviceType) { 
    inputs = new List<DeviceInput>();
    outputs = new List<DeviceOutput>();
    
    //Configure IO for this new device from a DeviceType
    for(DevicePin devicePin in deviceType.inputPins) {
      inputs.add(new DeviceInput(this, devicePin.id, devicePin));
    }
    for(DevicePin devicePin in deviceType.outputPins) {
      outputs.add(new DeviceOutput(this, devicePin.id, devicePin));
    }
    
    position = new Point(0,0);
    visible = true;
    selectable = true;
  }
 
  DeviceInput InputPinHit(Point p) {
    for (DeviceInput input in inputs) {
      if(input.connectable){
        if(input.pinHit(p))
          return input; 
      }
    }
    return null;
  }
  
  DeviceOutput OutputPinHit(Point p) {
    for (DeviceOutput output in outputs) {
      if(output.connectable){
        if(output.pinHit(p))
          return output; 
      }
    }
    return null;
  }    
    
  bool DeviceHit(Point p) {
    return contains(p);
  }
   
  // Move the device to a new location
  void MoveDevice(Point p) { 
      position.x = p.x;
      position.y = p.y;
  }
  
  // the user has click on a logic device
  void clicked() {
    switch (deviceType.type) {
      case 'INPUT': 
      case 'SWITCH': 
        outputs[0].value = !outputs[0].value; 
        updated = true; 
        break;
    }
  }
  
//   Id the given point within our image
  bool contains(Point p) {
    if ((p.x > position.x && p.x < position.x + deviceType.images[0].width) && 
          (p.y > position.y && p.y < position.y + deviceType.images[0].height)) {
      return true;
    } 
    else {
      return false;
    }
  }
  
  void Calculate() {
    if(!calculated) {
      calculated = true;
      
      for(DeviceInput input in inputs)
          input.updated = false;
      
      bool outputState = outputs[0].value;
      
      switch (deviceType.type){
        case 'AND':     outputs[0].value = inputs[0].value && inputs[1].value; break;
        case 'NAND':    outputs[0].value = !(inputs[0].value && inputs[1].value); break;
        case 'OR':      outputs[0].value = inputs[0].value || inputs[1].value; break;
        case 'NOR':     outputs[0].value = !(inputs[0].value || inputs[1].value); break;
        case 'XOR':     outputs[0].value = (inputs[0].value != inputs[1].value); break;
        case 'XNOR':    outputs[0].value = !(inputs[0].value != inputs[1].value); break;
        case 'NOT':     outputs[0].value = !(inputs[0].value); break;
        case 'SWITCH':  outputs[0].value = outputs[0].value; break;
        
        case 'INPUT':  outputs[0].value = outputs[0].value; break; // Dummy output for device design
        case 'OUTPUT': outputs[0].value = inputs[0].value; break; // Dummy input for device design
        
        case 'DLOGO':
        case 'LED':     outputs[0].value = inputs[0].value; break;
        case 'CLOCK':   CalcClock(this); break;
       }
      
      if(outputState != outputs[0].value){ 
        updated = true;
      }
      
      // Check inputs to see if that have devices connected to them that have updated
      for(DeviceInput input in inputs) { 
        input.checkUpdate();
      }
    }
  }

  Function CalcClock(LogicDevice device) {
    if(device.acc > device.rset) {
      device.acc = 0;
      device.outputs[0].value = !device.outputs[0].value;
      device.outputs[1].value = !device.outputs[0].value;
    }
    else
      device.acc++;
  }
}