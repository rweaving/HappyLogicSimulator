
/** Contains a point on our canvas */
class CanvasPoint {
  num x;
  num y;
  CanvasPoint(this.x, this.y);
}

/** Contains an ImageElement with an offset point */
class OffsetImage {
  CanvasPoint offsetPoint;
  ImageElement image;
  
  OffsetImage(var imageSrc, num offsetLeft, num offsetTop) {
    offsetPoint = new CanvasPoint(offsetLeft, offsetTop); 
    image = new Element.tag('img'); 
    image.src = imageSrc;
  }
}