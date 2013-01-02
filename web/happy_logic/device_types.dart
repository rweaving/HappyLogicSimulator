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
  
  OffsetImage baseImage;
  OffsetImage iconImage;
  OffsetImage disabledImage;
  OffsetImage selectedImage;
  
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
  void addInput(var id, int x, int y) {
    inputPins.add(new DevicePin(id, x, y));
  }
  
  void addOutput(var id, int x, int y) {
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
  void addInputImage(var inputID, var lowImage, var highImage, int offsetX, int offsetY) {
    inputImages.add(new ImageMap(inputID, lowImage, highImage, offsetX, offsetY));
  }
 
  /** These are images that are drawn based on an output value */
  void addOutputImage(var outputID, var lowImage, var highImage, int offsetX, int offsetY) {
    outputImages.add(new ImageMap(outputID, lowImage, highImage, offsetX, offsetY));
  }
  
  /** Add a sublogic(base) gate to the device type */
  void addSubLogicGate(var gateType, int connection1, int connection2) {
    subLogicGates.add(new SubLogicGate(gateType, connection1, connection2));
  }

  void setBaseImage(var imageSrc) {
    baseImage = new OffsetImage(imageSrc, 0, 0);
  }
  
  void setIconImage(var imageSrc) {
    iconImage = new OffsetImage(imageSrc, 0, 0);
  }
  
  void setDisabledImage(var imageSrc) {
    disabledImage = new OffsetImage(imageSrc, 0, 0);
  }
  
  void setSelectedImage(var imageSrc) {
    selectedImage = new OffsetImage(imageSrc, 0, 0);
  }

  int get ImageCount() => images.length;
}

class LogicDeviceTypes {
  
  List<LogicDeviceType> deviceTypes;
  
  LogicDeviceTypes() {
    deviceTypes = new List<LogicDeviceType>();
    loadDefaultTypes();
  }
  
