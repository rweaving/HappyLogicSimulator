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
      
/** A circuit contains and controls the logic simulaton */
class Circuit {
  LogicDeviceTypes deviceTypes; // Has all the various type of logic devices
  List<LogicDevice> deviceButtons; // Holds all the device creation buttons
  List<LogicDevice> logicDevices; // Holds all the devices in the simulation
  SelectedDevices selectedDevices; // Devices that are selected
  List<WirePoint> wirePoints; // All the wirepoints
  
  DeviceInput selectedInput;
  DeviceOutput selectedOutput;
  WirePoint selectedWirePoint;
  WirePoint movingWirePoint;
  Wires circuitWires; // Holds all the wires for the simulation
  Wire newWire; // Pointer to our new wire if adding one
  
  Wire selectedWire;
  LogicDevice moveDevice;
  LogicDevice selectedDevice;
  
  bool run;
  
  Circuit() : 
    deviceTypes = new LogicDeviceTypes(), 
    logicDevices = new List<LogicDevice>(),
    wirePoints = new List<WirePoint>(){
    
    circuitWires = new Wires();
    selectedDevices = new SelectedDevices(logicDevices, circuitWires);

    window.setInterval(f() => tick(), 5); // Create a timer to update the simulation tick
  }
  
  /** Creates a new device from a given device and adds it to the circuit */
  LogicDevice newDeviceFrom(LogicDevice device, CanvasPoint position) {
    LogicDevice newDevice = new LogicDevice(device.deviceType); 
    logicDevices.add(newDevice);
    newDevice.moveDevice(device.position);
    selectedDevices.clear();
    selectedDevices.add(newDevice, new CanvasPoint((device.position.x - position.x), (device.position.y - position.y)));
    return newDevice;
  }
  
  /** Creates a new device from a given device and adds it at given point */
  LogicDevice newDeviceAt(var type, CanvasPoint position) {
    LogicDeviceType deviceType = deviceTypes.getDeviceType(type);
    if (deviceType != null) {
      LogicDevice newDevice = new LogicDevice(deviceType); 
      logicDevices.add(newDevice);
      newDevice.moveDevice(position);
      return newDevice;
    }
    return null;
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
      device.calculate();
    }
  }
  
  /** Send keydown to approprate devices */
  void keyDown(int keyCode) {
    for (LogicDevice device in logicDevices) { 
      if (device.hasOutputMaps) {
        device.keyDown(keyCode);   
      }
    }
  }

  /** Send keyUp to approprate devices */
  void keyUp(int keyCode) {
    for (LogicDevice device in logicDevices) {
      if (device.hasOutputMaps) {
        device.keyUp(keyCode);   
      }
    }
  }
  
  /** Try to select a logic device at given point */
  LogicDevice tryDeviceSelect(CanvasPoint p) {
    for (LogicDevice device in logicDevices) {  
      if (device.contains(p)) {
        return device;
      }
    }            
    return null;
  }
  
  /** Try to select a logic device input at given point*/
  DeviceInput tryInputSelect(CanvasPoint p) {
    for (LogicDevice device in logicDevices) { 
      if (device.InputPinHit(p) != null) {
        return device.InputPinHit(p);
      }
    }
    return null;
  }
  
  /** Try to select a logic device output at given point */
  DeviceOutput tryOutputSelect(CanvasPoint p) {
    for (LogicDevice device in logicDevices) { 
      if (device.OutputPinHit(p) != null) {
        return device.OutputPinHit(p);
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
  int selectWirePoints(CanvasPoint p) {
    return circuitWires.selectWirePoints(p);
  }
  
  /** Try to select a wire at a given point */
  int tryWireSelect(CanvasPoint p) { 
    return circuitWires.selectWire(p);
  }

 /** Check to see if this point is a vaild connection when adding a wire */
 bool checkConnection(CanvasPoint p) {
   if (!addingWire) return false;
   
   // Looking for a vaild input
   if (newWire.needInput) {
     DeviceInput input = tryInputSelect(p); 
     selectedInput = input;
     if(selectedInput != null){
       newWire.UpdateLast(input.offset); // snap to point
       return true;
     }
   }
   
   // Looking for a vaild output
   if(newWire.needOutput) {
     DeviceOutput output = tryOutputSelect(p);
     selectedOutput = output;
     if(selectedOutput != null) {
       newWire.UpdateLast(output.offset); // snap to point 
       return true;
     }
   }
   return false;
 }
 
 /** Check to see if this point is vaild */
 bool checkValid(CanvasPoint p) {
     
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
 
 /** Try to start adding a wire, returns true if a wire is started */
 bool StartWire(CanvasPoint p) {
    
    DeviceInput input = tryInputSelect(p);
    // If we have a vaild point then continue adding a wire
    if(input != null){ 
      newWire = new Wire();
      newWire.input = input;
      WirePoint wp = newWire.AddPoint(input.offset);
      newWire.input = input;
      input.connectedWire = newWire;
      newWire.AddPoint(input.offset); // extra point to track to mouse
      return true;
    }
    
    DeviceOutput output = tryOutputSelect(p);    
    if(output != null){
      newWire = new Wire();
      newWire.output = output;
      WirePoint wp = newWire.AddPoint(output.offset);
      newWire.output = output;
      newWire.AddPoint(output.offset); // extra point to track to mouse
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
 bool addWirePoint(CanvasPoint p) {
   if(newWire == null) return false;

   newWire.UpdateLast(p);
   
   // Looking for a vaild input
   if (newWire.input == null) {
     DeviceInput input = tryInputSelect(p);
     if (input != null) {
       newWire.input = input;  
       newWire.UpdateLast(input.offset);
       input.connectedWire = newWire;
       newWire.AddPoint(input.offset);
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
     newWire.AddPoint(p);
     return true;
   }
   
   // Looking for a valid output
   if (newWire.output == null) {
     
     // Check for output points
     DeviceOutput output = tryOutputSelect(p); 
     if (output != null) {
       newWire.output = output;
       newWire.UpdateLast(output.offset);
       finishWire(); // Good connection
       return false;
     }
     
     // Check for wire points
     WirePoint wp = circuitWires.selectWirePoint(p);
     if (wp != null) {
       newWire.output = wp.wire.output;
       newWire.UpdateLast(wp);

       WirePoint endPoint = newWire.getLastPoint();
       newWire.setKnot(endPoint, true);
       newWire.AddPoint(wp);
       
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
       CanvasPoint sp = selectedWire.getWireSnapPoint(p);
       if(sp != null) {
         newWire.output = w.output;
         newWire.UpdateLast(sp);
         
         WirePoint endPoint = newWire.getLastPoint();
         newWire.setKnot(endPoint, true);
         newWire.AddPoint(sp);
         
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
   newWire.AddPoint(p);
   return true;
 }
  
  /** Finish adding a wire to the simulation */
  void finishWire() {
    if (newWire.input != null && newWire.output != null) {
      newWire.valid = true;
      circuitWires.addWire(newWire);
      newWire = null;
    }
  }
 
  /** Abort adding a wire to the simulation */
  void abortWire() {
    // Remove the new wire if we abort adding the wire
    if(newWire != null){
      newWire = null;
    }
  }
}
  
