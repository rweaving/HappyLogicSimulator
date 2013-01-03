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


/** Handles the selection of logic devices */
class SelectedDevices {

  List<LogicDevice> allDevices;
  Wires allWires;

  List<LogicDevice> selectedDevices;
  List<CanvasPoint> offsetPoints;
  List<WirePoint> selectedWirePoints;
  List<CanvasPoint> selectedWireOffsetPoints;

  SelectedDevices(this.allDevices, this.allWires) {
    selectedDevices = new List<LogicDevice>();
    offsetPoints = new List<CanvasPoint>();
    selectedWirePoints = new List<WirePoint>();
    selectedWireOffsetPoints = new List<CanvasPoint>();
  }

  /** Returns the number of devices that we have selected */
  get count => selectedDevices.length;

  /** Returns the total number of wirepoints that we have selected */
  get wirePointsCount => selectedWirePoints.length;

  /** Clear the list of selected devices */
  void clear(){
    selectedDevices.clear();
    offsetPoints.clear();
    selectedWireOffsetPoints.clear();
    selectedWirePoints.clear();
  }

  /** Add a device to the list of selected devices */
  void add(device, CanvasPoint p){
    selectedDevices.add(device);
    offsetPoints.add(p);
    print('${p.x},${p.y}');
  }

  /** Select all the devices at a give point */
  int selectAllAt(CanvasPoint p) {
    selectedDevices.clear();
    for (LogicDevice device in allDevices) {
      if(device.selectable){
        if(device.contains(p)) {
          //p.x = device.position.x - p.x;
          //p.y = device.position.y - p.y;
          add(device, new CanvasPoint((device.position.x - p.x), (device.position.y - p.y)));
        }
      }
    }
    return count;
  }

  /** Select the top most device at a give point */
  int selectTopAt(CanvasPoint p) {
    selectedDevices.clear();
    for (int t = allDevices.length - 1; t >= 0; t--) {
      if(allDevices[t].selectable) {
        if(allDevices[t].contains(p)) {
          //p.x = allDevices[t].position.x - p.x;
          //p.y = allDevices[t].position.y - p.y;
          add(allDevices[t], new CanvasPoint((allDevices[t].position.x - p.x), (allDevices[t].position.y - p.y)));

          selectWirePoints(allDevices[t], p);
          break;
        }
      }
    }
    return count;
  }

  /** Move selected devices to a new point */
  void moveTo(CanvasPoint p) {
    for (int t=0; t < selectedDevices.length; t++) {
      CanvasPoint op = new CanvasPoint((p.x + offsetPoints[t].x), (p.y + offsetPoints[t].y));
      selectedDevices[t].moveDevice(op);
      //print('MoveTo(${p.x},${p.y})');
    }

    // Move the selected wire points with the device
    for (int c=0; c < selectedWireOffsetPoints.length; c++) {
      selectedWirePoints[c].x = selectedWireOffsetPoints[c].x + p.x;
      selectedWirePoints[c].y = selectedWireOffsetPoints[c].y + p.y;
    }
  }

  /** Get all the wirepoints connected to the given devices */
  int selectWirePoints(LogicDevice device, CanvasPoint p) {
    // Get all the wirepoints that match the device input point
    for (DeviceInput input in device.inputs) {
      for (Wire wire in allWires.wires) {
        for(WirePoint wp in wire.wirePoints) {
          if(wp.x == input.offsetX && wp.y == input.offsetY) {
            addWirePoint(wp,
              new CanvasPoint((wire.input.offsetX - p.x),
                        (wire.input.offsetY - p.y)));
          }
        }
      }
    }

    // Get all the wirepoints that match the device output point
    for (DeviceOutput output in device.outputs) {
      for (Wire wire in allWires.wires) {
        for(WirePoint wp in wire.wirePoints) {
          if(wire.output != null) {
            if(wp.x == output.offsetX && wp.y == output.offsetY) {
              addWirePoint(wp, new CanvasPoint((wire.output.offsetX - p.x),(wire.output.offsetY - p.y)));
            }
          }
        }
      }
    }
    return wirePointsCount;
  }

  /** Clears all the points for a selected wire */
  void clearSelectedWirePoints() {
    selectedWirePoints.clear();
    selectedWireOffsetPoints.clear();
  }

  /** Add a wirepoint to our selected wirepoints list */
  void addWirePoint(p, op) {
   // print("Device Select addWirePoint($op.x, $op.y)");
    selectedWirePoints.add(p);
    selectedWireOffsetPoints.add(op);
  }

}
