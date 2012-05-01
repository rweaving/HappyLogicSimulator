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
  static final int PIN_INDICATOR_OFFSET = 5;
  static final TAU = Math.PI * 2;
  
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
  
  bool addingWire = false;
  bool showGrid = true;
  
  WirePoint wireEndPoint; 
  
  DeviceInput wireStart = null;
  DeviceOutput wireEnd = null;
  DeviceOutput selectedOutput = null;
  DeviceInput tempInput = null;
  
  LogicDevice startDevice = null;
  LogicDevice endDevice = null;
  LogicDevice moveDevice = null;
  
  ButtonElement addNandButton;
  ElementList buttons;
  
  Circuit(this.canvas) : 
    lastTime = Util.currentTimeMillis(), 
    logicDevices = new List<LogicDevice>(){

    context = canvas.getContext('2d');
    _width = canvas.width;
    _height = canvas.height;
    
    validPinImage = new Element.tag('img'); 
    validPinImage.src = "images/SelectPinGreen.png";
    
    selectPin = new Element.tag('img');
    selectPin.src = "images/SelectPinBlack.png";  
    
    startWireImage = new Element.tag('img');
    startWireImage.src = "images/SelectPinBlack.png"; 
    
    connectablePinImage = new Element.tag('img');
    connectablePinImage.src = "images/SelectPinPurple.png";   
    
    wireEndPoint = new WirePoint(-1, -1); 
    
    // Create a timer to update the simulation
    window.setInterval(f() => updateTime(), 50);
    
    // Add handlers to buttons that add the devices
    buttons = document.queryAll('.newdevice');
    buttons.forEach((f){
      f.on.click.add((MouseEvent e) {
        LogicDevice newDevice = new LogicDevice(this, getNewId(), f.name); 
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
    
    canvas.on.mouseDown.add(onMouseDown);
    canvas.on.doubleClick.add(onMouseDoubleClick);
    canvas.on.mouseMove.add(onMouseMove);
    
    Paint();
  }
  
  int get width() => _width;
  int get height() => _height;
  
  void set width(int width) 
  {
    _width = width;
    canvas.width = width;
  }
  
  void set height(int height) 
  {
    _height = height;
    canvas.height = height;
  }
  
  void ClearCircuit()
  {
    logicDevices.clear();
    Paint();
  }
  
  // Save the circuit to local storage
  void SaveCircuit(String name)
  {
    List<String> circuitStrings = new List<String>();
    List<String> connectionList = new List<String>();
    
    logicDevices.forEach((f) {
      circuitStrings.add(JSON.stringify(f.toJson()));
      connectionList.add(f.GetInputs());
    });
    
    window.localStorage[name] = JSON.stringify(circuitStrings);
    window.localStorage["ABC"] = JSON.stringify(connectionList);
  }
  
  LogicDevice GetDeviceByID(var id){
    for (LogicDevice device in logicDevices) {
      if(device.ID == id) return device; 
    }
    return null;
  }
  
  // Load the circuit from local storage
  void LoadCircuit(String name)
  {
    String loadedCircuit = window.localStorage[name];
    
    List<String> circuitStrings = new List<String>();
    circuitStrings = JSON.parse(loadedCircuit);
    
    circuitStrings.forEach((f) {
      LogicDevice newDevice = new LogicDevice.fromJson(this, JSON.parse(f)); 
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
          
          device.Input[sinout].createWire();
          int pointCount = wirePointList.length;
          
          for(int t1=0; t1<pointCount; t1++){
            Map json2 = JSON.parse(wirePointList[t1]);
            
            int x = json2['x'];
            int y = json2['y'];
            
            if(sinout < device.InputCount && sinout >= 0)
              device.Input[sinout].wire.AddPoint(x, y);
          }
        }
      }
    });
    Paint();    
 }
  
  void drawBorder() {
    context.beginPath();
    context.rect(0, 0, width, height);
    context.fillStyle = "#eeeeee";
    context.lineWidth = BORDER_LINE_WIDTH;
    context.strokeStyle = BORDER_LINE_COLOR;
    context.fillRect(0, 0, width, height);
    context.stroke();
    context.closePath();
  }
  
  void drawGrid(){
    context.beginPath();
    context.lineWidth = 1;
    context.strokeStyle = GRID_COLOR;
    
    for(int x=GRID_SIZE; x < width; x+=GRID_SIZE){
      for(int y=GRID_SIZE; y < height; y+=GRID_SIZE){
        context.rect(x, y, GRID_POINT_SIZE, GRID_POINT_SIZE);
      }
    }
    context.stroke();
    context.closePath(); 
  }
 
  void updateTime(){
    if(logicDevices.length <= 0) return;
    
    for (LogicDevice device in logicDevices) {
      device.calculated = false;
    }
    for (LogicDevice device in logicDevices) {
      device.Calculate();
    }
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
   
   if(moveDevice != null) 
     moveDevice = null;
   
   if(addingWire){
     if(selectedOutput  != null){
       EndWire(selectedOutput);
     }
     else{
       selectedInput.wire.AddPoint(e.offsetX, e.offsetY);  
    }
   }
   else{
     if(selectedInput  != null){
       StartWire(selectedInput);
       }
     else{
       for (LogicDevice device in logicDevices) {
         if(device.contains(e.offsetX, e.offsetY)){
           device.clicked();
           break;
         }
       }
     }
   }
 }

 void onMouseDoubleClick(MouseEvent e) 
 {
   e.stopPropagation();
   e.preventDefault();
   
   if(addingWire) return;
 }
 
 void onMouseMove(MouseEvent e) 
 {
   _mouseX = e.offsetX;
   _mouseY = e.offsetY; 
   
   if(moveDevice != null){
     moveDevice.MoveDevice(_mouseX, _mouseY);
     Paint();
     return;
   }
   
   // If the user is adding a wire to the simulation
   // We are in the process of connecting two devices
   if(addingWire){ 
     wireEndPoint.x = -1;
     wireEndPoint.y = -1;
     
     for (LogicDevice device in logicDevices) {
       selectedOutput = device.OutputPinHit(e.offsetX, e.offsetY);
       
       if(selectedOutput != null){ // Check to see if we are hitting an output pin 
         wireEndPoint.x = selectedOutput.offsetX; //Snap to output pin
         wireEndPoint.y = selectedOutput.offsetY;
         break;
       }
       else{
         selectedOutput = device.WireHit(e.offsetX, e.offsetY); // Check to see if we are hitting a wire
         if(selectedOutput != null){
           wireEndPoint.x = e.offsetX;
           wireEndPoint.y = e.offsetY;
           break; 
         }
       }
     }
       
     if(selectedOutput  != null){
       UpdateWire(wireEndPoint.x, wireEndPoint.y, 'VALID');
     }
     else{
          UpdateWire(e.offsetX, e.offsetY, 'INVALID');  
     }
    }
   
    if (!addingWire){
        for (LogicDevice device in logicDevices) {
          tempInput = device.InputPinHit(e.offsetX, e.offsetY);
          if(tempInput  != null){
            SelectInput(tempInput);
            break;
            }
         }
         if(tempInput == null){
           if(selectedInput != null){
             selectedInput = null;
             Paint();
           }
        }
     }
  }
  
  //Start Adding a wire
  void StartWire(DeviceInput input)
  {
    addingWire = true;
    wireStart = input;
    input.createWire();
    drawPinSelectors();
  }
  
  void EndWire(DeviceOutput output)
  {
    wireStart.connectedOutput = output;
    
    if(wireEndPoint.x > 0 && wireEndPoint.y > 0){
      wireStart.wire.AddPoint(wireEndPoint.x, wireEndPoint.y);
      wireEndPoint.x = 1;
      wireEndPoint.y = 1;
    }
    else
      wireStart.wire.AddPoint(output.offsetX, output.offsetY); 
    
    addingWire = false;
    wireStart = null;
    selectedInput = null;
    selectedOutput = null;
    Paint();
  }
  
  // Draw the wire being added to the current cursor position
  UpdateWire(int x, int y, var mode)
  {
    Paint();
    if(wireStart != null){
      if(wireStart.wire != null)
        wireStart.wire.UpdateLast(x, y);
        drawWire(wireStart, mode);
    }
  }
  
  void drawWire(DeviceInput input, state){
    if(input.wire == null) return;  
    
    switch(state){
      case 'VALID':   context.strokeStyle = NEW_WIRE_VALID; break;
      case 'INVALID': context.strokeStyle = NEW_WIRE_INVALID; break;
           
      case false:     context.strokeStyle = WIRE_LOW; break;
      case true:      context.strokeStyle = WIRE_HIGH; break;
           
      default:        context.strokeStyle = WIRE_INVALID;
    }
    
    context.fillStyle = context.strokeStyle;
    context.beginPath();
    context.lineWidth = WIRE_WIDTH;

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
          context.arc(input.wire.wirePoints[input.wire.wirePoints.length-1].x, input.wire.wirePoints[input.wire.wirePoints.length-1].y, 5, 0, TAU, false);
          context.fill();
          context.stroke();
          context.closePath(); 
      }
    }
  }    
  
  
  void abortWire()
  {
    addingWire = false;
    wireStart = null;
    Paint();
  }
  
  //Draw all the wires
  void drawWires()
  {
    for (LogicDevice device in logicDevices) 
      for (DeviceInput input in device.Input) 
        if (input.connectedOutput != null)
           drawWire(input, input.value);
  }
  
  //Draw the wires that have been updated
  void drawUpdatedWires()
  {
    for (LogicDevice device in logicDevices) 
      for (DeviceInput input in device.Input) 
        if (input.connectedOutput != null)
          if (input.updated) 
            drawWire(input, input.value);
  }
  
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
    drawGrid();
    drawDevices();
    drawWires();
    drawPinSelectors();
  }
   
  void drawPinSelectors()
  {
    if(wireStart != null){
      if(selectedOutput != null){
          if(wireEndPoint.x > 0)
            drawHighlightPin(wireEndPoint.x, wireEndPoint.y, 'VALID');
          else
            drawHighlightPin(selectedOutput.offsetX, selectedOutput.offsetY, 'VALID');
       }
       drawConnectableOutputPins();
    }
    if(selectedInput != null){
     if(selectedInput.connected)
          drawHighlightPin(selectedInput.offsetX, selectedInput.offsetY, 'CONNECTED');
      else
         drawHighlightPin(selectedInput.offsetX, selectedInput.offsetY, 'VALID'); 
    }
  }
  
  // Draw the output pins that we can connect to
  void drawConnectableOutputPins()
  {
    for (LogicDevice device in logicDevices) {
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
      for (DeviceInput input in device.Input) {
        if(input.connected == false && input.connectable == true)    
          drawHighlightPin(input.offsetX, input.offsetY, 'CONNECTABLE'); 
      }
    }      
  }
  
  void SelectInput(DeviceInput input)
  {
    if(selectedInput !== input){
      selectedInput = input;
      Paint(); 
    }
  }
  
  void SelectOutput(DeviceOutput output)
  {
    if(selectedOutput !== output){
      selectedOutput = output;
      Paint(); 
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
  
