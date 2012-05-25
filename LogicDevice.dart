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
   
/** There is one instance of the logic device for each logic device that is displayed */
class LogicDevice {

  CanvasPoint position;

  bool selected;
  bool selectable;
  bool enabled;
  bool calculated; 
  bool updated;
  bool visible;
  bool updateable;

  List<DeviceInput> inputs;
  List<DeviceOutput> outputs;
  List<Logic> subLogic;
  
  LogicDeviceType deviceType;

  int acc=0;
  int rset=4;
 
  LogicDevice(this.deviceType) { 
    inputs = new List<DeviceInput>();
    outputs = new List<DeviceOutput>();
    subLogic = new List<Logic>();
    
    //Configure IO for this new device from a DeviceType
    for(DevicePin devicePin in deviceType.inputPins) {
      inputs.add(new DeviceInput(this, devicePin.id, devicePin));
    }
    for(DevicePin devicePin in deviceType.outputPins) {
      outputs.add(new DeviceOutput(this, devicePin.id, devicePin));
    }
    
    position = new CanvasPoint(0,0);
    visible = true;
    selectable = true;
    
    loadSublogic();
  }
 
  DeviceInput InputPinHit(CanvasPoint p) {
    for (DeviceInput input in inputs) {
      if(input.connectable){
        if(input.pinHit(p))
          return input; 
      }
    }
    return null;
  }
  
  DeviceOutput OutputPinHit(CanvasPoint p) {
    for (DeviceOutput output in outputs) {
      if(output.connectable){
        if(output.pinHit(p))
          return output; 
      }
    }
    return null;
  }    
    
  bool deviceHit(CanvasPoint p) {
    return contains(p);
  }
   
  // Move the device to a new location
  void moveDevice(CanvasPoint p) { 
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
  bool contains(CanvasPoint p) {
    if ((p.x > position.x && p.x < position.x + deviceType.images[0].width) && 
          (p.y > position.y && p.y < position.y + deviceType.images[0].height)) {
      return true;
    } 
    else {
      return false;
    }
  }
  
  /** Calculate the logic state of this device */
  void calculate() {
    if(!calculated) {
      calculated = true;
      
      for(DeviceInput input in inputs) {
          input.updated = false;
      }
      
      // Set output values to check for changes
      for(DeviceOutput output in outputs) {
        output.previous_value = output.value;
      }
      
      subCalc();

      // Check inputs to see if that have devices connected to them that have updated
      for(DeviceInput input in inputs) { 
        input.checkUpdate();
      }
    }
  }

  /** Preform logic calculation on sublogic circuit */
  void subCalc() {
    for (Logic gate in subLogic) { // clear calc status
      gate.calculated = false;
    }
    
    for(DeviceInput input in inputs) { // Set inputs
      if(input.subLogicGate != null) {
        if (input.value) {
          input.subLogicGate.out = true;
        }
        else {
          input.subLogicGate.out = false;
        }
      }
    }
    
    for (Logic gate in subLogic) { // Calc sublogic
      gate.calc();
    }
    
    for (DeviceOutput output in outputs) { // Set outputs
      if (output.subLogicGate != null) {
        output.value = output.subLogicGate.out;
      }
    }
  }
  
  /** Load the devices subLogicGates */
  void loadSublogic() {
    subLogic.clear();
    
    for (SubLogicGate gate in deviceType.subLogicGates) {
      if (gate.gateType == 'IN') { // set the external connections for sublogic input
        if (gate.connection2 >= 0 && gate.connection2 < inputs.length) {
          inputs[gate.connection2].subLogicGate = addGate('IN', -1, -1);  
        }
        continue;
      }
      if (gate.gateType == 'OUT') { // set the external connections for sublogic output
        if (gate.connection2 >= 0 && gate.connection2 < outputs.length) {
          outputs[gate.connection2].subLogicGate = addGate('OUT', gate.connection1, -1);  
        }
        continue;
      } 
      addGate(gate.gateType, gate.connection1, gate.connection2);  
    }
    setConnections(); // connect the devices using preloads
  }
 
  
  /** After all the sublogic devices are created set their connections */
  void setConnections() {
    for (Logic sl in subLogic) {
      if (sl.ig1 >= 0 && sl.ig1 < subLogic.length) {
        sl.inGate1 = subLogic[sl.ig1];
      }
      if (sl.ig2 >= 0 && sl.ig2 < subLogic.length) {
        sl.inGate2 = subLogic[sl.ig2];
      }
    }
  }
    
  /** Add a sublogic gate */
  Logic addGate(var gateType, int inGate1, int inGate2) {
    
    Logic newGate;
    
    switch (gateType) {
      case 'IN':      newGate = new pIn();     break;
      case 'OUT':     newGate = new pOut();    break;
      case 'AND':     newGate = new pAnd();    break;
      case 'NAND':    newGate = new pNand();   break;
      case 'OR':      newGate = new pOr();     break;
      case 'NOR':     newGate = new pNor();    break;
      case 'XOR':     newGate = new pXor();    break;
      case 'XNOR':    newGate = new pXnor();   break;
      case 'NOT':     newGate = new pNot();    break;
      case 'BUFFER':  newGate = new pBuffer(); break;
      case 'SWITCH':  newGate = new pSwitch(); break;
      case 'CLOCK':   newGate = new pClock();  break;
    }
    
    if (newGate != null) {
      newGate.ig1 = inGate1; // Preset connections
      newGate.ig2 = inGate2;
      newGate.inGate1 = newGate;
      newGate.inGate2 = newGate;
      newGate.out = false;
      subLogic.add(newGate);
    }
    return newGate;
  }
  
    
}