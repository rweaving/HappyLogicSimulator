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


#library('logic_device_type');
#import('offset_image.dart');
#import('device_pin.dart');
#import('device_map.dart');
#import('dart:html');

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

//  /** Add a sublogic(base) gate to the device type */
//  void addSubLogicGate2(int id, var gateType, int connection1, int connection2) {
//    subLogicGates.add(new SubLogicGate(id, gateType, connection1, connection2));
//  }
  
//  /** Add a sublogic gate to the device type */
//  void addSubLogic(var id, var gateType) {
//    subLogicGates.add(new SubLogicGate(id, gateType, -1, -1));
//  }
  
//  /** Connect our sublogic gate up */
//  void connectSubLogic(var gateID, int pin, var outID) {
//    for(SubLogicGate gate in subLogicGates) {
//      if (gate.id == gateID) {
//        if (pin == 0) {
//          print("${gate.gateType} ${gate.id}.0 to ${outID}");
//          gate.connection1 = outID;
//        }
//        else if (pin == 1) {
//          print("${gate.gateType} ${gate.id}.1 to ${outID}");
//          gate.connection2 = outID;
//        }
//      }
//    }
//  }
