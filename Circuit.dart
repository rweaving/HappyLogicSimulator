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
      
/** A circuit contains and controls the logic simulaton */
class Circuit {

  static final int BORDER_LINE_WIDTH = 1;
  static final String BORDER_LINE_COLOR = '#000000';
  static final int    NEW_WIRE_WIDTH = 3;
  static final String NEW_WIRE_COLOR = '#990000';
  static final String NEW_WIRE_VALID = '#009900';
  static final String NEW_WIRE_INVALID = '#999999';
  static final String WIRE_HIGH = 'hsl(0, 100%, 50%)';
  static final String WIRE_LOW =  'hsl(0, 100%, 5%)';
  static final String WIRE_SELECT_STYLE = 'hsla(270, 100%, 60%, 0.75)';
  static final String WIRE_INVALID = '#999999';
  static final int    WIRE_WIDTH = 4;
  static final int GRID_SIZE = 10;
  static final int GRID_POINT_SIZE = 1;
  static final String GRID_COLOR = '#999493';
  static final String GRID_BACKGROUND_COLOR = '#eeeeee';

  static final PI2 = Math.PI * 2;
  static final int TOOLBAR_WIDTH = 115;
  
  CanvasElement canvas;
  CanvasRenderingContext2D context;
  
  ImageElement background;
  CanvasPattern backgroundPattern;
   
  int width;
  int height;
  int mouseX;
  int mouseY;

  LogicDeviceTypes deviceTypes; // Has all the various type of logic devices
  List<LogicDevice> deviceButtons; // Holds all the device creation buttons
  List<LogicDevice> logicDevices; // Holds all the devices in the simulation
  SelectedDevices selectedDevices; // Devices that are selected
  List<WirePoint> wirePoints; // All the wirepoints
  
  DeviceInput selectedInput;
  DeviceOutput selectedOutput;
  WirePoint selectedWirePoint;
  WirePoint movingWirePoint;
  
  LogicDevice moveDevice;
  
  Wire newWire; // Pointer to our new wire if adding one
  Wire selectedWire;
  Wires circuitWires; // Holds all the wires for the simulation
  Point wireSnapPoint; // A point that holds the wiresnap pointer
  Point uiPoint;

  bool showGrid;
  bool gridSnap;
  bool run;
  
  Circuit(this.canvas) : 
    deviceTypes = new LogicDeviceTypes(), 
    logicDevices = new List<LogicDevice>(),
    deviceButtons = new List<LogicDevice>(),
    wirePoints = new List<WirePoint>(){

    context = canvas.getContext('2d');
    width = canvas.width;
    height = canvas.height;
    
    circuitWires = new Wires();
    selectedDevices = new SelectedDevices(logicDevices, circuitWires);
    uiPoint = new Point(0,0);
    
    background = new Element.tag('img');
    background.src = "images/GridBackground.png";
    background.on.load.add((Event e) { backgroundPattern = context.createPattern(background,'repeat');});
    
    window.setInterval(f() => tick(), 50); // Create a timer to update the simulation tick
    window.on.resize.add((event) => onResize(), true);
    
    canvas.on.mouseDown.add(onMouseDown);
    canvas.on.mouseUp.add(onMouseUp);
    canvas.on.doubleClick.add(onMouseDoubleClick);
    canvas.on.mouseMove.add(onMouseMove);
    
    document.on.keyUp.add(onKeyUp);
        
  }
  
  /** Start the simulation */
  void start() {
    createSelectorBar();
    onResize();
    run = true;
    window.webkitRequestAnimationFrame(animate);
  }
  
  /** Stop the simulation */
  void stop() {
    run = false;  
  }
  
  /** Redraw the simulation */
  void animate(int time) {
    if (run) {
      draw(); // Draw the circuit
      //print("$time");
      window.webkitRequestAnimationFrame(animate); // Use animation frame 
    }
  }
  
