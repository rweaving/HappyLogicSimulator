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
   

class OffsetPoint {
  int xOffset;
  int yOffset;
  
  OffsetPoint(this.xOffset, this.yOffset){
  }
}

/** Handles the selection of logic devices */
class SelectedDevices {
   
  List<LogicDevice> allDevices;
  Wires allWires;
  
  List<LogicDevice> selectedDevices;
  List<OffsetPoint> offsetPoints;
  List<WirePoint> selectedWirePoints;
  List<OffsetPoint> selectedWireOffsetPoints;
  
  SelectedDevices(this.allDevices, this.allWires) {
    selectedDevices = new List<LogicDevice>();
    offsetPoints = new List<OffsetPoint>();
    selectedWirePoints = new List<WirePoint>();
    selectedWireOffsetPoints = new List<OffsetPoint>();
  }
  
  /** Returns the number of devices that we have selected */
  get count() => selectedDevices.length;
  
  /** Returns the total number of wirepoints that we have selected */
  get wirePointsCount() => selectedWirePoints.length;
  
  /** Clear the list of selected devices */
  void clear(){
    selectedDevices.clear();
    offsetPoints.clear();
    selectedWireOffsetPoints.clear();
    selectedWirePoints.clear();
  }
  
  /** Add a device to the list of selected devices */
  void add(device, offsetX, offsetY){
    selectedDevices.add(device);
    offsetPoints.add(new OffsetPoint(offsetX, offsetY));
  }
  
  /** Select all the devices at a give point */
  int selectAllAt(int selectX, int selectY) {
    selectedDevices.clear();
    for (LogicDevice device in allDevices) {  
      if(device.selectable){
        if(device.contains(selectX, selectY)) {
          add(device, (device.xPosition - selectX), (device.yPosition - selectY));
        }
      }
    }
    return count;
  }
  
  /** Select the top most device at a give point */
  int selectTopAt(int selectX, int selectY) {
    selectedDevices.clear();
    for (int t = allDevices.length - 1; t >= 0; t--) {  
      if(allDevices[t].selectable) {
        if(allDevices[t].contains(selectX, selectY)) {
          add(allDevices[t], (allDevices[t].xPosition - selectX), (allDevices[t].yPosition - selectY));
          selectWirePoints(allDevices[t], selectX, selectY);
          break;
        }
      }
    }
    return count;
  }
  
  /** Move selected devices to a new point */
  void moveTo(int x, int y) {
    for (int t=0; t < selectedDevices.length; t++) {
      selectedDevices[t].MoveDevice(x+offsetPoints[t].xOffset, y+offsetPoints[t].yOffset);
    }
    
    // Move the selected wire points with the device
    for (int c=0; c < selectedWireOffsetPoints.length; c++) {
      selectedWirePoints[c].x = (selectedWireOffsetPoints[c].xOffset + x);
      selectedWirePoints[c].y = (selectedWireOffsetPoints[c].yOffset + y);
    }
  }
  
  /** Get all the wirepoints connected to the given devices */
  int selectWirePoints(LogicDevice device, int selectX, int selectY) {
    // Get all the wirepoints that match the device input point
    for (DeviceInput input in device.inputs) { 
      for (Wire wire in allWires.wires) {
        for(WirePoint wp in wire.wirePoints) {
          if(wp.x == input.offsetX && wp.y == input.offsetY) {
            addWirePoint(wp,  (wire.input.offsetX - selectX), (wire.input.offsetY - selectY));
          }
        }
      }
    }
    
    // Get all the wirepoints that match the device output point
    for (DeviceOutput output in device.outputs) { 
      for (Wire wire in allWires.wires) {
        for(WirePoint wp in wire.wirePoints) {
          if(wp.x == output.offsetX && wp.y == output.offsetY) {
            addWirePoint(wp,  (wire.output.offsetX - selectX), (wire.output.offsetY - selectY));
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
  
  void addWirePoint(p, offsetX, offsetY) {
    print("addWirePoint($p, $offsetX, $offsetY)");
    selectedWirePoints.add(p);
    selectedWireOffsetPoints.add(new OffsetPoint(offsetX, offsetY));
  }
}
