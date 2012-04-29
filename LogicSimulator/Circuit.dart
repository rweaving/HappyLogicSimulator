/** Simple Logic Simulator for Google Dart Hackathon 4-27-2012   
/   By: Ryan C. Weaving  &  Athhur Liu                           */

class Circuit {

  static final int BORDER_LINE_WIDTH = 1;
  static final String BORDER_LINE_COLOR = '#000000';
  static final int NEW_WIRE_WIDTH = 3;
  static final String NEW_WIRE_COLOR = '#990000';
  
  static final String NEW_WIRE_VALID = '#009900';
  static final String NEW_WIRE_INVALID= '#999999';
  
  static final String WIRE_HIGH = '#ffde00';
  static final String WIRE_LOW = '#550091';
  static final int WIRE_WIDTH = 3;
  
  static final int GRID_SIZE = 10;
  static final int GRID_POINT_SIZE = 1;
  static final String GRID_COLOR = '#999493';
  static final int PIN_INDICATOR_OFFSET = 5;
  
  
  static final List<String> SELECTPIN = const ["images/SelectPinGreen.png",
                                               "images/SelectPinRed.png", 
                                               "images/SelectPinYellow.png",
                                               "images/SelectPinBlack.png"];
  

  CanvasElement canvas;
  CanvasRenderingContext2D context;
  DeviceInput selectedInput;
  
  ImageElement validPinImage;
  
  ImageElement selectPin;
  ImageElement startWireImage;
   
  int _width;
  int _height;
  int _mouseX;
  int _mouseY;
  
  DivElement root;
  int lastTime;
  List<LogicDevice> logicDevices;
  
  bool simulationActive = true;
  
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
    validPinImage.src = SELECTPIN[0];   
    
    selectPin = new Element.tag('img');
    selectPin.src = SELECTPIN[0];   
    
    startWireImage = new Element.tag('img');
    startWireImage.src = SELECTPIN[3];   
    
    wireEndPoint = new WirePoint(-1, -1); 
    
    // Create a timer to update the simulation
    window.setInterval(f() => updateTime(), 50);
    