  /** When the simulation is resized this is called. */
  void onResize() {
    height = window.innerHeight - 25;
    width = window.innerWidth - 25;
    
    canvas.height = height;
    canvas.width = width;
    
    draw();
  }
  
  /** Creates the button bar to add devices */
  void createSelectorBar() {
    addNewButtonDevice('clock', 'CLOCK', 0, 0);
    addNewButtonDevice('switch', 'SWITCH', 0, 60);
    addNewButtonDevice('not', 'NOT', 0, 120);
    addNewButtonDevice('and', 'AND', 0, 180);
    addNewButtonDevice('nand', 'NAND', 0, 240);
    addNewButtonDevice('or', 'OR', 0, 300);
    addNewButtonDevice('nor', 'NOR', 0, 360);
    addNewButtonDevice('xor', 'XOR', 0, 420);
    addNewButtonDevice('xnor', 'XNOR', 0, 480);
    addNewButtonDevice('led', 'LED', 50, 70);
  }
  
  /** add a new button type device */
  LogicDevice addNewButtonDevice(var id, var type, int x, int y) {
    LogicDeviceType deviceType = deviceTypes.getDeviceType(type);
    if(deviceType != null){
        LogicDevice newDevice = new LogicDevice(deviceType); 
        deviceButtons.add(newDevice);
        newDevice.selectable = false;
        newDevice.MoveDevice(x, y);
        return newDevice;
    }
  }
  
  /** Creates a new device from a given device and adds it to the circuit */
  LogicDevice newDeviceFrom(LogicDevice device) {
    LogicDevice newDevice = new LogicDevice(device.deviceType); 
    logicDevices.add(newDevice);
    newDevice.MoveDevice(device.xPosition, device.yPosition);
    selectedDevices.clear();
    selectedDevices.add(newDevice, (device.xPosition - mouseX), (device.yPosition - mouseY));
    return newDevice;
  }
  
  /** Clears the circuit of all devices */
  void ClearCircuit() {
    logicDevices.clear();
    circuitWires.clearAll();
  }
  
  /** Simulation tick */
  void tick() {
    for (LogicDevice device in logicDevices) { // Clear the calc status of each
      device.calculated = false;               // device  
    }
    for (LogicDevice device in logicDevices) { // Calculate the device
      device.Calculate();
    }
  }
  
  /** Try to select a logic device at given point */
  LogicDevice tryDeviceSelect(Point p) {
    for (LogicDevice device in logicDevices) {  
      if (device.contains(p.x, p.y)) {
        return device;
      }
    }            
    return null;
  }
  
  /** Try to select a logic device input at given point*/
  DeviceInput tryInputSelect(Point p) {
    for (LogicDevice device in logicDevices) { 
      if (device.InputPinHit(p.x, p.y) != null) {
        return device.InputPinHit(p.x, p.y);
      }
    }
    return null;
  }
  
  /** Try to select a logic device output at given point */
  DeviceOutput tryOutputSelect(Point p) {
    for (LogicDevice device in logicDevices) { 
      if (device.OutputPinHit(p.x, p.y) != null) {
        return device.OutputPinHit(p.x, p.y);
      }
    }   
    return null;
  }
  
  /** Returns true if we are adding a wire */
  bool get addingWire() {
    if(newWire != null) { 
      return true;
    }
    return false;
  }
  
  /** Select wire points at a give point */
  int selectWirePoints(int x, int y) {
    return circuitWires.selectWirePoints(x, y);
  }
  
  /** Try to select a wire at a given point */
  int tryWireSelect(Point p) { 
    return circuitWires.selectWire(p);
  }
  
  void onKeyUp(KeyboardEvent e) {
    int code = e.keyCode;
    bool shift = e.shiftKey;
    bool ctrl = e.ctrlKey;
    
    if(code == 46) { // Delete 
      if (addingWire) {
        abortWire();
        return;
      }
      
      if(circuitWires.wiresSelected){
        circuitWires.deleteSelectedWires();
      }
    }
    
   // print("keyPress shift:${shift} ctrl:${ctrl} code:${code}");
    
  }
  
