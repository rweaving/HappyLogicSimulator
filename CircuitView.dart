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

class CircuitView {

 
  static final int TOOLBAR_WIDTH = 115;
  
  CanvasElement canvas;
  
  
  Circuit circuit; // Handles the circuit simulation
  CircuitDraw circuitDraw; // Draws the simulation
  
  int width;
  int height;
  
  List<LogicDevice> deviceButtons; 
  
  Point wireSnapPoint; // A point that holds the wiresnap pointer
  Point uiPoint;


  bool gridSnap;
  
  CircuitView(this.canvas) :
    circuit = new Circuit() { // Create a circuit

    circuitDraw = new CircuitDraw(circuit, canvas);
    deviceButtons = new List<LogicDevice>();
        
    //context = canvas.getContext('2d');
    width = canvas.width;
    height = canvas.height;
    
    uiPoint = new Point(0,0);
    
    window.on.resize.add((event) => onResize(), true);
    canvas.on.mouseDown.add(onMouseDown);
    canvas.on.mouseUp.add(onMouseUp);
    canvas.on.doubleClick.add(onMouseDoubleClick);
    canvas.on.mouseMove.add(onMouseMove);
    
    // Touch Events
    //canvas.on.touchEnter.add((event) => onTouchEnter(event), false);
    canvas.on.touchStart.add((event) => onTouchStart(event), false);
    canvas.on.touchMove.add((event) => onTouchMove(event), false);
    canvas.on.touchEnd.add((event) => onTouchEnd(event), false);
    //canvas.on.touchCancel.add((event) => onTouchCancel(event), false);
    //canvas.on.touchLeave.add((event) => onTouchLeave(event), false); 
    
    window.setInterval(f() => draw(), 50); 
    
    document.on.keyUp.add(onKeyUp);
  }
  
  
  /** Start the simulation */
  void start() {
    createSelectorBar();
    onResize();
    circuit.run = true;
   // window.webkitRequestAnimationFrame(animate);
  }
  
  /** Stop the simulation */
  void stop() {
    circuit.run = false;  
  }
  
  /** Redraw the simulation */
  void animate(int time) {
//    if (circuit.run) {
//      draw(); // Draw the circuit
//      window.webkitRequestAnimationFrame(animate); // Use animation frame 
//    }
  }
  
  /** When the simulation is resized this is called. */
  void onResize() {
    height = window.innerHeight - 25;
    width = window.innerWidth - 25;
    
    canvas.height = height;
    canvas.width = width;
    
    circuitDraw.onResize();
    draw();
  }
  
  /** Redraws the entire circuit */
  void draw() {
    circuitDraw.clearCanvas(); // Clear the background 
    circuitDraw.drawBorder(); // Draw the border of the simulation
    //circuitDraw.drawGrid(); // Draw a background grid
    circuitDraw.drawDevices(deviceButtons); // Redraw all of the device buttons
    circuitDraw.drawSelectedWires(); // Draw the selected wires
    circuitDraw.drawWires(); // Draw all the wires
    circuitDraw.drawDevices(circuit.logicDevices); // Draw the logic circuit devices
    circuitDraw.drawPinSelectors(); // Draw pin selectors
  }
  
  /** Creates the button bar to add devices */
  void createSelectorBar() {
    addButton('CLOCK');
    addButton('INPUT');
    addButton('NOT');
    addButton('AND');
    addButton('NAND');
    addButton('OR');
    addButton('NOR');
    addButton('XOR');
    addButton('XNOR');
    addButton('OUTPUT');
   // addButton('LED');
  }
  
  int buttonIndex = 0;
  void addButton(var type){
    
    addNewButtonDevice(type, type, 0, buttonIndex * 60);
    
    buttonIndex++;
  }
  