    // Add handlers to buttons that add the devices
    buttons = document.queryAll('.newdevice');
    buttons.forEach((f){
      f.on.click.add((MouseEvent e) {
        LogicDevice newDevice = new LogicDevice(this, canvas, getNewId(), f.name); 
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
      LoadCircuit("Test");
    });
    
    
    canvas.on.mouseDown.add(onMouseDown);
    canvas.on.doubleClick.add(onMouseDoubleClick);
    canvas.on.mouseMove.add(onMouseMove);
    canvas.on.keyDown.add(onKeyPress);
    
    clearCanvas();  
    drawBorder();
    drawGrid();
  }
  
  int get width() => _width;
  int get height() => _height;
  
  void set width(int width) {
    _width = width;
    canvas.width = width;
  }
  
  void set height(int height) {
    _height = height;
    canvas.height = height;
  }
  
  void SaveCircuit(String name){
    List<String> circuitStrings = new List<String>();
    List<String> connectionList = new List<String>();
    
    logicDevices.forEach((f) {
      circuitStrings.add(JSON.stringify(f.toJson()));
 
      //print(f.GetInputs());
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
  
  void LoadCircuit(String name){
    String loadedCircuit = window.localStorage[name];
    
    List<String> circuitStrings = new List<String>();
    circuitStrings = JSON.parse(loadedCircuit);
    //print(circuitStrings);
    
    circuitStrings.forEach((f) {
      //print(f);  
      LogicDevice newDevice = new LogicDevice.fromJson(this, canvas, JSON.parse(f)); 
      logicDevices.add(newDevice);
      
    });
    
    List<String> connectionStrings = new List<String>();
    String loadedConnections = window.localStorage["ABC"];
    connectionStrings = JSON.parse(loadedConnections);
    
    connectionStrings.forEach((f) {
      //print("Restore"); print(f);  
      List<String> connections = new List<String>();
      connections = JSON.parse(f);
      
      for(int t=0; t<connections.length; t++){
      //connections.forEach((g){
        // 
        //print("Restore2"); print(g);
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
          
          //wirePointList.forEach((h){
            Map json2 = JSON.parse(wirePointList[t1]);
            
            int x = json2['x'];
            int y = json2['y'];
            
            if(sinout < device.InputCount && sinout >= 0)
              device.Input[sinout].wire.AddPoint(x, y);
          
          }//);
        }
      }//);
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
 
  // Gets called to update the simulation
  void updateTime(){
    // Clear the calc flag for every device
    logicDevices.forEach((f) {
      f.calculated = false;   
    });
    // Calculate device state
    logicDevices.forEach((f) {
      f.Calculate();
    });
    drawUpdate(); // Draw devices and wires that have updated
  }
  
  // add new id number
  getNewId(){
    //return "1234";    
    return logicDevices.length;
  }
  
  
  // Start the simulation 
  void run() {
    
   /** // TODO: add devices dynamically
    logicDevices.add(new LogicDevice(this, canvas, 'nand0', 'NAND'));
    logicDevices.add(new LogicDevice(this, canvas, 'nand1', 'NAND'));
    logicDevices.add(new LogicDevice(this, canvas, 'nand2', 'NAND'));
    logicDevices.add(new LogicDevice(this, canvas, 'nand3', 'NAND'));
    logicDevices.add(new LogicDevice(this, canvas, 'nand4', 'NAND'));
    logicDevices.add(new LogicDevice(this, canvas, 'nand5', 'NAND'));
    logicDevices.add(new LogicDevice(this, canvas, 'nand6', 'NAND'));
    logicDevices.add(new LogicDevice(this, canvas, 'nand7', 'NAND'));
    logicDevices.add(new LogicDevice(this, canvas, 'not1', 'NOT'));
    logicDevices.add(new LogicDevice(this, canvas, 'switch1', 'SWITCH'));
    logicDevices.add(new LogicDevice(this, canvas, 'led1', 'LED'));
    
    logicDevices[0].MoveDevice(100,50);
    logicDevices[1].MoveDevice(100,150);
    logicDevices[2].MoveDevice(200,50);
    logicDevices[3].MoveDevice(200,150);
    logicDevices[4].MoveDevice(300,50);
    logicDevices[5].MoveDevice(300,150);
    logicDevices[6].MoveDevice(400,50);
    logicDevices[7].MoveDevice(400,150);
    logicDevices[8].MoveDevice(200,250); //not
    logicDevices[9].MoveDevice(25,300); //switch
    logicDevices[10].MoveDevice(550,100); // disp
    
    logicDevices.add(new LogicDevice(this, canvas, 'clock1', 'CLOCK'));
    logicDevices[11].MoveDevice(25,100); 
      */   
  }
  
  // Keyboard events
 void onKeyPress(KeyboardEvent e){
   if(e.keyCode == 65 || e.keyCode == 97){
     LogicDevice newDevice = new LogicDevice(this, canvas, 'nand0', 'NAND');
     logicDevices.add(newDevice);
     newDevice.MoveDevice(_mouseX,_mouseY);
     Paint();
   }
 }
  
 // Mouse events 
 void onMouseDown(MouseEvent e) {
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

 void onMouseDoubleClick(MouseEvent e) {
   e.stopPropagation();
   e.preventDefault();
   
   if(addingWire) return;

   // Move the device
   /*
   for (LogicDevice device in logicDevices) {
     if(device.contains(e.offsetX, e.offsetY)){
       if(moveDevice == null)
         moveDevice = device;
       break;
     }
   }*/
 }
 
 void onMouseMove(MouseEvent e) {
   _mouseX = e.offsetX;
   _mouseY = e.offsetY; 
   
   // If the user is adding a wire to the simulation
   if(moveDevice != null){
     moveDevice.MoveDevice(_mouseX, _mouseY);
     Paint();
   }
   
   if(addingWire){
     wireEndPoint.x = -1;
     wireEndPoint.y = -1;
     
     for (LogicDevice device in logicDevices) {
          selectedOutput = device.OutputPinHit(e.offsetX, e.offsetY);
          
          if(selectedOutput == null){
            selectedOutput = device.WireHit(e.offsetX, e.offsetY);
            if(selectedOutput != null){
              wireEndPoint.x = e.offsetX;
              wireEndPoint.y = e.offsetY;
            }
          }
          if(selectedOutput  != null) break;
        }
        // TODO: check for wire hits
        if(selectedOutput  != null){
          UpdateWire(selectedOutput.offsetX, selectedOutput.offsetY, 'VALID');
          drawPinSelector();
        }
        else{
          UpdateWire(e.offsetX, e.offsetY, 'INVALID');  
        }
      }
    else{
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
    drawPinSelector();
  }
  
  void EndWire(DeviceOutput output){
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
  UpdateWire(int x, int y, var mode){
    // use XOR???
    
    Paint();
    wireStart.drawWire();
    
    if(wireStart != null){
      context.beginPath();
      context.lineWidth = NEW_WIRE_WIDTH;
    
      switch(mode){
        case 'VALID': context.strokeStyle = NEW_WIRE_VALID; break;
        case 'INVALID': context.strokeStyle = NEW_WIRE_INVALID; break;
        //WIRE_HIGH
        default: context.strokeStyle = NEW_WIRE_INVALID;
      }
   
      
      // if our endpoint is on a wire then draw the point to this location
      if(wireEndPoint.x > 0){ 
        context.moveTo(wireEndPoint.x, wireEndPoint.y);
      }      
      else{
        context.moveTo(x, y);
      }

      context.lineTo(wireStart.wire.lastX, wireStart.wire.lastY);

      context.stroke();
      context.closePath();
    }
  }

  void abortWire(){
    addingWire = false;
    wireStart = null;
    Paint();
  }
  
  void drawCircuit()
  {
    logicDevices.forEach((f) {
      f.Paint();
    });
  }
  
  void drawWires()
  {
    logicDevices.forEach((f) {
      f.drawWires();
    });
  }
  
  void clearCanvas()
  {
    context.clearRect(0, 0, _width, _height);
  }
  
  void drawUpdate()
  {
    logicDevices.forEach((f) {
      f.drawUpdate();
    });   
  }
  
  void Paint()
  {
    clearCanvas();  
    drawBorder();
    if(showGrid) drawGrid();
    drawCircuit();
    drawWires();
    drawPinSelector();
  }
   
  void drawPinSelector()
  {
    if(wireStart != null){
      if(selectedOutput != null){
          if(wireEndPoint.x > 0)
            drawHighlightPin(wireEndPoint.x, wireEndPoint.y, 'VALID');
          else
            drawHighlightPin(selectedOutput.offsetX, selectedOutput.offsetY, 'VALID');
       }
    }
    
    if(selectedInput != null){
      if(selectedInput.connected)
          drawHighlightPin(selectedInput.offsetX, selectedInput.offsetY, 'CONNECTED');
      else
         drawHighlightPin(selectedInput.offsetX, selectedInput.offsetY, 'VALID'); 
    }
  }
  
  void SelectInput(DeviceInput input){
    if(selectedInput !== input){
      selectedInput = input;
      Paint(); // TODO: use rec clipping to save having to repaint circuit
    }
  }
  
  void drawHighlightPin(int x, int y, var highlightMode){
    x = x - PIN_INDICATOR_OFFSET;
    y = y - PIN_INDICATOR_OFFSET;
    
    switch(highlightMode){
      case 'VALID':       context.drawImage(validPinImage, x, y); break;
      case 'INVALID':     context.drawImage(validPinImage, x, y); break;
      case 'WIRECONNECT': context.drawImage(startWireImage, x, y); break;
      case 'CONNECTED':   context.drawImage(startWireImage, x, y); break;
      default:            context.drawImage(validPinImage, x, y);
    }
  }

}
  