  /** When the user presses down the mouse button */
  void onMouseDown(MouseEvent e) {
    e.preventDefault();
    uiPoint.x = e.offsetX;
    uiPoint.y = e.offsetY;
    
    // If we are moving a device stop moving it and stick it
    if (moveDevice != null) { 
      moveDevice = null;
      return;
    }
   
    // If we are adding a new wire try to add a new point to it
    if (newWire != null) {
      if (selectedWire != null) {
        newWire.output = selectedWire.output;  
      }
      addWirePoint(newWire.lastPoint);
      return;
    }
   
    // selectWirePoints for moving if there is any
    if (selectWirePoints(e.offsetX , e.offsetY) > 0) {
      return;
    } 
   
    // Try to start a wire
    if (StartWire(uiPoint) == true) { 
      return;
    }
   
    // Check to see if user has pressed a device add button
    LogicDevice selectedButton = tryButtonSelect(e.offsetX, e.offsetY);
    if (selectedButton != null) {
      newDeviceFrom(selectedButton);
      return;
    }
    
    // Try to select a device in the simulation
    LogicDevice selectedDevice = tryDeviceSelect(uiPoint);
    if (selectedDevice != null) {
      selectedDevices.selectTopAt(e.offsetX, e.offsetY);
      selectedDevice.clicked();
      return;
    }
    
    // Try to select a wire
    if (tryWireSelect(uiPoint) > 0) {
      selectedWire = circuitWires.firstSelectedWire();  
    }
    
}
 
  /** Called when the user releases mouse button */
  void onMouseUp(MouseEvent e) {
    e.stopPropagation();
    e.preventDefault();
    
    if (selectedDevices.count > 0) { // If we are moving devices stop it
      
      // Make sure that all the devices are not on our device selector bar
      bool allowDrop = true;
      for (LogicDevice d in selectedDevices.selectedDevices) {
        if (d.xPosition < TOOLBAR_WIDTH) {
          allowDrop = false;
        }
      }
      if (allowDrop) { // If all is good then allow the selected devices to be dropped
        selectedDevices.clear();
      }
    }
    
    // If we have points selected deselect them on mouse up
    if (circuitWires.pointsSelected) {
      circuitWires.deselectWirePoints();
    }
    
    if (movingWirePoint != null) { // deselect wire point 
      movingWirePoint = null;
    }
  }

  /** Called when the user is double clicking on their mizzouse */
  void onMouseDoubleClick(MouseEvent e) {
    e.stopPropagation();
    e.preventDefault();
  }
 
