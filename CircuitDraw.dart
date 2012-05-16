class CircuitDraw {
  
  static final PI2 = Math.PI * 2;
  
  int width;
  int height;
  
  bool showGrid;
  
  Circuit circuit;
  
  CanvasElement canvas;
  CanvasRenderingContext2D context;
  
  ImageElement background;
  CanvasPattern backgroundPattern;
  
  CircuitDraw(this.circuit, this.canvas) {
    context = canvas.getContext('2d');
    
    background = new Element.tag('img');
    background.src = "images/GridBackground.png";
    background.on.load.add((Event e) { backgroundPattern = context.createPattern(background,'repeat');});  
   
    width = canvas.width;
    height = canvas.height;
    
    showGrid = false;
  }
  
  /** When the circuit view is resized this is called */
  void onResize() {
    width = canvas.width;
    height = canvas.height;  
  }
   
  /** Clear the background */
  void clearCanvas() {
    context.clearRect(0, 0, width, height);
  }
  
  /** Draws the simulation border */
  void drawBorder() {
    context.beginPath();
    context.rect(CircuitView.TOOLBAR_WIDTH, 0, width, height);
    context.fillStyle = Style.GRID_BACKGROUND_COLOR;
    context.lineWidth = Style.BORDER_LINE_WIDTH;
    context.strokeStyle = Style.GRID_BACKGROUND_COLOR;
    context.fillRect(CircuitView.TOOLBAR_WIDTH, 0, width, height);
    context.stroke();
    context.closePath();
  }
  
  /** Draw the background grid */
  void drawGrid(){
    context.fillStyle = backgroundPattern;  
    context.fillRect(CircuitView.TOOLBAR_WIDTH, 0, width, height);  
  }
  
  /** draw a list of devices */
  void drawDevices(List<LogicDevice> devices){
   for (LogicDevice device in devices) {
      context.drawImage(device.deviceType.getImage(device.outputs[0].value), device.position.x, device.position.y);   
    }
  }
  
//  /** Redraw all of the device buttons */
//  void drawDeviceButtons(){
//    for (LogicDevice device in deviceButtons) {
//       context.drawImage(device.deviceType.getImage(device.outputs[0].value), device.position.x, device.position.y);   
//     }
//   }
  
//  /** Redraw all of the devices */
//  void drawLogicDevices(){
//    drawDevices(circuit.logicDevices);
//    for (LogicDevice device in circuit.logicDevices) {
//      context.drawImage(device.deviceType.getImage(device.outputs[0].value), device.position.x, device.position.y);  
//    }
//  }
  
  /** Draw all the wires in the simulation */
  void drawWires() {
    for (Wire wire in circuit.circuitWires.wires) { 
      drawWire(wire);
    }
    if (circuit.newWire != null){
      drawWire(circuit.newWire);
    }
  }
  
  /** Draw all the selected wires in the simulation */
  void drawSelectedWires() {
    for (Wire wire in circuit.circuitWires.selectedWires) { 
      drawSelectedWire(wire);
    }
  }
  
  /** Draw all the selected wires in the simulation */
  void drawSelectedWire(Wire wire) {
    if(wire == null) return;  
    
    context.beginPath();
    context.strokeStyle = Style.WIRE_SELECT_STYLE;
    context.fillStyle = context.strokeStyle;

    context.lineWidth = 10;
    
    context.lineCap = 'round';
    context.lineJoin = 'round';
    context.miterLimit = 10;
    
    //need at least 2 points
    if(wire.wirePoints.length >= 2) {
      context.moveTo(wire.wirePoints[0].x, wire.wirePoints[0].y); 
      for (WirePoint point in wire.wirePoints) {
        context.lineTo(point.x, point.y);
      }
    }
    context.stroke();
    context.closePath(); 
  }
  
  /** Draw a given wire using its internal state */
  void drawWire(Wire wire) {
    if(wire == null) return;  

    context.beginPath();
    context.lineWidth = Style.WIRE_WIDTH;
    
    context.lineCap = 'round';
    context.lineJoin = 'round';
    context.miterLimit = 10;

    if(wire.input == null || wire.output == null){
      context.strokeStyle = Style.WIRE_INVALID;
    }
    else{
      if(wire.output.value == true){ // High
        context.strokeStyle = Style.WIRE_HIGH;
      }
      else{
        context.strokeStyle = Style.WIRE_LOW;
      }
    }

    context.fillStyle = context.strokeStyle;
    
    //need at least 2 points
    if(wire.wirePoints.length >= 2) {
      context.moveTo(wire.wirePoints[0].x, wire.wirePoints[0].y); 
      for (WirePoint point in wire.wirePoints) {
        context.lineTo(point.x, point.y);
      }
    }
    context.stroke();
    context.closePath(); 
    
    if (wire.wireKnot != null) {
      drawKnot(wire.wireKnot.x, wire.wireKnot.y);  
    }
  }
  
  /** Draws a knot (wire to wire connection point) at a given point */
  void drawKnot(int x, int y) {
    context.beginPath();
    context.lineWidth = 2;
    context.arc(x, y, 6, 0, PI2, false);
    context.fill();
    context.stroke();
    context.closePath(); 
  }
  
 
  /** Draw the device's visual pin indicators */
  void drawPinSelectors() {
    if(circuit.selectedOutput != null){
      drawHighlightPin(circuit.selectedOutput.offsetX, circuit.selectedOutput.offsetY, 'VALID'); 
    }
    
    if (circuit.selectedInput != null){
      if (circuit.selectedInput.connected)
        drawHighlightPin(circuit.selectedInput.offsetX, circuit.selectedInput.offsetY, 'CONNECTED');
      else
        drawHighlightPin(circuit.selectedInput.offsetX, circuit.selectedInput.offsetY, 'VALID');
    }
    
    if(circuit.selectedWirePoint != null){
      drawHighlightPin(circuit.selectedWirePoint.x , circuit.selectedWirePoint.y, 'VALID'); 
    }
        
    // If we are adding a wire draw acceptable connection points
    if(circuit.newWire != null){
      if(circuit.newWire.input == null) { // Looking for a vaild input
        drawConnectableInputPins();
      }
      if(circuit.newWire.output == null) { // Looking for a vaild output
        drawConnectableOutputPins();
      }
    }
  }
  
  /** Draw the output pins that we can connect to */
  void drawConnectableOutputPins() {
    for (LogicDevice device in circuit.logicDevices) {
      for (DeviceOutput output in device.outputs) {
        if(output.connectable == true)
          drawHighlightPin(output.offsetX, output.offsetY, 'CONNECTABLE'); 
      }
    }      
  }
  
  /** Draw the input pins that we can connect to */
  void drawConnectableInputPins() {
    for (LogicDevice device in circuit.logicDevices) {
      for (DeviceInput input in device.inputs) {
        if(input.connected == false && input.connectable == true)    
          drawHighlightPin(input.offsetX, input.offsetY, 'CONNECTABLE'); 
      }
    }      
  }
  
  /** Draw the highlight pin at a given coordinate */
  void drawHighlightPin(int x, int y, var highlightMode) {
    
    switch(highlightMode){
      case 'VALID':       context.strokeStyle = '#00AA00'; 
                          context.fillStyle = 'rgba(0, 170, 0, 0.25)';
                          break;
      case 'INVALID':     context.strokeStyle = '#999999'; 
                          context.fillStyle = 'rgba(153, 153, 153, 0.50)';
                          break;
      case 'WIRECONNECT': context.strokeStyle = '#00AA00'; 
                          context.fillStyle = 'rgba(0, 170, 0, 0.5)';
                          break;
      case 'CONNECTED':   context.strokeStyle = '#FFFF00'; 
                          context.fillStyle = 'rgba(0, 170, 0, 0.5)'; 
                          break;
      case 'WIREPOINT':   context.strokeStyle = 'hsla(240, 100%, 50%, 1)'; 
                          context.fillStyle = 'hsla(240, 100%, 50%, 0.25)'; 
                          break;
                          
      case 'CONNECTABLE': context.strokeStyle = 'hsla(270, 75%, 50%, 1)';//'#4000AA'; 
                          context.fillStyle = 'hsla(270, 75%, 50%, 0.25)';// 'rgba(64, 0, 170, 0.25)';
                          break; 
                          
      default:            context.strokeStyle = '#000000';
                          context.fillStyle = 'rgba(255, 0, 0, 0.5)';
    }
    
    context.beginPath();  
    context.lineWidth = 1;
    
    context.arc(x, y, 8, 0, PI2, false);  
    
    context.fill();
    context.stroke();  
    context.closePath(); 
  }
  
  
}
