/** Simple Logic Simulator for Google Dart Hackathon 4-27-2012   
/   By: Ryan C. Weaving  &  Arthur Liu                           */

class Circuit {

  static final int BORDER_LINE_WIDTH = 1;
  static final String BORDER_LINE_COLOR = '#000000';
  
  static final int    NEW_WIRE_WIDTH = 3;
  static final String NEW_WIRE_COLOR = '#990000';
  static final String NEW_WIRE_VALID = '#009900';
  static final String NEW_WIRE_INVALID = '#999999';
  
  static final String WIRE_HIGH = '#ff4444';
  static final String WIRE_LOW = '#550091';
  static final String WIRE_INVALID = '#999999';
  static final int    WIRE_WIDTH = 3;
  
  static final int GRID_SIZE = 10;
  static final int GRID_POINT_SIZE = 1;
  static final String GRID_COLOR = '#999493';
  static final String GRID_BACKGROUND_COLOR = '#eeeeee';
  static final int PIN_INDICATOR_OFFSET = 5;
  static final TAU = Math.PI * 2;
  static final int TOOLBAR_WIDTH = 115;
  
  CanvasElement canvas;
  CanvasRenderingContext2D context;
  DeviceInput selectedInput;
  
  ImageElement validPinImage;
  ImageElement selectPin;
  ImageElement startWireImage;
  ImageElement connectablePinImage;
   
  int _width;
  int _height;
  int _mouseX;
  int _mouseY;
  int _touchX;
  int _touchY;
  
  DivElement root;
  int lastTime;
  List<LogicDevice> logicDevices;
  
  bool showGrid = false;
  bool gridSnap = false;
  
  WirePoint wireEndPoint; 

  DeviceOutput selectedOutput;
  DeviceOutput tempOutput;
  DeviceInput tempInput;

  LogicDeviceTypes deviceTypes;
  
  LogicDevice moveDevice;
  LogicDevice cloneDevice;
  
  ButtonElement addNandButton;
  ElementList buttons;
  
  Wire dummyWire;
  
  var connectionMode = 'INIT';
  
  bool connectingOutputToInput = false;
  bool connectingInputToOutput = false;
  
  Circuit(this.canvas) : 
    deviceTypes = new LogicDeviceTypes(), 
    logicDevices = new List<LogicDevice>(){

    context = canvas.getContext('2d');
    _width = canvas.width;
    _height = canvas.height;
    
    dummyWire = new Wire();
    
    validPinImage = new Element.tag('img'); 
    validPinImage.src = "images/SelectPinGreen.png";
    
    selectPin = new Element.tag('img');
    selectPin.src = "images/SelectPinBlack.png";  
    
    startWireImage = new Element.tag('img');
    startWireImage.src = "images/SelectPinBlack.png"; 
    
    connectablePinImage = new Element.tag('img');
    connectablePinImage.src = "images/SelectPinPurple.png";   
    
    // Create a timer to update the simulation tick
    window.setInterval(f() => tick(), 50);
    
    canvas.on.mouseDown.add(onMouseDown);
    canvas.on.doubleClick.add(onMouseDoubleClick);
    canvas.on.mouseMove.add(onMouseMove);
    
    // Touch Events
    canvas.on.touchEnter.add((event) => onTouchEnter(event), false);
    canvas.on.touchStart.add((event) => onTouchStart(event), false);
    canvas.on.touchMove.add((event) => onTouchMove(event), false);
    canvas.on.touchEnd.add((event) => onTouchEnd(event), false);
    canvas.on.touchCancel.add((event) => onTouchCancel(event), false);
    canvas.on.touchLeave.add((event) => onTouchLeave(event), false); 
    
    window.on.resize.add((event) => onResize(), true);

  }
  
  int get width() => _width;
  int get height() => _height;
  
  void set width(int val) 
  {
    _width = val;
    canvas.width = val;
  }
  
  void set height(int val) 
  {
    _height = val;
    canvas.height = val;
  }
  
  void onResize() {
    height = window.innerHeight - 25;
    width = window.innerWidth - 25;
    Paint();
  }
  
  void start(){
    createSelectorBar();
    onResize();
  }
  
