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
   
/** Holds two points of a wire representing a segment of that wire */  
class WireSegment {
  WirePoint inputSide;
  WirePoint outputSide;
  
  WireSegment (this.inputSide, this.outputSide) {}
}

/** Handles all of the wires for the simulaton */
class Wires {

  List<Wire> wires;
  List<Wire> selectedWires;
  List<WirePoint> selectedWirePoints;
  
  Wires(){ 
    wires = new List<Wire>();
    selectedWires = new List<Wire>();
    selectedWirePoints = new List<WirePoint>();
  }
  
  /** The total number of wires in the simulation */
  int get count() => wires.length;
  int get selectedCount() => selectedWires.length;
  int get selectedWirePointsCount() => selectedWirePoints.length;
  
  /** Returns true if there are wirepoints selected */
  bool get pointsSelected() {
    if (selectedWirePoints.length > 0) {
      return true;
    }
    return false;
  }
  
  /** Returns true if there are wires selected */
  bool get wiresSelected() {
    if (selectedWires.length > 0) {
      return true;
    }
    return false;
  }
  
  /** Delete the wires that are selected */
  void deleteSelectedWires() {
    for(Wire w in selectedWires) {
      int wi = wires.indexOf(w);
      w.input.connectedWire = null; // Disconnect the wire
      wires.removeRange(wi, 1); // and remove it
    }
    selectedWires.clear();
  }
  
  /** Clears all the wires */
  void clearAll() {
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
  WirePoint selectWirePoint(CanvasPoint p) {
    for (Wire wire in wires) { 
      if(wire.getWirePoint(p) != null) {
        return wire.getWirePoint(p);
      }
    }        
    return null;
  }
  
  /** Try to select a wire points at a given point */
  int selectWirePoints(CanvasPoint p) {
    selectedWirePoints.clear();
    
    CanvasPoint firstPoint;
    
    for (Wire wire in wires) { 
      for (WirePoint point in wire.wirePoints) {
        if (p.x >= (point.x - Wire.WIREPOINT_HIT_RADIUS) && p.x <= (point.x + Wire.WIREPOINT_HIT_RADIUS)) {
          if (p.y >= (point.y - Wire.WIREPOINT_HIT_RADIUS) && p.y <= (point.y + Wire.WIREPOINT_HIT_RADIUS)) {
            if (firstPoint == null) {
              firstPoint = point;
              selectedWirePoints.add(point);
            }
            else { // Only add points that are in the exact spot
              if (point.x == firstPoint.x && point.y == firstPoint.y) {
                selectedWirePoints.add(point);
              }
            }
          }
        }
      }
    }        
    return selectedWirePoints.length;
  }
  
  
  /** Unselect wire points */
  void deselectWirePoints() {
    selectedWirePoints.clear();  
  }
  
  /** Unselect all wires */
  void deselectWires() {
    selectedWires.clear();
  }
  
  /** Moves selected wire points to new location */
  void moveSelectedPoints(CanvasPoint p) {
    for (WirePoint wp in selectedWirePoints) {
      wp.x = p.x;
      wp.y = p.y;
    }
  }
  
  /** Clears the list of selected wires */
  void clearSelectedWires() {
    selectedWires.clear();
  }
  
  /** Returns the first wire hit if any */
  Wire wireHit(CanvasPoint p) {
    for (Wire wire in wires) { 
      if (wire.contains(p) != null) {
        return wire;
      }
    }
    return null;
  }
  
  /** Returns two points on both sides of given point */
  WireSegment getWireSegment(CanvasPoint p) {
    Wire w = wireHit(p);
    if(w != null) {
      return w.getSegment(p);
    }
    return null;
  }
  
  /** tries to select a wire at a give point */
  int selectWire(CanvasPoint p) {
    selectedWires.clear();
    
    for (Wire wire in wires) { 
      if (wire.contains(p) != null) {
        selectedWires.add(wire);
      }
    }
    return selectedWires.length;
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