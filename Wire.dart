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
   

class WirePoint  implements CanvasPoint {
  int x;
  int y;
  bool drawKnot;
  Wire wire;
  
  WirePoint(this.wire, this.x, this.y) {}
}

/** A wire contains a list of wire points and connects logic devices together */
class Wire {
  static final int WIRE_HIT_RADIUS = 4;
  static final int WIREPOINT_HIT_RADIUS = 10;
  
  static final int WIRE_WIDTH = 3;
  static final int NEW_WIRE_WIDTH = 3;

  static final String NEW_WIRE_COLOR = '#990000';
  static final String NEW_WIRE_VALID = '#009900';
  static final String NEW_WIRE_INVALID = '#999999';
  
  static final String WIRE_HIGH = '#ff4444';
  static final String WIRE_LOW = '#550091';
  
  static final TAU = Math.PI * 2; 
  static final KNOT_RADIUS = 6;
  
  DeviceInput input;
  DeviceOutput output;
  
  WirePoint inputPoint;
  WirePoint outputPoint;
  WirePoint wireKnot; // when a wire ends on a wire draw a wire knot
  
  List<WirePoint> wirePoints;
  
  Wire() {
    wirePoints = new List<WirePoint>();
  }
  
  /** The wire's starting x point */
  int get startX() {
    if (wirePoints.length > 0) {
      return wirePoints[0].x;
    }
    return null;
  }
  
  /** The wire's starting y point */
  int get startY() {
    if (wirePoints.length > 0) {
      return wirePoints[0].y;
    }
    return null;
  }
  
  /** Returns the last x point in the wire */
  int get lastX() {
    return wirePoints.last().x; 
  }
  
  /** Returns the last y point in the wire */
  int get lastY() {
    return wirePoints.last().y; 
  }
  
  /** Returns the last wire point in the wire */
  WirePoint get lastPoint() {
    return wirePoints.last();
  }
  
  /** Returns true if we need an input connection for this wire */
  bool get needInput() {
    if (input == null) {
      return true;
    }
    else {
      return false;
    }
  }
  
  /** Returns true if we need an output connection for this wire */
  bool get needOutput() {
    if (output == null) {
      return true;
    }
    else {
      return false;
    }
  }
  
  /** Returns a point that is snapped to the wire */
  CanvasPoint getWireSnapPoint(CanvasPoint p) {
    WirePoint wp1, wp2; 
    wp1 = contains(p); // get upstream point
    
    if(wp1 != null) {
      int i = wirePoints.indexOf(wp1);
      wp2 = wirePoints[i+1];
      
      num length = distance(wp1, p); 
      
      num angle = Math.atan2((wp2.y - wp1.y), (wp2.x - wp1.x));
      num xp = length * Math.cos(angle) + wp1.x;
      num yp = length * Math.sin(angle) + wp1.y;
      
      return new CanvasPoint(xp.floor(), yp.floor());
    }
    return null;
  }
  
  /** Distance between two points */
  num distance(CanvasPoint a, CanvasPoint b) {
    return Math.sqrt((b.y - a.y) * (b.y - a.y) + (b.x - a.x) * (b.x - a.x));
  }

  /** Returns a wirepoint if it exists at the given point */
  WirePoint getWirePoint(CanvasPoint p) {
    for (WirePoint point in wirePoints) {
      if (p.x >= (point.x - WIREPOINT_HIT_RADIUS) && p.x <= (point.x + WIREPOINT_HIT_RADIUS)) {
        if (p.y >= (point.y - WIREPOINT_HIT_RADIUS) && p.y <= (point.y + WIREPOINT_HIT_RADIUS)) {
          return point;
        }
      }
    }
    return null;
  }
  
  /** Returns the last wirepoint in the wire */
  WirePoint getLastPoint(){
    return wirePoints.last();  
  }
  
  /** Clear the wire of all the wire points */
  void clear() {
    wirePoints.clear();
    lastX = null;
    lastY = null;
  }
  
