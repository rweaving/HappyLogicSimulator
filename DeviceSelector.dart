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


/**
/ Handles selection of devices
*/
class SelectedDevices {
   
  List<LogicDevice> _devices;
  List<LogicDevice> selectedDevices;
  List<OffsetPoint> offsetPoints;
  List<WirePoint> selectedWirePoints;
  List<OffsetPoint> selectedWireOffsetPoints;
  
  SelectedDevices(this._devices) {
    selectedDevices = new List<LogicDevice>();
    offsetPoints = new List<OffsetPoint>();
    selectedWirePoints = new List<WirePoint>();
    selectedWireOffsetPoints = new List<OffsetPoint>();
  }
  
  get count() => selectedDevices.length;
  get wirePointsCount() => selectedWirePoints.length;
  
  void clear(){
    selectedDevices.clear();
    offsetPoints.clear();
    selectedWireOffsetPoints.clear();
    selectedWirePoints.clear();
  }
  
  void add(device, offsetX, offsetY){
    selectedDevices.add(device);
    offsetPoints.add(new OffsetPoint(offsetX, offsetY));
  }
  
  // Select all the devices at a give point
  int selectAllAt(int selectX, int selectY) {
    selectedDevices.clear();
    for (LogicDevice device in _devices) {  
      if(device.selectable){
        if(device.contains(selectX, selectY)) {
          add(device, (device.X - selectX), (device.Y - selectY));
        }
      }
    }
    return count;
  }
  
  // Select all the devices at a give point
  int selectTopAt(int selectX, int selectY) {
    selectedDevices.clear();
    for (int t=_devices.length-1; t>=0; t--) {  
      if(_devices[t].selectable) {
        if(_devices[t].contains(selectX, selectY)) {
          add(_devices[t], (_devices[t].X - selectX), (_devices[t].Y - selectY));
          selectWirePoints(_devices[t], selectX, selectY);
          break;
        }
      }
    }
    return count;
  }
  
  // Move selected devices to a new point
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
  
  // Get all the wirepoints connected to the given devices
  int selectWirePoints(LogicDevice device, int selectX, int selectY) {
     
    print("device:$device.type");
    
    for (DeviceInput input in device.inputs) { 
      if(input.wirePoint != null) {
        addWirePoint(input.wirePoint, (input.wirePoint.x - selectX), (input.wirePoint.y - selectY));
      }
    }  
    for (DeviceOutput output in device.outputs) {
      if(output.wirePoint != null) {
        addWirePoint(output.wirePoint, (output.wirePoint.x - selectX), (output.wirePoint.y - selectY));
      }
    }
  
      print("WirePointCount:${selectedWirePoints.length}");
    return wirePointsCount;
  }
  
  clearSelectedWirePoints() {
    selectedWirePoints.clear();
    selectedWireOffsetPoints.clear();
  }
  
  void addWirePoint(p, offsetX, offsetY) {
    print("addWirePoint($p, $offsetX, $offsetY)");
    selectedWirePoints.add(p);
    selectedWireOffsetPoints.add(new OffsetPoint(offsetX, offsetY));
  }
}