  /** add a new button type device */
  LogicDevice addNewButtonDevice(var id, var type, int x, int y) {
    LogicDeviceType deviceType = circuit.deviceTypes.getDeviceType(type);
    if(deviceType != null){
        LogicDevice newDevice = new LogicDevice(deviceType); 
        deviceButtons.add(newDevice);
        newDevice.selectable = false;
        newDevice.MoveDevice(new Point(x, y));
        return newDevice;
    }
  }
  
  void onKeyUp(KeyboardEvent e) {
    int code = e.keyCode;
    bool shift = e.shiftKey;
    bool ctrl = e.ctrlKey;
    
    if(code == 27) { // Esc
      if (circuit.addingWire) {
        circuit.abortWire();
        return;
      }
    }
    
    if(code == 46) { // Delete 
      if (circuit.addingWire) {
        circuit.abortWire();
        return;
      }
      
      if(circuit.circuitWires.wiresSelected){
        circuit.circuitWires.deleteSelectedWires();
      }
    }
//    print("keyPress shift:${shift} ctrl:${ctrl} code:${code}");
  }
  
  /** When the use touches the screen this is called */
  void onTouchEnter(TouchEvent e) {
    uiPoint.x = e.targetTouches[0].pageX;
    uiPoint.y = e.targetTouches[0].pageY;
    
    e.preventDefault();
    
    if (uiSelect()) {
      //e.preventDefault();
      e.stopPropagation();
    }
  }
  
  void onTouchStart(TouchEvent e) {
    uiPoint.x = e.targetTouches[0].pageX;
    uiPoint.y = e.targetTouches[0].pageY;
    e.preventDefault();
    
    if (uiSelect()) {
      e.stopPropagation();
    }
    //e.stopPropagation();
  }
  
  void onTouchMove(TouchEvent e) {
    uiPoint.x = e.targetTouches[0].pageX;
    uiPoint.y = e.targetTouches[0].pageY;
    
    e.preventDefault();
  
    if (uiMove()) {
      e.stopPropagation();
    }
  }
  
  void onTouchEnd(TouchEvent e) {
    uiPoint.x = e.targetTouches[0].pageX;
    uiPoint.y = e.targetTouches[0].pageY;
    
    e.preventDefault();
    uiEndAction();
  }
  
  void onTouchLeave(TouchEvent e) {
    uiPoint.x = e.targetTouches[0].pageX;
    uiPoint.y = e.targetTouches[0].pageY;
    
    e.preventDefault();
    uiEndAction();

  }
  
  void onTouchCancel(TouchEvent e) {
    uiPoint.x = e.targetTouches[0].pageX;
    uiPoint.y = e.targetTouches[0].pageY;
    
    e.preventDefault();
    uiEndAction();
  }
  
  /** Do a select a the ui point */
  bool uiSelect() {
    // If we are moving a device stop moving it and stick it
    if (circuit.moveDevice != null) { 
      circuit.moveDevice = null;
      return true;
    }
    
    if (circuit.selectedDevices.count > 0) {
      return true;
    } 
    
    // If we are adding a new wire try to add a new point to it
    if (circuit.newWire != null) {
      if (circuit.selectedWire != null) {
        circuit.newWire.output = circuit.selectedWire.output;  
      }
      circuit.addWirePoint(circuit.newWire.lastPoint);
      return true;
    }
   
    // selectWirePoints for moving if there is any
    if (circuit.selectWirePoints(uiPoint) > 0) {
      return true;
    } 
   
    // Try to start a wire
    if (circuit.StartWire(uiPoint) == true) { 
      return  true;
    }
   
    // Check to see if user has pressed a device add button
    LogicDevice selectedButton = tryButtonSelect(uiPoint);
    if (selectedButton != null) {
      circuit.newDeviceFrom(selectedButton, uiPoint);
      return true;
    }
    
    // Try to select a device in the simulation
    LogicDevice selectedDevice = circuit.tryDeviceSelect(uiPoint);
    if (selectedDevice != null) {
      circuit.selectedDevices.selectTopAt(uiPoint);
      selectedDevice.clicked();
      return true;
    }
    
    // Try to select a wire
    if (circuit.tryWireSelect(uiPoint) > 0) {
      circuit.selectedWire = circuit.circuitWires.firstSelectedWire();  
      return true;
    }
    
    return false;
  }
 