  /** Reverse all the wire points */
  void flipWire() {
    List<WirePoint> flipPoints = new List<WirePoint>();
    for (int i = wirePoints.length - 1 ; i >= 0; i-- ) {
      flipPoints.add(wirePoints[i]);
    }
    wirePoints.clear();
    wirePoints = flipPoints;
  }
   
  /** Add a new point to the wire returns the point that was created */
  WirePoint AddPoint(CanvasPoint p) {
    UpdateLast(p);
    WirePoint wp = new WirePoint(this, p.x, p.y);
    wirePoints.add(wp);
    return wp;
  }

  
  /** Add a wire knot to the wire this happens when you
  connect a wire to another wire */
  void setKnot(WirePoint p, bool drawKnot) {
    p.drawKnot = drawKnot;
    if (p.drawKnot) {
      wireKnot = p;
    }
    else {
      wireKnot = null;
    }
  }

  /** Updates the last point in the wire */
  void UpdateLast(CanvasPoint p) {
    if(wirePoints.length >= 2) { // at least 2 points
      wirePoints.last().x = p.x;
      wirePoints.last().y = p.y;
    }
  }
  
  /** Get a segment between two points */
  WireSegment getSegment(CanvasPoint p) {
    WirePoint wp1 = contains(p);
    int wpi1 = wirePoints.indexOf(wp1);
    
    if (wpi1 + 1 < wirePoints.length) {
      WirePoint wp2 = wirePoints[wpi1 + 1];
      // TODO: need to correctly assign 
      if (wp1 != null && wp2 != null) {
        WireSegment ws = new WireSegment(wp2, wp1);
        return ws;
      }
    }
    return null;
  }
  
  /** Insert a point in a wire segment an returns the rest of the wire*/
  List<WirePoint> insertPoint(WireSegment ws, CanvasPoint p) {
    if (ws == null || p == null) return null;
    
    List<WirePoint> endWire = new List<WirePoint>();

    int wi = wirePoints.indexOf(ws.inputSide);
    endWire = wirePoints.getRange(wi, wirePoints.length - wi); // Store the end of the wire
    wirePoints.removeRange(wi, wirePoints.length - wi); // Remove the end
    
    WirePoint wp = new WirePoint(this, p.x.floor(), p.y.floor()); // Add our new point
    wirePoints.add(wp);
    
    for (WirePoint wpe in endWire) { // Stick the end of the wire back on
      wirePoints.add(wpe);
    }
    
    return endWire; // return the end points so that we can use it 
  }
  
  /** Add a list of wirepoints to the wire */
  addWire (List<WirePoint> newWire) {
    for (WirePoint wp in newWire) {
      AddPoint(wp);
    }
  }
  
  /** Print to the console a list of wire points */
  void printWirePoints (List<WirePoint> wps) {
    for (WirePoint wp in wps) {
      print("${wirePoints.indexOf(wp)}:(${wp.x},${wp.y})");
    }
  }
  
  /** Check to see of the wire contains a given point and returns
      the upstream point */
  WirePoint contains(CanvasPoint p) { 
    if(wirePoints.length >= 2) {
      int x1, x2, y1, y2;
      var d1;
      for(int t=0; t < wirePoints.length - 1; t++) { 
        x1 = wirePoints[t].x;
        x2 = wirePoints[t+1].x;
        
        y1 = wirePoints[t].y;
        y2 = wirePoints[t+1].y;
        
        d1 = (Math.sqrt((p.y-y1)*(p.y-y1)+(p.x-x1)*(p.x-x1)) 
            + Math.sqrt((p.y-y2)*(p.y-y2)+(p.x-x2)*(p.x-x2))) 
            - Math.sqrt((y2-y1)*(y2-y1)+(x2-x1)*(x2-x1));
        
        if(d1 <= WIRE_HIT_RADIUS){
          return wirePoints[t];
        }
      }
    }
    return null;
  }
  
}
