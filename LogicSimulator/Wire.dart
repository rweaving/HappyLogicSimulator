class WirePoint {
  int x;
  int y;
  WirePoint(this.x, this.y){}
  
  Map<String, Object> toMap() {
    Map<String, Object> wirePoints = new Map<String, Object>();
    
    wirePoints['x'] = x;
    wirePoints['y'] = y;
    return wirePoints;
  }
}


class Wire {
  static final int NEW_WIRE_WIDTH = 3;
  static final String NEW_WIRE_COLOR = '#990000';
  
  static final String NEW_WIRE_VALID = '#009900';
  static final String NEW_WIRE_INVALID= '#999999';
  
  static final String WIRE_HIGH = '#ff4444';
  static final String WIRE_LOW = '#550091';
  static final int WIRE_WIDTH = 3;
  static final TAU = Math.PI * 2;
  
  int startX;
  int startY;
  int lastX;
  int lastY;
  bool drawWireEndpoint = false;
  
  DeviceInput connectedInput;
  //ImageElement endPoint;
  
  List<WirePoint> wirePoints;
  
  Wire(this.connectedInput){
    wirePoints = new List<WirePoint>();
    wirePoints.add(new WirePoint(connectedInput.offsetX, connectedInput.offsetY));
    print("Add Wire");
    lastX = connectedInput.offsetX;
    lastY = connectedInput.offsetY;
  }
   
  void AddPoint(int x, int y)
  {
    lastX = x;
    lastY = y;
    
    wirePoints.add(new WirePoint(x, y));
  }
  
  void UpdateLast(int x, int y)
  {
    lastX = x;
    lastY = y;
  }
    
  String GetWireString()
  {
    List<String> wireString = new List<String>();
    wirePoints.forEach((f){
      wireString.add(JSON.stringify(f.toMap()));
    });
    return JSON.stringify(wireString);
  }
  
  // Check to see of the wire contains the point
  bool Contains(int x, int y, var d)
  { 
    if(wirePoints.length >= 2){
      int x1, x2, x3, y1, y2, y3;
      var d1;
      x3 = x; 
      y3 = y;
      for(int t=0; t<wirePoints.length-1; t++){ 
        x1 = wirePoints[t].x;
        x2 = wirePoints[t+1].x;
        
        y1 = wirePoints[t].y;
        y2 = wirePoints[t+1].y;
        
        d1 = (Math.sqrt((y3-y1)*(y3-y1)+(x3-x1)*(x3-x1)) + Math.sqrt((y3-y2)*(y3-y2)+(x3-x2)*(x3-x2))) - Math.sqrt((y2-y1)*(y2-y1)+(x2-x1)*(x2-x1));
        if(d1 <= d){
          return true;
        }
      }
    }
    return false;
  }
  
}
