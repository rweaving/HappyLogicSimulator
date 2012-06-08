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

#import('dart:html');
#import('dart:json');
#import('dart:core');

#source('circuit.dart');
#source('circuit_draw.dart');
#source('circuit_view.dart');
#source('logic_device_types.dart');
#source('logic.dart');
#source('logic_device.dart');
#source('device_creator.dart');
#source('device_input.dart');
#source('device_io.dart');
#source('device_output.dart');
#source('device_pin.dart');
#source('device_selector.dart');


#source('logic_style.dart');
#source('wire.dart');
#source('wires.dart');

void main() {
  new CircuitView(document.query('#canvas')).start();
}
