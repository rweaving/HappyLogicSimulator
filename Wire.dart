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
   

class WirePoint  implements Point{
  int x;
  int y;
  Wire wire;
  
  WirePoint(this.wire, this.x, this.y){}
}

/** A wire contains a list of wire points and connects logic devices together */
class Wire {
  static final int WIRE_HIT_RADIUS = 8;
  
  static final int WIRE_WIDTH = 3;
  static final int NEW_WIRE_WIDTH = 3;

  static final String NEW_WIRE_COLOR = '#990000';
  static final String NEW_WIRE_VALID = '#009900';
  static final String NEW_WIRE_INVALID= '#999999';
  
  static final String WIRE_HIGH = '#ff4444';
  static final String WIRE_LOW = '#550091';
  
  static final TAU = Math.PI * 2; 
  
  DeviceInput input;
  DeviceOutput output;
  
  WirePoint inputPoint;
  WirePoint outputPoint;
  
  bool drawWireEndpoint = false;

  
  List<WirePoint> wirePoints;
  
  Wire(){
    wirePoints = new List<WirePoint>();
  }
  
  /** The wire's starting x point */
  int get startX(){
    if(wirePoints.length > 0){
      return wirePoints[0].x;
    }
    return null;
  }
  
  /** The wire's starting y point */
  int get startY(){
    if(wirePoints.length > 0){
      return wirePoints[0].y;
    }
    return null;
  }
  
  int get lastX() {
    return wirePoints.last().x; 
  }
  
  int get lastY() {
    return wirePoints.last().y; 
  }
  
  
  /** Returns a point that is snapped to the wire */
  Point getWireSnapPoint(int x, int y){
    WirePoint wp1, wp2; 
    Point p = new Point(x, y);
    wp1 = contains(p); // get upstream point
    
    if(wp1 != null){
      int i = wirePoints.indexOf(wp1);
      wp2 = wirePoints[i+1];
      
      num length = distance(wp1.x, wp1.y, x, y); 
      
      num angle = Math.atan2((wp2.y - wp1.y), (wp2.x - wp1.x));
      num xp = length * Math.cos(angle) + wp1.x;
      num yp = length * Math.sin(angle) + wp1.y;
      
      return new Point(xp, yp);
    }
    return null;
  }
  
  num distance(num x1, num y1, num x2, num y2) {
    return Math.sqrt((y2 - y1) * (y2 - y1) + (x2 - x1) * (x2 - x1));
  }
  
  
  /** Returns a wirepoint if it exists at the given point */
  WirePoint getWirePoint(int x, int y) {
    for(WirePoint point in wirePoints) {
      if(x >= (point.x - WIRE_HIT_RADIUS) && x <= (point.x + WIRE_HIT_RADIUS)) {
        if(y >= (point.y - WIRE_HIT_RADIUS) && y <= (point.y + WIRE_HIT_RADIUS)) {
          return point;
        }
      }
    }
    return null;
  }
  
  /** Clear the wire of all the wire points */
  void clear() {
    wirePoints.clear();
    
    lastX = null;
    lastY = null;
  }
   
  /** Add a new point to the wire */
  WirePoint AddPoint(int x, int y) {
    UpdateLast(x,y);
    
    WirePoint wp = new WirePoint(this, x, y);
    wirePoints.add(wp);
    //print("new WirePoint($x,$y)");
    return wp;
  }
  
  /** Check to see if first or last point is here */
  bool HasStartEndPoint(int x, int y) {
    if(wirePoints.length >= 2) {
      if(wirePoints[0].x == x && wirePoints[0].y == y) { 
        return true;
      }
      if(wirePoints.last().x == x && wirePoints.last().y == y) {
        return true;
      }
    }
  }
  
  /** Updates the last point in the wire */
  void UpdateLast(int x, int y) {
    if(wirePoints.length >= 2) { // at least 2 points
      wirePoints.last().x = x;
      wirePoints.last().y = y;
    }
  }
  
  /** Check to see of the wire contains a given point */
  bool Contains(int x, int y) { 
    
    // TODO: optimise
    if(wirePoints.length >= 2) {
      int x1, x2, y1, y2;
      var d1;
      for(int t=0; t < wirePoints.length - 1; t++) { 
        x1 = wirePoints[t].x;
        x2 = wirePoints[t+1].x;
        
        y1 = wirePoints[t].y;
        y2 = wirePoints[t+1].y;
        
        d1 = (Math.sqrt((y-y1)*(y-y1)+(x-x1)*(x-x1)) 
            + Math.sqrt((y-y2)*(y-y2)+(x-x2)*(x-x2))) 
            - Math.sqrt((y2-y1)*(y2-y1)+(x2-x1)*(x2-x1));
        
        if(d1 <= WIRE_HIT_RADIUS){
          return true;
        }
      }
    }
    return false;
  }
  
  /** Check to see of the wire contains a given point and returns
      the upstream point */
  WirePoint contains(Point p) { 
    
    // TODO: optimise
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
