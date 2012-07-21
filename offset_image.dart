#library('offset_image');
#import('canvas_point.dart');
#import('dart:html');

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