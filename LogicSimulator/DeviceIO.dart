/** Simple Logic Simulator for Google Dart Hackathon 4-27-2012   
/   By: Ryan C. Weaving  &  Athhur Liu                           */

class DeviceInput{
  
  final LogicDevice device;  

  DeviceOutput connectedOutput;
  Wire wire;
  
  bool _value = false;  
  bool _connectable = true;
  int _pinX;
  int _pinY;
  var _id;
  
  bool updated;
  
  DeviceInput(this.device, this._id){
    value = false;
    connectedOutput = null;
   }
  
  Map<String, Object> toJson() {
    Map<String, Object> inputMap = new Map<String, Object>();
    
    if(connectedOutput != null){
      inputMap["SourceDevice"] = device.ID;
      inputMap["SourceDeviceInput"] = _id;
      inputMap["DestinationDevice"] = connectedOutput.device.ID;
      inputMap["DestinationDeviceOutput"] = connectedOutput.id;
      inputMap["wirePoints"] = wire.GetWireString();
    }
    else{
      inputMap["SourceDevice"] = device.ID;
      inputMap["SourceDeviceInput"] = _id;
      inputMap["DestinationDevice"] = null;
      inputMap["DestinationDeviceOutput"] = null;
//      inputMap["wirePoints"] =*/
    }
    return inputMap;
  }
  
  int get offsetX() => device.X + _pinX;  // the corrected absolute X position 
  int get offsetY() => device.Y + _pinY;  // the corrected absolute X position
  int get pinX()    => _pinX;             // the pins X location on the devices image
  int get pinY()    => _pinY;             // the pins Y location on the devices image
  
  
  bool get connectable() => _connectable;  // Can you connect to this input pin
  set connectable(bool val){
    _connectable = val;
  }
  
  void createWire(){
    wire = new Wire(this);
  }
  
  void drawWire(){
    wire.Draw(value);
  }  
  
  DeviceOutput wireHit(int x, int y){
    if(wire != null && connectedOutput != null){
      if(wire.Contains(x, y, 5))
        return connectedOutput;
    }
    return null;
  }
  
  void checkUpdate(){
    if(connectedOutput != null) {
      updated = connectedOutput.device.updated;
    }
    else
      updated = false;
   }
  
  // Has this device been calculated
  bool get calculated(){
    if(connectedOutput != null) {
      return connectedOutput.device.calculated;
    }
  }
  
  // Is this input connected to another device
  bool get connected(){
    if(connectedOutput != null) 
      return true;
    else
      return false;
  }
  
  bool get value(){
    if(connectedOutput != null){
      if(!connectedOutput.calculated){
        connectedOutput.calculate();
      }
      return connectedOutput.value;
    }
    else
      return false;
  }

  set value(bool val){
    _value = val;
  }
  
  String get id()   => _id;
  
  SetPinLocation(int x, int y){
    _pinX = x;
    _pinY = y;
  } 
}


class DeviceOutput{ 
  
  bool _value;  
  int _pinX;
  int _pinY;
  String _id;
  
  final LogicDevice device;
  
  DeviceOutput(this.device, this._id){
    value = false;
  }
  
  // Has this device been calculated
  bool get calculated(){
    return device.calculated;
  }
  
  calculate(){
    device.Calculate();
  }
  
  int get offsetX() => device.X + _pinX;
  int get offsetY() => device.Y + _pinY;
  int get pinX() => _pinX;
  int get pinY() => _pinY;
  
  String get id() => _id;
  
  bool get value() => _value;
  
  set value(bool val){
    _value = val;
  }
  
  SetPinLocation(int x, int y){
    _pinX = x;
    _pinY = y;
  }
}