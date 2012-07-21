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

#library('logic_device');

#import('logic.dart');
#import('canvas_point.dart');
#import('offset_image.dart');
#import('device_input.dart');
#import('device_output.dart');
#import('device_pin.dart');
#import('device_type.dart');
#import('device_map.dart');

/** There is one instance of the logic device for each logic device that is displayed */
class LogicDevice {

  CanvasPoint position;

  bool selected = false;
  bool selectable = false;
  bool enabled = false;
  bool calculated = false; 
  bool updated = false;
  bool visible = false;
  bool updateable = false;
  bool hasOutputMaps = false;
  bool hasInputMaps = false;
  
  List<DeviceInput> inputs;
  List<DeviceOutput> outputs;
  List<Logic> subLogic;
  List<OffsetImage> images;
  
  LogicDeviceType deviceType;

  LogicDevice(this.deviceType) { 
    
    inputs = new List<DeviceInput>();
    outputs = new List<DeviceOutput>();
    subLogic = new List<Logic>();
    images = new List<OffsetImage>();
    
    //Configure IO for this new device from a DeviceType
    for (DevicePin devicePin in deviceType.inputPins) {
      inputs.add(new DeviceInput(this, devicePin.id, devicePin));
    }
    
    for (DevicePin devicePin in deviceType.outputPins) {
      outputs.add(new DeviceOutput(this, devicePin.id, devicePin));
    }
    
    for (ImageMap outImage in deviceType.outputImages) {
      for (DeviceOutput output in outputs) {
        if (output.id == outImage.id) {
          output.imageMap = outImage;
        }
      }
    }
    
    for (ImageMap inImage in deviceType.inputImages) {
      for (DeviceInput input in inputs) {
        if (input.id == inImage.id) {
          input.imageMap = inImage;
        }
      }
    }
    
    for (OutputMap outMap in deviceType.outputMaps) {
      for (DeviceOutput output in outputs) {
        if (output.id == outMap.id) {
          output.outputMap = outMap;
          hasOutputMaps = true;
        }
      }
    }
    
    for (InputMap inMap in deviceType.inputMaps) {
      for (DeviceInput input in inputs) {
        if (input.id == inMap.id) {
          input.inputMap = inMap;
          hasInputMaps = true;
        }
      }
    }
    
    position = new CanvasPoint(0,0);
    visible = true;
    selectable = true;
    
    loadSublogic();
    buildImageList();
  }
  
  /** Build the stack of images to render for device */
  void buildImageList() {
    images.clear();
    
    if (deviceType.baseImage != null) {
      images.add(deviceType.baseImage);  
    }
    
    for (DeviceInput input in inputs) {
      if (input.mappedImage != null) {
          images.add(input.mappedImage);
      }
    }  
    
    for (DeviceOutput output in outputs) {
      if (output.mappedImage != null) {
          images.add(output.mappedImage);
      }
    }
  }
  
  /** Check to see if there are any sounds that need to be triggered */
  void checkSoundEvents() {
//    
//    for (DeviceInput input in inputs) {
//      if (input.inputMap != null) {
//        if (input.inputMap.type == 'SOUND') { 
//          if (input.value == true) {
//            if (!input.triggered) {
//              input
//            }
//          }
//          
//        }
//      }
//    }   
    
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
        outputs[0].value = !outputs[0].value; 
        updated = true; 
        break;
      case 'SWITCH': 
        outputs[0].value = !outputs[0].value; 
        updated = true; 
        break;
    }
    buildImageList();
  }
  
  /** When the user presses key*/
  void keyDown(int keyCode) {
    for (DeviceOutput output in outputs) {
      if(output.outputMap != null) {
        if(output.outputMap.type == 'KEY') {
          if(output.outputMap.value ==  keyCode) {
            output.value = true;  
          }
        }
      }
    }  
    buildImageList();
  }
  
  /** When the user releases key */
  void keyUp(int keyCode) {
    for (DeviceOutput output in outputs) {
      if(output.outputMap != null) {
        if(output.outputMap.type == 'KEY') {
          if(output.outputMap.value ==  keyCode) {
            output.value = false;            
          }
        }
      }
    }
    buildImageList();
  }
  
  
  /** Returns true if the image has this point */
  bool contains(CanvasPoint p) {
    if ((p.x > position.x && p.x < position.x + deviceType.baseImage.image.width) && 
          (p.y > position.y && p.y < position.y + deviceType.baseImage.image.height)) {
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
      updated = false;
      
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
        if(input.updated) {
          updated = true;
          break;
        }
      }
      
      for(DeviceOutput output in outputs) {
        if(output.previous_value != output.value) {
          updated = true;
          break;
        }
      }
      
      if(updated) {
        buildImageList();
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
    
    //print("addGate(${gateType}, ${inGate1}, ${inGate2})");
    
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