  void createSelectorBar()
  {
    addNewCloneableDevice('Clock', 'CLOCK', 0, 0);
    addNewCloneableDevice('Switch', 'SWITCH', 0, 60);
    addNewCloneableDevice('Not', 'NOT', 0, 120);
    addNewCloneableDevice('And', 'AND', 0, 180);
    addNewCloneableDevice('Nand', 'NAND', 0, 240);
    addNewCloneableDevice('Or', 'OR', 0, 300);
    addNewCloneableDevice('Nor', 'NOR', 0, 360);
    addNewCloneableDevice('XOR', 'XOR', 0, 420);
    addNewCloneableDevice('XNOR', 'XNOR', 0, 480);
    addNewCloneableDevice('LED', 'LED', 50, 60);
    
    Paint();
  }
  
  LogicDevice addNewCloneableDevice(var id, var type, int x, int y) 
  {
    LogicDeviceType deviceType = deviceTypes.getDeviceType(type);
    if(deviceType != null){
        LogicDevice newDevice = new LogicDevice(id, type, deviceType); 
        logicDevices.add(newDevice);
        newDevice.CloneMode = true;
        newDevice.MoveDevice(x, y);
        return newDevice;
    }
  }
  
  NewDeviceFrom(LogicDevice device){
    LogicDevice newDevice = new LogicDevice(getNewId(), device.Type, device.deviceType); 
    logicDevices.add(newDevice);
    newDevice.MoveDevice(device.X, device.Y);
    
    connectionMode = null;
    moveDevice = newDevice;
  }
  
  LogicDevice GetDeviceByID(var id){
    for (LogicDevice device in logicDevices) {
      if(device.ID == id) return device; 
    }
    return null;
  }
  
  void ClearCircuit()
  {
    logicDevices.clear();
    Paint();
  }
  
  
  void drawBorder() {
    context.beginPath();
    context.rect(TOOLBAR_WIDTH, 0, width, height);
    context.fillStyle = GRID_BACKGROUND_COLOR;
    context.lineWidth = BORDER_LINE_WIDTH;
    context.strokeStyle = GRID_BACKGROUND_COLOR;//BORDER_LINE_COLOR;
    context.fillRect(TOOLBAR_WIDTH, 0, width, height);
    context.stroke();
    context.closePath();
  }
  
  void drawGrid(){
    context.beginPath();
    context.lineWidth = 1;
    context.strokeStyle = GRID_COLOR;
    
    for(int x=TOOLBAR_WIDTH; x < width; x+=GRID_SIZE){
      for(int y=GRID_SIZE; y < height; y+=GRID_SIZE){
        context.rect(x, y, GRID_POINT_SIZE, GRID_POINT_SIZE);
      }
    }
    context.stroke();
    context.closePath(); 
  }
 
  void tick(){
    if(logicDevices.length <= 0) return;
    
    for (LogicDevice device in logicDevices) {
      device.calculated = false;
    }
    for (LogicDevice device in logicDevices) {
      device.Calculate();
    }
    
    Paint();   
  }
  
  // add new id number
  getNewId(){    
    return logicDevices.length;
  }
  
  LogicDevice tryDeviceSelect(int x, int y)
  {
    for (LogicDevice device in logicDevices) 
      if(device.contains(x, y))
        return device;
            
    return null;
  }
  
  DeviceInput tryInputSelect(int x, int y)
  {
    for (LogicDevice device in logicDevices) 
      if(device.InputPinHit(x, y) != null)
        return device.InputPinHit(x, y);
        
    return null;
  }
  
  DeviceOutput tryOutputSelect(int x, int y)
  {
    for (LogicDevice device in logicDevices) 
      if(device.OutputPinHit(x, y) != null)
        return device.OutputPinHit(x, y);
        
    return null;
  }
  
