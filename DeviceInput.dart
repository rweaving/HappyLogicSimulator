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
   
class DeviceInput {
  static final int PIND = 7; // Pin hit margin 
  final LogicDevice device;  

  DeviceOutput connectedOutput;
  
  WirePoint wirePoint;
  
  bool _value = false;
  
  DevicePin devicePin;
  
  int _pinX;
  int _pinY;
  
  int id;
  
  // Can you connect to this input pin?
  bool _connectable = true;
  bool get connectable(){
    if (_pinX < 0) return false;  
    else return _connectable;
  }
  set connectable(bool val){
    _connectable = val;
  }
  
  bool updated;
  
  DeviceInput(this.device, this.id, this.devicePin){
    value = false;
    connectedOutput = null;
    
    _pinX = devicePin.x;
    _pinY = devicePin.y;
    
   // wire = new Wire();
   }
  
  int get offsetX() => device.X + _pinX;  // the corrected absolute X position 
  int get offsetY() => device.Y + _pinY;  // the corrected absolute X position
  int get pinX()    => _pinX;             // the pins X location on the devices image
  int get pinY()    => _pinY;             // the pins Y location on the devices image
  set pinX(int x)   => _pinX;             // the pins X location on the devices image
  set pinY(int y)   => _pinY;             // the pins Y location on the devices image
   
  
//  void createWire(int x, int y){
//      wire.AddPoint(x, y);
//  }
//  
//  void addWire(List<WirePoint> wirePoints){
//    clearWire();
//    for(WirePoint point in wirePoints){
//      wire.AddPoint(point.x, point.y);
//    }
//  }
//  
//  void clearWire(){
//      wire.clear();
//  }
//  
//  DeviceOutput wireHit(int x, int y){
//    if(wire != null && connectedOutput != null){
//      if(wire.Contains(x, y, 1))
//        return connectedOutput;
//    }
//    return null;
//  }
  
  void checkUpdate(){
    if(connectedOutput != null) {
      updated = connectedOutput.device.updated;
    }
    else
      updated = false;
   }
  
  // Has this device been calculated
  bool get calculated(){
    if(wirePoint != null) {
      return wirePoint.wire.output.device.calculated;
    }
    return false;
  }
  
  // Is this input connected to another device
  bool get connected(){
    if(wirePoint == null) 
      return false;
    
    connectedOutput = wirePoint.wire.output;
    
    if(connectedOutput != null)   
      return true;
       
    return false;
  }
  
  bool get value(){

    if(connectedOutput == null){
      if(wirePoint != null){ 
        connectedOutput = wirePoint.wire.output;
      }
      return false;
    }
      
    if(!connectedOutput.calculated){
      connectedOutput.calculate();
    }
    
    return connectedOutput.value;
  }

  set value(bool val){
    _value = val;
  }
  
  SetPinLocation(int x, int y){
    _pinX = x;
    _pinY = y;
  } 
  
  bool pinHit(int x, int y){
    if(x <= (offsetX + PIND) && x >= (offsetX - PIND)){
      if(y <= (offsetY + PIND) && y >= (offsetY - PIND)){
        return true;
      }
    }
    return false;
  }
}