  /** Do a move on the ui point */
  bool uiMove() {
    // If we have points selected move them
    if (circuit.circuitWires.pointsSelected) {
      circuit.circuitWires.moveSelectedPoints(uiPoint);
      return true;
    }
    
    // If we have devices seleced move them to the new location
    if (circuit.selectedDevices.count > 0) {
      circuit.selectedDevices.moveTo(uiPoint);
      return true;
    }
   
    if (circuit.moveDevice != null) {
      circuit.moveDevice.MoveDevice(uiPoint);
      return true;
    }
      
    // If we are moving a point update its position
    if (circuit.movingWirePoint != null) {
      circuit.movingWirePoint = uiPoint;
      return true;
    }
   
    // If we are adding a wire update its last point
    if (circuit.addingWire) {
      circuit.newWire.UpdateLast(uiPoint);
      if (circuit.checkConnection(uiPoint)) {
        return true;
      }
        
      if (circuit.newWire.input != null) { // Snap to a wire only when connecting from an input.
        // Try to select a wirepoint 
        circuit.selectedWirePoint = circuit.circuitWires.selectWirePoint(uiPoint);
        if (circuit.selectedWirePoint != null){
          circuit.newWire.UpdateLast(uiPoint);
        }
        else{
          circuit.selectedWire = circuit.circuitWires.wireHit(uiPoint);
          if (circuit.selectedWire != null) {
            Point p = circuit.selectedWire.getWireSnapPoint(uiPoint);
            if(p != null) {
              circuit.selectedWirePoint = p;
              circuit.newWire.UpdateLast(p);
            }
          }
        }
      }
      return true;
    }
    return false;
  }
  
  /** Stop the ui action that the user is doing */
  bool uiEndAction() {
  
    if (circuit.selectedDevices.count > 0) { // If we are moving devices stop it
      // Make sure that all the devices are not on our device selector bar
      bool allowDrop = true;
      for (LogicDevice d in circuit.selectedDevices.selectedDevices) {
        if (d.position.x < TOOLBAR_WIDTH) {
          allowDrop = false;
        }
      }
      if (allowDrop) { // If all is good then allow the selected devices to be dropped
        circuit.selectedDevices.clear();
      }
    }
        
    // If we have points selected deselect them on mouse up
    if (circuit.circuitWires.pointsSelected) {
      circuit.circuitWires.deselectWirePoints();
    }
    
    if (circuit.movingWirePoint != null) { // deselect wire point 
      circuit.movingWirePoint = null;
    }  
    
    return true;
  }
  
  /** When the user presses down the mouse button */
  void onMouseDown(MouseEvent e) {
    e.preventDefault();
    
    uiPoint.x = e.offsetX;
    uiPoint.y = e.offsetY;
    
    // If we are moving a device stop moving it and stick it
    if (circuit.moveDevice != null) { 
      circuit.moveDevice = null;
      return;
    }
    
    // If we are adding a new wire try to add a new point to it
    if (circuit.newWire != null) {
      if (circuit.selectedWire != null) {
        circuit.newWire.output = circuit.selectedWire.output;  
      }
      circuit.addWirePoint(circuit.newWire.lastPoint);
      return;
    }
   
    // selectWirePoints for moving if there is any
    if (circuit.selectWirePoints(uiPoint) > 0) {
      return;
    } 
   
    // Try to start a wire
    if (circuit.StartWire(uiPoint) == true) { 
      return;
    }
   
    // Check to see if user has pressed a device add button
    LogicDevice selectedButton = tryButtonSelect(uiPoint);
    if (selectedButton != null) {
      circuit.newDeviceFrom(selectedButton, uiPoint);
      return;
    }
    
    // Try to select a device in the simulation
    LogicDevice selectedDevice = circuit.tryDeviceSelect(uiPoint);
    if (selectedDevice != null) {
      circuit.selectedDevices.selectTopAt(uiPoint);
      selectedDevice.clicked();
      return;
    }
    
    // Try to select a wire
    if (circuit.tryWireSelect(uiPoint) > 0) {
      circuit.selectedWire = circuit.circuitWires.firstSelectedWire();  
    }
}
 
