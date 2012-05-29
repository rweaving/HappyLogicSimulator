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

class SubLogicGate {
  var gateType;
  int connection1 = -1;
  int connection2 = -1;
  int external = -1;
  
  SubLogicGate(this.gateType, this.connection1, this.connection2){}
}

/** Used to map external events to device outputs i.g. KeyPress */
class OutputMap {
  var id;
  var type;
  var value;
  
  OutputMap(this.id, this.type, this.value) {}
}

/** Used to map internal inputs to events i.g. sounds */
class InputMap {
  var id;
  var type;
  var value;
  
  InputMap(this.id, this.type, this.value) {}
}

/** Used to map internal inputs to displayable events i.g. image updates*/
class ImageMap {
  var id;
  var type;
  ImageElement highImage;
  ImageElement lowImage;
  
  ImageMap(this.id, var mapLowImage, var mapHighImage) { 
    if (mapLowImage != null) {
      lowImage = new Element.tag('img'); 
      lowImage.src = mapLowImage;
    }
    
    if (mapHighImage != null) {
      highImage = new Element.tag('img'); 
      highImage.src = mapHighImage;
    }
  }
}

class LogicDeviceType {
  var type;
  bool updateable = false;
  bool hasOutputMaps = false;
  bool hasInputMaps = false;
  
  List<ImageElement> images;
  List<DevicePin> inputPins;
  List<DevicePin> outputPins;
  List<SubLogicGate> subLogicGates;
  List<OutputMap> outputMaps;
  List<InputMap> inputMaps;
  List<ImageMap> inputImages;
  List<ImageMap> outputImages;
  
  ImageElement baseImage;
  ImageElement iconImage;
  ImageElement disabledImage;
  ImageElement selectedImage;
  
  
  LogicDeviceType(this.type) {
    images = new List<ImageElement>();
    inputPins = new List<DevicePin>();
    outputPins = new List<DevicePin>();
    subLogicGates = new List<SubLogicGate>();
    outputMaps = new List<OutputMap>();
    inputMaps = new List<InputMap>();
    inputImages = new List<ImageMap>();
    outputImages = new List<ImageMap>();
  }
  
  int get inputCount() => inputPins.length;
  int get outputCount() => outputPins.length;
  int get gateCount() => subLogicGates.length;
   
  // The x and y are in relation to the image
  /** Add an input to this type */
  void AddInput(var id, int x, int y) {
    inputPins.add(new DevicePin(id, x, y));
  }
  
  void AddOutput(var id, int x, int y) {
    outputPins.add(new DevicePin(id, x, y));
  }
  
  /** Mapping an output allows triggering from external events e.g KeyPress */
  void mapOutput(var mapId, var mapType, var mapValue) {
    outputMaps.add(new OutputMap(mapId, mapType, mapValue));
    hasOutputMaps = true;
  }
  
  /** Mapping an output allows triggering from external events e.g KeyPress */
  void mapInput(var mapId, var mapType, var mapValue) {
    inputMaps.add(new InputMap(mapId, mapType, mapValue));
    hasInputMaps = true;
  }
  
  /** These are images that are drawn based on an input value */
  void addInputImage(var inputID, var lowImage, var highImage) {
    inputImages.add(new ImageMap(inputID, lowImage, highImage));
  }
 
  /** These are images that are drawn based on an output value */
  void addOutputImage(var outputID, var lowImage, var highImage) {
    outputImages.add(new ImageMap(outputID, lowImage, highImage));
  }
  
  
  /** Add a sublogic(base) gate to the device type */
  void addSubLogicGate(var gateType, int connection1, int connection2) {
    subLogicGates.add(new SubLogicGate(gateType, connection1, connection2));
  }
  
  void setBaseImage(var imageSrc) {
    baseImage = new Element.tag('img'); 
    baseImage.src = imageSrc;
  }
  
  void setIconImage(var imageSrc) {
    iconImage = new Element.tag('img'); 
    iconImage.src = imageSrc;
  }
  
  void setDisabledImage(var imageSrc) {
    disabledImage = new Element.tag('img'); 
    disabledImage.src = imageSrc;
  }
  
  void setSelectedImage(var imageSrc) {
    selectedImage = new Element.tag('img'); 
    selectedImage.src = imageSrc;
  }
//  
//  void AddImage(var imageSrc) {
//    ImageElement _elem;
//    _elem = new Element.tag('img'); 
//    _elem.src = imageSrc;
//    images.add(_elem);  
//  }
//  
  int get ImageCount() => images.length;
  
  // TODO: create output to image mappings
  ImageElement getImage(var state) {
    if(images.length == 1) 
      return images[0];
    
    switch(state){
      case 0: return images[0];
      case 1: return images[1];
      case false: return images[0];
      case true:  return images[1];
      }
  }
}

class LogicDeviceTypes {
  List<LogicDeviceType> deviceTypes;
  
  LogicDeviceTypes() {
    deviceTypes = new List<LogicDeviceType>();
    LoadDefaultTypes();
  }
  
