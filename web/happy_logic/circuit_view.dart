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

part of happy_logic;

class CircuitView {

  static final int TOOLBAR_WIDTH = 115;

  CanvasElement canvas;
  DeviceCreator deviceCreator;

  Circuit circuit; // Handles the circuit simulation
  CircuitDraw circuitDraw; // Draws the simulation

  int width;
  int height;

  List<LogicDevice> deviceButtons;

  CanvasPoint wireSnapPoint; // A point that holds the wiresnap pointer
  CanvasPoint uiPoint;

  bool useAnimationFrame;

  bool gridSnap;


  CircuitView(this.canvas) :
    circuit = new Circuit() { // Create a circuit

    circuitDraw = new CircuitDraw(circuit, canvas);
    deviceButtons = new List<LogicDevice>();
    deviceCreator = new DeviceCreator();

    width = canvas.width;
    height = canvas.height;

    useAnimationFrame = true;//false; // Check browser specs to see if we can use animation frame

    uiPoint = new CanvasPoint(0,0);

    window.on.resize.add((event) => onResize(), true);
    canvas.on.mouseDown.add(onMouseDown);
    canvas.on.mouseUp.add(onMouseUp);
    canvas.on.doubleClick.add(onMouseDoubleClick);
    canvas.on.mouseMove.add(onMouseMove);

    // Touch Events
    canvas.on.touchStart.add((event) => onTouchStart(event), false);
    canvas.on.touchMove.add((event) => onTouchMove(event), false);
    canvas.on.touchEnd.add((event) => onTouchEnd(event), false);

    window.setInterval(() => drawUpdate(), 50);

    //window.requestAnimationFrame(animate));

    document.on.keyUp.add(onKeyUp);
    document.on.keyDown.add(onKeyDown);
  }


  /** Start the simulation */
  void start() {
    createSelectorBar();
    onResize();
    circuit.run = true;

    if(useAnimationFrame) {
      window.requestAnimationFrame(animate);
    }
   }

  /** Stop the simulation */
  void stop() {
    circuit.run = false;
  }

  /** Redraw the simulation */
  animate(num highResTime) {

    if(highResTime >= 16) {
      draw(); // Draw the circuit
    }

    window.requestAnimationFrame(animate);
  }