  Wire tryWireSelect(int x, int y)
  {
    for (LogicDevice device in logicDevices) 
      if(device.WireHit(x, y) != null)
        return device.WireSelect(x, y);
        
    return null;
  }  

  
  void onTouchEnter(TouchEvent e)
  {
    e.preventDefault();
    e.stopPropagation();
    _touchX = e.targetTouches[0].pageX;// Use first point
    _touchY = e.targetTouches[0].pageY;
    
    if(connectionMode == null){
      // Check to see if we are touching in input
      selectedInput = tryInputSelect(_touchX, _touchY);
      if(selectedInput != null){
        connectionMode = 'InputSelected'; 
        Paint();
        return;
      }
      // Check to see if we are touching in Output
      selectedOutput = tryOutputSelect(_touchX, _touchY);
      if(selectedOutput != null){
        connectionMode = 'OutputSelected';
        Paint();
        return;
      } 
    }
  }
  
  void onTouchStart(TouchEvent e)
  {
    e.preventDefault();
    e.stopPropagation();
    _touchX = e.targetTouches[0].pageX;// Use first point
    _touchY = e.targetTouches[0].pageY;

    
    //Check to see if we are touching a device
    LogicDevice selectedDevice = tryDeviceSelect(_touchX, _touchY);
    if(selectedDevice != null){

        
        if(selectedDevice.CloneMode){ // If we start dragging on cloneable device make a new one and start moving it
          NewDeviceFrom(selectedDevice);
          Paint();
          return;
        }
        selectedDevice.clicked(); // Send click to touched device
        Paint();
     }
    
    // Check to see if we are touching in input
    DeviceInput _selectedInput = tryInputSelect(_touchX, _touchY);
    if(_selectedInput != null){
      selectedInput = _selectedInput;
      connectionMode = 'InputSelected';  
      StartWire(_touchX, _touchY);
      return;
    }
    
    // Check to see if we are touching in Output
    DeviceOutput _selectedOutput = tryOutputSelect(_touchX, _touchY);
    if(_selectedOutput != null){
      selectedOutput = _selectedOutput;
      connectionMode = 'OutputSelected';  
      StartWire(_touchX, _touchY); 
      return;
    } 
    

 }
  
  void onTouchMove(TouchEvent e)
  {
    e.preventDefault();
    e.stopPropagation();
    
    _touchX = e.targetTouches[0].pageX;// Use first point
    _touchY = e.targetTouches[0].pageY;
    
    if(moveDevice != null){ // We are moving a device
      if (e.targetTouches.length >= 1){
        moveDevice.MoveDevice(_touchX, _touchY);
        Paint();
        return;
      }
    }
    

    Paint();
  }
  
  void onTouchEnd(TouchEvent e)
  {
    e.preventDefault();
    e.stopPropagation();
    
    _touchX = e.targetTouches[0].pageX;// Use first point
    _touchY = e.targetTouches[0].pageY;
    
    if(moveDevice != null){ 
      moveDevice = null;
      Paint();
      return;
    }  
    
    switch(connectionMode){
      case 'InputToOutput':    
      case 'OutputToInput':   AddWirePoint(_touchX, _touchY); 
                              if(checkValidConnection())
                                EndWire();
                              return;
    }
  }  
  
  void onTouchCancel(TouchEvent e)
  {
    if(moveDevice != null){ 
      moveDevice = null;
      Paint();
      return;
    }  
  }
  
  
  void onTouchLeave(TouchEvent e)
  {
    if(moveDevice != null){ 
      moveDevice = null;
      Paint();
      return;
    } 
  }
  
 // Mouse events 
 void onMouseDown(MouseEvent e) 
 {
   e.preventDefault();
   
   //Paint();
   LogicDevice selectedDevice = tryDeviceSelect(_mouseX, _mouseY);
   if(selectedDevice != null)
     print(selectedDevice.deviceType.type);
   
   if(moveDevice != null){ 
     moveDevice = null;
     return;
   }
   
   switch(connectionMode){
     case 'InputToOutput':    
     case 'OutputToInput':   AddWirePoint(_mouseX, _mouseY); 
                             if(checkValidConnection())
                               EndWire();
                             return;
                                                         
     case 'InputSelected' :  StartWire(_mouseX, _mouseY); return;
                             
     case 'OutputSelected' : StartWire(_mouseX, _mouseY); return;
      
     case 'CloneDevice' :    NewDeviceFrom(cloneDevice); return;
                                                       
     case null:              LogicDevice device = tryDeviceSelect(_mouseX, _mouseY);
                             if(device != null)        
                                device.clicked();
                             break;  
   }
 }

