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

/** This class is fore creating deritive devices */
class DeviceCreator {
  
  DeviceCreator();
  
  String xmlString;
  
  
  String createDevice(List<LogicDevice> logicDevices) {
    int inCount = 0;
    int outCount = 0;
    
    for (LogicDevice d in logicDevices) {
      if (d.deviceType.type == 'INPUT') {
        inCount++;
      }
      if (d.deviceType.type == 'OUTPUT') {
        outCount++;
      }
    }
    
    print("Inputs:${inCount},  Outputs:${outCount}");
    
    for (LogicDevice d in logicDevices) {

      if (d.deviceType.type == 'INPUT' || d.deviceType.type == 'OUTPUT') {
        continue;
      }
    
      var deviceID = logicDevices.indexOf(d);
      
      for (Logic sl in d.subLogic) {
        var subGate = sl.name;
        var id =   d.subLogic.indexOf(sl);
        var con1 = d.subLogic.indexOf(sl.inGate1);
        var con2 = d.subLogic.indexOf(sl.inGate2);
        
        print('${subGate} : <${deviceID}.${id}> : ${deviceID}.${id}_${con1} , ${deviceID}.${id}_${con2}');
      }
    }
    
  }
  
  
}
