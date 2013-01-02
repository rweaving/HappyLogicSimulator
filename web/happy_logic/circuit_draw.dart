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

    showGrid = true;
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

  /** Draw all the devices */
  void drawDevices(List<LogicDevice> devices) {
   for (LogicDevice device in devices) {
     for (OffsetImage img in device.images) {  // Draw the stack of images
       context.drawImage(img.image, device.position.x + img.offsetPoint.x, device.position.y + img.offsetPoint.y);
     }
    }
  }

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

   if(wire.valid) {
      if(wire.output.value == true) {
        context.strokeStyle = Style.WIRE_HIGH;
      }
      else {
        context.strokeStyle = Style.WIRE_LOW;
      }
    }
    else {
      context.strokeStyle = Style.WIRE_INVALID;
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
  void drawKnot(num x, num y) {
    context.beginPath();
    context.lineWidth = 2;
    context.arc(x, y, 6.1, 0, PI2, false);
    context.fill();
    context.stroke();
    context.closePath();
  }


  /** Draw the device's visual pin indicators */
  void drawPinSelectors() {

    if (circuit.selectedOutput != null) {
      drawHighlightPin(circuit.selectedOutput.offsetX, circuit.selectedOutput.offsetY, 'VALID');
    }

    if (circuit.selectedInput != null) {
      if (circuit.selectedInput.connected) {
        drawHighlightPin(circuit.selectedInput.offsetX, circuit.selectedInput.offsetY, 'CONNECTED');
      }
      else {
        drawHighlightPin(circuit.selectedInput.offsetX, circuit.selectedInput.offsetY, 'VALID');
      }
    }

    if (circuit.selectedWirePoint != null) {
      drawHighlightPin(circuit.selectedWirePoint.x , circuit.selectedWirePoint.y, 'WIREPOINT');
    }

    // If we are adding a wire draw acceptable connection points
    if (circuit.newWire != null) {
      if (circuit.newWire.input == null) { // Looking for a vaild input
        drawConnectableInputPins();
      }
      if (circuit.newWire.output == null) { // Looking for a vaild output
        drawConnectableOutputPins();
      }
    }

  }

  /** Draw the output pins that we can connect to */
  void drawConnectableOutputPins() {
    for (LogicDevice device in circuit.logicDevices) {
      for (DeviceOutput output in device.outputs) {
        if (output.connectable == true) {
          drawHighlightPin(output.offsetX, output.offsetY, 'CONNECTABLE');
        }
      }
    }
  }

  /** Draw the input pins that we can connect to */
  void drawConnectableInputPins() {
    for (LogicDevice device in circuit.logicDevices) {
      for (DeviceInput input in device.inputs) {
        if(input.connected == false && input.connectable == true) {
          drawHighlightPin(input.offsetX, input.offsetY, 'CONNECTABLE');
        }
      }
    }
  }

  /** Draw the highlight pin at a given coordinate */
  void drawHighlightPin(num x, num y, var highlightMode) {

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

      case 'CONNECTABLE': context.strokeStyle = 'hsla(270, 75%, 50%, 1)';
                          context.fillStyle = 'hsla(270, 75%, 50%, 0.25)';
                          break;

      default:            context.strokeStyle = '#000000';
                          context.fillStyle = 'rgba(255, 0, 0, 0.5)';
                          break;
    }

    context.beginPath();
    context.lineWidth = 1;

    context.arc(x, y, 8.1, 0, PI2, false);

    context.fill();
    context.stroke();
    context.closePath();
  }
}

class Style {

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

}

