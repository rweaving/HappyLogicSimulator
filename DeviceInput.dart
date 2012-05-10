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
  
 static final int IO_HIT_RADIUS = 9; // Pin hit radius 
  
  LogicDevice device; // parent device  
  DevicePin devicePin; // the pin that we connect to 
    
  bool _value; // The IO value
  bool _connectable;
  var id; // the IO's id TODO:use hashcode
  
  /** True if this IO's value has been updated */
  bool updated; 
  
  /** Returns the corrected absolute X position */
  int get offsetX() => device.X + devicePin.x;   
  
  /** Returns the corrected absolute Y position */
  int get offsetY() => device.Y + devicePin.y;  
  
  /** Returns true if given point is within the pin hit radius */
  bool pinHit(int x, int y) {
    if(x <= (offsetX + IO_HIT_RADIUS) && x >= (offsetX - IO_HIT_RADIUS)) {
      if(y <= (offsetY + IO_HIT_RADIUS) && y >= (offsetY - IO_HIT_RADIUS)) {
        return true;
      }
    }
    return false;
  }

  /** Returns true if you connect to this io */
  bool get connectable() {
    if (devicePin.x < 0) { 
      return false; 
    }
    else { 
      return true;
    }
  }
  
  set connectable(bool c){
    _connectable = c;
  }

  DeviceOutput connectedOutput;
  
  WirePoint wirePoint;
  
  DeviceInput(LogicDevice d, var ioId, DevicePin pin) {
//    super.device = d;
//    super.id = ioId;
//    super.devicePin = pin;
//  
    this.device = d;
    this.id = ioId;
    this.devicePin = pin;
  }
  
  /** Check to see if any connected output has been updated */
  void checkUpdate() {
    if(connectedOutput != null) {
      updated = connectedOutput.device.updated;
    }
    else
      updated = false;
   }
  
  /** Returns true if the device has been calculated */
  bool get calculated() {
    if(wirePoint != null) {
      return wirePoint.wire.output.device.calculated;
    }
    return false;
  }
  
  /** Returns true if this input connected to another device */
  bool get connected() {
    if(wirePoint == null) 
      return false;
    
    connectedOutput = wirePoint.wire.output;
    
    if(connectedOutput != null)   
      return true;
       
    return false;
  }
  
  /** returns the inputs value */
  bool get value(){

    if(connectedOutput == null) {
      if(wirePoint != null) { 
        connectedOutput = wirePoint.wire.output;
      }
      return false;
    }
    if(!connectedOutput.calculated) {
      connectedOutput.calculate();
    }
    return connectedOutput.value;
  }

}