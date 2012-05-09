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
   

class DeviceOutput{ 
  static final int PIND = 6; // Pin hit margin
  bool _value;  
  int _pinX;
  int _pinY;
  
  int id;
  
  DevicePin devicePin;
  WirePoint wirePoint;
  
  // Can you connect to this output pin
  bool _connectable = true;
  bool get connectable(){
    if (_pinX < 0) return false;  
    else return _connectable;
  }
  set connectable(bool val){
    _connectable = val;
  }
  
  final LogicDevice device;
  
  DeviceOutput(this.device, this.id, this.devicePin){
    value = false;
    
    _pinX = devicePin.x;
    _pinY = devicePin.y;
    
  }
  
  // Has this device been calculated
  bool get calculated(){
    return device.calculated;
  }
  
  calculate(){
    device.Calculate();
  }
  
  int get offsetX() => device.X + _pinX;
  int get offsetY() => device.Y + _pinY;
  int get pinX() => _pinX;
  int get pinY() => _pinY;
  set pinX(int x) => _pinX;             // the pins X location on the devices image
  set pinY(int y) => _pinY;             // the pins Y location on the devices image
  
  bool get value() => _value;
  
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