  //Add a new device type
  LogicDeviceType AddNewType(var type) {
    LogicDeviceType newType = new LogicDeviceType(type);
    deviceTypes.add(newType);
    return newType;
  }
    
  //Get a specifided device type
  LogicDeviceType getDeviceType(var type) {
    for(LogicDeviceType deviceType in deviceTypes)
      if(deviceType.type == type)
        return deviceType;
    
    return null;
  }
  
  //TODO: move all of this to xml
  LoadDefaultTypes() {
    
    LogicDeviceType _and = AddNewType('AND');
    _and.setBaseImage('images/125dpi/and.png');
    _and.setIconImage('images/125dpi/and_d.png');
    _and.AddInput(0, 2, 12);
    _and.AddInput(1, 2, 32);
    _and.AddOutput(0, 90, 22); 
    _and.addSubLogicGate('AND',   1, 2); // 0
    _and.addSubLogicGate('IN',   -1, 0); // 1 
    _and.addSubLogicGate('IN',   -1, 1); // 2 
    _and.addSubLogicGate('OUT',   0, 0); // 3 
    
    LogicDeviceType _nand = AddNewType('NAND');
    _nand.setBaseImage('images/125dpi/nand.png');
    _nand.setIconImage('images/125dpi/nand_d.png');
    _nand.AddInput(0, 2, 12);
    _nand.AddInput(1, 2, 32);
    _nand.AddOutput(0, 90, 22);  
    _nand.addSubLogicGate('NAND',  1, 2); // 0
    _nand.addSubLogicGate('IN',   -1, 0); // 1 
    _nand.addSubLogicGate('IN',   -1, 1); // 2 
    _nand.addSubLogicGate('OUT',   0, 0); // 3 

    LogicDeviceType _input = AddNewType('INPUT');
    _input.setBaseImage("images/125dpi/input_low.png");
    _input.setIconImage('images/125dpi/input_low.png');

    _input.addInputImage(0, null, "images/125dpi/input_high.png");
    _input.AddInput(0, -1, -1);
    _input.AddOutput(0, 68, 22);
    _input.updateable = true;
    
    LogicDeviceType _output = AddNewType('OUTPUT');
    _output.setBaseImage("images/125dpi/output_low.png");
    _output.setIconImage("images/125dpi/output_low.png");

    _output.addOutputImage(0, null, "images/125dpi/output_high.png");
    _output.AddInput(0, 2, 22);
    _output.AddOutput(0, -1, -1);
    _output.updateable = true;
    _output.addSubLogicGate('IN',  -1, 0); // 0 
    _output.addSubLogicGate('OUT',  0, 0); // 1 
    
    LogicDeviceType _clock = AddNewType('CLOCK');
    _clock.setBaseImage("images/125dpi/clock_low.png");
    _clock.setIconImage("images/125dpi/clock_low.png");
    _clock.addOutputImage(0, null, "images/125dpi/clock_high.png");
    _clock.AddInput(0, -1, -1);
    _clock.AddOutput(0, 68, 22);
    _clock.updateable = true;
    _clock.addSubLogicGate('CLOCK', -1, -1); // 0
    _clock.addSubLogicGate('OUT',    0,  0); // 1
    
    LogicDeviceType _or = AddNewType('OR');
    _or.setBaseImage("images/125dpi/or.png");
    _or.setIconImage("images/125dpi/or_d.png");
    _or.AddInput(0, 2, 12);
    _or.AddInput(1, 2, 32);
    _or.AddOutput(0, 90, 22);
    _or.addSubLogicGate('OR',    1, 2); // 0
    _or.addSubLogicGate('IN',   -1, 0); // 1 
    _or.addSubLogicGate('IN',   -1, 1); // 2 
    _or.addSubLogicGate('OUT',   0, 0); // 3 

    LogicDeviceType _nor = AddNewType('NOR');
    _nor.setBaseImage("images/125dpi/nor.png");
    _nor.setIconImage("images/125dpi/nor_d.png");
    _nor.AddInput(0, 2, 12);
    _nor.AddInput(1, 2, 32);
    _nor.AddOutput(0, 90, 22);
    _nor.addSubLogicGate('NOR',   1, 2); // 0
    _nor.addSubLogicGate('IN',   -1, 0); // 1 
    _nor.addSubLogicGate('IN',   -1, 1); // 2 
    _nor.addSubLogicGate('OUT',   0, 0); // 3 
    
    LogicDeviceType _xor = AddNewType('XOR');
    _xor.setBaseImage("images/125dpi/xor.png");
    _xor.setIconImage("images/125dpi/xor_d.png");
    _xor.AddInput(0, 2, 12);
    _xor.AddInput(1, 2, 32);
    _xor.AddOutput(0, 90, 22);
    _xor.addSubLogicGate('XOR',   1, 2); // 0
    _xor.addSubLogicGate('IN',   -1, 0); // 1 
    _xor.addSubLogicGate('IN',   -1, 1); // 2 
    _xor.addSubLogicGate('OUT',   0, 0); // 3 
    
    LogicDeviceType _xnor = AddNewType('XNOR');
    _xnor.setBaseImage("images/125dpi/xnor.png");
    _xnor.setIconImage("images/125dpi/xnor_d.png");
    _xnor.AddInput(0, 2, 12);
    _xnor.AddInput(1, 2, 32);
    _xnor.AddOutput(0, 90, 22);
    _xnor.addSubLogicGate('XNOR',  1, 2); // 0
    _xnor.addSubLogicGate('IN',   -1, 0); // 1 
    _xnor.addSubLogicGate('IN',   -1, 1); // 2 
    _xnor.addSubLogicGate('OUT',   0, 0); // 3 
    
    LogicDeviceType _not = AddNewType('NOT');
    _not.setBaseImage("images/125dpi/not.png");
    _not.setIconImage("images/125dpi/not_d.png");
    _not.AddInput(0, 2, 24);
    _not.AddOutput(0, 90, 24);
    _not.addSubLogicGate('NOT',   1, -1); // 0
    _not.addSubLogicGate('IN',   -1,  0); // 1 
    _not.addSubLogicGate('OUT',   0,  0); // 2 
    
    LogicDeviceType _tff = AddNewType('TFF');
    _tff.setBaseImage("images/125dpi/tff.png");
    _tff.setIconImage("images/125dpi/tff.png");
    _tff.AddInput(0, 2, 44);
    _tff.AddOutput(0, 93, 15);
    _tff.AddOutput(1, 93, 72);
    _tff.addSubLogicGate('NOT',  9, 9);  // 0   Buid the device logic
    _tff.addSubLogicGate('NAND', 9, 8);  // 1   This defines the internal
    _tff.addSubLogicGate('NAND', 9, 7);  // 2   connections that make up 
    _tff.addSubLogicGate('NAND', 1, 4);  // 3   a logic device
    _tff.addSubLogicGate('NAND', 2, 3);  // 4
    _tff.addSubLogicGate('NAND', 3, 0);  // 5
    _tff.addSubLogicGate('NAND', 4, 0);  // 6
    _tff.addSubLogicGate('NAND', 5, 8);  // 7 
    _tff.addSubLogicGate('NAND', 6, 7);  // 8 
    _tff.addSubLogicGate('IN',  -1, 0);  // 9   T
    _tff.addSubLogicGate('OUT',  7, 0);  // 10  Q
    _tff.addSubLogicGate('OUT',  8, 1);  // 11  !Q
    
    LogicDeviceType _clkedRS = AddNewType('CLOCKED_RSFF');
    _clkedRS.setBaseImage("images/125dpi/tff.png");
    _clkedRS.setIconImage("images/125dpi/tff.png");
    _clkedRS.AddInput(0, 2, 22);
    _clkedRS.AddInput(1, 2, 44);
    _clkedRS.AddInput(2, 2, 66);
    _clkedRS.AddOutput(0, 93, 15);
    _clkedRS.addSubLogicGate('NAND', 4, 5);  // 0
    _clkedRS.addSubLogicGate('NAND', 6, 5);  // 1
    _clkedRS.addSubLogicGate('NAND', 0, 3);  // 2
    _clkedRS.addSubLogicGate('NAND', 1, 2);  // 3 
    _clkedRS.addSubLogicGate('IN',  -1, 0);  // 4  Set
    _clkedRS.addSubLogicGate('IN',  -1, 1);  // 5  Clock
    _clkedRS.addSubLogicGate('IN',  -1, 2);  // 6  Reset
    _clkedRS.addSubLogicGate('OUT',  2, 0);  // 7  Q

    LogicDeviceType _makey = AddNewType('MAKEY');
    _makey.setBaseImage("images/makey/makey_base.png");
    _makey.setIconImage("images/makey/makey_icon.png");
    _makey.AddOutput(0, 35, 78);
    _makey.AddOutput(1, 177, 78);
    _makey.AddOutput(2, 106, 7);
    _makey.AddOutput(3, 106, 149);
    _makey.AddOutput(4, 238, 37);
    _makey.AddOutput(5, 313, 37);
    _makey.AddInput(0, -1, -1);
    _makey.AddInput(1, -1, -1);
    _makey.AddInput(2, -1, -1);
    _makey.AddInput(3, -1, -1);
    _makey.AddInput(4, -1, -1);
    _makey.AddInput(5, -1, -1);
    _makey.mapOutput(0, 'KEY', 37); // Left
    _makey.mapOutput(1, 'KEY', 39); // Right
    _makey.mapOutput(2, 'KEY', 38); // Up
    _makey.mapOutput(3, 'KEY', 40); // Down
    _makey.mapOutput(4, 'KEY', 32); // Space
    _makey.mapOutput(5, 'MOUSE', 'LEFTCLICK');
    _makey.addOutputImage(0, null, "images/makey/makey_left.png");
    _makey.addOutputImage(1, null, "images/makey/makey_right.png");
    _makey.addOutputImage(2, null, "images/makey/makey_up.png");
    _makey.addOutputImage(3, null, "images/makey/makey_down.png");
    _makey.addOutputImage(4, null, "images/makey/makey_space.png");
    _makey.addOutputImage(5, null, "images/makey/makey_mouse.png");
    
    
    
    
  }
}
