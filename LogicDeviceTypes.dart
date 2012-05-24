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

class LogicDeviceType{
  var type;
  bool updateable = false;
  
  List<ImageElement> images;
  List<DevicePin> inputPins;
  List<DevicePin> outputPins;

  LogicDeviceType(this.type){
    images = new List<ImageElement>();
    inputPins = new List<DevicePin>();
    outputPins = new List<DevicePin>();
  }
  
  int get InputCount() => inputPins.length;
  int get OutputCount() => outputPins.length;
   
  // The x and y are in relation to the image
  void AddInput(var id, int x, int y){
    inputPins.add(new DevicePin(id, x, y));
  }
  void AddOutput(var id, int x, int y){
    outputPins.add(new DevicePin(id, x, y));
  }
  
  void AddImage(var imageSrc){
    ImageElement _elem;
    _elem = new Element.tag('img'); 
    _elem.src = imageSrc;
    images.add(_elem);  
  }
  
  int get ImageCount() => images.length;
  
  // TODO: create output to image mappings
  ImageElement getImage(var state){
    if(images.length == 1) 
      return images[0];
    
    switch(state){
      case 0: return images[0];
      case 1: return images[1];
      
      case true: return images[1];
      case false: return images[0];
      }
  }
}

class LogicDeviceTypes{
  List<LogicDeviceType> deviceTypes;
  
  LogicDeviceTypes(){
    deviceTypes = new List<LogicDeviceType>();
    LoadDefaultTypes();
  }
  
  //Add a new device type
  LogicDeviceType AddNewType(var type){
    LogicDeviceType newType = new LogicDeviceType(type);
    deviceTypes.add(newType);
    return newType;
  }
    
  //Get a specifided device type
  LogicDeviceType getDeviceType(var type){
    for(LogicDeviceType deviceType in deviceTypes)
      if(deviceType.type == type)
        return deviceType;
    
    return null;
  }
  
  //TODO: move all of this to xml
  LoadDefaultTypes(){
    LogicDeviceType _and = AddNewType('AND');
    _and.AddImage('images/125dpi/and.png');
    _and.AddInput(0, 2, 12);
    _and.AddInput(1, 2, 32);
    _and.AddOutput(0, 90, 22);  
    
    LogicDeviceType _nand = AddNewType('NAND');
    _nand.AddImage('images/125dpi/nand.png');
    _nand.AddInput(0, 2, 12);
    _nand.AddInput(1, 2, 32);
    _nand.AddOutput(0, 90, 22);  
//    
//    LogicDeviceType _switch = AddNewType('SWITCH');
//    _switch.AddImage("images/01Switch_Low.png");
//    _switch.AddImage("images/01Switch_High.png");
//    _switch.AddInput(0, -1, -1);
//    _switch.AddOutput(0, 21, 0);
//    _switch.updateable = true;
    
    LogicDeviceType _input = AddNewType('INPUT');
    _input.AddImage("images/125dpi/input_low.png");
    _input.AddImage("images/125dpi/input_high.png");
    _input.AddInput(0, -1, -1);
    _input.AddOutput(0, 68, 22);
    _input.updateable = true;
    
    LogicDeviceType _output = AddNewType('OUTPUT');
    _output.AddImage("images/125dpi/output_low.png");
    _output.AddImage("images/125dpi/output_high.png");
    _output.AddInput(0, 2, 22);
    _output.AddOutput(0, -1, -1);
    _output.updateable = true;
    
    LogicDeviceType _clock = AddNewType('CLOCK');
    _clock.AddImage("images/125dpi/clock_low.png");
    _clock.AddImage("images/125dpi/clock_high.png");
    _clock.AddInput(0, -1, -1);
    _clock.AddOutput(0, 68, 22);
    _clock.updateable = true;
//    
//    LogicDeviceType _led = AddNewType('LED');
//    _led.AddImage("images/01Disp_Low.png");
//    _led.AddImage("images/01Disp_High.png");
//    _led.AddInput(0, 20, 12);
//    _led.AddOutput(0, -1, -1);
//    _led.updateable = true;
    
    LogicDeviceType _or = AddNewType('OR');
    _or.AddImage("images/125dpi/or.png");
    _or.AddInput(0, 2, 12);
    _or.AddInput(1, 2, 32);
    _or.AddOutput(0, 90, 22);

    LogicDeviceType _nor = AddNewType('NOR');
    _nor.AddImage("images/125dpi/nor.png");
    _nor.AddInput(0, 2, 12);
    _nor.AddInput(1, 2, 32);
    _nor.AddOutput(0, 90, 22);

    LogicDeviceType _xor = AddNewType('XOR');
    _xor.AddImage("images/125dpi/xor.png");
    _xor.AddInput(0, 2, 12);
    _xor.AddInput(1, 2, 32);
    _xor.AddOutput(0, 90, 22);

    LogicDeviceType _xnor = AddNewType('XNOR');
    _xnor.AddImage("images/125dpi/xnor.png");
    _xnor.AddInput(0, 2, 12);
    _xnor.AddInput(1, 2, 32);
    _xnor.AddOutput(0, 90, 22);

    LogicDeviceType _not = AddNewType('NOT');
    _not.AddImage("images/125dpi/not.png");
    _not.AddInput(0, 2, 24);
    _not.AddOutput(0, 90, 24);
    
    LogicDeviceType _tff = AddNewType('TFF');
    _tff.AddImage("images/125dpi/tff.png");
    _tff.AddInput(0, 2, 44);
    _tff.AddOutput(0, 93, 15);
    _tff.AddOutput(1, 93, 72);
    
    }
}
