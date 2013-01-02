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
