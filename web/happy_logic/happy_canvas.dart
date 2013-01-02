//  (c) Copyright 2012 - Ryan C. Weaving
//  https://plus.google.com/111607634508834917317
//
//  This file is part of Happy Logic Simulator.
//  http://HappyLogicSimulator.com
//
//  Happy Logic Simulator is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  Happy Logic Simulator is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with Happy Logic Simulator.  If not, see <http://www.gnu.org/licenses/>.

part of happy_logic;

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