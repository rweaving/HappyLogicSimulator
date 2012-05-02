/** Simple Logic Simulator for Google Dart Hackathon 4-27-2012   
/   By: Ryan C. Weaving  &  Athhur Liu                           */

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
  
  DivElement root;
  int lastTime;
  List<LogicDevice> logicDevices;
  
  bool showGrid = false;
  
  WirePoint wireEndPoint; 

  DeviceOutput selectedOutput;
  
  DeviceOutput tempOutput;
  DeviceInput tempInput;

  LogicDevice moveDevice;
  LogicDevice cloneDevice;
  
  ButtonElement addNandButton;
  ElementList buttons;
  
  Wire dummyWire;
  
  var connectionMode = 'INIT';
  
  bool connectingOutputToInput = false;
  bool connectingInputToOutput = false;
  
  Circuit(this.canvas) : 
    lastTime = Util.currentTimeMillis(), 
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
    window.setInterval(f() => tick(), 100);
    /***
    // Add handlers to buttons that add the devices
    buttons = document.queryAll('.newdevice');
    buttons.forEach((f){
      f.on.click.add((MouseEvent e) {
        LogicDevice newDevice = new LogicDevice(getNewId(), f.name); 
        logicDevices.add(newDevice);
        moveDevice = newDevice;
      });});
    
    ButtonElement saveButton;
    saveButton = document.query('#saveButton');
    saveButton.on.click.add((MouseEvent e) {
      SaveCircuit("Test");
    });

    ButtonElement loadButton;
    loadButton = document.query('#loadButton');
    loadButton.on.click.add((MouseEvent e) {
      ClearCircuit();
      LoadCircuit("Test");
    });
    
    ButtonElement clearButton;
    loadButton = document.query('#clearButton');
    loadButton.on.click.add((MouseEvent e) {
      ClearCircuit();
    });
     */
    canvas.on.mouseDown.add(onMouseDown);
    canvas.on.doubleClick.add(onMouseDoubleClick);
    canvas.on.mouseMove.add(onMouseMove);
    
    window.on.resize.add((event) => onResize(), true);
   
    createSelectorBar();
    
    Paint();
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
    LogicDevice newDevice = new LogicDevice(id, type); 
    logicDevices.add(newDevice);
    newDevice.CloneMode = true;
    newDevice.MoveDevice(x, y);
    return newDevice;
  }
  
  NewDeviceFrom(LogicDevice device){
    LogicDevice newDevice = new LogicDevice(getNewId(), device.Type); 
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
  
  // TODO: Cleanup save code
  // Save the circuit to local storage
  void SaveCircuit(String name)
  { /**
    List<String> circuitStrings = new List<String>();
    List<String> connectionList = new List<String>();
    
    logicDevices.forEach((f) {
      circuitStrings.add(JSON.stringify(f.toJson()));
      connectionList.add(f.GetInputs());
    });
    
    window.localStorage[name] = JSON.stringify(circuitStrings);
    window.localStorage["ABC"] = JSON.stringify(connectionList); */
  }
  
 
  
  // TODO: Cleanup load code
  // Load the circuit from local storage
  void LoadCircuit(String name)
  { /***
    String loadedCircuit = window.localStorage[name];
    
    List<String> circuitStrings = new List<String>();
    circuitStrings = JSON.parse(loadedCircuit);
    
    circuitStrings.forEach((f) {
      LogicDevice newDevice = new LogicDevice.fromJson(JSON.parse(f)); 
      logicDevices.add(newDevice);
    });
    
    List<String> connectionStrings = new List<String>();
    String loadedConnections = window.localStorage["ABC"];
    connectionStrings = JSON.parse(loadedConnections);
    
    connectionStrings.forEach((f) {
      List<String> connections = new List<String>();
      connections = JSON.parse(f);
      
      for(int t=0; t<connections.length; t++){
        Map json = JSON.parse(connections[t]);
        
        var SourceDevice = json['SourceDevice'];
        var SourceDeviceInput = json['SourceDeviceInput'];
        
        var DestinationDevice = json['DestinationDevice'];
        var DestinationDeviceOutput = json['DestinationDeviceOutput'];
        
        if(DestinationDevice == null)
          continue;
            
        int sinout = Math.parseInt(SourceDeviceInput);
        int dpin = Math.parseInt(DestinationDeviceOutput);
        
        LogicDevice outputDevice = GetDeviceByID(json['DestinationDevice']);
        LogicDevice device = GetDeviceByID(json['SourceDevice']);
        
        device.Input[sinout].connectedOutput = outputDevice.Output[dpin]; 
        
        String wirePoints = json['wirePoints'];
        List<String> wirePointList = new List<String>();
        wirePointList = JSON.parse(wirePoints);
        
        if(wirePointList.length >= 2){
          int pointCount = wirePointList.length;
          
          for(int t1=0; t1<pointCount; t1++){
            Map json2 = JSON.parse(wirePointList[t1]);
            
            int x = json2['x'];
            int y = json2['y'];
              
            if(sinout < device.InputCount && sinout >= 0){
              if(device.Input[sinout].wire == null)
                device.Input[sinout].createWire(x, y);
              
              device.Input[sinout].wire.AddPoint(x, y);
            }
          }
        }
      }
    });
    Paint(); */
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
    if(logicDevices.length <= 0)return;
    
    for (LogicDevice device in logicDevices) {
      device.calculated = false;
    }
    for (LogicDevice device in logicDevices) {
      device.Calculate();
    }
    
    if(logicDevices.length <= 10) Paint(); //Hack
   
    drawUpdate(); // Draw devices and wires that have updated
  }
  
  // add new id number
  getNewId(){    
    return logicDevices.length;
  }
  
 // Mouse events 
 void onMouseDown(MouseEvent e) 
 {
   e.preventDefault();
   Paint();
   if(moveDevice != null) 
     moveDevice = null;
   
   switch(connectionMode){
     case 'InputToOutput':    
     case 'OutputToInput':   AddWirePoint(_mouseX, _mouseY); 
                             if(checkValidConnection())
                               EndWire();
                             return;
                                                         
     case 'InputSelected' :  StartWire(_mouseX, _mouseY); return;
                             
     case 'OutputSelected' : StartWire(_mouseX, _mouseY); return;
      
     case 'CloneDevice' :    NewDeviceFrom(cloneDevice); return;
                                                       
     case null:              for (LogicDevice device in logicDevices) {
                               if(device.contains(e.offsetX, e.offsetY)){
                                 device.clicked();
                                 break;
                               }
                             } break;
             
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
   
   //print('MouseMove() $connectionMode');
   
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
   //print('AddWirePoint($x, $y) $connectionMode');
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
  
  //Draw the wires that have been updated
  void drawUpdatedWires()
  {
    for (LogicDevice device in logicDevices) 
      for (DeviceInput input in device.Input) 
        if (input.connectedOutput != null)
          if (input.updated){
            drawWire(input, 'ERASE');
            drawWire(input, input.value);
          }
  }
  
  // Redraw all of the devices
  void drawDevices()
  {
    for (LogicDevice device in logicDevices) {
      if(device.Images.length > 1 && device.OutputCount > 0){
        if(device.Output[0].value == true)
          context.drawImage(device.Images[1], device.X, device.Y);
        else
          context.drawImage(device.Images[0], device.X, device.Y);
        }
      else
        context.drawImage(device.Images[0], device.X, device.Y);
    }
  }
  
  // Draw the devices that have been updated
  void drawUpdatedDevices()
  {
    for (LogicDevice device in logicDevices) {
      if(device.updateable && device.updated){
        if(device.Images.length > 1 && device.OutputCount > 0){
          if(device.Output[0].value == true)
            context.drawImage(device.Images[1], device.X, device.Y);
          else
            context.drawImage(device.Images[0], device.X, device.Y);
        }
        else
          context.drawImage(device.Images[0], device.X, device.Y);
        }
     }
  }
  
  void clearCanvas()
  {
    context.clearRect(0, 0, _width, _height);
  }
  
  void drawUpdate()
  {
    drawUpdatedDevices();
    drawUpdatedWires();
  }
  
  void Paint()
  {
    clearCanvas();  
    drawBorder();
    //drawGrid();
    drawDevices();
    drawWires();
    drawPinSelectors();
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
  