 void onMouseDoubleClick(MouseEvent e) 
 {
   e.stopPropagation();
   e.preventDefault();
 }
 
 void onMouseMove(MouseEvent e) 
 {
   _mouseX = e.offsetX;
   _mouseY = e.offsetY; 
   
   if(gridSnap){  // Snap mouse cursor to grid
    double x1 = _mouseX.toDouble() / GRID_SIZE.toDouble();
    double y1 = _mouseY.toDouble() / GRID_SIZE.toDouble();
  
    _mouseX = x1.toInt() * GRID_SIZE;
    _mouseY = y1.toInt() * GRID_SIZE;
   }
   
   if(moveDevice != null){
     moveDevice.MoveDevice(_mouseX, _mouseY);
     Paint();
     return;
   }
     
   switch(connectionMode){
     case 'OutputToInput':    selectedInput = checkForInputPinHit(e.offsetX, e.offsetY);
                              if(selectedInput != null){ // Check to see if we are hitting an input pin 
                                _mouseX = selectedInput.offsetX; //Snap to output pin
                                _mouseY = selectedInput.offsetY; 
                              }
                              dummyWire.UpdateLast(_mouseX, _mouseY);
                              Paint();
                              return; 
                             
     case 'InputToOutput':    selectedOutput = checkForOutputPinHit(e.offsetX, e.offsetY);
                              if(selectedOutput != null){ // Check to see if we are hitting an output pin 
                                _mouseX = selectedOutput.offsetX; //Snap to output pin
                                _mouseY = selectedOutput.offsetY;
                              }
                              else{
                                selectedOutput = checkForWireHit(e.offsetX, e.offsetY);      
                              }
                              dummyWire.UpdateLast(_mouseX, _mouseY);
                              Paint();
                              return;
     default:
   }

   // Check to see if mouse is over an input pin if so select it
   selectedInput = checkForInputPinHit(e.offsetX, e.offsetY);
   if(selectedInput != null){
     connectionMode = 'InputSelected';
     _mouseX = selectedInput.offsetX;
     _mouseY = selectedInput.offsetY;
     Paint();
     return;
   }
   
   // Check to see if mouse is over an output pin if so select it
   selectedOutput = checkForOutputPinHit(e.offsetX, e.offsetY);
   if(selectedOutput != null){
     connectionMode = 'OutputSelected';
     _mouseX = selectedOutput.offsetX;
     _mouseY = selectedOutput.offsetY;
     Paint();
     return;
   }
   
   cloneDevice = checkCloneableDevices(e.offsetX, e.offsetY);
   if(cloneDevice != null){
     connectionMode = 'CloneDevice';
     return;
   }
   
   if(connectionMode != null){
     connectionMode = null;
     Paint();
   }
 }

 LogicDevice checkCloneableDevices(int x, int y){
  // Check to see if we 
   for (LogicDevice device in logicDevices)
     if(device.CloneMode)
       if(device.contains(x, y))
         return device;
 }
 
 
 bool checkValidConnection(){
 // If we have a valid connection
   if(selectedOutput  != null && selectedInput != null) return true;
   return false;
 }
 
 // Check to see if we are hitting an output pin return first hit
 DeviceOutput checkForOutputPinHit(int x, int y){
   for (LogicDevice device in logicDevices)
     if(device.OutputPinHit(x, y) != null)
       return device.OutputPinHit(x, y);
 }
 
// Check to see if we are hitting a wire
 DeviceOutput checkForWireHit(int x, int y){
   for (LogicDevice device in logicDevices)
     if(device.WireHit(x, y) != null)
       return device.WireHit(x, y); 
 }
       
// Check to see if we are hitting an input pin return first hit
 DeviceInput checkForInputPinHit(int x, int y){
   for (LogicDevice device in logicDevices)
     if(device.InputPinHit(x, y) != null)
       return device.InputPinHit(x, y);
 }
 
 bool SelectInput(DeviceInput input)
 {
   if(selectedInput !== input){
     selectedInput = input;
     return true; 
   }
   return false;
 }
 
