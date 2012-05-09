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
   

class DeviceIO { 
  static final int PIND = 10; // Pin hit radius 
  
  LogicDevice device; // parent device  
  DevicePin devicePin; // the pin that we connect to 
  
  var value; // io points value
  var id; // io id TODO:use hashcode
  
  bool connectable; // Can you connect to this input pin
  bool updated; // True if this IO's value has been updated 
  
  DeviceIO(this.device, this.id, DevicePin pin) {
    value = false;
    devicePin = pin; 
  }
  
  int get offsetX() => device.X + devicePin.x;  // the corrected absolute X position 
  int get offsetY() => device.Y + devicePin.y;  // the corrected absolute Y position
  
  bool pinHit(int x, int y) {
    if(x <= (offsetX + PIND) && x >= (offsetX - PIND)) {
      if(y <= (offsetY + PIND) && y >= (offsetY - PIND)) {
        return true;
      }
    }
    return false;
  }
}