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
  static final String WIRE_INVALID = '#999999';
  static final int    WIRE_WIDTH = 4;
  static final int GRID_SIZE = 10;
  static final int GRID_POINT_SIZE = 1;
  static final String GRID_COLOR = '#999493';
  static final String GRID_BACKGROUND_COLOR = '#eeeeee';
  static final int PIN_INDICATOR_OFFSET = 5;
  static final TAU = Math.PI * 2;
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

  bool showGrid = false;
  bool gridSnap = false;
  
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
    
    background = new Element.tag('img');
    background.src = "images/GridBackground.png";
    background.on.load.add((Event e) { backgroundPattern = context.createPattern(background,'repeat');});
    
    window.setInterval(f() => tick(), 50); // Create a timer to update the simulation tick
    window.on.resize.add((event) => onResize(), true);
    
    canvas.on.mouseDown.add(onMouseDown);
    canvas.on.mouseUp.add(onMouseUp);
    canvas.on.doubleClick.add(onMouseDoubleClick);
    canvas.on.mouseMove.add(onMouseMove);
  }
  
  /** Start the simulation */
  void start() {
    createSelectorBar();
    onResize();
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
    
    draw();
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
    draw();
  }
  
  /** Simulation tick */
  void tick() {
    
    for (LogicDevice device in logicDevices) { // Clear the calc status of each
      device.calculated = false;               // device  
    }
    for (LogicDevice device in logicDevices) { // Calculate the device
      device.Calculate();
    }
  
    draw(); // Redraw background
  }
  
  /** Try to select a logic device at given point*/
  LogicDevice tryDeviceSelect(int x, int y) {
    for (LogicDevice device in logicDevices) {  
      if (device.contains(x, y)) {
        return device;
      }
    }            
    return null;
  }
  
  /** Try to select a logic device input at given point*/
  DeviceInput tryInputSelect(int x, int y) {
    for (LogicDevice device in logicDevices) { 
      if (device.InputPinHit(x, y) != null) {
        return device.InputPinHit(x, y);
      }
    }
    return null;
  }
  
  /** Try to select a logic device output at given point */
  DeviceOutput tryOutputSelect(int x, int y) {
    for (LogicDevice device in logicDevices) { 
      if (device.OutputPinHit(x, y) != null) {
        return device.OutputPinHit(x, y);
      }
    }   
    return null;
  }
  
  /** Try to select a wire at a given point */
  int tryWireSelect(int x, int y) { 
    return circuitWires.selectWire(x, y);
  } 
  
  /** When the user presses down the mouse button */
  void onMouseDown(MouseEvent e) {
    e.preventDefault();
   
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
      addWirePoint(newWire.lastX, newWire.lastY);
      return;
    }
   
    // Start moving a wirepoint if it was selected 
    if (selectedWirePoint != null) {
      movingWirePoint = selectedWirePoint; 
      selectedWirePoint = null; 
      return;
    } 
   
    // Try to start a wire
    if (StartWire(e.offsetX , e.offsetY) == true) { 
      return;
    }
   
    // Check to see if user has pressed a device add button
    LogicDevice selectedButton = tryButtonSelect(e.offsetX, e.offsetY);
    if (selectedButton != null) {
      newDeviceFrom(selectedButton);
      return;
    }
    
    // Try to select a device in the simulation
    LogicDevice selectedDevice = tryDeviceSelect(e.offsetX, e.offsetY);
    if (selectedDevice != null) {
      selectedDevices.selectTopAt(e.offsetX, e.offsetY);
      selectedDevice.clicked();
      return;
    }
    
    // Try to select or deselect a wire
    if (tryWireSelect(e.offsetX, e.offsetY) > 0) {
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
    
    if (selectedDevices.count > 0) {
      selectedDevices.moveTo(mouseX, mouseY);
      return;
    }
   
    if (moveDevice != null) {
      moveDevice.MoveDevice(mouseX, mouseY);
      draw();
      return;
    }
    
    // If we are moving a point update its position
    if (movingWirePoint != null) {
      movingWirePoint.x = mouseX;
      movingWirePoint.y = mouseY;
      return;
    }
   
    // If we are adding a wire update its last point
    if (newWire != null) {
      newWire.UpdateLast(mouseX, mouseY);
      if (checkConnection(e.offsetX, e.offsetY)) {
        draw();
        return;
        // Check to see if we have valid connection
      }
        
      if (newWire.input != null) { // Snap to a wire only when connecting from an input.
        // Try to select a wirepoint 
        selectedWirePoint = circuitWires.selectWirePoint(e.offsetX, e.offsetY);
        if (selectedWirePoint != null){
          newWire.UpdateLast(selectedWirePoint.x, selectedWirePoint.y);
        }
        else{
          selectedWire = circuitWires.wireHit(e.offsetX, e.offsetY);
          if (selectedWire != null) {
            Point p = selectedWire.getWireSnapPoint(e.offsetX, e.offsetY);
            if(p != null) {
              selectedWirePoint = p;
              newWire.UpdateLast(p.x, p.y);
            }
          }
        }
      }
      
      draw();
      return;
    }
    
    // Check to see if mouse cursor is over a vaild point and select it
    if (checkValid(e.offsetX, e.offsetY)) { 
      return;
    }
    
    // Try to select a wirepoint 
    selectedWirePoint = circuitWires.selectWirePoint(e.offsetX, e.offsetY);
    if (selectedWirePoint != null){
      return;
    }
    
 }
 
 
 /** Check to see if this point is a vaild connection */
 bool checkConnection(int x, int y) {
   if (newWire == null) return false;
   
   // Looking for a vaild input
   if (newWire.input == null) {
     DeviceInput input = tryInputSelect(x, y); 
     selectedInput = input;
     if(selectedInput != null){
       newWire.UpdateLast(input.offsetX, input.offsetY); // snap to point
       return true;
     }
   }
   
   // Looking for a vaild output
   if(newWire.output == null) {
     DeviceOutput output = tryOutputSelect(x, y);
     selectedOutput = output;
     if(selectedOutput != null) {
       newWire.UpdateLast(output.offsetX, output.offsetY); // snap to point 
       return true;
     }
   }
   return false;
 }
 
 /** Check to see if this point is vaild */
 bool checkValid(int x, int y) {
     
   if (newWire != null) { // We are adding a wire
     return checkConnection(x, y);  
   }
   
   selectedInput = tryInputSelect(x, y); 
  
   if (selectedInput != null){
     //drawHighlightPin(selectedInput.offsetX, selectedInput.offsetY, "VALID");  
     return true;
   }
   
   selectedOutput = tryOutputSelect(x, y);
   
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
 bool StartWire(int x, int y) {
    
    DeviceInput input = tryInputSelect(x, y);
    // If we have a vaild point then continue adding a wire
    if(input != null){ 
      newWire = new Wire();
      newWire.input = input;
      WirePoint wp = newWire.AddPoint(input.offsetX, input.offsetY);
      newWire.input = input;
      input.connectedWire = newWire;
      newWire.AddPoint(input.offsetX, input.offsetY); // extra point to track to mouse
      //print("StartWire:${input.device.id} ${input.id}");
      return true;
    }
    
    DeviceOutput output = tryOutputSelect(x, y);    
    if(output != null){
      newWire = new Wire();
      newWire.output = output;
      WirePoint wp = newWire.AddPoint(output.offsetX, output.offsetY);
      newWire.output = output;
      newWire.AddPoint(output.offsetX, output.offsetY); // extra point to track to mouse
      //print("StartWire:${output.device.id} ${output.id}");
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
 bool addWirePoint(int x, int y) {
   
   if(newWire == null) return false;

   newWire.UpdateLast(x, y);
      
   // Looking for a vaild input
   if (newWire.input == null) {
     DeviceInput input = tryInputSelect(x, y);
     if (input != null) {
       newWire.input = input;  
       newWire.UpdateLast(input.offsetX, input.offsetY);
       input.connectedWire = newWire;
       newWire.AddPoint(input.offsetX, input.offsetY);
       finishWire(); // Good connection
       return false;
     }
     else {// if user tries to place connection on top of start device then abort
       LogicDevice device = tryDeviceSelect(x, y);
       if (newWire.output.device != null){  
         if (device === newWire.output.device){
           abortWire();
           return false;
         }
       }
     }
   }
   
   // Looking for a valid output
   if (newWire.output == null) {
     
     // Check for output points
     DeviceOutput output = tryOutputSelect(x, y); 
     if (output != null) {
       newWire.output = output;
       newWire.UpdateLast(output.offsetX, output.offsetY);
       finishWire(); // Good connection
       print("output select");
       return false;
     }
     
     // Check for wire points
     WirePoint wp = circuitWires.selectWirePoint(x, y);
     if (wp != null) {
       newWire.output = wp.wire.output;
       newWire.UpdateLast(wp.x, wp.y);
       newWire.addKnot(wp.x, wp.y);
       newWire.AddPoint(wp.x, wp.y);
       finishWire(); // Good connection
       return false;
       }
     }
     
     // Check on wire
     Wire w = circuitWires.wireHit(x, y);
     if (w != null) {
       Point p = selectedWire.getWireSnapPoint(x, y);
       if(p != null) {
         newWire.output = w.output;
         newWire.UpdateLast(p.x, p.y);
         newWire.addKnot(p.x, p.y);
         newWire.AddPoint(p.x, p.y);
         finishWire(); // Good connection
         print("Wire Hit Snap Point");
         return false;
        }
     }
     
     //else {// if user tries to place connection on top of start device then abort 
       LogicDevice device = tryDeviceSelect(x, y);
       if (newWire.input.device != null) {  
         if (device === newWire.input.device) {
           abortWire();
           return false;
         }
       }

//   // Check vaid connection
   if(newWire.input != null && newWire.output != null) {
     newWire = null;
     return false;
   }

   // Add the new point
   newWire.AddPoint(x, y);
   print("add point");
   return true;
 }
  
 void finishWire() {
   if (newWire.input != null && newWire.output != null) {
    circuitWires.addWire(newWire);
    newWire = null;
    print("finish wire");
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
    draw();
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
    context.strokeStyle = 'hsla(40, 100%, 60%, 0.75)';
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
    //context.fillStyle = context.strokeStyle;
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
    context.arc(x, y, 6, 0, TAU, false);
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
    
    //DeviceIO.IO_HIT_RADIUS
    
    context.arc(x, y, 7, 0, TAU, true);  
    
    context.fill();
    context.stroke();  
    context.closePath(); 

  }
  
}
  
