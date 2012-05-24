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

/** 
This is the base logic class for devices, It allow logic devices to use
derivive circuits for their core logic */
class Logic {

  static final int NC = -1;
  
  int duration;
  int delay;
  int ticks;
  
  var name;
  String label;
  
  bool calculated;
  
  int ig1; // holds input gate index for preconnecting
  int ig2;
  
  bool in1;
  bool in2;
  bool out;
  
  Logic inGate1; // Pointer to connected gate
  Logic inGate2;
  
  Logic() { 
    
  }
  
  bool get status() => out;
  
  setDelay(int count) {
    
  }
  
  void calc() { 
    calculated = true;
    
    if (inGate1 != null) {
      inGate1.calc();
    }
    
    if (inGate2 == null) {
      inGate2.calc();
    }
  }
  
}

/**External input */
class pIn extends Logic { 
  pIn(){name='IN';}
  void calc() {
    calculated = true;
  }
}

/**External output */
class pOut extends Logic { 
  pOut(){name='OUT';}
  void calc() {
    calculated = true;
    out = inGate1.out;
  }
}

/**PRIMARY AND (2 in - 1 out) */
class pAnd extends Logic { 
  pAnd(){name='AND';}
  void calc() {
    calculated = true;
    out = inGate1.out && inGate2.out;
  }
}

/**PRIMARY NAND (2 in - 1 out) */
class pNand extends Logic { 
  pNand(){name='NAND';}
  void calc() {
    calculated = true;
    out = !(inGate1.out && inGate2.out);
  }
}

/**PRIMARY OR (2 in - 1 out) */
class pOr extends Logic { 
  pOr(){name='OR';}
  void calc() {
    calculated = true;
    out = inGate1.out || inGate2.out;
  }
}

/**PRIMARY NOR (2 in - 1 out) */
class pNor extends Logic { 
  pNor(){name='NOR';}
  void calc() {
    calculated = true;
    out = !(inGate1.out || inGate2.out);     
  }
}

/**PRIMARY XOR (2 in - 1 out) */
class pXor extends Logic { 
  pXor(){name='XOR';}
  void calc() {
    calculated = true;
    out = inGate1.out != inGate2.out;
  }
}

/**PRIMARY XNOR (2 in - 1 out) */
class pXnor extends Logic { 
  pXNor(){name='XNOR';}
  void calc() {
    calculated = true;
    out = !(inGate1.out != inGate2.out);
  }
}

/**PRIMARY Not (2 in - 1 out) */
class pNot extends Logic { 
  pXNot(){name='NOT';}
  void calc() {
    calculated = true;
    out = !inGate1.out;
  }
}

/**PRIMARY Switch (1 in - 1 out) */
class pSwitch extends Logic { 
  pSwitch(){name='SWITCH';}
  void calc() {
    out = in1;  
  }
}

/**PRIMARY CLOCK (0 in - 1 out) */
class pClock extends Logic { 
  
  pClock() { 
    name = 'CLOCK';
    duration = 10; 
    delay = 10;
    ticks = 0;
  }
  
  set delay(int d) => delay = d;
  set duration(int d) => duration = d;
  
  /* Calculate the clock state */
  void calc() {
      ticks++;
    
    if(out && ticks > duration) {
      out = false;
      ticks = 0;
      return;
    }
    
    if(out && ticks > delay) {
      out = true;
      ticks = 0;
      return;
    }  
  }
  
}
