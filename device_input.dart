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

class DeviceInput {
  
 static final int IO_HIT_RADIUS = 9; // Pin hit radius 
  
  LogicDevice device; // parent device  
  DevicePin devicePin; // the pin that we connect to
  Logic subLogicGate;
  ImageMap imageMap;
  InputMap inputMap;
  
  bool _connectable = true;
  bool triggered = false; 
  
  var id; // the IO's id 
  
  /** True if this IO's value has been updated */
  bool updated = false; 
  
  /** The previous value */
  bool previous_value = false; 
  
  /** Returns the corrected absolute X position */
  num get offsetX() => device.position.x + devicePin.x;   
  
  /** Returns the corrected absolute Y position */
  num get offsetY() => device.position.y + devicePin.y;  
  
  /** returns the absolute point */
  CanvasPoint get offset() => new CanvasPoint(offsetX, offsetY);
  
  /** return the approprate mapped value */
  get mappedImage() {
    if (imageMap != null) {
      if (value == true) {
        return imageMap.highImage;
      }
      return imageMap.lowImage;
    }
    return null;
  }
  
  /** Returns true if given point is within the pin hit radius */
  bool pinHit(CanvasPoint p) {
    if(p.x <= (offsetX + IO_HIT_RADIUS) && p.x >= (offsetX - IO_HIT_RADIUS)) {
      if(p.y <= (offsetY + IO_HIT_RADIUS) && p.y >= (offsetY - IO_HIT_RADIUS)) {
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
    if (connectedWire == null) {
      return true;
    }
    return false;
  }
  
  
  set connectable(bool c){
    _connectable = c;
  }

  DeviceOutput connectedOutput;
  Wire connectedWire;

  DeviceInput(LogicDevice d, var ioId, DevicePin pin) {

    this.device = d;
    this.id = ioId;
    this.devicePin = pin;
  }
  
  /** Check to see if any connected output has been updated */
  checkUpdate() {
    if(connectedOutput != null) {
      updated = connectedOutput.updated;// .device.updated;
    }
    else
      updated = false;
   }
  
  /** Returns true if the device has been calculated */
  bool get calculated() {
    if(connectedWire.output != null) {
      return connectedWire.output.device.calculated;
    }
    return false;
  }
  
  /** Returns true if this input connected to another device */
  bool get connected() {
    
    if(connectedWire == null) {
      return false;
    }
    
    if(connectedWire.output == null) { 
      return false;
    }
    
    return true;
  }
  
  /** returns the inputs value */
  bool get value(){

    if(connectedWire == null) {
      return false;
    }
    
    if(connectedWire.output == null) { 
        return false;
    }
    
    if(connectedWire.output.calculated == false) {
      connectedWire.output.calculate();
    }
    return connectedWire.output.value;
  }

}