  /** Called when the user is moving the mouse */
  void onMouseMove(MouseEvent e) {
    mouseX = e.offsetX;
    mouseY = e.offsetY; 
    
    uiPoint.x = e.offsetX;
    uiPoint.y = e.offsetY;
        
    // If we have points selected move them
    if (circuitWires.pointsSelected) {
      circuitWires.moveSelectedPoints(uiPoint);
      return;
    }
    
    if (selectedDevices.count > 0) {
      selectedDevices.moveTo(mouseX, mouseY);
      return;
    }
   
    if (moveDevice != null) {
      moveDevice.MoveDevice(mouseX, mouseY);
      //draw();
      return;
    }
          
      
    // If we are moving a point update its position
    if (movingWirePoint != null) {
      movingWirePoint.x = mouseX;
      movingWirePoint.y = mouseY;
      return;
    }
   
    // If we are adding a wire update its last point
    if (addingWire) {
      newWire.UpdateLast(mouseX, mouseY);
      if (checkConnection(uiPoint)) {
        return;
      }
        
      if (newWire.input != null) { // Snap to a wire only when connecting from an input.
        // Try to select a wirepoint 
        selectedWirePoint = circuitWires.selectWirePoint(e.offsetX, e.offsetY);
        if (selectedWirePoint != null){
          newWire.UpdateLast(selectedWirePoint.x, selectedWirePoint.y);
        }
        else{
          selectedWire = circuitWires.wireHit(uiPoint);
          if (selectedWire != null) {
            Point p = selectedWire.getWireSnapPoint(e.offsetX, e.offsetY);
            if(p != null) {
              selectedWirePoint = p;
              newWire.UpdateLast(p.x, p.y);
            }
          }
        }
      }
      return;
    }
    
    // Check to see if mouse cursor is over a vaild point and select it
    if (checkValid(uiPoint)) { 
      return;
    }
    
    // Try to select a wirepoint 
    selectedWirePoint = circuitWires.selectWirePoint(e.offsetX, e.offsetY);
    if (selectedWirePoint != null){
      return;
    }
    
 }
 
  
 /** Check to see if this point is a vaild connection when adding a wire */
 bool checkConnection(Point p) {
   if (!addingWire) return false;
   
   // Looking for a vaild input
   if (newWire.needInput) {
     DeviceInput input = tryInputSelect(p); 
     selectedInput = input;
     if(selectedInput != null){
       newWire.UpdateLast(input.offsetX, input.offsetY); // snap to point
       return true;
     }
   }
   
   // Looking for a vaild output
   if(newWire.needOutput) {
     DeviceOutput output = tryOutputSelect(p);
     selectedOutput = output;
     if(selectedOutput != null) {
       newWire.UpdateLast(output.offsetX, output.offsetY); // snap to point 
       return true;
     }
   }
   return false;
 }
 
 /** Check to see if this point is vaild */
 bool checkValid(Point p) {
     
   if (newWire != null) { // We are adding a wire
     return checkConnection(p);  
   }
   
   selectedInput = tryInputSelect(p); 
  
   if (selectedInput != null){
     //drawHighlightPin(selectedInput.offsetX, selectedInput.offsetY, "VALID");  
     return true;
   }
   
   selectedOutput = tryOutputSelect(p);
   
   if (selectedOutput != null){
     //drawHighlightPin(selectedOutput.offsetX, selectedOutput.offsetY, "VALID");  
     return true;
   }
   
   return false;
 }

 /** Check the button type devices to see if any have the given point */
 LogicDevice tryButtonSelect(int x, int y) {
   for (LogicDevice device in deviceButtons) {
      if(device.contains(x, y)) {
         return device;
      }
   }
 }
 
 /** Try to start adding a wire, returns true if a wire is started */
 bool StartWire(Point p) {
    
    DeviceInput input = tryInputSelect(p);
    // If we have a vaild point then continue adding a wire
    if(input != null){ 
      newWire = new Wire();
      newWire.input = input;
      WirePoint wp = newWire.AddPoint(input.offsetX, input.offsetY);
      newWire.input = input;
      input.connectedWire = newWire;
      newWire.AddPoint(input.offsetX, input.offsetY); // extra point to track to mouse
      return true;
    }
    
    DeviceOutput output = tryOutputSelect(p);    
    if(output != null){
      newWire = new Wire();
      newWire.output = output;
      WirePoint wp = newWire.AddPoint(output.offsetX, output.offsetY);
      newWire.output = output;
      newWire.AddPoint(output.offsetX, output.offsetY); // extra point to track to mouse
      return true;
    }
    
    // If we are adding a new wire and we get here we should abort
    if(newWire != null)
      circuitWires.deleteWire(newWire);
 }
 