  /** Called when the user releases mouse button */
  void onMouseUp(MouseEvent e) {
    e.stopPropagation();
    e.preventDefault();
    
    if (circuit.selectedDevices.count > 0) { // If we are moving devices stop it
      
      // Make sure that all the devices are not on our device selector bar
      bool allowDrop = true;
      for (LogicDevice d in circuit.selectedDevices.selectedDevices) {
        if (d.position.x < TOOLBAR_WIDTH) {
          allowDrop = false;
        }
      }
      if (allowDrop) { // If all is good then allow the selected devices to be dropped
        circuit.selectedDevices.clear();
      }
    }
        
    // If we have points selected deselect them on mouse up
    if (circuit.circuitWires.pointsSelected) {
      circuit.circuitWires.deselectWirePoints();
    }
    
    if (circuit.movingWirePoint != null) { // deselect wire point 
      circuit.movingWirePoint = null;
    }
  }

  /** Called when the user is double clicking on their mizzouse */
  void onMouseDoubleClick(MouseEvent e) {
    e.stopPropagation();
    e.preventDefault();
  }
 
  /** Called when the user is moving the mouse */
  void onMouseMove(MouseEvent e) {
    uiPoint.x = e.offsetX;
    uiPoint.y = e.offsetY;
        
    // If we have points selected move them
    if (circuit.circuitWires.pointsSelected) {
      circuit.circuitWires.moveSelectedPoints(uiPoint);
      return;
    }
    
    // If we have devices seleced move them to the new location
    if (circuit.selectedDevices.count > 0) {
      circuit.selectedDevices.moveTo(uiPoint);
      return;
    }
   
    if (circuit.moveDevice != null) {
      circuit.moveDevice.MoveDevice(uiPoint);
      return;
    }
      
    // If we are moving a point update its position
    if (circuit.movingWirePoint != null) {
      circuit.movingWirePoint = uiPoint;
      return;
    }
   
    // If we are adding a wire update its last point
    if (circuit.addingWire) {
      circuit.newWire.UpdateLast(uiPoint);
      if (circuit.checkConnection(uiPoint)) {
        return;
      }
        
      if (circuit.newWire.input != null) { // Snap to a wire only when connecting from an input.
        // Try to select a wirepoint 
        circuit.selectedWirePoint = circuit.circuitWires.selectWirePoint(uiPoint);
        if (circuit.selectedWirePoint != null){
          circuit.newWire.UpdateLast(uiPoint);
        }
        else{
          circuit.selectedWire = circuit.circuitWires.wireHit(uiPoint);
          if (circuit.selectedWire != null) {
            Point p = circuit.selectedWire.getWireSnapPoint(uiPoint);
            if(p != null) {
              circuit.selectedWirePoint = p;
              circuit.newWire.UpdateLast(p);
            }
          }
        }
      }
      return;
    }
    
    // Check to see if mouse cursor is over a vaild point and select it
    if (circuit.checkValid(uiPoint)) { 
      return;
    }
    
    // Try to select a wirepoint 
    circuit.selectedWirePoint = circuit.circuitWires.selectWirePoint(uiPoint);
    if (circuit.selectedWirePoint != null){
      return;
    }
    
 }
 
 /** Check the button type devices to see if any have the given point */
 LogicDevice tryButtonSelect(Point p) {
   for (LogicDevice device in deviceButtons) {
      if(device.contains(p)) {
         return device;
      }
   }
 }
  
}
