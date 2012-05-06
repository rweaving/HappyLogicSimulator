/** Simple Logic Simulator for Google Dart Hackathon 4-27-2012   
/   By: Ryan C. Weaving  &  Arthur Liu                           */

// there is one instance of the logic device for each logic device that is displayed
class LogicDevice {

  var ID;

  int X;
  int Y;
  
  bool selected;
  bool selectable;
  bool enabled;
  bool calculated; 
  bool updated;
  bool visible;
  bool updateable;
  
  bool CloneMode = false; 
  
  static final int PIND = 7;

  List<DeviceInput> inputs;
  List<DeviceOutput> outputs;
  
  LogicDeviceType deviceType;

  int acc=0;
  int rset=4;
 
  LogicDevice(this.ID, this.deviceType) { 
    inputs = new List<DeviceInput>();
    outputs = new List<DeviceOutput>();
    
    //Configure IO for this new device from a DeviceType
    for(DevicePin devicePin in deviceType.inputPins) {
      inputs.add(new DeviceInput(this, devicePin.id, devicePin));
    }
    for(DevicePin devicePin in deviceType.outputPins) {
      outputs.add(new DeviceOutput(this, devicePin.id, devicePin));
    }
    
    visible = true;
  }

//  // Devices are updateable if they have images that need updating based on state
//  bool get updateable() => _updateable;
//  set updateable(bool val) {
//    _updateable = val;
//  }
//  
//  // Has the status of this device changed
//  bool get updated() => _updated;
//  set updated(bool ud) {
//    _updated = ud;
//  }
   
  // Does any of this devices wires start or end with this point
  // sHould return a list
  Wire HasWirePoint(int x, int y) {
    if(CloneMode) return null;

    for (DeviceInput input in inputs) {
      if(input.wire.HasStartEndPoint(x, y))
          return input.wire; 
    }
    return null;  
  }
 
  DeviceInput InputPinHit(int x, int y) {
    if(CloneMode) return null;
    
    for (DeviceInput input in inputs) {
      if(input.connectable){
        if(input.pinHit(x, y))
          return input; 
      }
    }
    return null;
  }
  
  DeviceOutput OutputPinHit(int x, int y) {
    if(CloneMode) return null;
    
    for (DeviceOutput output in outputs) {
      if(output.connectable){
        if(output.pinHit(x, y))
          return output; 
      }
    }
    return null;
  }    
    
  bool DeviceHit(int x, int y) {
    return contains(x, y);
  }
    
  // Find what Device output is connected to this device
  DeviceOutput WireHit(int x, int y) {
    for (DeviceInput input in inputs) {
      if(input.wireHit(x, y) != null)
        return input.wireHit(x, y); 
    }
    return null;
  }
  
  // Try to select a wire
  Wire WireSelect(int x, int y) {
    for (DeviceInput input in inputs) 
      if(input.wireHit(x, y) != null)
        return input.wire;

    return null;
  }
  
  // Move the device to a new location
  MoveDevice(int newX, int newY) { 
    if(deviceType.images[0] != null) {    
        Util.pos(deviceType.images[0], newX.toDouble(), newY.toDouble());
        X = newX;
        Y = newY;
      }
  }
  
  // the user has click on a logic device
  void clicked() {
    switch (deviceType.type) {
      case 'SWITCH': 
        outputs[0].value = !outputs[0].value; 
        updated = true; 
        break;
    }
  }
  
//   Id the given point within our image
  bool contains(int pointX, int pointY) {
    if ((pointX > X && pointX < X + deviceType.images[0].width) && 
          (pointY > Y && pointY < Y + deviceType.images[0].height)) {
      return true;
    } else {
      return false;
    }
  }
  
  void Calculate() {
    if(!calculated) {
      calculated = true;
      
      for(DeviceInput input in inputs)
          input.updated = false;
      
      bool outputState = outputs[0].value;
      
      switch (deviceType.type){
        case 'AND':     outputs[0].value = inputs[0].value && inputs[1].value; break;
        case 'NAND':    outputs[0].value = !(inputs[0].value && inputs[1].value); break;
        case 'OR':      outputs[0].value = inputs[0].value || inputs[1].value; break;
        case 'NOR':     outputs[0].value = !(inputs[0].value || inputs[1].value); break;
        case 'XOR':     outputs[0].value = (inputs[0].value != inputs[1].value); break;
        case 'XNOR':    outputs[0].value = !(inputs[0].value != inputs[1].value); break;
        case 'NOT':     outputs[0].value = !(inputs[0].value); break;
        case 'SWITCH':  outputs[0].value = outputs[0].value; break;
        case 'DLOGO':
        case 'LED':     outputs[0].value = inputs[0].value; break;
        case 'CLOCK':   CalcClock(this); break;
       }
      
      if(outputState != outputs[0].value){ 
        updated = true;
      }
      
      // Check inputs to see if that have devices connected to them that have updated
      for(DeviceInput input in inputs) { 
        input.checkUpdate();
      }
    }
  }


  Function CalcClock(LogicDevice device) {
    if(device.acc > device.rset) {
      device.acc = 0;
      device.outputs[0].value = !device.outputs[0].value;
      device.outputs[1].value = !device.outputs[0].value;
    }
    else
      device.acc++;
  }
}