 /**
 / Add a new point to the wire and end it if vaild connection
 / returns true if wire point is added and false if wire connection ends
 */
 bool addWirePoint(Point p) {
   if(newWire == null) return false;

   newWire.UpdateLast(p.x, p.y);
   
   // Looking for a vaild input
   if (newWire.input == null) {
     DeviceInput input = tryInputSelect(p);
     if (input != null) {
       newWire.input = input;  
       newWire.UpdateLast(input.offsetX, input.offsetY);
       input.connectedWire = newWire;
       newWire.AddPoint(input.offsetX, input.offsetY);
       newWire.flipWire(); // reverse the wire so it starts with an input and goes to an output
       finishWire(); // Good connection
       return false;
     }
     else {// if user tries to place connection on top of start device then abort
       LogicDevice device = tryDeviceSelect(p);
       if (newWire.output.device != null){  
         if (device === newWire.output.device){
           abortWire();
           return false;
         }
       }
     }
     // Add the new point
     newWire.AddPoint(p.x, p.y);
     return true;
   }
   
   // Looking for a valid output
   if (newWire.output == null) {
     
     // Check for output points
     DeviceOutput output = tryOutputSelect(p); 
     if (output != null) {
       newWire.output = output;
       newWire.UpdateLast(output.offsetX, output.offsetY);
       finishWire(); // Good connection
       return false;
     }
     
     // Check for wire points
     WirePoint wp = circuitWires.selectWirePoint(p.x, p.y);
     if (wp != null) {
       newWire.output = wp.wire.output;
       newWire.UpdateLast(wp.x, wp.y);

       WirePoint endPoint = newWire.getLastPoint();
       newWire.setKnot(endPoint, true);
       newWire.AddPoint(wp.x, wp.y);
       
       WireSegment ws = wp.wire.getSegment(wp);
       List<WirePoint> endWire = wp.wire.insertPoint(ws, wp);
       
       newWire.addWire(endWire);

       finishWire(); // Good connection
       return false;
       }
     }
     
     // Check on wire
     Wire w = circuitWires.wireHit(p);
     if (w != null) {
       Point sp = selectedWire.getWireSnapPoint(p.x, p.y);
       if(sp != null) {
         newWire.output = w.output;
         newWire.UpdateLast(sp.x, sp.y);
         
         WirePoint endPoint = newWire.getLastPoint();
         newWire.setKnot(endPoint, true);
         newWire.AddPoint(sp.x, sp.y);
         
         WireSegment ws = w.getSegment(sp);
         List<WirePoint> endWire = w.insertPoint(ws, sp);
         newWire.addWire(endWire);

         finishWire(); // Good connection
         return false;
        }
     }
     
     // if user tries to place connection on top of start device then abort 
     LogicDevice device = tryDeviceSelect(p);
     if (newWire.input.device != null) {  
       if (device === newWire.input.device) {
         abortWire();
         return false;
       }
     }

  // Check vaid connection
   if(newWire.input != null && newWire.output != null) {
     newWire = null;
     return false;
   }

   // Add the new point
   newWire.AddPoint(p.x, p.y);
   return true;
 }
  
  /** Finish adding a wire to the simulation */
  void finishWire() {
    if (newWire.input != null && newWire.output != null) {
      circuitWires.addWire(newWire);
      newWire = null;
    }
  }
 
  /** Abort adding a wire to the simulation */
  void abortWire() {
    selectedInput = null;
    selectedOutput = null;
    
    // Remove the new wire if we abort adding the wire
    if(newWire != null){
      circuitWires.deleteWire(newWire);
      newWire = null;
    }
  }

  /** Redraws the entire simulation */
  void draw() {
    
    clearCanvas(); // Clear the background 
    
    drawBorder(); // Draw the border of the simulation
    
    if(showGrid) drawGrid(); // Draw a background grid
    
    drawDeviceButtons(); // Redraw all of the device buttons 
    
    drawSelectedWires(); // Draw the selected wires
    
    drawWires(); // Draw all the wires
    
    drawDevices(); // Draw all the devices
        
    drawPinSelectors(); // Draw pin selectors
  }
  