 bool SelectOutput(DeviceOutput output)
 {
   if(selectedOutput !== output){
     selectedOutput = output;
     return true; 
   }
   return false;
 }
  
 void AddWirePoint(int x, int y){
   dummyWire.AddPoint(x, y);
 }
 
  //Start Adding a wire from an input
  void StartWire(int x, int y)
  {
    dummyWire.clear();
    dummyWire.AddPoint(x, y);
    
    switch(connectionMode){
      case 'InputSelected' :  connectionMode = 'InputToOutput'; break;
                              
      case 'OutputSelected' : connectionMode = 'OutputToInput'; break;
    }
    //print('StartWire($x, $y) $connectionMode');
    drawPinSelectors();  
  }
  
  void EndWire()
  {
    if(selectedOutput  == null || selectedInput == null){ // No Vaild connection
      selectedInput = null;
      selectedOutput = null;
      connectionMode = null;
      return;
    }

    selectedInput.connectedOutput = selectedOutput;

    // Add Dummy Wire to real wire
    selectedInput.addWire(dummyWire.wirePoints);
    
    // Clear selected IO and get ready for a new connection
    selectedInput = null;
    selectedOutput = null;
    connectionMode = null;
    dummyWire.clear();
    Paint();
  }
  
  // Abort the connection of two devices
  void abortWire()
  {
    selectedInput = null;
    selectedOutput = null;
    connectionMode = null;
    dummyWire.clear();
    Paint();
  }


//  
//  //Draw the wires that have been updated
//  void drawUpdatedWires()
//  {
//    for (LogicDevice device in logicDevices) 
//      for (DeviceInput input in device.Input) 
//        if (input.connectedOutput != null)
//          if (input.updated){
//            drawWire(input, 'ERASE');
//            drawWire(input, input.value);
//          }
//  }
  


  
//  void drawUpdate()
//  {
//    Paint();
//    //drawUpdatedDevices();
//    //drawUpdatedWires();
//  }
//  
  void Paint()
  {
    clearCanvas();  
    drawBorder();
    //drawGrid();
    drawDevices();
    drawWires();
    drawPinSelectors();
  }
  
  void clearCanvas()
  {
    context.clearRect(0, 0, _width, _height);
  }
  
  // Redraw all of the devices
  void drawDevices()
  {
    for (LogicDevice device in logicDevices) {
      context.drawImage(device.deviceType.getImage(device.Output[0].value), device.X, device.Y);  
    }
  }
   
  // Draw the dummy Wire
  void drawDummyWire(state){
    context.fillStyle = context.strokeStyle;
    context.beginPath();
    context.lineWidth = WIRE_WIDTH;
    
    switch(state){
      case 'VALID':   context.strokeStyle = NEW_WIRE_VALID; break;
      case 'INVALID': context.strokeStyle = NEW_WIRE_INVALID; break;
      case 'ERASE':   context.strokeStyle = GRID_BACKGROUND_COLOR; 
                      context.lineWidth = WIRE_WIDTH + 1; break;
 
      case true:      context.strokeStyle = WIRE_HIGH; break;
      case false:     context.strokeStyle = WIRE_LOW; break;
           
      default:        context.strokeStyle = WIRE_INVALID;
    }
    
    context.moveTo(dummyWire.startX, dummyWire.startY); 
    
    for (WirePoint wirePoint in dummyWire.wirePoints) 
      context.lineTo(wirePoint.x, wirePoint.y);
      
    context.lineTo(dummyWire.lastX, dummyWire.lastY); 
    context.stroke();
    context.closePath(); 
  }
  
  
  void drawWire(DeviceInput input, state){
    if(input.wire == null) return;  

    context.fillStyle = context.strokeStyle;
    context.beginPath();
    context.lineWidth = WIRE_WIDTH;

    switch(state){
      case 'VALID':   context.strokeStyle = NEW_WIRE_VALID; break;
      case 'INVALID': context.strokeStyle = NEW_WIRE_INVALID; break;
      
      case 'ERASE':   context.strokeStyle = GRID_BACKGROUND_COLOR; 
                      context.lineWidth = WIRE_WIDTH + 1; break;
                      
      case false:     context.strokeStyle = WIRE_LOW; break;
      case true:      context.strokeStyle = WIRE_HIGH; break;
           
      default:        context.strokeStyle = WIRE_INVALID;
    }
    
    context.fillStyle = context.strokeStyle;
    
    //need at least 2 points
    if(input.wire.wirePoints.length >= 2){
      context.moveTo(input.wire.wirePoints[0].x, input.wire.wirePoints[0].y); 
      for (WirePoint point in input.wire.wirePoints) {
        context.lineTo(point.x, point.y);
      }
    }
   
    if(input.wire.lastX != input.wire.wirePoints.last().x ||  // Adding wire
        input.wire.lastY != input.wire.wirePoints.last().y){
      context.moveTo(input.wire.wirePoints.last().x, input.wire.wirePoints.last().y);
      context.lineTo(input.wire.lastX, input.wire.lastY);
    }
   
    context.stroke();
    context.closePath(); 
      
    // Check to see if we need to draw a knot
    if(input.connectedOutput != null){
      if(input.connectedOutput.offsetX != input.wire.wirePoints.last().x &&
          input.connectedOutput.offsetY != input.wire.wirePoints.last().y){
          context.beginPath();
          context.lineWidth = 2;
          context.arc(input.wire.wirePoints[input.wire.wirePoints.length-1].x, input.wire.wirePoints[input.wire.wirePoints.length-1].y, 5, 0, TAU, false);
          context.fill();
          context.stroke();
          context.closePath(); 
      }
    }
  }    
  
