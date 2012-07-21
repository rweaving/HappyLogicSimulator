
/** Used to map internal inputs to displayable events i.g. image updates*/
class ImageMap {
  var id;
  var type;
  OffsetImage highImage;
  OffsetImage lowImage;
  
  ImageMap(this.id, var mapLowImage, var mapHighImage, int offsetX, int offsetY) {
    
    if (mapLowImage != null) {
      lowImage = new OffsetImage(mapLowImage, offsetX, offsetY);
    }
    
    if (mapHighImage != null) {
      highImage = new OffsetImage(mapHighImage, offsetX, offsetY);
    }
  }
}

class SubLogicGate {
  var gateType;
  //var id;
  int connection1 = -1;
  int connection2 = -1;
  
  SubLogicGate(this.gateType, this.connection1, this.connection2);
}

/** Used to map external events to device outputs i.g. KeyPress */
class OutputMap {
  var id;
  var type;
  var value;
  
  OutputMap(this.id, this.type, this.value);
}

/** Used to map internal inputs to events i.g. sounds */
class InputMap {
  var id;
  var type;
  var value;
  
  InputMap(this.id, this.type, this.value);
}
