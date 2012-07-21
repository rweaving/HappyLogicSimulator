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

#library('device_io');
#import('logic_device.dart');
#import('logic.dart');
#import('device_map.dart');
#import('device_pin.dart');
#import('canvas_point.dart');

class DeviceIO { 
  static final int IO_HIT_RADIUS = 9; // Pin hit radius 
  
  LogicDevice device; // parent device  
  DevicePin devicePin; // the pin that we connect to 
    
  bool value; // The IO value
  bool previous_value; // The previous value;
  bool _connectable;
  
  var id; // the IO's id TODO:use hashcode
  
  /** True if this IO's value has been updated */
  bool updated; 
  
  /** Returns the corrected absolute X position */
  int get offsetX() => device.position.x + devicePin.x;   
  
  /** Returns the corrected absolute Y position */
  int get offsetY() => device.position.y + devicePin.y;  
  
  /** returns the absolute point */
  CanvasPoint get offset() => new CanvasPoint(offsetX, offsetY);
  
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
    else { 
      return true;
    }
  }
  
  set connectable(bool c){
    _connectable = c;
  }
  
}