  //Add a new device type
  LogicDeviceType addNewType(var type) {
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
  
  LogicDeviceType deviceFromJSON(var jsonString) {
    
    //print(jsonString);
    
    Map parsedMap = JSON.parse(jsonString);

    LogicDeviceType newType = addNewType(parsedMap["name"]);
    
    newType.setBaseImage(parsedMap["base"]);
    newType.setIconImage(parsedMap["icon"]);
    
    // Add Inputs
    for(int t=0; t<parsedMap["inputs"].length; t++) {
      int x = parsedMap["inputs"][t]["x"].toInt();
      int y = parsedMap["inputs"][t]["y"].toInt();
      var id = parsedMap["inputs"][t]["id"];
      newType.addInput(id, x, y);
    }
    
    // Add Outputs
    for(int t=0; t<parsedMap["outputs"].length; t++) {
        int x = parsedMap["outputs"][t]["x"].toInt();
        int y = parsedMap["outputs"][t]["y"].toInt();
        var id = parsedMap["outputs"][t]["id"];
        newType.addOutput(id, x, y);
    }
    
    // Add Sublogic
    for(int t=0; t<parsedMap["subdevices"].length; t++){
      int con1 = parsedMap["subdevices"][t]["c1"].toInt();
      int con2 = parsedMap["subdevices"][t]["c2"].toInt();
      var type = parsedMap["subdevices"][t]["type"];
      newType.addSubLogicGate(type, con1, con2);
    } 
    return newType;
  }
    
  loadDefaultTypes() {
    
    String _andJSON = """{"name":"AND",
      "base":"images/125dpi/and.png",
      "icon":"images/125dpi/and_d.png",
      "inputs":[
          {"y":12,"id":"0","x":2},
          {"y":32,"id":"1","x":2}],
      "outputs":[
          {"y":22,"id":"3","x":90}],
      "subdevices":[
          {"c2":0,"id":"0","type":"IN","c1":-1},
          {"c2":1,"id":"1","type":"IN","c1":-1},
          {"c2":1,"id":"2","type":"AND","c1":0},
          {"c2":0,"id":"3","type":"OUT","c1":2}]}""";
    
    String _nandJSON = """{"name":"NAND",
        "base":"images/125dpi/nand.png",
        "icon":"images/125dpi/nand_d.png",
        "inputs":[
            {"y":12,"id":"0","x":2},
            {"y":32,"id":"1","x":2}],
        "outputs":[
            {"y":22,"id":"3","x":90}],
        "subdevices":[
            {"c2":0,"id":"0","type":"IN","c1":-1},
            {"c2":1,"id":"1","type":"IN","c1":-1},
            {"c2":1,"id":"2","type":"NAND","c1":0},
            {"c2":0,"id":"3","type":"OUT","c1":2}]}""";
    
    String _notJSON = """{"name":"NOT",
        "base":"images/125dpi/not.png",
        "icon":"images/125dpi/not_d.png",
        "inputs":[
            {"y":24,"id":"1","x":2}],
        "outputs":[
            {"y":24,"id":"3","x":90}],
        "subdevices":[
            {"c2":0,"id":"0","type":"IN","c1":-1},
            {"c2":-1,"id":"1","type":"NOT","c1":0},
            {"c2":0,"id":"2","type":"OUT","c1":1}]}""";
    
    //String _tffJSON = """{"base":"images/125dpi/tff.png","icon":"images/125dpi/tff.png","outputs":[{"y":15,"id":9,"x":93},{"y":72,"id":10,"x":93}],"name":"TFF","subdevices":[{"c2":8,"id":0,"type":"NAND","c1":7},{"c2":6,"id":1,"type":"NAND","c1":8},{"c2":3,"id":2,"type":"NAND","c1":0},{"c2":1,"id":3,"type":"NAND","c1":2},{"c2":11,"id":4,"type":"NAND","c1":2},{"c2":3,"id":5,"type":"NAND","c1":11},{"c2":7,"id":6,"type":"NAND","c1":4},{"c2":5,"id":7,"type":"NAND","c1":6},{"c2":0,"id":8,"type":"IN","c1":-1},{"c2":0,"id":9,"type":"OUT","c1":6},{"c2":1,"id":10,"type":"OUT","c1":7},{"c2":-1,"id":11,"type":"NOT","c1":8}],"inputs":[{"y":44,"id":8,"x":2}]}""";
    
    
    String _tffJSON = """{"base":"images/125dpi/tff.png","icon":"images/125dpi/tff.png","outputs":[{"y":15,"id":"2","x":93},{"y":72,"id":"3","x":93}],"name":"TFF","subdevices":[{"c2":0,"id":"0","type":"IN","c1":-1},{"c2":-1,"id":"1","type":"NOT","c1":0},{"c2":0,"id":"2","type":"OUT","c1":10},{"c2":1,"id":"3","type":"OUT","c1":11},{"c2":0,"id":4,"type":"NAND","c1":11},{"c2":10,"id":5,"type":"NAND","c1":0},{"c2":7,"id":6,"type":"NAND","c1":4},{"c2":5,"id":7,"type":"NAND","c1":6},{"c2":6,"id":8,"type":"NAND","c1":1},{"c2":1,"id":9,"type":"NAND","c1":7},{"c2":11,"id":10,"type":"NAND","c1":8},{"c2":9,"id":11,"type":"NAND","c1":10}],"inputs":[{"y":44,"id":0,"x":2}]}""";
    
//    String _and3JSON = """{"name":"AND3",
//                          "base":"images/125dpi/and.png",
//                          "icon":"images/125dpi/and_d.png",
//                          "inputs":[
//                              {"y":0,"id":3,"x":0},
//                              {"y":10,"id":4,"x":0},
//                              {"y":20,"id":5,"x":0},
//                              {"y":30,"id":6,"x":0}],
//                          "outputs":[
//                              {"y":0,"id":7,"x":20}],
//                          "subdevices":[
//                              {"c2":4,"id":0,"type":"AND","c1":3},
//                              {"c2":6,"id":1,"type":"AND","c1":5},
//                              {"c2":1,"id":2,"type":"AND","c1":0},
//                              {"c2":0,"id":3,"type":"IN","c1":-1},
//                              {"c2":1,"id":4,"type":"IN","c1":-1},
//                              {"c2":2,"id":5,"type":"IN","c1":-1},
//                              {"c2":3,"id":6,"type":"IN","c1":-1},
//                              {"c2":0,"id":7,"type":"OUT","c1":2}]}""";
                             
    LogicDeviceType _and = deviceFromJSON(_andJSON);
    LogicDeviceType _nand = deviceFromJSON(_nandJSON);
    LogicDeviceType _not = deviceFromJSON(_notJSON);
    LogicDeviceType _tff = deviceFromJSON(_tffJSON);
    
    
   // String _and3JSON = """{"outputs":[{"yOffset":0,"outputID":0,"deviceID":5,"xOffset":20}],"subdeviceCount":6,"iconImage":"images/125dpi/and_d.png","outCount":1,"subdevices":[{"con2":0,"deviceID":0,"type":"IN","con1":-1},{"con2":1,"deviceID":1,"type":"IN","con1":-1},{"con2":2,"deviceID":2,"type":"IN","con1":-1},{"con2":1,"deviceID":3,"type":"AND","con1":0},{"con2":2,"deviceID":4,"type":"AND","con1":3},{"con2":0,"deviceID":5,"type":"OUT","con1":4}],"inCount":3,"type":"AND3","inputs":[{"yOffset":0,"inputID":0,"deviceID":0,"xOffset":0},{"yOffset":10,"inputID":1,"deviceID":1,"xOffset":0},{"yOffset":20,"inputID":2,"deviceID":2,"xOffset":0}],"baseImage":"images/125dpi/and.png"}""";

    //LogicDeviceType _and3 = deviceFromJSON(_and3JSON);
        
//    LogicDeviceType _not = addNewType('NOT');
//    _not.setBaseImage("images/125dpi/not.png");
//    _not.setIconImage("images/125dpi/not_d.png");
//    _not.addInput(0, 2, 24);
//    _not.addOutput(0, 90, 24);
//    _not.addSubLogicGate('NOT',   1, -1); // 0
//    _not.addSubLogicGate('IN',   -1,  0); // 1 
//    _not.addSubLogicGate('OUT',   0,  0); // 2 
    
//    LogicDeviceType _and = addNewType('AND');
//    _and.setBaseImage('images/125dpi/and.png');
//    _and.setIconImage('images/125dpi/and_d.png');
//    _and.addInput(0, 2, 12);
//    _and.addInput(1, 2, 32);
//    _and.addOutput(0, 90, 22); 
//    _and.addSubLogicGate('AND',   1, 2); // 0
//    _and.addSubLogicGate('IN',   -1, 0); // 1 
//    _and.addSubLogicGate('IN',   -1, 1); // 2 
//    _and.addSubLogicGate('OUT',   0, 0); // 3 
    
//    LogicDeviceType _nand = addNewType('NAND');
//    _nand.setBaseImage('images/125dpi/nand.png');
//    _nand.setIconImage('images/125dpi/nand_d.png');
//    _nand.addInput(0, 2, 12);
//    _nand.addInput(1, 2, 32);
//    _nand.addOutput(0, 90, 22);  
//    _nand.addSubLogicGate('NAND',  1, 2); // 0
//    _nand.addSubLogicGate('IN',   -1, 0); // 1 
//    _nand.addSubLogicGate('IN',   -1, 1); // 2 
//    _nand.addSubLogicGate('OUT',   0, 0); // 3 

    LogicDeviceType _input = addNewType('INPUT');
    _input.setBaseImage('images/125dpi/input_low.png');
    _input.setIconImage('images/125dpi/input_low.png');
    _input.addOutputImage(0, 'images/125dpi/input_low.png', "images/125dpi/input_high.png",0,0);
    _input.addOutput('0', 68, 22);
    _input.updateable = true;
    
    LogicDeviceType _output = addNewType('OUTPUT');
    _output.setBaseImage("images/125dpi/output_low.png");
    _output.setIconImage("images/125dpi/output_low.png");
    _output.addOutputImage(0, null, "images/125dpi/output_high.png",0,0);
    _output.addInput('0', 2, 22);
    _output.addOutput('0', -1, -1);
    _output.updateable = true;
    _output.addSubLogicGate('IN',  -1, 0); // 0 
    _output.addSubLogicGate('OUT',  0, 0); // 1 
    
//    LogicDeviceType _clock = addNewType('CLOCK');
//    _clock.setBaseImage("images/125dpi/clock_low.png");
//    _clock.setIconImage("images/125dpi/clock_low.png");
//    _clock.addOutputImage(0, null, "images/125dpi/clock_high.png",0,0);
//    _clock.addInput(0, -1, -1);
//    _clock.addOutput(0, 68, 22);
//    _clock.updateable = true;
//    _clock.addSubLogicGate('CLOCK', -1, -1); // 0
//    _clock.addSubLogicGate('OUT',    0,  0); // 1
//    
//    LogicDeviceType _or = addNewType('OR');
//    _or.setBaseImage("images/125dpi/or.png");
//    _or.setIconImage("images/125dpi/or_d.png");
//    _or.addInput(0, 2, 12);
//    _or.addInput(1, 2, 32);
//    _or.addOutput(0, 90, 22);
//    _or.addSubLogicGate('OR',    1, 2); // 0
//    _or.addSubLogicGate('IN',   -1, 0); // 1 
//    _or.addSubLogicGate('IN',   -1, 1); // 2 
//    _or.addSubLogicGate('OUT',   0, 0); // 3 
//
//    LogicDeviceType _nor = addNewType('NOR');
//    _nor.setBaseImage("images/125dpi/nor.png");
//    _nor.setIconImage("images/125dpi/nor_d.png");
//    _nor.addInput(0, 2, 12);
//    _nor.addInput(1, 2, 32);
//    _nor.addOutput(0, 90, 22);
//    _nor.addSubLogicGate('NOR',   1, 2); // 0
//    _nor.addSubLogicGate('IN',   -1, 0); // 1 
//    _nor.addSubLogicGate('IN',   -1, 1); // 2 
//    _nor.addSubLogicGate('OUT',   0, 0); // 3 
//    
//    LogicDeviceType _xor = addNewType('XOR');
//    _xor.setBaseImage("images/125dpi/xor.png");
//    _xor.setIconImage("images/125dpi/xor_d.png");
//    _xor.addInput(0, 2, 12);
//    _xor.addInput(1, 2, 32);
//    _xor.addOutput(0, 90, 22);
//    _xor.addSubLogicGate('XOR',   1, 2); // 0
//    _xor.addSubLogicGate('IN',   -1, 0); // 1 
//    _xor.addSubLogicGate('IN',   -1, 1); // 2 
//    _xor.addSubLogicGate('OUT',   0, 0); // 3 
//    
//    LogicDeviceType _xnor = addNewType('XNOR');
//    _xnor.setBaseImage("images/125dpi/xnor.png");
//    _xnor.setIconImage("images/125dpi/xnor_d.png");
//    _xnor.addInput(0, 2, 12);
//    _xnor.addInput(1, 2, 32);
//    _xnor.addOutput(0, 90, 22);
//    _xnor.addSubLogicGate('XNOR',  1, 2); // 0
//    _xnor.addSubLogicGate('IN',   -1, 0); // 1 
//    _xnor.addSubLogicGate('IN',   -1, 1); // 2 
//    _xnor.addSubLogicGate('OUT',   0, 0); // 3 
//    

//    
//    LogicDeviceType _tff = addNewType('TFF');
//    _tff.setBaseImage("images/125dpi/tff.png");
//    _tff.setIconImage("images/125dpi/tff.png");
//    _tff.addInput(0, 2, 44);
//    _tff.addOutput(0, 93, 15);
//    _tff.addOutput(1, 93, 72);
//    _tff.addSubLogicGate('NOT',  9, 9);  // 0   Buid the device logic
//    _tff.addSubLogicGate('NAND', 9, 8);  // 1   This defines the internal
//    _tff.addSubLogicGate('NAND', 9, 7);  // 2   connections that make up 
//    _tff.addSubLogicGate('NAND', 1, 4);  // 3   a logic device
//    _tff.addSubLogicGate('NAND', 2, 3);  // 4
//    _tff.addSubLogicGate('NAND', 3, 0);  // 5
//    _tff.addSubLogicGate('NAND', 4, 0);  // 6
//    _tff.addSubLogicGate('NAND', 5, 8);  // 7 
//    _tff.addSubLogicGate('NAND', 6, 7);  // 8 
//    _tff.addSubLogicGate('IN',  -1, 0);  // 9   T
//    _tff.addSubLogicGate('OUT',  7, 0);  // 10  Q
//    _tff.addSubLogicGate('OUT',  8, 1);  // 11  !Q
//    
//    LogicDeviceType _clkedRS = addNewType('CLOCKED_RSFF');
//    _clkedRS.setBaseImage("images/125dpi/tff.png");
//    _clkedRS.setIconImage("images/125dpi/tff.png");
//    _clkedRS.addInput(0, 2, 22);
//    _clkedRS.addInput(1, 2, 44);
//    _clkedRS.addInput(2, 2, 66);
//    _clkedRS.addOutput(0, 93, 15);
//    _clkedRS.addSubLogicGate('NAND', 4, 5);  // 0
//    _clkedRS.addSubLogicGate('NAND', 6, 5);  // 1
//    _clkedRS.addSubLogicGate('NAND', 0, 3);  // 2
//    _clkedRS.addSubLogicGate('NAND', 1, 2);  // 3 
//    _clkedRS.addSubLogicGate('IN',  -1, 0);  // 4  Set
//    _clkedRS.addSubLogicGate('IN',  -1, 1);  // 5  Clock
//    _clkedRS.addSubLogicGate('IN',  -1, 2);  // 6  Reset
//    _clkedRS.addSubLogicGate('OUT',  2, 0);  // 7  Q
//
//    LogicDeviceType _makey = addNewType('MAKEY');
//    _makey.setBaseImage("images/makey/makey_base.png");
//    _makey.setIconImage("images/makey/makey_icon.png");
//    _makey.addOutput(0, 35, 78);
//    _makey.addOutput(1, 177, 78);
//    _makey.addOutput(2, 106, 7);
//    _makey.addOutput(3, 106, 149);
//    _makey.addOutput(4, 238, 37);
//    _makey.addOutput(5, 313, 37);
//    _makey.mapOutput(0, 'KEY', 37); // Left
//    _makey.mapOutput(1, 'KEY', 39); // Right
//    _makey.mapOutput(2, 'KEY', 38); // Up
//    _makey.mapOutput(3, 'KEY', 40); // Down
//    _makey.mapOutput(4, 'KEY', 32); // Space
//    _makey.mapOutput(5, 'MOUSE', 'LEFTCLICK');
//    _makey.addOutputImage(0, null, "images/makey/makey_left.png",0,0);
//    _makey.addOutputImage(1, null, "images/makey/makey_right.png",0,0);
//    _makey.addOutputImage(2, null, "images/makey/makey_up.png",0,0);
//    _makey.addOutputImage(3, null, "images/makey/makey_down.png",0,0);
//    _makey.addOutputImage(4, null, "images/makey/makey_space.png",0,0);
//    _makey.addOutputImage(5, null, "images/makey/makey_mouse.png",0,0);
//    
//    LogicDeviceType _arrowpad = addNewType('ARROWPAD');
//    _arrowpad.setBaseImage("images/arrowpad/arrow_pad.png");
//    _arrowpad.setIconImage("images/arrowpad/arrow_pad.png");
//    _arrowpad.addOutput(0, 1, 91);
//    _arrowpad.addOutput(1, 181, 91);
//    _arrowpad.addOutput(2, 91, 1);
//    _arrowpad.addOutput(3, 91, 181);
//    _arrowpad.mapOutput(0, 'KEY', 37); // Left
//    _arrowpad.mapOutput(1, 'KEY', 39); // Right
//    _arrowpad.mapOutput(2, 'KEY', 38); // Up
//    _arrowpad.mapOutput(3, 'KEY', 40); // Down
//    _arrowpad.addOutputImage(0, "images/arrowpad/arrow_left_low.png", "images/arrowpad/arrow_left_high.png", 18, 71);
//    _arrowpad.addOutputImage(1, "images/arrowpad/arrow_right_low.png", "images/arrowpad/arrow_right_high.png", 109, 71);
//    _arrowpad.addOutputImage(2, "images/arrowpad/arrow_up_low.png", "images/arrowpad/arrow_up_high.png", 72, 18);
//    _arrowpad.addOutputImage(3, "images/arrowpad/arrow_down_low.png", "images/arrowpad/arrow_down_high.png", 73, 108);
//    
//    LogicDeviceType _soundtrigger1 = addNewType('SOUNDTRIGGER_4BIT');
//    _soundtrigger1.setBaseImage("images/soundtrigger/soundtrigger_4bit.png");
//    _soundtrigger1.setIconImage("images/soundtrigger/soundtrigger_4bit.png");
//    _soundtrigger1.addInput(0, 1, 11);
//    _soundtrigger1.addInput(1, 1, 31);
//    _soundtrigger1.addInput(2, 1, 51);
//    _soundtrigger1.addInput(3, 1, 71);
//    _soundtrigger1.addOutput(0, -1, -1);
//    _soundtrigger1.addOutput(1, -1, -1);
//    _soundtrigger1.addOutput(2, -1, -1);
//    _soundtrigger1.addOutput(3, -1, -1);
//    _soundtrigger1.addOutputImage(0, null, "images/soundtrigger/sound_high.png",16,3);
//    _soundtrigger1.addOutputImage(1, null, "images/soundtrigger/sound_high.png",16,23);
//    _soundtrigger1.addOutputImage(2, null, "images/soundtrigger/sound_high.png",16,43);
//    _soundtrigger1.addOutputImage(3, null, "images/soundtrigger/sound_high.png",16,63);
//    _soundtrigger1.mapInput(0, 'SOUND', 'sounds/beep1000.wav');
//    _soundtrigger1.mapInput(1, 'SOUND', 'sounds/drip1.wav');
//    _soundtrigger1.mapInput(2, 'SOUND', 'sounds/drip1.wav');
//    _soundtrigger1.mapInput(3, 'SOUND', 'sounds/poke-pikachuhappy.ogg');
//    _soundtrigger1.addSubLogicGate('IN',  -1, 0); // 0 
//    _soundtrigger1.addSubLogicGate('IN',  -1, 1); // 1 
//    _soundtrigger1.addSubLogicGate('IN',  -1, 2); // 2 
//    _soundtrigger1.addSubLogicGate('IN',  -1, 3); // 3 
//    _soundtrigger1.addSubLogicGate('OUT',  0, 0); // 4 
//    _soundtrigger1.addSubLogicGate('OUT',  1, 1); // 5 
//    _soundtrigger1.addSubLogicGate('OUT',  2, 2); // 6 
//    _soundtrigger1.addSubLogicGate('OUT',  3, 3); // 7 
//    _soundtrigger1.updateable = true;
       
  }
}
