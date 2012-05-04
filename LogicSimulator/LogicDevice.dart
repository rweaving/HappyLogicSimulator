/** Simple Logic Simulator for Google Dart Hackathon 4-27-2012   
/   By: Ryan C. Weaving  &  Arthur Liu                           */

// there is one instance of the logic device for each logic device that is displayed
class LogicDevice {
  
  var Type;
  var ID;

  int X;
  int Y;
  bool selected = false;
  static final int PIND = 7;

  List<DeviceInput> Input;
  List<DeviceOutput> Output;
  
  LogicDeviceType deviceType;

  int acc=0;
  int rset=4;
  
  bool _calculated = false; 
  bool _updated = false;
  bool _visible = true;
  bool _updateable = false;
  bool CloneMode = false;

  LogicDevice(this.ID, this.Type, this.deviceType){ 
    Input = new List<DeviceInput>();
    Output = new List<DeviceOutput>();
    
    //Configure IO for this new device from a DeviceType
    for(DevicePin devicePin in deviceType.inputPins){
      Input.add(new DeviceInput(this, devicePin.id, devicePin));
    }
    for(DevicePin devicePin in deviceType.outputPins){
      Output.add(new DeviceOutput(this, devicePin.id, devicePin));
    }
  }

  void remove(){
    Input.clear();
    Output.clear();
  }
  
  // Has this device been calculated
  bool get calculated() => _calculated;
  
  // Has this device been calculated
  set calculated(bool calc)
  {
    _calculated = calc;
    
    if(!_calculated)
      for(DeviceInput input in Input)
        input.updated = false;
  }
 
  // Devices are updateable if they have images that need updating based on state
  bool get updateable() => _updateable;
  set updateable(bool val){
    _updateable = val;
  }
  
  // Has the status of this device changed
  bool get updated() => _updated;
  set updated(bool ud){
    _updated = ud;
  }
   
  // Does any of this devices wires start or end with this point
  // sHould return a list
  Wire HasWirePoint(int x, int y)
  {
    if(CloneMode) return null;

    for (DeviceInput input in Input) {
      if(input.wire.HasStartEndPoint(x, y))
          return input.wire; 
    }
    return null;  
  }
 
  DeviceInput InputPinHit(int x, int y)
  {
    if(CloneMode) return null;
    
    for (DeviceInput input in Input) {
      if(input.connectable){
        if(input.pinHit(x, y))
          return input; 
      }
    }
    return null;
  }
  
  DeviceOutput OutputPinHit(int x, int y)
  {
    if(CloneMode) return null;
    
    for (DeviceOutput output in Output) {
      if(output.connectable){
        if(output.pinHit(x, y))
          return output; 
      }
    }
    return null;
  }    
    
  bool DeviceHit(int x, int y)
  {
    return contains(x, y);
  }
    
  // Find what Device output is connected to this device
  DeviceOutput WireHit(int x, int y)
  {
    for (DeviceInput input in Input) {
      if(input.wireHit(x, y) != null)
        return input.wireHit(x, y); 
    }
    return null;
  }
  
  // Try to select a wire
  Wire WireSelect(int x, int y)
  {
    for (DeviceInput input in Input) 
      if(input.wireHit(x, y) != null)
        return input.wire;

    return null;
  }
  
  // Move the device to a new location
  MoveDevice(int newX, int newY)
  { 
    if(deviceType.images[0] != null){    
        Util.pos(deviceType.images[0], newX.toDouble(), newY.toDouble());
        X = newX;
        Y = newY;
      }
  }
  
  // the user has click on a logic device
  void clicked()
  {
    switch (Type){
      case 'SWITCH': 
        Output[0].value = !Output[0].value; 
        _updated = true; 
        break;
    }
  }
  
//   Id the given point within our image
  bool contains(int pointX, int pointY) 
  {
    if ((pointX > X && pointX < X + deviceType.images[0].width) && 
        (pointY > Y && pointY < Y + deviceType.images[0].height)) {
      return true;
    } else {
      return false;
    }
  }
  
  void Calculate(){
    if(!_calculated){
      _calculated = true;
      
      bool outputState = Output[0].value;
      
      switch (Type){
        case 'AND':     Output[0].value = Input[0].value && Input[1].value; break;
        case 'NAND':    Output[0].value = !(Input[0].value && Input[1].value); break;
        case 'OR':      Output[0].value = Input[0].value || Input[1].value; break;
        case 'NOR':     Output[0].value = !(Input[0].value || Input[1].value); break;
        case 'XOR':     Output[0].value = (Input[0].value != Input[1].value); break;
        case 'XNOR':    Output[0].value = !(Input[0].value != Input[1].value); break;
        case 'NOT':     Output[0].value = !(Input[0].value); break;
        case 'SWITCH':  Output[0].value = Output[0].value; break;
        case 'DLOGO':
        case 'LED':     Output[0].value = Input[0].value; break;
        case 'CLOCK':   CalcClock(this); break;
       }
      
      if(outputState != Output[0].value) 
        _updated = true;
      
      // Check inputs to see if that have devices connected to them that have updated
      for(DeviceInput input in Input) input.checkUpdate();
       
  }
}

Function CalcClock(LogicDevice device)
{
  if(device.acc > device.rset){
    device.acc = 0;
    device.Output[0].value = !device.Output[0].value;
    device.Output[1].value = !device.Output[0].value;
  }
  else
    device.acc++;
}



}