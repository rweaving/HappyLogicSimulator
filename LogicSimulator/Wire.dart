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
    
    //endPoint = new Element.tag('img'); 
    //endPoint.src = "images/endPoint.png";   
  }
   
  void AddPoint(int x, int y)
  {
    lastX = x;
    lastY = y;
    
    wirePoints.add(new WirePoint(x, y));
    print("Add Point");
    Draw(0);
  }
    
  String GetWireString()
  {
    List<String> wireString = new List<String>();
 //   List<String> circuitStrings = new List<String>();
    
    wirePoints.forEach((f){
      wireString.add(JSON.stringify(f.toMap()));
    });
    
    return JSON.stringify(wireString);
  }
  // Draw the wire
  void Draw(var state){
   //CanvasRenderingContext2D context = connectedInput.device.circuit.context;
    
   connectedInput.device.circuit.context.beginPath();
   connectedInput.device.circuit.context.lineWidth = NEW_WIRE_WIDTH;
    
    switch(state){
        case 'VALID': connectedInput.device.circuit.context.strokeStyle = NEW_WIRE_VALID; break;
        case 'INVALID': connectedInput.device.circuit.context.strokeStyle = NEW_WIRE_INVALID; break;
        
        case false: connectedInput.device.circuit.context.strokeStyle = WIRE_LOW; break;
        case true: connectedInput.device.circuit.context.strokeStyle = WIRE_HIGH; break;
        
        //default: connectedInput.device.circuit.context.strokeStyle = WIRE_INVALID;
    }
    connectedInput.device.circuit.context.fillStyle = connectedInput.device.circuit.context.strokeStyle;
 
    //need at least 2 points
    if(wirePoints.length >= 2){
      connectedInput.device.circuit.context.moveTo(wirePoints[0].x, wirePoints[0].y); 
      
      for (WirePoint point in wirePoints) {
        connectedInput.device.circuit.context.lineTo(point.x, point.y);
      }
    }
    connectedInput.device.circuit.context.stroke();
    connectedInput.device.circuit.context.closePath(); 
    
    if(drawWireEndpoint){
      connectedInput.device.circuit.context.beginPath();
      
      connectedInput.device.circuit.context.arc(wirePoints[wirePoints.length-1].x, wirePoints[wirePoints.length-1].y, 5, 0, TAU, false);
      connectedInput.device.circuit.context.fill();
      
      connectedInput.device.circuit.context.stroke();
      connectedInput.device.circuit.context.closePath(); 
    }
    
   
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
