#library('wire_point');
#import('canvas_point.dart');
#import('wire.dart');

class WirePoint  implements CanvasPoint {
  num x;
  num y;
  bool drawKnot = false;
  Wire wire;
  
  WirePoint(this.wire, this.x, this.y) {}
}