  //Draw all the wires
  void drawWires()
  {
    for (LogicDevice device in logicDevices) 
      for (DeviceInput input in device.Input) 
        if (input.connectedOutput != null)
           drawWire(input, input.value);
         
     if(dummyWire.wirePoints.length > 0) 
       if(checkValidConnection())
         drawDummyWire('VALID');
       else
         drawDummyWire('INVAILD');
     
  }
  
  // Draw the device visual pin indicators
  void drawPinSelectors()
  {
    switch(connectionMode){
      case 'InputToOutput':  drawConnectableOutputPins(); 
                             if(selectedOutput != null)
                               drawHighlightPin(_mouseX, _mouseY, 'VALID'); break;
                                     
      case 'OutputToInput':  drawConnectableInputPins(); 
                             if(selectedInput != null)
                               drawHighlightPin(_mouseX, _mouseY, 'VALID'); break;
                                     
      case 'InputSelected':  drawHighlightPin(selectedInput.offsetX, selectedInput.offsetY, 'VALID'); break;
      
      case 'OutputSelected':  drawHighlightPin(selectedOutput.offsetX, selectedOutput.offsetY, 'VALID'); break;
      
    }
  }
  
  // Draw the output pins that we can connect to
  void drawConnectableOutputPins()
  {
    for (LogicDevice device in logicDevices) {
      if(device.CloneMode) continue;
      for (DeviceOutput output in device.Output) {
        if(output.connectable == true)
          drawHighlightPin(output.offsetX, output.offsetY, 'CONNECTABLE'); 
      }
    }      
  }
  
  // Draw the input pins that we can connect to
  void drawConnectableInputPins()
  {
    for (LogicDevice device in logicDevices) {
      if(device.CloneMode) continue;     
      for (DeviceInput input in device.Input) {
        if(input.connected == false && input.connectable == true)    
          drawHighlightPin(input.offsetX, input.offsetY, 'CONNECTABLE'); 
      }
    }      
  }
  
  void drawHighlightPin(int x, int y, var highlightMode)
  {
    x = x - PIN_INDICATOR_OFFSET;
    y = y - PIN_INDICATOR_OFFSET;
    
    switch(highlightMode){
      case 'VALID':       context.drawImage(validPinImage, x, y); break;
      case 'INVALID':     context.drawImage(validPinImage, x, y); break;
      case 'WIRECONNECT': context.drawImage(startWireImage, x, y); break;
      case 'CONNECTED':   context.drawImage(startWireImage, x, y); break;
      case 'CONNECTABLE': context.drawImage(connectablePinImage, x, y); break; 
      default:            context.drawImage(validPinImage, x, y);
    }
  }
}
  
