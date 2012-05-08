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
   

/** 
/ Handles all of the wires for the simulaton
*/
class Wires {
  
  List<Wire> wires;
  
  Wires(){ 
    wires = new List<Wire>();
  }
  
  get count() => wires.length;
  
  // clear all the wires
  void clearAll(){
    wires.clear();
  }
  
  // Add a wire
  void addWire(Wire w) {
    wires.add(w);
  }
  
  // Create a new wire
  Wire createWire() {
    Wire w = new Wire();
    wires.add(w);
    return w;
  }
  
  void deleteLast() {
    wires.removeLast();
  }
  
  // Delete a given wire
  void deleteWire(Wire w) {
     wires.removeRange(wires.indexOf(w),1);
  }
}