/** Simple Logic Simulator for Google Dart Hackathon 4-27-2012   
/   By: Ryan C. Weaving  &  Athhur Liu                           */

// there is one instance of the logic device for each logic device that is displayed
class LogicDevice {
  
  var Type;
  var ID;

  int X;
  int Y;
  bool selected = false;
  static final int PIND = 7;
  
  final Circuit circuit;
  
  List<DeviceInput> Input;
  List<DeviceOutput> Output;
  List<ImageElement> Images;
  
  int SelectedInputPin = -1;

  int acc=0;
  int rset=10;
  
  bool _CreateWire = false;
  bool _calculated = false; 
  bool _updated = false;
  bool _visible = true;
  bool _updateable = false;
  
  LogicDevice.fromJson(this.circuit, Map json) : ID = json['id'], X = json['x'], Y = json['y'], Type = json['type']{    
    Input = new List<DeviceInput>();
    Output = new List<DeviceOutput>();
    Images = new List<ImageElement>();
    
    Configure(this);
  }
  
  LogicDevice(this.circuit, this.ID, this.Type){ 
    Input = new List<DeviceInput>();
    Output = new List<DeviceOutput>();
    Images = new List<ImageElement>();
    
    Configure(this);
  }
  
  Map<String, Object> toJson() {
    Map<String, Object> deviceMap = new Map<String, Object>();
    deviceMap["id"] = ID;
    deviceMap["type"] = Type;
    deviceMap["x"] = X; 
    deviceMap["y"] = Y;
    return deviceMap;
  }

  int get InputCount() => Input.length;
  int get OutputCount() => Output.length;
  
  set InputCount(int count){
    if(InputCount < count){
      do{
        Input.add(new DeviceInput(this,InputCount.toString()));
      }while(InputCount < count);
    }
  }
  
  set OutputCount(int count){
    if(OutputCount < count){
      do{
        Output.add(new DeviceOutput(this,OutputCount.toString()));
      }while(OutputCount < count);
    }
  }
  
  void remove(){
    Input.clear();
    Output.clear();
    Images.clear();
  }
  
  // Get connections
  String GetInputs(){
    List<String> inputList = new List<String>();
    Input.forEach((f) {
      inputList.add(JSON.stringify(f.toJson()));
    });
    return JSON.stringify(inputList);
  }
  
  // Has this device been calculated
  bool get calculated() => _calculated;
  
  // Has this device been calculated
  set calculated(bool calc)
  {
    _calculated = calc;
    
    if(!_calculated)
      Input.forEach((f) { f.updated = false; });
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
  
  // Load device image
  void addImage(var image){
    ImageElement _elem;
    _elem = new Element.tag('img'); 
    _elem.src = image;
    //_elem.on.load.add((event) { drawDevice(); });
    Images.add(_elem);  
  }
  
  // Set the X and Y offsets for the x pin location
  SetInputPinLocation(int pin, int xPos, int yPos)
  {
    if(pin >= 0 && pin < Input.length){ 
      Input[pin].SetPinLocation(xPos, yPos); 
    }
  }
  
  // Set the X and Y offsets for the x pin location
  SetOutputPinLocation(int pin, int xPos, int yPos)
  {
    if(pin >= 0 && pin < Output.length){ 
      Output[pin].SetPinLocation(xPos, yPos); 
    }
  }
  
  SetInputConnectable(int pin, bool connectable)
  {
    if(pin >= 0 && pin < Input.length){ 
      Input[pin].connectable = false;
    }
  }
 
  DeviceInput InputPinHit(int x, int y)
  {
    if(InputCount <= 0) return null;
    
    for (DeviceInput input in Input) {
      if(input.connectable){
        if(x <= (X + input.pinX + PIND) && x >= (X + input.pinX - PIND)){
          if(y <= (Y + input.pinY + PIND) && y >= (Y + input.pinY - PIND)){
            return input;
          }
        }
      }
    }
    return null;
  }
  
  DeviceOutput OutputPinHit(int x, int y)
  {
    if(OutputCount <= 0) return null;
    
    for (DeviceOutput output in Output) {
      if(x <= (X + output.pinX + PIND) && x >= (X + output.pinX - PIND)){
        if(y <= (Y + output.pinY + PIND) && y >= (Y + output.pinY - PIND)){
          return output;
        }
      }
    }
    return null;
  }    
    
  bool DeviceHit(int x, int y)
  {
    return contains(x, y);
  }
    
  DeviceOutput WireHit(int x, int y)
  {
    DeviceOutput hitDevice;
    for (DeviceInput input in Input) {
      hitDevice = input.wireHit(x, y);
      if(hitDevice != null)
        return hitDevice; 
    }
    return null;
  }
  
  
  // Move the device to a new location
  MoveDevice(int newX, int newY)
  { 
    if(Images[0] != null){    
        Util.pos(Images[0], newX.toDouble(), newY.toDouble());
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
  
  // Id the given point within our image
  bool contains(int pointX, int pointY) 
  {
    if ((pointX > X && pointX < X + Images[0].width) && 
        (pointY > Y && pointY < Y + Images[0].height)) {
      return true;
    } else {
      return false;
    }
  }
  
  void Calculate(){
    if(!_calculated){
      _calculated = true;
      
      //bool out0 = Output[0].value;
      
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
        case 'LED':     break;
        case 'CLOCK':   CalcClock(this); break;
       }
      
      //if(out0 != Output[0].value) 
      _updated = true;
      
      // Check inputs to see if that have devices connected to them that have updated
      Input.forEach((f) { f.checkUpdate(); });
    }
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




