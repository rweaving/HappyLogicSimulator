    // Touch Events
    canvas.on.touchEnter.add((event) => onTouchEnter(event), false);
    canvas.on.touchStart.add((event) => onTouchStart(event), false);
    canvas.on.touchMove.add((event) => onTouchMove(event), false);
    canvas.on.touchEnd.add((event) => onTouchEnd(event), false);
    canvas.on.touchCancel.add((event) => onTouchCancel(event), false);
    canvas.on.touchLeave.add((event) => onTouchLeave(event), false); 
 

  
  void onTouchEnter(TouchEvent e) {
    e.preventDefault();
    e.stopPropagation();
    _touchX = e.targetTouches[0].pageX;// Use first point
    _touchY = e.targetTouches[0].pageY;
  
  }
  
  void onTouchStart(TouchEvent e) {
    e.preventDefault();
    e.stopPropagation();
    _touchX = e.targetTouches[0].pageX;// Use first point
    _touchY = e.targetTouches[0].pageY;
    
    //Check to see if we are touching a device
    LogicDevice selectedDevice = tryDeviceSelect(_touchX, _touchY);
    if(selectedDevice != null) {
        if(selectedDevice.CloneMode) { // If we start dragging on cloneable device make a new one and start moving it
          newDeviceFrom(selectedDevice);
          Paint();
          return;
        }
        selectedDevice.clicked(); // Send click to touched device
        Paint();
     }
    
    // Check to see if we are touching in input
    DeviceInput _selectedInput = tryInputSelect(_touchX, _touchY);
    if(_selectedInput != null) {
      selectedInput = _selectedInput;
      connectionMode = 'InputSelected';  
      StartWire(_touchX, _touchY);
      return;
    }
    
    // Check to see if we are touching in Output
    DeviceOutput _selectedOutput = tryOutputSelect(_touchX, _touchY);
    if(_selectedOutput != null) {
      selectedOutput = _selectedOutput;
      connectionMode = 'OutputSelected';  
      StartWire(_touchX, _touchY); 
      return;
    } 
  }
  
  void onTouchMove(TouchEvent e) {
    e.preventDefault();
    e.stopPropagation();
    
    _touchX = e.targetTouches[0].pageX;// Use first point
    _touchY = e.targetTouches[0].pageY;
    
    if(moveDevice != null){ // We are moving a device
      if (e.targetTouches.length >= 1) {
        moveDevice.MoveDevice(_touchX, _touchY);
        Paint();
        return;
      }
    }
    Paint();
  }
  
  void onTouchEnd(TouchEvent e) {
    e.preventDefault();
    e.stopPropagation();
    
    _touchX = e.targetTouches[0].pageX;// Use first point
    _touchY = e.targetTouches[0].pageY;
    
    if(moveDevice != null) { 
      moveDevice = null;
      Paint();
      return;
    }  
  }  
  
  void onTouchCancel(TouchEvent e) {
    if(moveDevice != null) { 
      moveDevice = null;
      Paint();
      return;
    }  
  }
  
  
  void onTouchLeave(TouchEvent e) {
    if(moveDevice != null) { 
      moveDevice = null;
      Paint();
      return;
    } 
  }
  