  /** Clear the background */
  void clearCanvas() {
    context.clearRect(0, 0, width, height);
  }
  
  /** Draws the simulation border */
  void drawBorder() {
    context.beginPath();
    context.rect(TOOLBAR_WIDTH, 0, width, height);
    context.fillStyle = GRID_BACKGROUND_COLOR;
    context.lineWidth = BORDER_LINE_WIDTH;
    context.strokeStyle = GRID_BACKGROUND_COLOR;
    context.fillRect(TOOLBAR_WIDTH, 0, width, height);
    context.stroke();
    context.closePath();
  }
  
  /** Draw the background grid */
  void drawGrid(){
    context.fillStyle = backgroundPattern;  
    context.fillRect(TOOLBAR_WIDTH, 0, width, height);  
  }
  
  /** Redraw all of the device buttons */
  void drawDeviceButtons(){
   for (LogicDevice device in deviceButtons) {
      context.drawImage(device.deviceType.getImage(device.outputs[0].value), device.xPosition, device.yPosition);   
    }
  }
  
  /** Redraw all of the devices */
  void drawDevices(){
    for (LogicDevice device in logicDevices) {
      context.drawImage(device.deviceType.getImage(device.outputs[0].value), device.xPosition, device.yPosition);  
    }
  }
  
  /** Draw all the wires in the simulation */
  void drawWires() {
    for (Wire wire in circuitWires.wires) { 
      drawWire(wire);
    }
    if (newWire != null){
      drawWire(newWire);
    }
  }
  
  /** Draw all the selected wires in the simulation */
  void drawSelectedWires() {
    for (Wire wire in circuitWires.selectedWires) { 
      drawSelectedWire(wire);
    }
  }
  
  /** Draw all the selected wires in the simulation */
  void drawSelectedWire(Wire wire) {
    if(wire == null) return;  
    
    context.beginPath();
    context.strokeStyle = WIRE_SELECT_STYLE;
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
    context.lineWidth = WIRE_WIDTH;
    
    context.lineCap = 'round';
    context.lineJoin = 'round';
    context.miterLimit = 10;

    if(wire.input == null || wire.output == null){
      context.strokeStyle = WIRE_INVALID;
    }
    else{
      if(wire.output.value == true){ // High
        context.strokeStyle = WIRE_HIGH;
      }
      else{
        context.strokeStyle = WIRE_LOW;
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
    if(selectedOutput != null){
      drawHighlightPin(selectedOutput.offsetX, selectedOutput.offsetY, 'VALID'); 
    }
    
    if (selectedInput != null){
      if (selectedInput.connected)
        drawHighlightPin(selectedInput.offsetX, selectedInput.offsetY, 'CONNECTED');
      else
        drawHighlightPin(selectedInput.offsetX, selectedInput.offsetY, 'VALID');
    }
    
    if(selectedWirePoint != null){
      drawHighlightPin(selectedWirePoint.x , selectedWirePoint.y, 'VALID'); 
    }
        
    // If we are adding a wire draw acceptable connection points
    if(newWire != null){
      if(newWire.input == null) { // Looking for a vaild input
        drawConnectableInputPins();
      }
      if(newWire.output == null){ // Looking for a vaild output
        drawConnectableOutputPins();
      }
    }
  }
  
  /** Draw the output pins that we can connect to */
  void drawConnectableOutputPins() {
    for (LogicDevice device in logicDevices) {
      for (DeviceOutput output in device.outputs) {
        if(output.connectable == true)
          drawHighlightPin(output.offsetX, output.offsetY, 'CONNECTABLE'); 
      }
    }      
  }
  
  /** Draw the input pins that we can connect to */
  void drawConnectableInputPins() {
    for (LogicDevice device in logicDevices) {
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
    
    context.arc(x, y, 7, 0, PI2, true);  
    
    context.fill();
    context.stroke();  
    context.closePath(); 
  }
  
}
  