  /** Called by window timer to redraw */
  void drawUpdate() {
    if(!useAnimationFrame) {
      if (circuit.run) {
        draw();
      }
    }
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
//    addButton('CLOCK');
    addButton('INPUT');
    addButton('NOT');
    addButton('AND');
   // addButton('AND3');
    addButton('NAND');
//    addButton('OR');
//    addButton('NOR');
//    addButton('XOR');
//    addButton('XNOR');
    addButton('OUTPUT');
    addButton('TFF');

    var element = document.query('device');

    if (element != null) {
      print("image:${element.attributes['image']}");
    }
    else {
      print("NOPE");
    }
//    var element = new Element.tag('div');
//
//    element.classes.add('device');
//    element.attributes['name'] = "AND";
//    element.attributes['base'] = "images/125dpi/and.png";
//    element.attributes['icon'] = "images/125dpi/and_d.png";
//    element.attributes['data'] = """"inputs":[{"y":12,"id":0,"x":2},{"y":32,"id":1,"x":2}],"outputs":[{"y":22,"id":3,"x":90}],"subdevices":[{"c2":0,"id":0,"type":"IN","c1":-1},{"c2":1,"id":1,"type":"IN","c1":-1},{"c2":1,"id":2,"type":"AND","c1":0},{"c2":0,"id":3,"type":"OUT","c1":2}]}""";
//    document.body.nodes.add(element);

    //circuit.newDeviceAt('ARROWPAD', new CanvasPoint(175, 50));
    //circuit.newDeviceAt('SOUNDTRIGGER_4BIT', new CanvasPoint(600, 50));

    //addButton('CLOCKED_RSFF');
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
        LogicDevice newDevice = new LogicDevice(deviceType, id);
        deviceButtons.add(newDevice);
        newDevice.selectable = false;
        newDevice.moveDevice(new CanvasPoint(x, y));
        return newDevice;
    }
  }

  /** Triggered when the user presses down a key */
  void onKeyDown(KeyboardEvent e) {
    e.preventDefault();

    circuit.keyDown(e.keyCode);
  }

  /** Triggered when the user lets up on a key */
  void onKeyUp(KeyboardEvent e) {
    int code = e.keyCode;
    bool shift = e.shiftKey;
    bool ctrl = e.ctrlKey;

    e.preventDefault();

    circuit.keyUp(e.keyCode);

    if(code == 27) { // Esc

      //AudioElement audio = new AudioElement("sounds/poke-pikachuhappy.ogg"); // Audio test
      //audio.play();

      //deviceCreator.createDevice(circuit.logicDevices, document);

      circuit.saveCircuit(document);

      if (circuit.addingWire) {
        circuit.abortWire();
        return;
      }
    }

    //print("${code}");

    if (code == 76)  {
      circuit.loadCircuit("And2", document);
    }
    if (code == 84)  {
      circuit.loadCircuit("Tff", document);
    }

    if (code == 46) { // Delete
      if (circuit.addingWire) {
        circuit.abortWire();
        return;
      }

      if (circuit.circuitWires.wiresSelected) {
        circuit.circuitWires.deleteSelectedWires();
      }
    }
  }

  /** When the use touches the screen this is called */
  void onTouchEnter(TouchEvent e) {
    uiPoint.x = e.targetTouches[0].pageX.floor();
    uiPoint.y = e.targetTouches[0].pageY.floor();

    e.preventDefault();

    if (uiSelect()) {
      e.stopPropagation();
    }
  }

  void onTouchStart(TouchEvent e) {
    uiPoint.x = e.targetTouches[0].pageX.floor();
    uiPoint.y = e.targetTouches[0].pageY.floor();
    e.preventDefault();

    if (uiSelect()) {
      e.stopPropagation();
    }
  }

  void onTouchMove(TouchEvent e) {
    uiPoint.x = e.targetTouches[0].pageX.floor();
    uiPoint.y = e.targetTouches[0].pageY.floor();

    e.preventDefault();

    if (uiMove()) {
      e.stopPropagation();
    }
  }

  void onTouchEnd(TouchEvent e) {
    uiPoint.x = e.targetTouches[0].pageX.floor();
    uiPoint.y = e.targetTouches[0].pageY.floor();

    e.preventDefault();
    uiEndAction();
  }

  void onTouchLeave(TouchEvent e) {
    uiPoint.x = e.targetTouches[0].pageX.floor();
    uiPoint.y = e.targetTouches[0].pageY.floor();

    e.preventDefault();
    uiEndAction();

  }

  void onTouchCancel(TouchEvent e) {
    uiPoint.x = e.targetTouches[0].pageX.floor();
    uiPoint.y = e.targetTouches[0].pageY.floor();

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
      circuit.moveDevice.moveDevice(uiPoint);
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
        if (circuit.selectedWirePoint != null) {
          circuit.newWire.UpdateLast(uiPoint);
        }
        else {
          circuit.selectedWire = circuit.circuitWires.wireHit(uiPoint);
          if (circuit.selectedWire != null) {
            CanvasPoint p = circuit.selectedWire.getWireSnapPoint(uiPoint);
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

    uiPoint.x = e.offsetX.floor();
    uiPoint.y = e.offsetY.floor();

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
    uiPoint.x = e.offsetX.floor();
    uiPoint.y = e.offsetY.floor();

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
      circuit.moveDevice.moveDevice(uiPoint);
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
        else {
          circuit.selectedWire = circuit.circuitWires.wireHit(uiPoint);
          if (circuit.selectedWire != null) {
            CanvasPoint p = circuit.selectedWire.getWireSnapPoint(uiPoint);
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
    if (circuit.selectedWirePoint != null) {
      return;
    }

 }

 /** Check the button type devices to see if any have the given point */
 LogicDevice tryButtonSelect(CanvasPoint p) {
   for (LogicDevice device in deviceButtons) {
      if(device.contains(p)) {
         return device;
      }
   }
 }

}
