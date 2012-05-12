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
   

/** Handles all of the wires for the simulaton */
class Wires {

  List<Wire> wires;
  List<Wire> selectedWires;
  
  Wires(){ 
    wires = new List<Wire>();
    selectedWires = new List<Wire>();
  }
  
  /** The total number of wires in the simulation */
  get count() => wires.length;
  get selectedCount() => selectedWires.length;
  
  /** Clears all the wires */
  void clearAll(){
    wires.clear();
  }
  
  /** Adds a wire */
  void addWire(Wire w) {
    wires.add(w);
  }
  
  /** Create a new wire */
  Wire createWire() {
    Wire w = new Wire();
    wires.add(w);
    return w;
  }
  
  /** Try to select a wire point at a given point */
  WirePoint selectWirePoint(int x, int y) {
    for (Wire wire in wires) { 
      if(wire.getWirePoint(x, y) != null) {
        return wire.getWirePoint(x, y);
      }
    }        
    return null;
  }
  
  /** Clears the list of selected wires */
  void clearSelectedWires() {
    selectedWires.clear();
  }
  
  /** Returns the first wire hit if any */
  Wire wireHit(int x, int y) {
    for (Wire wire in wires) { 
      if (wire.Contains(x, y)) {
        return wire;
      }
    }
    return null;
  }
  
  /** tries to select a wire at a give point */
  int selectWire(int x, int y) {
    for (Wire wire in wires) { 
      if (wire.Contains(x, y)) {
        addWireToSelection(wire); 
      }
    }
    return selectedWires.length;
  }
  
  /** tries to select a wire at a give point */  
  void addWireToSelection(Wire wire) {
    for(Wire w in selectedWires) {
      if(w === wire) {
        selectedWires.removeRange(selectedWires.indexOf(w), 1); 
        return;
      }
    }
    selectedWires.add(wire);
  }
  
  /** returns the first wire that is selected */
  Wire firstSelectedWire() {
    if (selectedWires.length <= 0) {
      return null;
    }
    return selectedWires[0];
  }
  
  /** Delete the last wire in the simulation */
  void deleteLast() {
    wires.removeLast();
  }
  
  /** Delete the given wire from the simulation */
  void deleteWire(Wire w) {
     wires.removeRange(wires.indexOf(w),1);
  }
  
}