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

/** This class is for creating deritive devices */
class DeviceCreator {
  
  DeviceCreator();
  
  /** Creates a logic the device in the given document from a given list of logic devices */
  void createDevice(List<LogicDevice> logicDevices, Document doc) {

    var element = new Element.tag('device');
    element.attributes['name'] = "AND";
    element.attributes['image'] = "images/125dpi/and.png";
    element.attributes['icon'] = "images/125dpi/and_d.png";

    for (LogicDevice d in logicDevices) {
      var e = new Element.tag('gate');
      var type = d.deviceType.type;
      e.attributes['type'] = type;
      e.attributes['id'] = logicDevices.indexOf(d).toString();
      
      for(DeviceInput i in d.inputs) {
        if(i.connected == true) {
          e.attributes['i${d.inputs.indexOf(i)}'] = logicDevices.indexOf(i.connectedWire.output.device).toString();
        }
      }
      // Add x and y locations for io pin offsets
      if (type == "INPUT" || type == "OUTPUT") { 
        e.attributes['x'] = '0';
        e.attributes['y'] = '0';
        //e.attributes['tag'] = 'TestTagName';
      }
      element.nodes.add(e);  
    }
    doc.body.nodes.add(element);
  }
}


