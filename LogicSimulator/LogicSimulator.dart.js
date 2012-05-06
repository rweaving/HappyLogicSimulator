function $defProp(obj, prop, value) {
  Object.defineProperty(obj, prop,
      {value: value, enumerable: false, writable: true, configurable: true});
}
function $throw(e) {
  // If e is not a value, we can use V8's captureStackTrace utility method.
  // TODO(jmesserly): capture the stack trace on other JS engines.
  if (e && (typeof e == 'object') && Error.captureStackTrace) {
    // TODO(jmesserly): this will clobber the e.stack property
    Error.captureStackTrace(e, $throw);
  }
  throw e;
}
$defProp(Object.prototype, '$index', function(i) {
  $throw(new NoSuchMethodException(this, "operator []", [i]));
});
$defProp(Array.prototype, '$index', function(index) {
  var i = index | 0;
  if (i !== index) {
    throw new IllegalArgumentException('index is not int');
  } else if (i < 0 || i >= this.length) {
    throw new IndexOutOfRangeException(index);
  }
  return this[i];
});
$defProp(String.prototype, '$index', function(i) {
  return this[i];
});
$defProp(Object.prototype, '$setindex', function(i, value) {
  $throw(new NoSuchMethodException(this, "operator []=", [i, value]));
});
$defProp(Array.prototype, '$setindex', function(index, value) {
  var i = index | 0;
  if (i !== index) {
    throw new IllegalArgumentException('index is not int');
  } else if (i < 0 || i >= this.length) {
    throw new IndexOutOfRangeException(index);
  }
  return this[i] = value;
});
function $wrap_call$0(fn) { return fn; }
function $wrap_call$1(fn) { return fn; };
function $wrap_call$2(fn) { return fn; };
function $add$complex$(x, y) {
  if (typeof(x) == 'number') {
    $throw(new IllegalArgumentException(y));
  } else if (typeof(x) == 'string') {
    var str = (y == null) ? 'null' : y.toString();
    if (typeof(str) != 'string') {
      throw new Error("calling toString() on right hand operand of operator " +
      "+ did not return a String");
    }
    return x + str;
  } else if (typeof(x) == 'object') {
    return x.$add(y);
  } else {
    $throw(new NoSuchMethodException(x, "operator +", [y]));
  }
}

function $add$(x, y) {
  if (typeof(x) == 'number' && typeof(y) == 'number') return x + y;
  return $add$complex$(x, y);
}
function $eq$(x, y) {
  if (x == null) return y == null;
  return (typeof(x) != 'object') ? x === y : x.$eq(y);
}
// TODO(jimhug): Should this or should it not match equals?
$defProp(Object.prototype, '$eq', function(other) {
  return this === other;
});
function $lte$complex$(x, y) {
  if (typeof(x) == 'number') {
    $throw(new IllegalArgumentException(y));
  } else if (typeof(x) == 'object') {
    return x.$lte(y);
  } else {
    $throw(new NoSuchMethodException(x, "operator <=", [y]));
  }
}
function $lte$(x, y) {
  if (typeof(x) == 'number' && typeof(y) == 'number') return x <= y;
  return $lte$complex$(x, y);
}
function $ne$(x, y) {
  if (x == null) return y != null;
  return (typeof(x) != 'object') ? x !== y : !x.$eq(y);
}
function $truncdiv$(x, y) {
  if (typeof(x) == 'number') {
    if (typeof(y) == 'number') {
      if (y == 0) $throw(new IntegerDivisionByZeroException());
      var tmp = x / y;
      return (tmp < 0) ? Math.ceil(tmp) : Math.floor(tmp);
    } else {
      $throw(new IllegalArgumentException(y));
    }
  } else if (typeof(x) == 'object') {
    return x.$truncdiv(y);
  } else {
    $throw(new NoSuchMethodException(x, "operator ~/", [y]));
  }
}
$defProp(Object.prototype, '$typeNameOf', (function() {
  function constructorNameWithFallback(obj) {
    var constructor = obj.constructor;
    if (typeof(constructor) == 'function') {
      // The constructor isn't null or undefined at this point. Try
      // to grab hold of its name.
      var name = constructor.name;
      // If the name is a non-empty string, we use that as the type
      // name of this object. On Firefox, we often get 'Object' as
      // the constructor name even for more specialized objects so
      // we have to fall through to the toString() based implementation
      // below in that case.
      if (typeof(name) == 'string' && name && name != 'Object') return name;
    }
    var string = Object.prototype.toString.call(obj);
    return string.substring(8, string.length - 1);
  }

  function chrome$typeNameOf() {
    var name = this.constructor.name;
    if (name == 'Window') return 'DOMWindow';
    if (name == 'CanvasPixelArray') return 'Uint8ClampedArray';
    return name;
  }

  function firefox$typeNameOf() {
    var name = constructorNameWithFallback(this);
    if (name == 'Window') return 'DOMWindow';
    if (name == 'Document') return 'HTMLDocument';
    if (name == 'XMLDocument') return 'Document';
    if (name == 'WorkerMessageEvent') return 'MessageEvent';
    return name;
  }

  function ie$typeNameOf() {
    var name = constructorNameWithFallback(this);
    if (name == 'Window') return 'DOMWindow';
    // IE calls both HTML and XML documents 'Document', so we check for the
    // xmlVersion property, which is the empty string on HTML documents.
    if (name == 'Document' && this.xmlVersion) return 'Document';
    if (name == 'Document') return 'HTMLDocument';
    if (name == 'HTMLTableDataCellElement') return 'HTMLTableCellElement';
    if (name == 'HTMLTableHeaderCellElement') return 'HTMLTableCellElement';
    if (name == 'MSStyleCSSProperties') return 'CSSStyleDeclaration';
    return name;
  }

  // If we're not in the browser, we're almost certainly running on v8.
  if (typeof(navigator) != 'object') return chrome$typeNameOf;

  var userAgent = navigator.userAgent;
  if (/Chrome|DumpRenderTree/.test(userAgent)) return chrome$typeNameOf;
  if (/Firefox/.test(userAgent)) return firefox$typeNameOf;
  if (/MSIE/.test(userAgent)) return ie$typeNameOf;
  return function() { return constructorNameWithFallback(this); };
})());
$defProp(Object.prototype, "get$typeName", Object.prototype.$typeNameOf);
/** Implements extends for Dart classes on JavaScript prototypes. */
function $inherits(child, parent) {
  if (child.prototype.__proto__) {
    child.prototype.__proto__ = parent.prototype;
  } else {
    function tmp() {};
    tmp.prototype = parent.prototype;
    child.prototype = new tmp();
    child.prototype.constructor = child;
  }
}
function $dynamic(name) {
  var f = Object.prototype[name];
  if (f && f.methods) return f.methods;

  var methods = {};
  if (f) methods.Object = f;
  function $dynamicBind() {
    // Find the target method
    var obj = this;
    var tag = obj.$typeNameOf();
    var method = methods[tag];
    if (!method) {
      var table = $dynamicMetadata;
      for (var i = 0; i < table.length; i++) {
        var entry = table[i];
        if (entry.map.hasOwnProperty(tag)) {
          method = methods[entry.tag];
          if (method) break;
        }
      }
    }
    method = method || methods.Object;

    var proto = Object.getPrototypeOf(obj);

    if (method == null) {
      // Trampoline to throw NoSuchMethodException (TODO: call noSuchMethod).
      method = function(){
        // Exact type check to prevent this code shadowing the dispatcher from a
        // subclass.
        if (Object.getPrototypeOf(this) === proto) {
          // TODO(sra): 'name' is the jsname, should be the Dart name.
          $throw(new NoSuchMethodException(
              obj, name, Array.prototype.slice.call(arguments)));
        }
        return Object.prototype[name].apply(this, arguments);
      };
    }

    if (!proto.hasOwnProperty(name)) {
      $defProp(proto, name, method);
    }

    return method.apply(this, Array.prototype.slice.call(arguments));
  };
  $dynamicBind.methods = methods;
  $defProp(Object.prototype, name, $dynamicBind);
  return methods;
}
if (typeof $dynamicMetadata == 'undefined') $dynamicMetadata = [];
Function.prototype.bind = Function.prototype.bind ||
  function(thisObj) {
    var func = this;
    var funcLength = func.$length || func.length;
    var argsLength = arguments.length;
    if (argsLength > 1) {
      var boundArgs = Array.prototype.slice.call(arguments, 1);
      var bound = function() {
        // Prepend the bound arguments to the current arguments.
        var newArgs = Array.prototype.slice.call(arguments);
        Array.prototype.unshift.apply(newArgs, boundArgs);
        return func.apply(thisObj, newArgs);
      };
      bound.$length = Math.max(0, funcLength - (argsLength - 1));
      return bound;
    } else {
      var bound = function() {
        return func.apply(thisObj, arguments);
      };
      bound.$length = funcLength;
      return bound;
    }
  };
function $dynamicSetMetadata(inputTable) {
  // TODO: Deal with light isolates.
  var table = [];
  for (var i = 0; i < inputTable.length; i++) {
    var tag = inputTable[i][0];
    var tags = inputTable[i][1];
    var map = {};
    var tagNames = tags.split('|');
    for (var j = 0; j < tagNames.length; j++) {
      map[tagNames[j]] = true;
    }
    table.push({tag: tag, tags: tags, map: map});
  }
  $dynamicMetadata = table;
}
$defProp(Object.prototype, "noSuchMethod", function(name, args) {
  $throw(new NoSuchMethodException(this, name, args));
});
$defProp(Object.prototype, "$dom_addEventListener$3", function($0, $1, $2) {
  return this.noSuchMethod("$dom_addEventListener", [$0, $1, $2]);
});
$defProp(Object.prototype, "add$1", function($0) {
  return this.noSuchMethod("add", [$0]);
});
$defProp(Object.prototype, "filter$1", function($0) {
  return this.noSuchMethod("filter", [$0]);
});
$defProp(Object.prototype, "forEach$1", function($0) {
  return this.noSuchMethod("forEach", [$0]);
});
$defProp(Object.prototype, "is$Collection", function() {
  return false;
});
$defProp(Object.prototype, "is$List", function() {
  return false;
});
$defProp(Object.prototype, "is$Map", function() {
  return false;
});
$defProp(Object.prototype, "is$RegExp", function() {
  return false;
});
$defProp(Object.prototype, "is$html_Element", function() {
  return false;
});
$defProp(Object.prototype, "remove$0", function() {
  return this.noSuchMethod("remove", []);
});
function IndexOutOfRangeException(_index) {
  this._index = _index;
}
IndexOutOfRangeException.prototype.is$IndexOutOfRangeException = function(){return true};
IndexOutOfRangeException.prototype.toString = function() {
  return ("IndexOutOfRangeException: " + this._index);
}
function NoSuchMethodException(_receiver, _functionName, _arguments, _existingArgumentNames) {
  this._receiver = _receiver;
  this._functionName = _functionName;
  this._arguments = _arguments;
  this._existingArgumentNames = _existingArgumentNames;
}
NoSuchMethodException.prototype.is$NoSuchMethodException = function(){return true};
NoSuchMethodException.prototype.toString = function() {
  var sb = new StringBufferImpl("");
  for (var i = (0);
   i < this._arguments.get$length(); i++) {
    if (i > (0)) {
      sb.add(", ");
    }
    sb.add(this._arguments.$index(i));
  }
  if (null == this._existingArgumentNames) {
    return (("NoSuchMethodException : method not found: '" + this._functionName + "'\n") + ("Receiver: " + this._receiver + "\n") + ("Arguments: [" + sb + "]"));
  }
  else {
    var actualParameters = sb.toString();
    sb = new StringBufferImpl("");
    for (var i = (0);
     i < this._existingArgumentNames.get$length(); i++) {
      if (i > (0)) {
        sb.add(", ");
      }
      sb.add(this._existingArgumentNames.$index(i));
    }
    var formalParameters = sb.toString();
    return ("NoSuchMethodException: incorrect number of arguments passed to " + ("method named '" + this._functionName + "'\nReceiver: " + this._receiver + "\n") + ("Tried calling: " + this._functionName + "(" + actualParameters + ")\n") + ("Found: " + this._functionName + "(" + formalParameters + ")"));
  }
}
function ClosureArgumentMismatchException() {

}
ClosureArgumentMismatchException.prototype.toString = function() {
  return "Closure argument mismatch";
}
function ObjectNotClosureException() {

}
ObjectNotClosureException.prototype.toString = function() {
  return "Object is not closure";
}
function IllegalArgumentException(arg) {
  this._arg = arg;
}
IllegalArgumentException.prototype.is$IllegalArgumentException = function(){return true};
IllegalArgumentException.prototype.toString = function() {
  return ("Illegal argument(s): " + this._arg);
}
function StackOverflowException() {

}
StackOverflowException.prototype.toString = function() {
  return "Stack Overflow";
}
function BadNumberFormatException(_s) {
  this._s = _s;
}
BadNumberFormatException.prototype.toString = function() {
  return ("BadNumberFormatException: '" + this._s + "'");
}
function NullPointerException(functionName, arguments) {
  this.functionName = functionName;
  this.arguments = arguments;
}
NullPointerException.prototype.toString = function() {
  if (this.functionName == null) {
    return this.get$exceptionName();
  }
  else {
    return (("" + this.get$exceptionName() + " : method: '" + this.functionName + "'\n") + "Receiver: null\n" + ("Arguments: " + this.arguments));
  }
}
NullPointerException.prototype.get$exceptionName = function() {
  return "NullPointerException";
}
function NoMoreElementsException() {

}
NoMoreElementsException.prototype.toString = function() {
  return "NoMoreElementsException";
}
function EmptyQueueException() {

}
EmptyQueueException.prototype.toString = function() {
  return "EmptyQueueException";
}
function UnsupportedOperationException(_message) {
  this._message = _message;
}
UnsupportedOperationException.prototype.toString = function() {
  return ("UnsupportedOperationException: " + this._message);
}
function IntegerDivisionByZeroException() {

}
IntegerDivisionByZeroException.prototype.is$IntegerDivisionByZeroException = function(){return true};
IntegerDivisionByZeroException.prototype.toString = function() {
  return "IntegerDivisionByZeroException";
}
Function.prototype.to$call$0 = function() {
  this.call$0 = this._genStub(0);
  this.to$call$0 = function() { return this.call$0; };
  return this.call$0;
};
Function.prototype.call$0 = function() {
  return this.to$call$0()();
};
function to$call$0(f) { return f && f.to$call$0(); }
Function.prototype.to$call$1 = function() {
  this.call$1 = this._genStub(1);
  this.to$call$1 = function() { return this.call$1; };
  return this.call$1;
};
Function.prototype.call$1 = function($0) {
  return this.to$call$1()($0);
};
function to$call$1(f) { return f && f.to$call$1(); }
Function.prototype.to$call$2 = function() {
  this.call$2 = this._genStub(2);
  this.to$call$2 = function() { return this.call$2; };
  return this.call$2;
};
Function.prototype.call$2 = function($0, $1) {
  return this.to$call$2()($0, $1);
};
function to$call$2(f) { return f && f.to$call$2(); }
function Strings() {}
Strings.join = function(strings, separator) {
  return StringBase.join(strings, separator);
}
function print$(obj) {
  return _print(obj);
}
function _print(obj) {
  if (typeof console == 'object') {
    if (obj) obj = obj.toString();
    console.log(obj);
  } else if (typeof write === 'function') {
    write(obj);
    write('\n');
  }
}
function _toDartException(e) {
  function attachStack(dartEx) {
    // TODO(jmesserly): setting the stack property is not a long term solution.
    var stack = e.stack;
    // The stack contains the error message, and the stack is all that is
    // printed (the exception's toString() is never called).  Make the Dart
    // exception's toString() be the dominant message.
    if (typeof stack == 'string') {
      var message = dartEx.toString();
      if (/^(Type|Range)Error:/.test(stack)) {
        // Indent JS message (it can be helpful) so new message stands out.
        stack = '    (' + stack.substring(0, stack.indexOf('\n')) + ')\n' +
                stack.substring(stack.indexOf('\n') + 1);
      }
      stack = message + '\n' + stack;
    }
    dartEx.stack = stack;
    return dartEx;
  }

  if (e instanceof TypeError) {
    switch(e.type) {
      case 'property_not_function':
      case 'called_non_callable':
        if (e.arguments[0] == null) {
          return attachStack(new NullPointerException(null, []));
        } else {
          return attachStack(new ObjectNotClosureException());
        }
        break;
      case 'non_object_property_call':
      case 'non_object_property_load':
        return attachStack(new NullPointerException(null, []));
        break;
      case 'undefined_method':
        var mname = e.arguments[0];
        if (typeof(mname) == 'string' && (mname.indexOf('call$') == 0
            || mname == 'call' || mname == 'apply')) {
          return attachStack(new ObjectNotClosureException());
        } else {
          // TODO(jmesserly): fix noSuchMethod on operators so we don't hit this
          return attachStack(new NoSuchMethodException('', e.arguments[0], []));
        }
        break;
    }
  } else if (e instanceof RangeError) {
    if (e.message.indexOf('call stack') >= 0) {
      return attachStack(new StackOverflowException());
    }
  }
  return e;
}
var ListFactory = Array;
$defProp(ListFactory.prototype, "is$List", function(){return true});
$defProp(ListFactory.prototype, "is$Collection", function(){return true});
ListFactory.ListFactory$from$factory = function(other) {
  var list = [];
  for (var $$i = other.iterator(); $$i.hasNext(); ) {
    var e = $$i.next();
    list.add$1(e);
  }
  return list;
}
$defProp(ListFactory.prototype, "get$length", function() { return this.length; });
$defProp(ListFactory.prototype, "set$length", function(value) { return this.length = value; });
$defProp(ListFactory.prototype, "add", function(value) {
  this.push(value);
});
$defProp(ListFactory.prototype, "clear$_", function() {
  this.set$length((0));
});
$defProp(ListFactory.prototype, "removeLast", function() {
  return this.pop();
});
$defProp(ListFactory.prototype, "last", function() {
  return this.$index(this.get$length() - (1));
});
$defProp(ListFactory.prototype, "iterator", function() {
  return new ListIterator(this);
});
$defProp(ListFactory.prototype, "toString", function() {
  return Collections.collectionToString(this);
});
$defProp(ListFactory.prototype, "add$1", ListFactory.prototype.add);
$defProp(ListFactory.prototype, "filter$1", function($0) {
  return this.filter(to$call$1($0));
});
$defProp(ListFactory.prototype, "forEach$1", function($0) {
  return this.forEach(to$call$1($0));
});
function ListIterator(array) {
  this._array = array;
  this._pos = (0);
}
ListIterator.prototype.hasNext = function() {
  return this._array.get$length() > this._pos;
}
ListIterator.prototype.next = function() {
  if (!this.hasNext()) {
    $throw(const$0001);
  }
  return this._array.$index(this._pos++);
}
function JSSyntaxRegExp(pattern, multiLine, ignoreCase) {
  JSSyntaxRegExp._create$ctor.call(this, pattern, $add$(($eq$(multiLine, true) ? "m" : ""), ($eq$(ignoreCase, true) ? "i" : "")));
}
JSSyntaxRegExp._create$ctor = function(pattern, flags) {
  this.re = new RegExp(pattern, flags);
      this.pattern = pattern;
      this.multiLine = this.re.multiline;
      this.ignoreCase = this.re.ignoreCase;
}
JSSyntaxRegExp._create$ctor.prototype = JSSyntaxRegExp.prototype;
JSSyntaxRegExp.prototype.is$RegExp = function(){return true};
JSSyntaxRegExp.prototype.hasMatch = function(str) {
  return this.re.test(str);
}
var NumImplementation = Number;
NumImplementation.prototype.hashCode = function() {
  'use strict'; return this & 0x1FFFFFFF;
}
NumImplementation.prototype.toInt = function() {
  
    'use strict';
    if (isNaN(this)) $throw(new BadNumberFormatException("NaN"));
    if ((this == Infinity) || (this == -Infinity)) {
      $throw(new BadNumberFormatException("Infinity"));
    }
    var truncated = (this < 0) ? Math.ceil(this) : Math.floor(this);
    if (truncated == -0.0) return 0;
    return truncated;
}
NumImplementation.prototype.toDouble = function() {
  'use strict'; return this + 0;
}
function Collections() {}
Collections.collectionToString = function(c) {
  var result = new StringBufferImpl("");
  Collections._emitCollection(c, result, new Array());
  return result.toString();
}
Collections._emitCollection = function(c, result, visiting) {
  visiting.add(c);
  var isList = !!(c && c.is$List());
  result.add(isList ? "[" : "{");
  var first = true;
  for (var $$i = c.iterator(); $$i.hasNext(); ) {
    var e = $$i.next();
    if (!first) {
      result.add(", ");
    }
    first = false;
    Collections._emitObject(e, result, visiting);
  }
  result.add(isList ? "]" : "}");
  visiting.removeLast();
}
Collections._emitObject = function(o, result, visiting) {
  if (!!(o && o.is$Collection())) {
    if (Collections._containsRef(visiting, o)) {
      result.add(!!(o && o.is$List()) ? "[...]" : "{...}");
    }
    else {
      Collections._emitCollection(o, result, visiting);
    }
  }
  else if (!!(o && o.is$Map())) {
    if (Collections._containsRef(visiting, o)) {
      result.add("{...}");
    }
    else {
      Maps._emitMap(o, result, visiting);
    }
  }
  else {
    result.add($eq$(o) ? "null" : o);
  }
}
Collections._containsRef = function(c, ref) {
  for (var $$i = c.iterator(); $$i.hasNext(); ) {
    var e = $$i.next();
    if ((null == e ? null == (ref) : e === ref)) return true;
  }
  return false;
}
function HashMapImplementation() {
  this._numberOfEntries = (0);
  this._numberOfDeleted = (0);
  this._loadLimit = HashMapImplementation._computeLoadLimit((8));
  this._keys = new Array((8));
  this._values = new Array((8));
}
HashMapImplementation.prototype.is$Map = function(){return true};
HashMapImplementation._computeLoadLimit = function(capacity) {
  return $truncdiv$((capacity * (3)), (4));
}
HashMapImplementation._firstProbe = function(hashCode, length) {
  return hashCode & (length - (1));
}
HashMapImplementation._nextProbe = function(currentProbe, numberOfProbes, length) {
  return (currentProbe + numberOfProbes) & (length - (1));
}
HashMapImplementation.prototype._probeForAdding = function(key) {
  var hash = HashMapImplementation._firstProbe(key.hashCode(), this._keys.get$length());
  var numberOfProbes = (1);
  var initialHash = hash;
  var insertionIndex = (-1);
  while (true) {
    var existingKey = this._keys.$index(hash);
    if (null == existingKey) {
      if (insertionIndex < (0)) return hash;
      return insertionIndex;
    }
    else if ($eq$(existingKey, key)) {
      return hash;
    }
    else if ((insertionIndex < (0)) && ((null == const$0000 ? null == (existingKey) : const$0000 === existingKey))) {
      insertionIndex = hash;
    }
    hash = HashMapImplementation._nextProbe(hash, numberOfProbes++, this._keys.get$length());
  }
}
HashMapImplementation.prototype._probeForLookup = function(key) {
  var hash = HashMapImplementation._firstProbe(key.hashCode(), this._keys.get$length());
  var numberOfProbes = (1);
  var initialHash = hash;
  while (true) {
    var existingKey = this._keys.$index(hash);
    if (null == existingKey) return (-1);
    if ($eq$(existingKey, key)) return hash;
    hash = HashMapImplementation._nextProbe(hash, numberOfProbes++, this._keys.get$length());
  }
}
HashMapImplementation.prototype._ensureCapacity = function() {
  var newNumberOfEntries = this._numberOfEntries + (1);
  if (newNumberOfEntries >= this._loadLimit) {
    this._grow(this._keys.get$length() * (2));
    return;
  }
  var capacity = this._keys.get$length();
  var numberOfFreeOrDeleted = capacity - newNumberOfEntries;
  var numberOfFree = numberOfFreeOrDeleted - this._numberOfDeleted;
  if (this._numberOfDeleted > numberOfFree) {
    this._grow(this._keys.get$length());
  }
}
HashMapImplementation._isPowerOfTwo = function(x) {
  return ((x & (x - (1))) == (0));
}
HashMapImplementation.prototype._grow = function(newCapacity) {
  var capacity = this._keys.get$length();
  this._loadLimit = HashMapImplementation._computeLoadLimit(newCapacity);
  var oldKeys = this._keys;
  var oldValues = this._values;
  this._keys = new Array(newCapacity);
  this._values = new Array(newCapacity);
  for (var i = (0);
   i < capacity; i++) {
    var key = oldKeys.$index(i);
    if (null == key || (null == key ? null == (const$0000) : key === const$0000)) {
      continue;
    }
    var value = oldValues.$index(i);
    var newIndex = this._probeForAdding(key);
    this._keys.$setindex(newIndex, key);
    this._values.$setindex(newIndex, value);
  }
  this._numberOfDeleted = (0);
}
HashMapImplementation.prototype.$setindex = function(key, value) {
  var $0;
  this._ensureCapacity();
  var index = this._probeForAdding(key);
  if ((null == this._keys.$index(index)) || ((($0 = this._keys.$index(index)) == null ? null == (const$0000) : $0 === const$0000))) {
    this._numberOfEntries++;
  }
  this._keys.$setindex(index, key);
  this._values.$setindex(index, value);
}
HashMapImplementation.prototype.$index = function(key) {
  var index = this._probeForLookup(key);
  if (index < (0)) return null;
  return this._values.$index(index);
}
HashMapImplementation.prototype.get$length = function() {
  return this._numberOfEntries;
}
HashMapImplementation.prototype.forEach = function(f) {
  var length = this._keys.get$length();
  for (var i = (0);
   i < length; i++) {
    var key = this._keys.$index(i);
    if ((null != key) && ((null == key ? null != (const$0000) : key !== const$0000))) {
      f(key, this._values.$index(i));
    }
  }
}
HashMapImplementation.prototype.toString = function() {
  return Maps.mapToString(this);
}
HashMapImplementation.prototype.forEach$1 = function($0) {
  return this.forEach(to$call$2($0));
};
$inherits(HashMapImplementation_dart_core_String$dart_core_String, HashMapImplementation);
function HashMapImplementation_dart_core_String$dart_core_String() {
  this._numberOfEntries = (0);
  this._numberOfDeleted = (0);
  this._loadLimit = HashMapImplementation._computeLoadLimit((8));
  this._keys = new Array((8));
  this._values = new Array((8));
}
HashMapImplementation_dart_core_String$dart_core_String.prototype.forEach$1 = function($0) {
  return this.forEach(to$call$2($0));
};
function HashSetImplementation() {
  this._backingMap = new HashMapImplementation();
}
HashSetImplementation.prototype.is$Collection = function(){return true};
HashSetImplementation.prototype.add = function(value) {
  this._backingMap.$setindex(value, value);
}
HashSetImplementation.prototype.forEach = function(f) {
  this._backingMap.forEach(function _(key, value) {
    f(key);
  }
  );
}
HashSetImplementation.prototype.filter = function(f) {
  var result = new HashSetImplementation();
  this._backingMap.forEach(function _(key, value) {
    if (f(key)) result.add(key);
  }
  );
  return result;
}
HashSetImplementation.prototype.get$length = function() {
  return this._backingMap.get$length();
}
HashSetImplementation.prototype.iterator = function() {
  return new HashSetIterator(this);
}
HashSetImplementation.prototype.toString = function() {
  return Collections.collectionToString(this);
}
HashSetImplementation.prototype.add$1 = HashSetImplementation.prototype.add;
HashSetImplementation.prototype.filter$1 = function($0) {
  return this.filter(to$call$1($0));
};
HashSetImplementation.prototype.forEach$1 = function($0) {
  return this.forEach(to$call$1($0));
};
$inherits(HashSetImplementation_dart_core_String, HashSetImplementation);
function HashSetImplementation_dart_core_String() {
  this._backingMap = new HashMapImplementation_dart_core_String$dart_core_String();
}
HashSetImplementation_dart_core_String.prototype.add$1 = HashSetImplementation_dart_core_String.prototype.add;
function HashSetIterator(set_) {
  this._nextValidIndex = (-1);
  this._entries = set_._backingMap._keys;
  this._advance();
}
HashSetIterator.prototype.hasNext = function() {
  var $0;
  if (this._nextValidIndex >= this._entries.get$length()) return false;
  if ((($0 = this._entries.$index(this._nextValidIndex)) == null ? null == (const$0000) : $0 === const$0000)) {
    this._advance();
  }
  return this._nextValidIndex < this._entries.get$length();
}
HashSetIterator.prototype.next = function() {
  if (!this.hasNext()) {
    $throw(const$0001);
  }
  var res = this._entries.$index(this._nextValidIndex);
  this._advance();
  return res;
}
HashSetIterator.prototype._advance = function() {
  var length = this._entries.get$length();
  var entry;
  var deletedKey = const$0000;
  do {
    if (++this._nextValidIndex >= length) break;
    entry = this._entries.$index(this._nextValidIndex);
  }
  while ((null == entry) || ((null == entry ? null == (deletedKey) : entry === deletedKey)))
}
function _DeletedKeySentinel() {

}
function Maps() {}
Maps.mapToString = function(m) {
  var result = new StringBufferImpl("");
  Maps._emitMap(m, result, new Array());
  return result.toString();
}
Maps._emitMap = function(m, result, visiting) {
  visiting.add(m);
  result.add("{");
  var first = true;
  m.forEach$1((function (k, v) {
    if (!first) {
      result.add(", ");
    }
    first = false;
    Collections._emitObject(k, result, visiting);
    result.add(": ");
    Collections._emitObject(v, result, visiting);
  })
  );
  result.add("}");
  visiting.removeLast();
}
function DoubleLinkedQueueEntry(e) {
  this._element = e;
}
DoubleLinkedQueueEntry.prototype._link = function(p, n) {
  this._next = n;
  this._previous = p;
  p._next = this;
  n._previous = this;
}
DoubleLinkedQueueEntry.prototype.prepend = function(e) {
  new DoubleLinkedQueueEntry(e)._link(this._previous, this);
}
DoubleLinkedQueueEntry.prototype.remove = function() {
  this._previous._next = this._next;
  this._next._previous = this._previous;
  this._next = null;
  this._previous = null;
  return this._element;
}
DoubleLinkedQueueEntry.prototype.get$element = function() {
  return this._element;
}
DoubleLinkedQueueEntry.prototype.remove$0 = DoubleLinkedQueueEntry.prototype.remove;
$inherits(_DoubleLinkedQueueEntrySentinel, DoubleLinkedQueueEntry);
function _DoubleLinkedQueueEntrySentinel() {
  DoubleLinkedQueueEntry.call(this, null);
  this._link(this, this);
}
_DoubleLinkedQueueEntrySentinel.prototype.remove = function() {
  $throw(const$0002);
}
_DoubleLinkedQueueEntrySentinel.prototype.get$element = function() {
  $throw(const$0002);
}
_DoubleLinkedQueueEntrySentinel.prototype.remove$0 = _DoubleLinkedQueueEntrySentinel.prototype.remove;
function DoubleLinkedQueue() {
  this._sentinel = new _DoubleLinkedQueueEntrySentinel();
}
DoubleLinkedQueue.prototype.is$Collection = function(){return true};
DoubleLinkedQueue.prototype.addLast = function(value) {
  this._sentinel.prepend(value);
}
DoubleLinkedQueue.prototype.add = function(value) {
  this.addLast(value);
}
DoubleLinkedQueue.prototype.get$length = function() {
  var counter = (0);
  this.forEach(function _(element) {
    counter++;
  }
  );
  return counter;
}
DoubleLinkedQueue.prototype.forEach = function(f) {
  var entry = this._sentinel._next;
  while ((null == entry ? null != (this._sentinel) : entry !== this._sentinel)) {
    var nextEntry = entry._next;
    f(entry._element);
    entry = nextEntry;
  }
}
DoubleLinkedQueue.prototype.filter = function(f) {
  var other = new DoubleLinkedQueue();
  var entry = this._sentinel._next;
  while ((null == entry ? null != (this._sentinel) : entry !== this._sentinel)) {
    var nextEntry = entry._next;
    if (f(entry._element)) other.addLast(entry._element);
    entry = nextEntry;
  }
  return other;
}
DoubleLinkedQueue.prototype.iterator = function() {
  return new _DoubleLinkedQueueIterator(this._sentinel);
}
DoubleLinkedQueue.prototype.toString = function() {
  return Collections.collectionToString(this);
}
DoubleLinkedQueue.prototype.add$1 = DoubleLinkedQueue.prototype.add;
DoubleLinkedQueue.prototype.filter$1 = function($0) {
  return this.filter(to$call$1($0));
};
DoubleLinkedQueue.prototype.forEach$1 = function($0) {
  return this.forEach(to$call$1($0));
};
function _DoubleLinkedQueueIterator(_sentinel) {
  this._sentinel = _sentinel;
  this._currentEntry = this._sentinel;
}
_DoubleLinkedQueueIterator.prototype.hasNext = function() {
  var $0;
  return (($0 = this._currentEntry._next) == null ? null != (this._sentinel) : $0 !== this._sentinel);
}
_DoubleLinkedQueueIterator.prototype.next = function() {
  if (!this.hasNext()) {
    $throw(const$0001);
  }
  this._currentEntry = this._currentEntry._next;
  return this._currentEntry.get$element();
}
function StringBufferImpl(content) {
  this.clear$_();
  this.add(content);
}
StringBufferImpl.prototype.get$length = function() {
  return this._length;
}
StringBufferImpl.prototype.add = function(obj) {
  var str = obj.toString();
  if (null == str || str.isEmpty()) return this;
  this._buffer.add(str);
  this._length = this._length + str.length;
  return this;
}
StringBufferImpl.prototype.clear$_ = function() {
  this._buffer = new Array();
  this._length = (0);
  return this;
}
StringBufferImpl.prototype.toString = function() {
  if (this._buffer.get$length() == (0)) return "";
  if (this._buffer.get$length() == (1)) return this._buffer.$index((0));
  var result = StringBase.concatAll(this._buffer);
  this._buffer.clear$_();
  this._buffer.add(result);
  return result;
}
StringBufferImpl.prototype.add$1 = StringBufferImpl.prototype.add;
function StringBase() {}
StringBase.join = function(strings, separator) {
  if (strings.get$length() == (0)) return "";
  var s = strings.$index((0));
  for (var i = (1);
   i < strings.get$length(); i++) {
    s = $add$($add$(s, separator), strings.$index(i));
  }
  return s;
}
StringBase.concatAll = function(strings) {
  return StringBase.join(strings, "");
}
var StringImplementation = String;
StringImplementation.prototype.get$length = function() { return this.length; };
StringImplementation.prototype.startsWith = function(other) {
    'use strict';
    if (other.length > this.length) return false;
    return other == this.substring(0, other.length);
}
StringImplementation.prototype.isEmpty = function() {
  return this.length == (0);
}
StringImplementation.prototype.split$_ = function(pattern) {
  if ((typeof(pattern) == 'string')) return this._split(pattern);
  if (!!(pattern && pattern.is$RegExp())) return this._splitRegExp(pattern);
  $throw("String.split(Pattern) unimplemented.");
}
StringImplementation.prototype._split = function(pattern) {
  'use strict'; return this.split(pattern);
}
StringImplementation.prototype._splitRegExp = function(pattern) {
  'use strict'; return this.split(pattern.re);
}
StringImplementation.prototype.hashCode = function() {
      'use strict';
      var hash = 0;
      for (var i = 0; i < this.length; i++) {
        hash = 0x1fffffff & (hash + this.charCodeAt(i));
        hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
        hash ^= hash >> 6;
      }

      hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
      hash ^= hash >> 11;
      return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
}
$inherits(_ArgumentMismatchException, ClosureArgumentMismatchException);
function _ArgumentMismatchException(_message) {
  this._dart_coreimpl_message = _message;
  ClosureArgumentMismatchException.call(this);
}
_ArgumentMismatchException.prototype.toString = function() {
  return ("Closure argument mismatch: " + this._dart_coreimpl_message);
}
var _FunctionImplementation = Function;
_FunctionImplementation.prototype._genStub = function(argsLength, names) {
      // Fast path #1: if no named arguments and arg count matches.
      var thisLength = this.$length || this.length;
      if (thisLength == argsLength && !names) {
        return this;
      }

      var paramsNamed = this.$optional ? (this.$optional.length / 2) : 0;
      var paramsBare = thisLength - paramsNamed;
      var argsNamed = names ? names.length : 0;
      var argsBare = argsLength - argsNamed;

      // Check we got the right number of arguments
      if (argsBare < paramsBare || argsLength > thisLength ||
          argsNamed > paramsNamed) {
        return function() {
          $throw(new _ArgumentMismatchException(
            'Wrong number of arguments to function. Expected ' + paramsBare +
            ' positional arguments and at most ' + paramsNamed +
            ' named arguments, but got ' + argsBare +
            ' positional arguments and ' + argsNamed + ' named arguments.'));
        };
      }

      // First, fill in all of the default values
      var p = new Array(paramsBare);
      if (paramsNamed) {
        p = p.concat(this.$optional.slice(paramsNamed));
      }
      // Fill in positional args
      var a = new Array(argsLength);
      for (var i = 0; i < argsBare; i++) {
        p[i] = a[i] = '$' + i;
      }
      // Then overwrite with supplied values for optional args
      var lastParameterIndex;
      var namesInOrder = true;
      for (var i = 0; i < argsNamed; i++) {
        var name = names[i];
        a[i + argsBare] = name;
        var j = this.$optional.indexOf(name);
        if (j < 0 || j >= paramsNamed) {
          return function() {
            $throw(new _ArgumentMismatchException(
              'Named argument "' + name + '" was not expected by function.' +
              ' Did you forget to mark the function parameter [optional]?'));
          };
        } else if (lastParameterIndex && lastParameterIndex > j) {
          namesInOrder = false;
        }
        p[j + paramsBare] = name;
        lastParameterIndex = j;
      }

      if (thisLength == argsLength && namesInOrder) {
        // Fast path #2: named arguments, but they're in order and all supplied.
        return this;
      }

      // Note: using Function instead of 'eval' to get a clean scope.
      // TODO(jmesserly): evaluate the performance of these stubs.
      var f = 'function(' + a.join(',') + '){return $f(' + p.join(',') + ');}';
      return new Function('$f', 'return ' + f + '').call(null, this);
    
}
$dynamic("$dom_addEventListener$3").EventTarget = function($0, $1, $2) {
  if (Object.getPrototypeOf(this).hasOwnProperty("$dom_addEventListener$3")) {
    return this.addEventListener($0, $wrap_call$1(to$call$1($1)), $2);
  }
  return Object.prototype.$dom_addEventListener$3.call(this, $0, $1, $2);
};
$dynamic("remove").Node = function() {
  if ($ne$(this.get$parent())) {
    var parent = this.get$parent();
    parent.removeChild(this);
  }
  return this;
}
$dynamic("replaceWith").Node = function(otherNode) {
  try {
    var parent = this.get$parent();
    parent.replaceChild(otherNode, this);
  } catch (e) {
    e = _toDartException(e);
  }
  ;
  return this;
}
$dynamic("get$$$dom_attributes").Node = function() {
  return this.attributes;
}
$dynamic("get$$$dom_childNodes").Node = function() {
  return this.childNodes;
}
$dynamic("get$parent").Node = function() {
  return this.parentNode;
}
$dynamic("set$text").Node = function(value) {
  this.textContent = value;
}
$dynamic("remove$0").Node = function() {
  return this.remove();
};
$dynamic("is$html_Element").Element = function(){return true};
$dynamic("get$attributes").Element = function() {
  return new _ElementAttributeMap(this);
}
$dynamic("get$on").Element = function() {
  return new _ElementEventsImpl(this);
}
$dynamic("get$$$dom_className").Element = function() {
  return this.className;
}
$dynamic("set$$$dom_className").Element = function(value) {
  this.className = value;
}
$dynamic("get$$$dom_lastElementChild").Element = function() {
  return this.lastElementChild;
}
$dynamic("get$style").Element = function() { return this.style; };
$dynamic("$dom_addEventListener$3").AbstractWorker = function($0, $1, $2) {
  return this.addEventListener($0, $wrap_call$1(to$call$1($1)), $2);
};
function _EventsImpl(_ptr) {
  this._ptr = _ptr;
}
_EventsImpl.prototype.$index = function(type) {
  return this._get(type.toLowerCase());
}
_EventsImpl.prototype._get = function(type) {
  return new _EventListenerListImpl(this._ptr, type);
}
$inherits(_AbstractWorkerEventsImpl, _EventsImpl);
function _AbstractWorkerEventsImpl() {}
$dynamic("get$name").HTMLAnchorElement = function() { return this.name; };
$dynamic("get$name").WebKitAnimation = function() { return this.name; };
$dynamic("get$length").WebKitAnimationList = function() { return this.length; };
$dynamic("get$height").HTMLAppletElement = function() { return this.height; };
$dynamic("get$name").HTMLAppletElement = function() { return this.name; };
$dynamic("get$width").HTMLAppletElement = function() { return this.width; };
$dynamic("get$name").Attr = function() { return this.name; };
$dynamic("get$value").Attr = function() { return this.value; };
$dynamic("set$value").Attr = function(value) { return this.value = value; };
$dynamic("get$length").AudioBuffer = function() { return this.length; };
$inherits(_AudioContextEventsImpl, _EventsImpl);
function _AudioContextEventsImpl() {}
$dynamic("get$on").HTMLMediaElement = function() {
  return new _MediaElementEventsImpl(this);
}
$dynamic("get$name").AudioParam = function() { return this.name; };
$dynamic("get$value").AudioParam = function() { return this.value; };
$dynamic("set$value").AudioParam = function(value) { return this.value = value; };
$dynamic("$dom_addEventListener$3").BatteryManager = function($0, $1, $2) {
  return this.addEventListener($0, $wrap_call$1(to$call$1($1)), $2);
};
$inherits(_BatteryManagerEventsImpl, _EventsImpl);
function _BatteryManagerEventsImpl() {}
$dynamic("get$on").HTMLBodyElement = function() {
  return new _BodyElementEventsImpl(this);
}
$inherits(_ElementEventsImpl, _EventsImpl);
function _ElementEventsImpl(_ptr) {
  _EventsImpl.call(this, _ptr);
}
_ElementEventsImpl.prototype.get$doubleClick = function() {
  return this._get("dblclick");
}
_ElementEventsImpl.prototype.get$mouseDown = function() {
  return this._get("mousedown");
}
_ElementEventsImpl.prototype.get$mouseMove = function() {
  return this._get("mousemove");
}
_ElementEventsImpl.prototype.get$touchCancel = function() {
  return this._get("touchcancel");
}
_ElementEventsImpl.prototype.get$touchEnd = function() {
  return this._get("touchend");
}
_ElementEventsImpl.prototype.get$touchEnter = function() {
  return this._get("touchenter");
}
_ElementEventsImpl.prototype.get$touchLeave = function() {
  return this._get("touchleave");
}
_ElementEventsImpl.prototype.get$touchMove = function() {
  return this._get("touchmove");
}
_ElementEventsImpl.prototype.get$touchStart = function() {
  return this._get("touchstart");
}
$inherits(_BodyElementEventsImpl, _ElementEventsImpl);
function _BodyElementEventsImpl(_ptr) {
  _ElementEventsImpl.call(this, _ptr);
}
$dynamic("get$name").HTMLButtonElement = function() { return this.name; };
$dynamic("get$value").HTMLButtonElement = function() { return this.value; };
$dynamic("set$value").HTMLButtonElement = function(value) { return this.value = value; };
$dynamic("get$length").CharacterData = function() { return this.length; };
$dynamic("get$name").WebKitCSSKeyframesRule = function() { return this.name; };
$dynamic("get$length").CSSRuleList = function() { return this.length; };
$dynamic("get$length").CSSStyleDeclaration = function() { return this.length; };
$dynamic("get$height").CSSStyleDeclaration = function() {
  return this.getPropertyValue("height");
}
$dynamic("set$left").CSSStyleDeclaration = function(value) {
  this.setProperty("left", value, "");
}
$dynamic("set$top").CSSStyleDeclaration = function(value) {
  this.setProperty("top", value, "");
}
$dynamic("get$width").CSSStyleDeclaration = function() {
  return this.getPropertyValue("width");
}
$dynamic("get$length").CSSValueList = function() { return this.length; };
$dynamic("get$height").HTMLCanvasElement = function() { return this.height; };
$dynamic("get$width").HTMLCanvasElement = function() { return this.width; };
$dynamic("get$height").ClientRect = function() { return this.height; };
$dynamic("get$width").ClientRect = function() { return this.width; };
$dynamic("get$length").ClientRectList = function() { return this.length; };
var _ConsoleImpl = (typeof console == 'undefined' ? {} : console);
$dynamic("$dom_addEventListener$3").DOMApplicationCache = function($0, $1, $2) {
  return this.addEventListener($0, $wrap_call$1(to$call$1($1)), $2);
};
$inherits(_DOMApplicationCacheEventsImpl, _EventsImpl);
function _DOMApplicationCacheEventsImpl() {}
$dynamic("get$name").DOMException = function() { return this.name; };
$dynamic("get$name").DOMFileSystem = function() { return this.name; };
$dynamic("get$name").DOMFileSystemSync = function() { return this.name; };
$dynamic("get$length").DOMMimeTypeArray = function() { return this.length; };
$dynamic("get$length").DOMPlugin = function() { return this.length; };
$dynamic("get$name").DOMPlugin = function() { return this.name; };
$dynamic("get$length").DOMPluginArray = function() { return this.length; };
$dynamic("get$length").DOMTokenList = function() { return this.length; };
$dynamic("add$1").DOMTokenList = function($0) {
  return this.add($0);
};
$dynamic("get$value").DOMSettableTokenList = function() { return this.value; };
$dynamic("set$value").DOMSettableTokenList = function(value) { return this.value = value; };
$dynamic("is$List").DOMStringList = function(){return true};
$dynamic("is$Collection").DOMStringList = function(){return true};
$dynamic("get$length").DOMStringList = function() { return this.length; };
$dynamic("$index").DOMStringList = function(index) {
  return this[index];
}
$dynamic("$setindex").DOMStringList = function(index, value) {
  $throw(new UnsupportedOperationException("Cannot assign element of immutable List."));
}
$dynamic("iterator").DOMStringList = function() {
  return new _FixedSizeListIterator_dart_core_String(this);
}
$dynamic("add").DOMStringList = function(value) {
  $throw(new UnsupportedOperationException("Cannot add to immutable List."));
}
$dynamic("forEach").DOMStringList = function(f) {
  return _Collections.forEach(this, f);
}
$dynamic("filter").DOMStringList = function(f) {
  return _Collections.filter(this, [], f);
}
$dynamic("last").DOMStringList = function() {
  return this.$index(this.length - (1));
}
$dynamic("removeLast").DOMStringList = function() {
  $throw(new UnsupportedOperationException("Cannot removeLast on immutable List."));
}
$dynamic("add$1").DOMStringList = function($0) {
  return this.add($0);
};
$dynamic("filter$1").DOMStringList = function($0) {
  return this.filter($wrap_call$1(to$call$1($0)));
};
$dynamic("forEach$1").DOMStringList = function($0) {
  return this.forEach($wrap_call$1(to$call$1($0)));
};
$dynamic("get$length").DataTransferItemList = function() { return this.length; };
$dynamic("add$1").DataTransferItemList = function($0) {
  return this.add($0);
};
$dynamic("$dom_addEventListener$3").WorkerContext = function($0, $1, $2) {
  return this.addEventListener($0, $wrap_call$1(to$call$1($1)), $2);
};
$inherits(_WorkerContextEventsImpl, _EventsImpl);
function _WorkerContextEventsImpl() {}
$inherits(_DedicatedWorkerContextEventsImpl, _WorkerContextEventsImpl);
function _DedicatedWorkerContextEventsImpl() {}
$dynamic("$dom_addEventListener$3").DeprecatedPeerConnection = function($0, $1, $2) {
  return this.addEventListener($0, $wrap_call$1(to$call$1($1)), $2);
};
$inherits(_DeprecatedPeerConnectionEventsImpl, _EventsImpl);
function _DeprecatedPeerConnectionEventsImpl() {}
$dynamic("get$name").Entry = function() { return this.name; };
$dynamic("get$name").EntrySync = function() { return this.name; };
$dynamic("remove$0").EntrySync = function() {
  return this.remove();
};
$dynamic("is$html_Element").HTMLDocument = function(){return true};
$dynamic("get$on").HTMLDocument = function() {
  return new _DocumentEventsImpl(this);
}
$dynamic("query").HTMLDocument = function(selectors) {
  if (const$0004.hasMatch(selectors)) {
    return this.getElementById(selectors.substring((1)));
  }
  return this.$dom_querySelector(selectors);
}
$dynamic("$dom_querySelector").HTMLDocument = function(selectors) {
  return this.querySelector(selectors);
}
$inherits(_DocumentEventsImpl, _ElementEventsImpl);
function _DocumentEventsImpl(_ptr) {
  _ElementEventsImpl.call(this, _ptr);
}
_DocumentEventsImpl.prototype.get$doubleClick = function() {
  return this._get("dblclick");
}
_DocumentEventsImpl.prototype.get$mouseDown = function() {
  return this._get("mousedown");
}
_DocumentEventsImpl.prototype.get$mouseMove = function() {
  return this._get("mousemove");
}
_DocumentEventsImpl.prototype.get$touchCancel = function() {
  return this._get("touchcancel");
}
_DocumentEventsImpl.prototype.get$touchEnd = function() {
  return this._get("touchend");
}
_DocumentEventsImpl.prototype.get$touchMove = function() {
  return this._get("touchmove");
}
_DocumentEventsImpl.prototype.get$touchStart = function() {
  return this._get("touchstart");
}
function FilteredElementList() {}
FilteredElementList.prototype.is$List = function(){return true};
FilteredElementList.prototype.is$Collection = function(){return true};
FilteredElementList.prototype.get$_filtered = function() {
  return ListFactory.ListFactory$from$factory(this._childNodes.filter$1((function (n) {
    return !!(n && n.is$html_Element());
  })
  ));
}
FilteredElementList.prototype.forEach = function(f) {
  this.get$_filtered().forEach$1(f);
}
FilteredElementList.prototype.$setindex = function(index, value) {
  this.$index(index).replaceWith(value);
}
FilteredElementList.prototype.add = function(value) {
  this._childNodes.add(value);
}
FilteredElementList.prototype.clear$_ = function() {
  this._childNodes.clear$_();
}
FilteredElementList.prototype.removeLast = function() {
  var result = this.last();
  if ($ne$(result)) {
    result.remove$0();
  }
  return result;
}
FilteredElementList.prototype.filter = function(f) {
  return this.get$_filtered().filter$1(f);
}
FilteredElementList.prototype.get$length = function() {
  return this.get$_filtered().get$length();
}
FilteredElementList.prototype.$index = function(index) {
  return this.get$_filtered().$index(index);
}
FilteredElementList.prototype.iterator = function() {
  return this.get$_filtered().iterator();
}
FilteredElementList.prototype.last = function() {
  return this.get$_filtered().last();
}
FilteredElementList.prototype.add$1 = FilteredElementList.prototype.add;
FilteredElementList.prototype.filter$1 = function($0) {
  return this.filter($wrap_call$1(to$call$1($0)));
};
FilteredElementList.prototype.forEach$1 = function($0) {
  return this.forEach($wrap_call$1(to$call$1($0)));
};
function EmptyElementRect() {}
$dynamic("is$html_Element").DocumentFragment = function(){return true};
$dynamic("get$parent").DocumentFragment = function() {
  return null;
}
$dynamic("get$style").DocumentFragment = function() {
  return _ElementFactoryProvider.Element$tag$factory("div").get$style();
}
$dynamic("get$on").DocumentFragment = function() {
  return new _ElementEventsImpl(this);
}
$dynamic("get$name").DocumentType = function() { return this.name; };
function _ChildrenElementList() {}
_ChildrenElementList.prototype.is$List = function(){return true};
_ChildrenElementList.prototype.is$Collection = function(){return true};
_ChildrenElementList.prototype._toList = function() {
  var output = new Array(this._childElements.get$length());
  for (var i = (0), len = this._childElements.get$length();
   i < len; i++) {
    output.$setindex(i, this._childElements.$index(i));
  }
  return output;
}
_ChildrenElementList.prototype.forEach = function(f) {
  var $$list = this._childElements;
  for (var $$i = $$list.iterator(); $$i.hasNext(); ) {
    var element = $$i.next();
    f(element);
  }
}
_ChildrenElementList.prototype.filter = function(f) {
  var output = [];
  this.forEach((function (element) {
    if (f(element)) {
      output.add$1(element);
    }
  })
  );
  return new _FrozenElementList._wrap$ctor(output);
}
_ChildrenElementList.prototype.get$length = function() {
  return this._childElements.get$length();
}
_ChildrenElementList.prototype.$index = function(index) {
  return this._childElements.$index(index);
}
_ChildrenElementList.prototype.$setindex = function(index, value) {
  this._html_element.replaceChild(value, this._childElements.$index(index));
}
_ChildrenElementList.prototype.add = function(value) {
  this._html_element.appendChild(value);
  return value;
}
_ChildrenElementList.prototype.iterator = function() {
  return this._toList().iterator();
}
_ChildrenElementList.prototype.clear$_ = function() {
  this._html_element.set$text("");
}
_ChildrenElementList.prototype.removeLast = function() {
  var result = this.last();
  if ($ne$(result)) {
    this._html_element.removeChild(result);
  }
  return result;
}
_ChildrenElementList.prototype.last = function() {
  return this._html_element.get$$$dom_lastElementChild();
}
_ChildrenElementList.prototype.add$1 = _ChildrenElementList.prototype.add;
_ChildrenElementList.prototype.filter$1 = function($0) {
  return this.filter($wrap_call$1(to$call$1($0)));
};
_ChildrenElementList.prototype.forEach$1 = function($0) {
  return this.forEach($wrap_call$1(to$call$1($0)));
};
_FrozenElementList._wrap$ctor = function(_nodeList) {
  this._nodeList = _nodeList;
}
_FrozenElementList._wrap$ctor.prototype = _FrozenElementList.prototype;
function _FrozenElementList() {}
_FrozenElementList.prototype.is$List = function(){return true};
_FrozenElementList.prototype.is$Collection = function(){return true};
_FrozenElementList.prototype.forEach = function(f) {
  for (var $$i = this.iterator(); $$i.hasNext(); ) {
    var el = $$i.next();
    f(el);
  }
}
_FrozenElementList.prototype.filter = function(f) {
  var out = new _ElementList([]);
  for (var $$i = this.iterator(); $$i.hasNext(); ) {
    var el = $$i.next();
    if (f(el)) out.add$1(el);
  }
  return out;
}
_FrozenElementList.prototype.get$length = function() {
  return this._nodeList.get$length();
}
_FrozenElementList.prototype.$index = function(index) {
  return this._nodeList.$index(index);
}
_FrozenElementList.prototype.$setindex = function(index, value) {
  $throw(const$0003);
}
_FrozenElementList.prototype.add = function(value) {
  $throw(const$0003);
}
_FrozenElementList.prototype.iterator = function() {
  return new _FrozenElementListIterator(this);
}
_FrozenElementList.prototype.clear$_ = function() {
  $throw(const$0003);
}
_FrozenElementList.prototype.removeLast = function() {
  $throw(const$0003);
}
_FrozenElementList.prototype.last = function() {
  return this._nodeList.last();
}
_FrozenElementList.prototype.add$1 = _FrozenElementList.prototype.add;
_FrozenElementList.prototype.filter$1 = function($0) {
  return this.filter($wrap_call$1(to$call$1($0)));
};
_FrozenElementList.prototype.forEach$1 = function($0) {
  return this.forEach($wrap_call$1(to$call$1($0)));
};
function _FrozenElementListIterator(_list) {
  this._html_index = (0);
  this._html_list = _list;
}
_FrozenElementListIterator.prototype.next = function() {
  if (!this.hasNext()) {
    $throw(const$0001);
  }
  return this._html_list.$index(this._html_index++);
}
_FrozenElementListIterator.prototype.hasNext = function() {
  return this._html_index < this._html_list.get$length();
}
function _ListWrapper() {}
_ListWrapper.prototype.is$List = function(){return true};
_ListWrapper.prototype.is$Collection = function(){return true};
_ListWrapper.prototype.iterator = function() {
  return this._html_list.iterator();
}
_ListWrapper.prototype.forEach = function(f) {
  return this._html_list.forEach$1(f);
}
_ListWrapper.prototype.filter = function(f) {
  return this._html_list.filter$1(f);
}
_ListWrapper.prototype.get$length = function() {
  return this._html_list.get$length();
}
_ListWrapper.prototype.$index = function(index) {
  return this._html_list.$index(index);
}
_ListWrapper.prototype.$setindex = function(index, value) {
  this._html_list.$setindex(index, value);
}
_ListWrapper.prototype.add = function(value) {
  return this._html_list.add(value);
}
_ListWrapper.prototype.clear$_ = function() {
  return this._html_list.clear$_();
}
_ListWrapper.prototype.removeLast = function() {
  return this._html_list.removeLast();
}
_ListWrapper.prototype.last = function() {
  return this._html_list.last();
}
_ListWrapper.prototype.add$1 = _ListWrapper.prototype.add;
_ListWrapper.prototype.filter$1 = function($0) {
  return this.filter($wrap_call$1(to$call$1($0)));
};
_ListWrapper.prototype.forEach$1 = function($0) {
  return this.forEach($wrap_call$1(to$call$1($0)));
};
$inherits(_ListWrapper_Element, _ListWrapper);
function _ListWrapper_Element(_list) {
  this._html_list = _list;
}
_ListWrapper_Element.prototype.add$1 = _ListWrapper_Element.prototype.add;
$inherits(_ElementList, _ListWrapper_Element);
function _ElementList(list) {
  _ListWrapper_Element.call(this, list);
}
_ElementList.prototype.filter = function(f) {
  return new _ElementList(_ListWrapper_Element.prototype.filter.call(this, f));
}
_ElementList.prototype.filter$1 = function($0) {
  return this.filter($wrap_call$1(to$call$1($0)));
};
function _ElementAttributeMap(_element) {
  this._html_element = _element;
}
_ElementAttributeMap.prototype.is$Map = function(){return true};
_ElementAttributeMap.prototype.$index = function(key) {
  return this._html_element.getAttribute(key);
}
_ElementAttributeMap.prototype.$setindex = function(key, value) {
  this._html_element.setAttribute(key, ("" + value));
}
_ElementAttributeMap.prototype.forEach = function(f) {
  var attributes = this._html_element.get$$$dom_attributes();
  for (var i = (0), len = attributes.get$length();
   i < len; i++) {
    var item = attributes.$index(i);
    f(item.get$name(), item.get$value());
  }
}
_ElementAttributeMap.prototype.get$length = function() {
  return this._html_element.get$$$dom_attributes().length;
}
_ElementAttributeMap.prototype.forEach$1 = function($0) {
  return this.forEach($wrap_call$2(to$call$2($0)));
};
function _DataAttributeMap() {}
_DataAttributeMap.prototype.is$Map = function(){return true};
_DataAttributeMap.prototype.$index = function(key) {
  return this.$$dom_attributes.$index(this._attr(key));
}
_DataAttributeMap.prototype.$setindex = function(key, value) {
  this.$$dom_attributes.$setindex(this._attr(key), ("" + value));
}
_DataAttributeMap.prototype.forEach = function(f) {
  var $this = this;
  this.$$dom_attributes.forEach$1((function (key, value) {
    if ($this._matches(key)) {
      f($this._strip(key), value);
    }
  })
  );
}
_DataAttributeMap.prototype.getKeys = function() {
  var $this = this;
  var keys = new Array();
  this.$$dom_attributes.forEach$1((function (key, value) {
    if ($this._matches(key)) {
      keys.add$1($this._strip(key));
    }
  })
  );
  return keys;
}
_DataAttributeMap.prototype.get$length = function() {
  return this.getKeys().get$length();
}
_DataAttributeMap.prototype._attr = function(key) {
  return ("data-" + key);
}
_DataAttributeMap.prototype._matches = function(key) {
  return key.startsWith("data-");
}
_DataAttributeMap.prototype._strip = function(key) {
  return key.substring((5));
}
_DataAttributeMap.prototype.forEach$1 = function($0) {
  return this.forEach($wrap_call$2(to$call$2($0)));
};
function _CssClassSet() {}
_CssClassSet.prototype.is$Collection = function(){return true};
_CssClassSet.prototype.toString = function() {
  return this._formatSet(this._read());
}
_CssClassSet.prototype.iterator = function() {
  return this._read().iterator();
}
_CssClassSet.prototype.forEach = function(f) {
  this._read().forEach$1(f);
}
_CssClassSet.prototype.filter = function(f) {
  return this._read().filter$1(f);
}
_CssClassSet.prototype.get$length = function() {
  return this._read().get$length();
}
_CssClassSet.prototype.add = function(value) {
  this._modify((function (s) {
    return s.add$1(value);
  })
  );
}
_CssClassSet.prototype._modify = function(f) {
  var s = this._read();
  f(s);
  this._write(s);
}
_CssClassSet.prototype._read = function() {
  var s = new HashSetImplementation_dart_core_String();
  var $$list = this._classname().split$_(" ");
  for (var $$i = $$list.iterator(); $$i.hasNext(); ) {
    var name = $$i.next();
    var trimmed = name.trim();
    if (!trimmed.isEmpty()) {
      s.add(trimmed);
    }
  }
  return s;
}
_CssClassSet.prototype._classname = function() {
  return this._html_element.get$$$dom_className();
}
_CssClassSet.prototype._write = function(s) {
  this._html_element.set$$$dom_className(this._formatSet(s));
}
_CssClassSet.prototype._formatSet = function(s) {
  var list = ListFactory.ListFactory$from$factory(s);
  return Strings.join(list, " ");
}
_CssClassSet.prototype.add$1 = _CssClassSet.prototype.add;
_CssClassSet.prototype.filter$1 = function($0) {
  return this.filter($wrap_call$1(to$call$1($0)));
};
_CssClassSet.prototype.forEach$1 = function($0) {
  return this.forEach($wrap_call$1(to$call$1($0)));
};
function _SimpleClientRect() {}
_SimpleClientRect.prototype.get$width = function() { return this.width; };
_SimpleClientRect.prototype.get$height = function() { return this.height; };
_SimpleClientRect.prototype.$eq = function(other) {
  return null != other && this.left == other.left && this.top == other.top && this.width == other.width && this.height == other.height;
}
_SimpleClientRect.prototype.toString = function() {
  return ("(" + this.left + ", " + this.top + ", " + this.width + ", " + this.height + ")");
}
function _ElementRectImpl() {}
function _ElementFactoryProvider() {}
_ElementFactoryProvider.Element$tag$factory = function(tag) {
  return document.createElement(tag)
}
$dynamic("get$height").HTMLEmbedElement = function() { return this.height; };
$dynamic("get$name").HTMLEmbedElement = function() { return this.name; };
$dynamic("get$width").HTMLEmbedElement = function() { return this.width; };
$dynamic("get$length").EntryArray = function() { return this.length; };
$dynamic("get$length").EntryArraySync = function() { return this.length; };
$dynamic("get$name").EventException = function() { return this.name; };
$dynamic("$dom_addEventListener$3").EventSource = function($0, $1, $2) {
  return this.addEventListener($0, $wrap_call$1(to$call$1($1)), $2);
};
$inherits(_EventSourceEventsImpl, _EventsImpl);
function _EventSourceEventsImpl() {}
function _EventListenerListImpl(_ptr, _type) {
  this._ptr = _ptr;
  this._type = _type;
}
_EventListenerListImpl.prototype.add = function(listener, useCapture) {
  this._add(listener, useCapture);
  return this;
}
_EventListenerListImpl.prototype._add = function(listener, useCapture) {
  this._ptr.$dom_addEventListener$3(this._type, listener, useCapture);
}
_EventListenerListImpl.prototype.add$1 = function($0) {
  return this.add($wrap_call$1(to$call$1($0)), false);
};
$dynamic("get$name").HTMLFieldSetElement = function() { return this.name; };
$dynamic("get$name").File = function() { return this.name; };
$dynamic("get$name").FileException = function() { return this.name; };
$dynamic("get$length").FileList = function() { return this.length; };
$dynamic("$dom_addEventListener$3").FileReader = function($0, $1, $2) {
  return this.addEventListener($0, $wrap_call$1(to$call$1($1)), $2);
};
$inherits(_FileReaderEventsImpl, _EventsImpl);
function _FileReaderEventsImpl() {}
$dynamic("get$length").FileWriter = function() { return this.length; };
$dynamic("$dom_addEventListener$3").FileWriter = function($0, $1, $2) {
  return this.addEventListener($0, $wrap_call$1(to$call$1($1)), $2);
};
$inherits(_FileWriterEventsImpl, _EventsImpl);
function _FileWriterEventsImpl() {}
$dynamic("get$length").FileWriterSync = function() { return this.length; };
$dynamic("is$List").Float32Array = function(){return true};
$dynamic("is$Collection").Float32Array = function(){return true};
$dynamic("get$length").Float32Array = function() { return this.length; };
$dynamic("$index").Float32Array = function(index) {
  return this[index];
}
$dynamic("$setindex").Float32Array = function(index, value) {
  this[index] = value
}
$dynamic("iterator").Float32Array = function() {
  return new _FixedSizeListIterator_num(this);
}
$dynamic("add").Float32Array = function(value) {
  $throw(new UnsupportedOperationException("Cannot add to immutable List."));
}
$dynamic("forEach").Float32Array = function(f) {
  return _Collections.forEach(this, f);
}
$dynamic("filter").Float32Array = function(f) {
  return _Collections.filter(this, [], f);
}
$dynamic("last").Float32Array = function() {
  return this.$index(this.length - (1));
}
$dynamic("removeLast").Float32Array = function() {
  $throw(new UnsupportedOperationException("Cannot removeLast on immutable List."));
}
$dynamic("add$1").Float32Array = function($0) {
  return this.add($0);
};
$dynamic("filter$1").Float32Array = function($0) {
  return this.filter($wrap_call$1(to$call$1($0)));
};
$dynamic("forEach$1").Float32Array = function($0) {
  return this.forEach($wrap_call$1(to$call$1($0)));
};
$dynamic("is$List").Float64Array = function(){return true};
$dynamic("is$Collection").Float64Array = function(){return true};
$dynamic("get$length").Float64Array = function() { return this.length; };
$dynamic("$index").Float64Array = function(index) {
  return this[index];
}
$dynamic("$setindex").Float64Array = function(index, value) {
  this[index] = value
}
$dynamic("iterator").Float64Array = function() {
  return new _FixedSizeListIterator_num(this);
}
$dynamic("add").Float64Array = function(value) {
  $throw(new UnsupportedOperationException("Cannot add to immutable List."));
}
$dynamic("forEach").Float64Array = function(f) {
  return _Collections.forEach(this, f);
}
$dynamic("filter").Float64Array = function(f) {
  return _Collections.filter(this, [], f);
}
$dynamic("last").Float64Array = function() {
  return this.$index(this.length - (1));
}
$dynamic("removeLast").Float64Array = function() {
  $throw(new UnsupportedOperationException("Cannot removeLast on immutable List."));
}
$dynamic("add$1").Float64Array = function($0) {
  return this.add($0);
};
$dynamic("filter$1").Float64Array = function($0) {
  return this.filter($wrap_call$1(to$call$1($0)));
};
$dynamic("forEach$1").Float64Array = function($0) {
  return this.forEach($wrap_call$1(to$call$1($0)));
};
$dynamic("get$length").HTMLFormElement = function() { return this.length; };
$dynamic("get$name").HTMLFormElement = function() { return this.name; };
$dynamic("get$height").HTMLFrameElement = function() { return this.height; };
$dynamic("get$name").HTMLFrameElement = function() { return this.name; };
$dynamic("get$width").HTMLFrameElement = function() { return this.width; };
$dynamic("get$on").HTMLFrameSetElement = function() {
  return new _FrameSetElementEventsImpl(this);
}
$inherits(_FrameSetElementEventsImpl, _ElementEventsImpl);
function _FrameSetElementEventsImpl(_ptr) {
  _ElementEventsImpl.call(this, _ptr);
}
$dynamic("get$width").HTMLHRElement = function() { return this.width; };
$dynamic("get$length").HTMLAllCollection = function() { return this.length; };
$dynamic("is$List").HTMLCollection = function(){return true};
$dynamic("is$Collection").HTMLCollection = function(){return true};
$dynamic("get$length").HTMLCollection = function() { return this.length; };
$dynamic("$index").HTMLCollection = function(index) {
  return this[index];
}
$dynamic("$setindex").HTMLCollection = function(index, value) {
  $throw(new UnsupportedOperationException("Cannot assign element of immutable List."));
}
$dynamic("iterator").HTMLCollection = function() {
  return new _FixedSizeListIterator_html_Node(this);
}
$dynamic("add").HTMLCollection = function(value) {
  $throw(new UnsupportedOperationException("Cannot add to immutable List."));
}
$dynamic("forEach").HTMLCollection = function(f) {
  return _Collections.forEach(this, f);
}
$dynamic("filter").HTMLCollection = function(f) {
  return _Collections.filter(this, [], f);
}
$dynamic("last").HTMLCollection = function() {
  return this.$index(this.get$length() - (1));
}
$dynamic("removeLast").HTMLCollection = function() {
  $throw(new UnsupportedOperationException("Cannot removeLast on immutable List."));
}
$dynamic("add$1").HTMLCollection = function($0) {
  return this.add($0);
};
$dynamic("filter$1").HTMLCollection = function($0) {
  return this.filter($wrap_call$1(to$call$1($0)));
};
$dynamic("forEach$1").HTMLCollection = function($0) {
  return this.forEach($wrap_call$1(to$call$1($0)));
};
$dynamic("get$length").HTMLOptionsCollection = function() {
  return this.length;
}
$dynamic("get$length").History = function() { return this.length; };
$dynamic("get$value").IDBCursorWithValue = function() { return this.value; };
$dynamic("get$name").IDBDatabase = function() { return this.name; };
$dynamic("$dom_addEventListener$3").IDBDatabase = function($0, $1, $2) {
  return this.addEventListener($0, $wrap_call$1(to$call$1($1)), $2);
};
$inherits(_IDBDatabaseEventsImpl, _EventsImpl);
function _IDBDatabaseEventsImpl() {}
$dynamic("get$name").IDBDatabaseException = function() { return this.name; };
$dynamic("get$name").IDBIndex = function() { return this.name; };
$dynamic("get$name").IDBObjectStore = function() { return this.name; };
$dynamic("add$1").IDBObjectStore = function($0) {
  return this.add($0);
};
$dynamic("$dom_addEventListener$3").IDBRequest = function($0, $1, $2) {
  if (Object.getPrototypeOf(this).hasOwnProperty("$dom_addEventListener$3")) {
    return this.addEventListener($0, $wrap_call$1(to$call$1($1)), $2);
  }
  return Object.prototype.$dom_addEventListener$3.call(this, $0, $1, $2);
};
$inherits(_IDBRequestEventsImpl, _EventsImpl);
function _IDBRequestEventsImpl() {}
$dynamic("$dom_addEventListener$3").IDBTransaction = function($0, $1, $2) {
  return this.addEventListener($0, $wrap_call$1(to$call$1($1)), $2);
};
$inherits(_IDBTransactionEventsImpl, _EventsImpl);
function _IDBTransactionEventsImpl() {}
$dynamic("$dom_addEventListener$3").IDBVersionChangeRequest = function($0, $1, $2) {
  return this.addEventListener($0, $wrap_call$1(to$call$1($1)), $2);
};
$inherits(_IDBVersionChangeRequestEventsImpl, _IDBRequestEventsImpl);
function _IDBVersionChangeRequestEventsImpl() {}
$dynamic("get$height").HTMLIFrameElement = function() { return this.height; };
$dynamic("get$name").HTMLIFrameElement = function() { return this.name; };
$dynamic("get$width").HTMLIFrameElement = function() { return this.width; };
$dynamic("get$height").ImageData = function() { return this.height; };
$dynamic("get$width").ImageData = function() { return this.width; };
$dynamic("get$height").HTMLImageElement = function() { return this.height; };
$dynamic("get$name").HTMLImageElement = function() { return this.name; };
$dynamic("get$width").HTMLImageElement = function() { return this.width; };
$dynamic("get$x").HTMLImageElement = function() { return this.x; };
$dynamic("get$y").HTMLImageElement = function() { return this.y; };
$dynamic("get$on").HTMLInputElement = function() {
  return new _InputElementEventsImpl(this);
}
$dynamic("get$name").HTMLInputElement = function() { return this.name; };
$dynamic("get$value").HTMLInputElement = function() { return this.value; };
$dynamic("set$value").HTMLInputElement = function(value) { return this.value = value; };
$inherits(_InputElementEventsImpl, _ElementEventsImpl);
function _InputElementEventsImpl(_ptr) {
  _ElementEventsImpl.call(this, _ptr);
}
$dynamic("is$List").Int16Array = function(){return true};
$dynamic("is$Collection").Int16Array = function(){return true};
$dynamic("get$length").Int16Array = function() { return this.length; };
$dynamic("$index").Int16Array = function(index) {
  return this[index];
}
$dynamic("$setindex").Int16Array = function(index, value) {
  this[index] = value
}
$dynamic("iterator").Int16Array = function() {
  return new _FixedSizeListIterator_int(this);
}
$dynamic("add").Int16Array = function(value) {
  $throw(new UnsupportedOperationException("Cannot add to immutable List."));
}
$dynamic("forEach").Int16Array = function(f) {
  return _Collections.forEach(this, f);
}
$dynamic("filter").Int16Array = function(f) {
  return _Collections.filter(this, [], f);
}
$dynamic("last").Int16Array = function() {
  return this.$index(this.length - (1));
}
$dynamic("removeLast").Int16Array = function() {
  $throw(new UnsupportedOperationException("Cannot removeLast on immutable List."));
}
$dynamic("add$1").Int16Array = function($0) {
  return this.add($0);
};
$dynamic("filter$1").Int16Array = function($0) {
  return this.filter($wrap_call$1(to$call$1($0)));
};
$dynamic("forEach$1").Int16Array = function($0) {
  return this.forEach($wrap_call$1(to$call$1($0)));
};
$dynamic("is$List").Int32Array = function(){return true};
$dynamic("is$Collection").Int32Array = function(){return true};
$dynamic("get$length").Int32Array = function() { return this.length; };
$dynamic("$index").Int32Array = function(index) {
  return this[index];
}
$dynamic("$setindex").Int32Array = function(index, value) {
  this[index] = value
}
$dynamic("iterator").Int32Array = function() {
  return new _FixedSizeListIterator_int(this);
}
$dynamic("add").Int32Array = function(value) {
  $throw(new UnsupportedOperationException("Cannot add to immutable List."));
}
$dynamic("forEach").Int32Array = function(f) {
  return _Collections.forEach(this, f);
}
$dynamic("filter").Int32Array = function(f) {
  return _Collections.filter(this, [], f);
}
$dynamic("last").Int32Array = function() {
  return this.$index(this.length - (1));
}
$dynamic("removeLast").Int32Array = function() {
  $throw(new UnsupportedOperationException("Cannot removeLast on immutable List."));
}
$dynamic("add$1").Int32Array = function($0) {
  return this.add($0);
};
$dynamic("filter$1").Int32Array = function($0) {
  return this.filter($wrap_call$1(to$call$1($0)));
};
$dynamic("forEach$1").Int32Array = function($0) {
  return this.forEach($wrap_call$1(to$call$1($0)));
};
$dynamic("is$List").Int8Array = function(){return true};
$dynamic("is$Collection").Int8Array = function(){return true};
$dynamic("get$length").Int8Array = function() { return this.length; };
$dynamic("$index").Int8Array = function(index) {
  return this[index];
}
$dynamic("$setindex").Int8Array = function(index, value) {
  this[index] = value
}
$dynamic("iterator").Int8Array = function() {
  return new _FixedSizeListIterator_int(this);
}
$dynamic("add").Int8Array = function(value) {
  $throw(new UnsupportedOperationException("Cannot add to immutable List."));
}
$dynamic("forEach").Int8Array = function(f) {
  return _Collections.forEach(this, f);
}
$dynamic("filter").Int8Array = function(f) {
  return _Collections.filter(this, [], f);
}
$dynamic("last").Int8Array = function() {
  return this.$index(this.length - (1));
}
$dynamic("removeLast").Int8Array = function() {
  $throw(new UnsupportedOperationException("Cannot removeLast on immutable List."));
}
$dynamic("add$1").Int8Array = function($0) {
  return this.add($0);
};
$dynamic("filter$1").Int8Array = function($0) {
  return this.filter($wrap_call$1(to$call$1($0)));
};
$dynamic("forEach$1").Int8Array = function($0) {
  return this.forEach($wrap_call$1(to$call$1($0)));
};
$dynamic("$dom_addEventListener$3").JavaScriptAudioNode = function($0, $1, $2) {
  return this.addEventListener($0, $wrap_call$1(to$call$1($1)), $2);
};
$inherits(_JavaScriptAudioNodeEventsImpl, _EventsImpl);
function _JavaScriptAudioNodeEventsImpl() {}
$dynamic("get$name").HTMLKeygenElement = function() { return this.name; };
$dynamic("get$value").HTMLLIElement = function() { return this.value; };
$dynamic("set$value").HTMLLIElement = function(value) { return this.value = value; };
$dynamic("$dom_addEventListener$3").MediaStream = function($0, $1, $2) {
  return this.addEventListener($0, $wrap_call$1(to$call$1($1)), $2);
};
$dynamic("get$name").HTMLMapElement = function() { return this.name; };
$dynamic("get$height").HTMLMarqueeElement = function() { return this.height; };
$dynamic("get$width").HTMLMarqueeElement = function() { return this.width; };
$dynamic("$dom_addEventListener$3").MediaController = function($0, $1, $2) {
  return this.addEventListener($0, $wrap_call$1(to$call$1($1)), $2);
};
$inherits(_MediaElementEventsImpl, _ElementEventsImpl);
function _MediaElementEventsImpl(_ptr) {
  _ElementEventsImpl.call(this, _ptr);
}
$dynamic("is$List").MediaList = function(){return true};
$dynamic("is$Collection").MediaList = function(){return true};
$dynamic("get$length").MediaList = function() { return this.length; };
$dynamic("$index").MediaList = function(index) {
  return this[index];
}
$dynamic("$setindex").MediaList = function(index, value) {
  $throw(new UnsupportedOperationException("Cannot assign element of immutable List."));
}
$dynamic("iterator").MediaList = function() {
  return new _FixedSizeListIterator_dart_core_String(this);
}
$dynamic("add").MediaList = function(value) {
  $throw(new UnsupportedOperationException("Cannot add to immutable List."));
}
$dynamic("forEach").MediaList = function(f) {
  return _Collections.forEach(this, f);
}
$dynamic("filter").MediaList = function(f) {
  return _Collections.filter(this, [], f);
}
$dynamic("last").MediaList = function() {
  return this.$index(this.length - (1));
}
$dynamic("removeLast").MediaList = function() {
  $throw(new UnsupportedOperationException("Cannot removeLast on immutable List."));
}
$dynamic("add$1").MediaList = function($0) {
  return this.add($0);
};
$dynamic("filter$1").MediaList = function($0) {
  return this.filter($wrap_call$1(to$call$1($0)));
};
$dynamic("forEach$1").MediaList = function($0) {
  return this.forEach($wrap_call$1(to$call$1($0)));
};
$inherits(_MediaStreamEventsImpl, _EventsImpl);
function _MediaStreamEventsImpl() {}
$dynamic("get$length").MediaStreamList = function() { return this.length; };
$dynamic("get$length").MediaStreamTrackList = function() { return this.length; };
$dynamic("$dom_addEventListener$3").MessagePort = function($0, $1, $2) {
  return this.addEventListener($0, $wrap_call$1(to$call$1($1)), $2);
};
$inherits(_MessagePortEventsImpl, _EventsImpl);
function _MessagePortEventsImpl() {}
$dynamic("get$name").HTMLMetaElement = function() { return this.name; };
$dynamic("get$value").HTMLMeterElement = function() { return this.value; };
$dynamic("set$value").HTMLMeterElement = function(value) { return this.value = value; };
$dynamic("get$x").MouseEvent = function() { return this.x; };
$dynamic("get$y").MouseEvent = function() { return this.y; };
$dynamic("is$List").NamedNodeMap = function(){return true};
$dynamic("is$Collection").NamedNodeMap = function(){return true};
$dynamic("get$length").NamedNodeMap = function() { return this.length; };
$dynamic("$index").NamedNodeMap = function(index) {
  return this[index];
}
$dynamic("$setindex").NamedNodeMap = function(index, value) {
  $throw(new UnsupportedOperationException("Cannot assign element of immutable List."));
}
$dynamic("iterator").NamedNodeMap = function() {
  return new _FixedSizeListIterator_html_Node(this);
}
$dynamic("add").NamedNodeMap = function(value) {
  $throw(new UnsupportedOperationException("Cannot add to immutable List."));
}
$dynamic("forEach").NamedNodeMap = function(f) {
  return _Collections.forEach(this, f);
}
$dynamic("filter").NamedNodeMap = function(f) {
  return _Collections.filter(this, [], f);
}
$dynamic("last").NamedNodeMap = function() {
  return this.$index(this.length - (1));
}
$dynamic("removeLast").NamedNodeMap = function() {
  $throw(new UnsupportedOperationException("Cannot removeLast on immutable List."));
}
$dynamic("add$1").NamedNodeMap = function($0) {
  return this.add($0);
};
$dynamic("filter$1").NamedNodeMap = function($0) {
  return this.filter($wrap_call$1(to$call$1($0)));
};
$dynamic("forEach$1").NamedNodeMap = function($0) {
  return this.forEach($wrap_call$1(to$call$1($0)));
};
function _ChildNodeListLazy() {}
_ChildNodeListLazy.prototype.is$List = function(){return true};
_ChildNodeListLazy.prototype.is$Collection = function(){return true};
_ChildNodeListLazy.prototype.last = function() {
  return this._this.lastChild;
}
_ChildNodeListLazy.prototype.add = function(value) {
  this._this.appendChild(value);
}
_ChildNodeListLazy.prototype.removeLast = function() {
  var result = this.last();
  if ($ne$(result)) {
    this._this.removeChild(result);
  }
  return result;
}
_ChildNodeListLazy.prototype.clear$_ = function() {
  this._this.set$text("");
}
_ChildNodeListLazy.prototype.$setindex = function(index, value) {
  this._this.replaceChild(value, this.$index(index));
}
_ChildNodeListLazy.prototype.iterator = function() {
  return this._this.get$$$dom_childNodes().iterator();
}
_ChildNodeListLazy.prototype.forEach = function(f) {
  return _Collections.forEach(this, f);
}
_ChildNodeListLazy.prototype.filter = function(f) {
  return new _NodeListWrapper(_Collections.filter(this, [], f));
}
_ChildNodeListLazy.prototype.get$length = function() {
  return this._this.get$$$dom_childNodes().length;
}
_ChildNodeListLazy.prototype.$index = function(index) {
  return this._this.get$$$dom_childNodes().$index(index);
}
_ChildNodeListLazy.prototype.add$1 = _ChildNodeListLazy.prototype.add;
_ChildNodeListLazy.prototype.filter$1 = function($0) {
  return this.filter($wrap_call$1(to$call$1($0)));
};
_ChildNodeListLazy.prototype.forEach$1 = function($0) {
  return this.forEach($wrap_call$1(to$call$1($0)));
};
$inherits(_ListWrapper_Node, _ListWrapper);
function _ListWrapper_Node(_list) {
  this._html_list = _list;
}
_ListWrapper_Node.prototype.add$1 = _ListWrapper_Node.prototype.add;
$inherits(_NodeListWrapper, _ListWrapper_Node);
function _NodeListWrapper(list) {
  _ListWrapper_Node.call(this, list);
}
_NodeListWrapper.prototype.filter = function(f) {
  return new _NodeListWrapper(this._html_list.filter$1(f));
}
_NodeListWrapper.prototype.filter$1 = function($0) {
  return this.filter($wrap_call$1(to$call$1($0)));
};
$dynamic("is$List").NodeList = function(){return true};
$dynamic("is$Collection").NodeList = function(){return true};
$dynamic("iterator").NodeList = function() {
  return new _FixedSizeListIterator_html_Node(this);
}
$dynamic("add").NodeList = function(value) {
  this._parent.appendChild(value);
}
$dynamic("removeLast").NodeList = function() {
  var result = this.last();
  if ($ne$(result)) {
    this._parent.removeChild(result);
  }
  return result;
}
$dynamic("clear$_").NodeList = function() {
  this._parent.set$text("");
}
$dynamic("$setindex").NodeList = function(index, value) {
  this._parent.replaceChild(value, this.$index(index));
}
$dynamic("forEach").NodeList = function(f) {
  return _Collections.forEach(this, f);
}
$dynamic("filter").NodeList = function(f) {
  return new _NodeListWrapper(_Collections.filter(this, [], f));
}
$dynamic("last").NodeList = function() {
  return this.$index(this.length - (1));
}
$dynamic("get$length").NodeList = function() { return this.length; };
$dynamic("$index").NodeList = function(index) {
  return this[index];
}
$dynamic("add$1").NodeList = function($0) {
  return this.add($0);
};
$dynamic("filter$1").NodeList = function($0) {
  return this.filter($wrap_call$1(to$call$1($0)));
};
$dynamic("forEach$1").NodeList = function($0) {
  return this.forEach($wrap_call$1(to$call$1($0)));
};
$inherits(_NotificationEventsImpl, _EventsImpl);
function _NotificationEventsImpl() {}
$dynamic("get$height").HTMLObjectElement = function() { return this.height; };
$dynamic("get$name").HTMLObjectElement = function() { return this.name; };
$dynamic("get$width").HTMLObjectElement = function() { return this.width; };
$dynamic("get$name").OperationNotAllowedException = function() { return this.name; };
$dynamic("get$value").HTMLOptionElement = function() { return this.value; };
$dynamic("set$value").HTMLOptionElement = function(value) { return this.value = value; };
$dynamic("get$name").HTMLOutputElement = function() { return this.name; };
$dynamic("get$value").HTMLOutputElement = function() { return this.value; };
$dynamic("set$value").HTMLOutputElement = function(value) { return this.value = value; };
$dynamic("get$name").HTMLParamElement = function() { return this.name; };
$dynamic("get$value").HTMLParamElement = function() { return this.value; };
$dynamic("set$value").HTMLParamElement = function(value) { return this.value = value; };
$dynamic("$dom_addEventListener$3").PeerConnection00 = function($0, $1, $2) {
  return this.addEventListener($0, $wrap_call$1(to$call$1($1)), $2);
};
$inherits(_PeerConnection00EventsImpl, _EventsImpl);
function _PeerConnection00EventsImpl() {}
$dynamic("get$x").WebKitPoint = function() { return this.x; };
$dynamic("get$y").WebKitPoint = function() { return this.y; };
$dynamic("get$width").HTMLPreElement = function() { return this.width; };
$dynamic("get$value").HTMLProgressElement = function() { return this.value; };
$dynamic("set$value").HTMLProgressElement = function(value) { return this.value = value; };
$dynamic("get$name").RangeException = function() { return this.name; };
$dynamic("get$length").SQLResultSetRowList = function() { return this.length; };
$dynamic("get$x").SVGTextPositioningElement = function() { return this.x; };
$dynamic("get$y").SVGTextPositioningElement = function() { return this.y; };
$dynamic("get$value").SVGAngle = function() { return this.value; };
$dynamic("set$value").SVGAngle = function(value) { return this.value = value; };
$dynamic("get$x").SVGCursorElement = function() { return this.x; };
$dynamic("get$y").SVGCursorElement = function() { return this.y; };
$inherits(_AttributeClassSet, _CssClassSet);
function _AttributeClassSet() {}
_AttributeClassSet.prototype._write = function(s) {
  this._html_element.get$attributes().$setindex("class", this._formatSet(s));
}
$inherits(_SVGElementInstanceEventsImpl, _EventsImpl);
function _SVGElementInstanceEventsImpl() {}
_SVGElementInstanceEventsImpl.prototype.get$doubleClick = function() {
  return this._get("dblclick");
}
_SVGElementInstanceEventsImpl.prototype.get$mouseDown = function() {
  return this._get("mousedown");
}
_SVGElementInstanceEventsImpl.prototype.get$mouseMove = function() {
  return this._get("mousemove");
}
$dynamic("get$length").SVGElementInstanceList = function() { return this.length; };
$dynamic("get$name").SVGException = function() { return this.name; };
$dynamic("get$height").SVGFEBlendElement = function() { return this.height; };
$dynamic("get$width").SVGFEBlendElement = function() { return this.width; };
$dynamic("get$x").SVGFEBlendElement = function() { return this.x; };
$dynamic("get$y").SVGFEBlendElement = function() { return this.y; };
$dynamic("get$height").SVGFEColorMatrixElement = function() { return this.height; };
$dynamic("get$width").SVGFEColorMatrixElement = function() { return this.width; };
$dynamic("get$x").SVGFEColorMatrixElement = function() { return this.x; };
$dynamic("get$y").SVGFEColorMatrixElement = function() { return this.y; };
$dynamic("get$height").SVGFEComponentTransferElement = function() { return this.height; };
$dynamic("get$width").SVGFEComponentTransferElement = function() { return this.width; };
$dynamic("get$x").SVGFEComponentTransferElement = function() { return this.x; };
$dynamic("get$y").SVGFEComponentTransferElement = function() { return this.y; };
$dynamic("get$height").SVGFECompositeElement = function() { return this.height; };
$dynamic("get$width").SVGFECompositeElement = function() { return this.width; };
$dynamic("get$x").SVGFECompositeElement = function() { return this.x; };
$dynamic("get$y").SVGFECompositeElement = function() { return this.y; };
$dynamic("get$height").SVGFEConvolveMatrixElement = function() { return this.height; };
$dynamic("get$width").SVGFEConvolveMatrixElement = function() { return this.width; };
$dynamic("get$x").SVGFEConvolveMatrixElement = function() { return this.x; };
$dynamic("get$y").SVGFEConvolveMatrixElement = function() { return this.y; };
$dynamic("get$height").SVGFEDiffuseLightingElement = function() { return this.height; };
$dynamic("get$width").SVGFEDiffuseLightingElement = function() { return this.width; };
$dynamic("get$x").SVGFEDiffuseLightingElement = function() { return this.x; };
$dynamic("get$y").SVGFEDiffuseLightingElement = function() { return this.y; };
$dynamic("get$height").SVGFEDisplacementMapElement = function() { return this.height; };
$dynamic("get$width").SVGFEDisplacementMapElement = function() { return this.width; };
$dynamic("get$x").SVGFEDisplacementMapElement = function() { return this.x; };
$dynamic("get$y").SVGFEDisplacementMapElement = function() { return this.y; };
$dynamic("get$height").SVGFEDropShadowElement = function() { return this.height; };
$dynamic("get$width").SVGFEDropShadowElement = function() { return this.width; };
$dynamic("get$x").SVGFEDropShadowElement = function() { return this.x; };
$dynamic("get$y").SVGFEDropShadowElement = function() { return this.y; };
$dynamic("get$height").SVGFEFloodElement = function() { return this.height; };
$dynamic("get$width").SVGFEFloodElement = function() { return this.width; };
$dynamic("get$x").SVGFEFloodElement = function() { return this.x; };
$dynamic("get$y").SVGFEFloodElement = function() { return this.y; };
$dynamic("get$height").SVGFEGaussianBlurElement = function() { return this.height; };
$dynamic("get$width").SVGFEGaussianBlurElement = function() { return this.width; };
$dynamic("get$x").SVGFEGaussianBlurElement = function() { return this.x; };
$dynamic("get$y").SVGFEGaussianBlurElement = function() { return this.y; };
$dynamic("get$height").SVGFEImageElement = function() { return this.height; };
$dynamic("get$width").SVGFEImageElement = function() { return this.width; };
$dynamic("get$x").SVGFEImageElement = function() { return this.x; };
$dynamic("get$y").SVGFEImageElement = function() { return this.y; };
$dynamic("get$height").SVGFEMergeElement = function() { return this.height; };
$dynamic("get$width").SVGFEMergeElement = function() { return this.width; };
$dynamic("get$x").SVGFEMergeElement = function() { return this.x; };
$dynamic("get$y").SVGFEMergeElement = function() { return this.y; };
$dynamic("get$height").SVGFEMorphologyElement = function() { return this.height; };
$dynamic("get$width").SVGFEMorphologyElement = function() { return this.width; };
$dynamic("get$x").SVGFEMorphologyElement = function() { return this.x; };
$dynamic("get$y").SVGFEMorphologyElement = function() { return this.y; };
$dynamic("get$height").SVGFEOffsetElement = function() { return this.height; };
$dynamic("get$width").SVGFEOffsetElement = function() { return this.width; };
$dynamic("get$x").SVGFEOffsetElement = function() { return this.x; };
$dynamic("get$y").SVGFEOffsetElement = function() { return this.y; };
$dynamic("get$x").SVGFEPointLightElement = function() { return this.x; };
$dynamic("get$y").SVGFEPointLightElement = function() { return this.y; };
$dynamic("get$height").SVGFESpecularLightingElement = function() { return this.height; };
$dynamic("get$width").SVGFESpecularLightingElement = function() { return this.width; };
$dynamic("get$x").SVGFESpecularLightingElement = function() { return this.x; };
$dynamic("get$y").SVGFESpecularLightingElement = function() { return this.y; };
$dynamic("get$x").SVGFESpotLightElement = function() { return this.x; };
$dynamic("get$y").SVGFESpotLightElement = function() { return this.y; };
$dynamic("get$height").SVGFETileElement = function() { return this.height; };
$dynamic("get$width").SVGFETileElement = function() { return this.width; };
$dynamic("get$x").SVGFETileElement = function() { return this.x; };
$dynamic("get$y").SVGFETileElement = function() { return this.y; };
$dynamic("get$height").SVGFETurbulenceElement = function() { return this.height; };
$dynamic("get$width").SVGFETurbulenceElement = function() { return this.width; };
$dynamic("get$x").SVGFETurbulenceElement = function() { return this.x; };
$dynamic("get$y").SVGFETurbulenceElement = function() { return this.y; };
$dynamic("get$height").SVGFilterElement = function() { return this.height; };
$dynamic("get$width").SVGFilterElement = function() { return this.width; };
$dynamic("get$x").SVGFilterElement = function() { return this.x; };
$dynamic("get$y").SVGFilterElement = function() { return this.y; };
$dynamic("get$height").SVGFilterPrimitiveStandardAttributes = function() { return this.height; };
$dynamic("get$width").SVGFilterPrimitiveStandardAttributes = function() { return this.width; };
$dynamic("get$x").SVGFilterPrimitiveStandardAttributes = function() { return this.x; };
$dynamic("get$y").SVGFilterPrimitiveStandardAttributes = function() { return this.y; };
$dynamic("get$height").SVGForeignObjectElement = function() { return this.height; };
$dynamic("get$width").SVGForeignObjectElement = function() { return this.width; };
$dynamic("get$x").SVGForeignObjectElement = function() { return this.x; };
$dynamic("get$y").SVGForeignObjectElement = function() { return this.y; };
$dynamic("get$x").SVGGlyphRefElement = function() { return this.x; };
$dynamic("get$y").SVGGlyphRefElement = function() { return this.y; };
$dynamic("get$height").SVGImageElement = function() { return this.height; };
$dynamic("get$width").SVGImageElement = function() { return this.width; };
$dynamic("get$x").SVGImageElement = function() { return this.x; };
$dynamic("get$y").SVGImageElement = function() { return this.y; };
$dynamic("get$value").SVGLength = function() { return this.value; };
$dynamic("set$value").SVGLength = function(value) { return this.value = value; };
$dynamic("get$height").SVGMaskElement = function() { return this.height; };
$dynamic("get$width").SVGMaskElement = function() { return this.width; };
$dynamic("get$x").SVGMaskElement = function() { return this.x; };
$dynamic("get$y").SVGMaskElement = function() { return this.y; };
$dynamic("get$value").SVGNumber = function() { return this.value; };
$dynamic("set$value").SVGNumber = function(value) { return this.value = value; };
$dynamic("get$x").SVGPathSegArcAbs = function() { return this.x; };
$dynamic("get$y").SVGPathSegArcAbs = function() { return this.y; };
$dynamic("get$x").SVGPathSegArcRel = function() { return this.x; };
$dynamic("get$y").SVGPathSegArcRel = function() { return this.y; };
$dynamic("get$x").SVGPathSegCurvetoCubicAbs = function() { return this.x; };
$dynamic("get$y").SVGPathSegCurvetoCubicAbs = function() { return this.y; };
$dynamic("get$x").SVGPathSegCurvetoCubicRel = function() { return this.x; };
$dynamic("get$y").SVGPathSegCurvetoCubicRel = function() { return this.y; };
$dynamic("get$x").SVGPathSegCurvetoCubicSmoothAbs = function() { return this.x; };
$dynamic("get$y").SVGPathSegCurvetoCubicSmoothAbs = function() { return this.y; };
$dynamic("get$x").SVGPathSegCurvetoCubicSmoothRel = function() { return this.x; };
$dynamic("get$y").SVGPathSegCurvetoCubicSmoothRel = function() { return this.y; };
$dynamic("get$x").SVGPathSegCurvetoQuadraticAbs = function() { return this.x; };
$dynamic("get$y").SVGPathSegCurvetoQuadraticAbs = function() { return this.y; };
$dynamic("get$x").SVGPathSegCurvetoQuadraticRel = function() { return this.x; };
$dynamic("get$y").SVGPathSegCurvetoQuadraticRel = function() { return this.y; };
$dynamic("get$x").SVGPathSegCurvetoQuadraticSmoothAbs = function() { return this.x; };
$dynamic("get$y").SVGPathSegCurvetoQuadraticSmoothAbs = function() { return this.y; };
$dynamic("get$x").SVGPathSegCurvetoQuadraticSmoothRel = function() { return this.x; };
$dynamic("get$y").SVGPathSegCurvetoQuadraticSmoothRel = function() { return this.y; };
$dynamic("get$x").SVGPathSegLinetoAbs = function() { return this.x; };
$dynamic("get$y").SVGPathSegLinetoAbs = function() { return this.y; };
$dynamic("get$x").SVGPathSegLinetoHorizontalAbs = function() { return this.x; };
$dynamic("get$x").SVGPathSegLinetoHorizontalRel = function() { return this.x; };
$dynamic("get$x").SVGPathSegLinetoRel = function() { return this.x; };
$dynamic("get$y").SVGPathSegLinetoRel = function() { return this.y; };
$dynamic("get$y").SVGPathSegLinetoVerticalAbs = function() { return this.y; };
$dynamic("get$y").SVGPathSegLinetoVerticalRel = function() { return this.y; };
$dynamic("get$x").SVGPathSegMovetoAbs = function() { return this.x; };
$dynamic("get$y").SVGPathSegMovetoAbs = function() { return this.y; };
$dynamic("get$x").SVGPathSegMovetoRel = function() { return this.x; };
$dynamic("get$y").SVGPathSegMovetoRel = function() { return this.y; };
$dynamic("get$height").SVGPatternElement = function() { return this.height; };
$dynamic("get$width").SVGPatternElement = function() { return this.width; };
$dynamic("get$x").SVGPatternElement = function() { return this.x; };
$dynamic("get$y").SVGPatternElement = function() { return this.y; };
$dynamic("get$x").SVGPoint = function() { return this.x; };
$dynamic("get$y").SVGPoint = function() { return this.y; };
$dynamic("get$height").SVGRect = function() { return this.height; };
$dynamic("get$width").SVGRect = function() { return this.width; };
$dynamic("get$x").SVGRect = function() { return this.x; };
$dynamic("get$y").SVGRect = function() { return this.y; };
$dynamic("get$height").SVGRectElement = function() { return this.height; };
$dynamic("get$width").SVGRectElement = function() { return this.width; };
$dynamic("get$x").SVGRectElement = function() { return this.x; };
$dynamic("get$y").SVGRectElement = function() { return this.y; };
$dynamic("get$height").SVGSVGElement = function() { return this.height; };
$dynamic("get$width").SVGSVGElement = function() { return this.width; };
$dynamic("get$x").SVGSVGElement = function() { return this.x; };
$dynamic("get$y").SVGSVGElement = function() { return this.y; };
$dynamic("get$height").SVGUseElement = function() { return this.height; };
$dynamic("get$width").SVGUseElement = function() { return this.width; };
$dynamic("get$x").SVGUseElement = function() { return this.x; };
$dynamic("get$y").SVGUseElement = function() { return this.y; };
$dynamic("get$height").Screen = function() { return this.height; };
$dynamic("get$width").Screen = function() { return this.width; };
$dynamic("get$length").HTMLSelectElement = function() { return this.length; };
$dynamic("get$name").HTMLSelectElement = function() { return this.name; };
$dynamic("get$value").HTMLSelectElement = function() { return this.value; };
$dynamic("set$value").HTMLSelectElement = function(value) { return this.value = value; };
$dynamic("get$name").SharedWorkerContext = function() { return this.name; };
$inherits(_SharedWorkerContextEventsImpl, _WorkerContextEventsImpl);
function _SharedWorkerContextEventsImpl() {}
$dynamic("get$length").SpeechGrammarList = function() { return this.length; };
$dynamic("get$length").SpeechInputResultList = function() { return this.length; };
$dynamic("$dom_addEventListener$3").SpeechRecognition = function($0, $1, $2) {
  return this.addEventListener($0, $wrap_call$1(to$call$1($1)), $2);
};
$inherits(_SpeechRecognitionEventsImpl, _EventsImpl);
function _SpeechRecognitionEventsImpl() {}
$dynamic("get$length").SpeechRecognitionResult = function() { return this.length; };
$dynamic("get$length").SpeechRecognitionResultList = function() { return this.length; };
$dynamic("is$Map").Storage = function(){return true};
$dynamic("$index").Storage = function(key) {
  return this.getItem(key);
}
$dynamic("$setindex").Storage = function(key, value) {
  return this.setItem(key, value);
}
$dynamic("forEach").Storage = function(f) {
  for (var i = (0);
   true; i = $add$(i, (1))) {
    var key = this.key(i);
    if ($eq$(key)) return;
    f(key, this.$index(key));
  }
}
$dynamic("get$length").Storage = function() {
  return this.get$$$dom_length();
}
$dynamic("get$$$dom_length").Storage = function() {
  return this.length;
}
$dynamic("forEach$1").Storage = function($0) {
  return this.forEach($wrap_call$2(to$call$2($0)));
};
$dynamic("is$List").StyleSheetList = function(){return true};
$dynamic("is$Collection").StyleSheetList = function(){return true};
$dynamic("get$length").StyleSheetList = function() { return this.length; };
$dynamic("$index").StyleSheetList = function(index) {
  return this[index];
}
$dynamic("$setindex").StyleSheetList = function(index, value) {
  $throw(new UnsupportedOperationException("Cannot assign element of immutable List."));
}
$dynamic("iterator").StyleSheetList = function() {
  return new _FixedSizeListIterator_html_StyleSheet(this);
}
$dynamic("add").StyleSheetList = function(value) {
  $throw(new UnsupportedOperationException("Cannot add to immutable List."));
}
$dynamic("forEach").StyleSheetList = function(f) {
  return _Collections.forEach(this, f);
}
$dynamic("filter").StyleSheetList = function(f) {
  return _Collections.filter(this, [], f);
}
$dynamic("last").StyleSheetList = function() {
  return this.$index(this.length - (1));
}
$dynamic("removeLast").StyleSheetList = function() {
  $throw(new UnsupportedOperationException("Cannot removeLast on immutable List."));
}
$dynamic("add$1").StyleSheetList = function($0) {
  return this.add($0);
};
$dynamic("filter$1").StyleSheetList = function($0) {
  return this.filter($wrap_call$1(to$call$1($0)));
};
$dynamic("forEach$1").StyleSheetList = function($0) {
  return this.forEach($wrap_call$1(to$call$1($0)));
};
$dynamic("get$height").HTMLTableCellElement = function() { return this.height; };
$dynamic("get$width").HTMLTableCellElement = function() { return this.width; };
$dynamic("get$width").HTMLTableColElement = function() { return this.width; };
$dynamic("get$width").HTMLTableElement = function() { return this.width; };
$dynamic("get$name").HTMLTextAreaElement = function() { return this.name; };
$dynamic("get$value").HTMLTextAreaElement = function() { return this.value; };
$dynamic("set$value").HTMLTextAreaElement = function(value) { return this.value = value; };
$dynamic("get$width").TextMetrics = function() { return this.width; };
$dynamic("$dom_addEventListener$3").TextTrack = function($0, $1, $2) {
  return this.addEventListener($0, $wrap_call$1(to$call$1($1)), $2);
};
$inherits(_TextTrackEventsImpl, _EventsImpl);
function _TextTrackEventsImpl() {}
$dynamic("$dom_addEventListener$3").TextTrackCue = function($0, $1, $2) {
  return this.addEventListener($0, $wrap_call$1(to$call$1($1)), $2);
};
$inherits(_TextTrackCueEventsImpl, _EventsImpl);
function _TextTrackCueEventsImpl() {}
$dynamic("get$length").TextTrackCueList = function() { return this.length; };
$dynamic("get$length").TextTrackList = function() { return this.length; };
$dynamic("$dom_addEventListener$3").TextTrackList = function($0, $1, $2) {
  return this.addEventListener($0, $wrap_call$1(to$call$1($1)), $2);
};
$inherits(_TextTrackListEventsImpl, _EventsImpl);
function _TextTrackListEventsImpl() {}
$dynamic("get$length").TimeRanges = function() { return this.length; };
$dynamic("is$List").TouchList = function(){return true};
$dynamic("is$Collection").TouchList = function(){return true};
$dynamic("get$length").TouchList = function() { return this.length; };
$dynamic("$index").TouchList = function(index) {
  return this[index];
}
$dynamic("$setindex").TouchList = function(index, value) {
  $throw(new UnsupportedOperationException("Cannot assign element of immutable List."));
}
$dynamic("iterator").TouchList = function() {
  return new _FixedSizeListIterator_html_Touch(this);
}
$dynamic("add").TouchList = function(value) {
  $throw(new UnsupportedOperationException("Cannot add to immutable List."));
}
$dynamic("forEach").TouchList = function(f) {
  return _Collections.forEach(this, f);
}
$dynamic("filter").TouchList = function(f) {
  return _Collections.filter(this, [], f);
}
$dynamic("last").TouchList = function() {
  return this.$index(this.length - (1));
}
$dynamic("removeLast").TouchList = function() {
  $throw(new UnsupportedOperationException("Cannot removeLast on immutable List."));
}
$dynamic("add$1").TouchList = function($0) {
  return this.add($0);
};
$dynamic("filter$1").TouchList = function($0) {
  return this.filter($wrap_call$1(to$call$1($0)));
};
$dynamic("forEach$1").TouchList = function($0) {
  return this.forEach($wrap_call$1(to$call$1($0)));
};
$dynamic("is$List").Uint16Array = function(){return true};
$dynamic("is$Collection").Uint16Array = function(){return true};
$dynamic("get$length").Uint16Array = function() { return this.length; };
$dynamic("$index").Uint16Array = function(index) {
  return this[index];
}
$dynamic("$setindex").Uint16Array = function(index, value) {
  this[index] = value
}
$dynamic("iterator").Uint16Array = function() {
  return new _FixedSizeListIterator_int(this);
}
$dynamic("add").Uint16Array = function(value) {
  $throw(new UnsupportedOperationException("Cannot add to immutable List."));
}
$dynamic("forEach").Uint16Array = function(f) {
  return _Collections.forEach(this, f);
}
$dynamic("filter").Uint16Array = function(f) {
  return _Collections.filter(this, [], f);
}
$dynamic("last").Uint16Array = function() {
  return this.$index(this.length - (1));
}
$dynamic("removeLast").Uint16Array = function() {
  $throw(new UnsupportedOperationException("Cannot removeLast on immutable List."));
}
$dynamic("add$1").Uint16Array = function($0) {
  return this.add($0);
};
$dynamic("filter$1").Uint16Array = function($0) {
  return this.filter($wrap_call$1(to$call$1($0)));
};
$dynamic("forEach$1").Uint16Array = function($0) {
  return this.forEach($wrap_call$1(to$call$1($0)));
};
$dynamic("is$List").Uint32Array = function(){return true};
$dynamic("is$Collection").Uint32Array = function(){return true};
$dynamic("get$length").Uint32Array = function() { return this.length; };
$dynamic("$index").Uint32Array = function(index) {
  return this[index];
}
$dynamic("$setindex").Uint32Array = function(index, value) {
  this[index] = value
}
$dynamic("iterator").Uint32Array = function() {
  return new _FixedSizeListIterator_int(this);
}
$dynamic("add").Uint32Array = function(value) {
  $throw(new UnsupportedOperationException("Cannot add to immutable List."));
}
$dynamic("forEach").Uint32Array = function(f) {
  return _Collections.forEach(this, f);
}
$dynamic("filter").Uint32Array = function(f) {
  return _Collections.filter(this, [], f);
}
$dynamic("last").Uint32Array = function() {
  return this.$index(this.length - (1));
}
$dynamic("removeLast").Uint32Array = function() {
  $throw(new UnsupportedOperationException("Cannot removeLast on immutable List."));
}
$dynamic("add$1").Uint32Array = function($0) {
  return this.add($0);
};
$dynamic("filter$1").Uint32Array = function($0) {
  return this.filter($wrap_call$1(to$call$1($0)));
};
$dynamic("forEach$1").Uint32Array = function($0) {
  return this.forEach($wrap_call$1(to$call$1($0)));
};
$dynamic("is$List").Uint8Array = function(){return true};
$dynamic("is$Collection").Uint8Array = function(){return true};
$dynamic("get$length").Uint8Array = function() { return this.length; };
$dynamic("$index").Uint8Array = function(index) {
  return this[index];
}
$dynamic("$setindex").Uint8Array = function(index, value) {
  this[index] = value
}
$dynamic("iterator").Uint8Array = function() {
  return new _FixedSizeListIterator_int(this);
}
$dynamic("add").Uint8Array = function(value) {
  $throw(new UnsupportedOperationException("Cannot add to immutable List."));
}
$dynamic("forEach").Uint8Array = function(f) {
  return _Collections.forEach(this, f);
}
$dynamic("filter").Uint8Array = function(f) {
  return _Collections.filter(this, [], f);
}
$dynamic("last").Uint8Array = function() {
  return this.$index(this.length - (1));
}
$dynamic("removeLast").Uint8Array = function() {
  $throw(new UnsupportedOperationException("Cannot removeLast on immutable List."));
}
$dynamic("add$1").Uint8Array = function($0) {
  return this.add($0);
};
$dynamic("filter$1").Uint8Array = function($0) {
  return this.filter($wrap_call$1(to$call$1($0)));
};
$dynamic("forEach$1").Uint8Array = function($0) {
  return this.forEach($wrap_call$1(to$call$1($0)));
};
$dynamic("get$height").HTMLVideoElement = function() { return this.height; };
$dynamic("get$width").HTMLVideoElement = function() { return this.width; };
$dynamic("get$name").WebGLActiveInfo = function() { return this.name; };
$dynamic("$dom_addEventListener$3").WebSocket = function($0, $1, $2) {
  return this.addEventListener($0, $wrap_call$1(to$call$1($1)), $2);
};
$inherits(_WebSocketEventsImpl, _EventsImpl);
function _WebSocketEventsImpl() {}
$dynamic("get$x").WheelEvent = function() { return this.x; };
$dynamic("get$y").WheelEvent = function() { return this.y; };
$dynamic("get$on").DOMWindow = function() {
  return new _WindowEventsImpl(this);
}
$dynamic("get$length").DOMWindow = function() { return this.length; };
$dynamic("get$name").DOMWindow = function() { return this.name; };
$dynamic("$dom_addEventListener$3").DOMWindow = function($0, $1, $2) {
  return this.addEventListener($0, $wrap_call$1(to$call$1($1)), $2);
};
$inherits(_WindowEventsImpl, _EventsImpl);
function _WindowEventsImpl(_ptr) {
  _EventsImpl.call(this, _ptr);
}
_WindowEventsImpl.prototype.get$doubleClick = function() {
  return this._get("dblclick");
}
_WindowEventsImpl.prototype.get$mouseDown = function() {
  return this._get("mousedown");
}
_WindowEventsImpl.prototype.get$mouseMove = function() {
  return this._get("mousemove");
}
_WindowEventsImpl.prototype.get$resize = function() {
  return this._get("resize");
}
_WindowEventsImpl.prototype.get$touchCancel = function() {
  return this._get("touchcancel");
}
_WindowEventsImpl.prototype.get$touchEnd = function() {
  return this._get("touchend");
}
_WindowEventsImpl.prototype.get$touchMove = function() {
  return this._get("touchmove");
}
_WindowEventsImpl.prototype.get$touchStart = function() {
  return this._get("touchstart");
}
$inherits(_WorkerEventsImpl, _AbstractWorkerEventsImpl);
function _WorkerEventsImpl() {}
$dynamic("$dom_addEventListener$3").XMLHttpRequest = function($0, $1, $2) {
  return this.addEventListener($0, $wrap_call$1(to$call$1($1)), $2);
};
$inherits(_XMLHttpRequestEventsImpl, _EventsImpl);
function _XMLHttpRequestEventsImpl() {}
$dynamic("get$name").XMLHttpRequestException = function() { return this.name; };
$dynamic("$dom_addEventListener$3").XMLHttpRequestUpload = function($0, $1, $2) {
  return this.addEventListener($0, $wrap_call$1(to$call$1($1)), $2);
};
$inherits(_XMLHttpRequestUploadEventsImpl, _EventsImpl);
function _XMLHttpRequestUploadEventsImpl() {}
$dynamic("get$name").XPathException = function() { return this.name; };
function _AudioElementFactoryProvider() {}
function _BlobBuilderFactoryProvider() {}
function _CSSMatrixFactoryProvider() {}
function _DOMParserFactoryProvider() {}
function _DOMURLFactoryProvider() {}
function _DeprecatedPeerConnectionFactoryProvider() {}
function _EventSourceFactoryProvider() {}
function _FileReaderFactoryProvider() {}
function _FileReaderSyncFactoryProvider() {}
function _IceCandidateFactoryProvider() {}
function _MediaControllerFactoryProvider() {}
function _MediaStreamFactoryProvider() {}
function _MessageChannelFactoryProvider() {}
function _NotificationFactoryProvider() {}
function _OptionElementFactoryProvider() {}
function _PeerConnection00FactoryProvider() {}
function _SessionDescriptionFactoryProvider() {}
function _ShadowRootFactoryProvider() {}
function _SharedWorkerFactoryProvider() {}
function _SpeechGrammarFactoryProvider() {}
function _SpeechGrammarListFactoryProvider() {}
function _SpeechRecognitionFactoryProvider() {}
function _TextTrackCueFactoryProvider() {}
function _WorkerFactoryProvider() {}
function _XMLHttpRequestFactoryProvider() {}
function _XMLSerializerFactoryProvider() {}
function _XPathEvaluatorFactoryProvider() {}
function _XSLTProcessorFactoryProvider() {}
function _Collections() {}
_Collections.forEach = function(iterable, f) {
  for (var $$i = iterable.iterator(); $$i.hasNext(); ) {
    var e = $$i.next();
    f(e);
  }
}
_Collections.filter = function(source, destination, f) {
  for (var $$i = source.iterator(); $$i.hasNext(); ) {
    var e = $$i.next();
    if (f(e)) destination.add(e);
  }
  return destination;
}
function _XMLHttpRequestUtils() {}
function _MeasurementRequest() {}
_MeasurementRequest.prototype.get$value = function() { return this.value; };
_MeasurementRequest.prototype.set$value = function(value) { return this.value = value; };
function _EventFactoryProvider() {}
function _MouseEventFactoryProvider() {}
function _CSSStyleDeclarationFactoryProvider() {}
function _DocumentFragmentFactoryProvider() {}
function _SVGElementFactoryProvider() {}
function _SVGSVGElementFactoryProvider() {}
function _AudioContextFactoryProvider() {}
function _PointFactoryProvider() {}
function _WebSocketFactoryProvider() {}
function _TextFactoryProvider() {}
function _TypedArrayFactoryProvider() {}
function Testing() {}
function _Device() {}
function _VariableSizeListIterator() {}
_VariableSizeListIterator.prototype.hasNext = function() {
  return this._html_array.get$length() > this._html_pos;
}
_VariableSizeListIterator.prototype.next = function() {
  if (!this.hasNext()) {
    $throw(const$0001);
  }
  return this._html_array.$index(this._html_pos++);
}
$inherits(_FixedSizeListIterator, _VariableSizeListIterator);
function _FixedSizeListIterator() {}
_FixedSizeListIterator.prototype.hasNext = function() {
  return this._html_length > this._html_pos;
}
$inherits(_VariableSizeListIterator_dart_core_String, _VariableSizeListIterator);
function _VariableSizeListIterator_dart_core_String(array) {
  this._html_array = array;
  this._html_pos = (0);
}
$inherits(_FixedSizeListIterator_dart_core_String, _FixedSizeListIterator);
function _FixedSizeListIterator_dart_core_String(array) {
  this._html_length = array.get$length();
  _VariableSizeListIterator_dart_core_String.call(this, array);
}
$inherits(_VariableSizeListIterator_int, _VariableSizeListIterator);
function _VariableSizeListIterator_int(array) {
  this._html_array = array;
  this._html_pos = (0);
}
$inherits(_FixedSizeListIterator_int, _FixedSizeListIterator);
function _FixedSizeListIterator_int(array) {
  this._html_length = array.get$length();
  _VariableSizeListIterator_int.call(this, array);
}
$inherits(_VariableSizeListIterator_num, _VariableSizeListIterator);
function _VariableSizeListIterator_num(array) {
  this._html_array = array;
  this._html_pos = (0);
}
$inherits(_FixedSizeListIterator_num, _FixedSizeListIterator);
function _FixedSizeListIterator_num(array) {
  this._html_length = array.get$length();
  _VariableSizeListIterator_num.call(this, array);
}
$inherits(_VariableSizeListIterator_html_Node, _VariableSizeListIterator);
function _VariableSizeListIterator_html_Node(array) {
  this._html_array = array;
  this._html_pos = (0);
}
$inherits(_FixedSizeListIterator_html_Node, _FixedSizeListIterator);
function _FixedSizeListIterator_html_Node(array) {
  this._html_length = array.get$length();
  _VariableSizeListIterator_html_Node.call(this, array);
}
$inherits(_VariableSizeListIterator_html_StyleSheet, _VariableSizeListIterator);
function _VariableSizeListIterator_html_StyleSheet(array) {
  this._html_array = array;
  this._html_pos = (0);
}
$inherits(_FixedSizeListIterator_html_StyleSheet, _FixedSizeListIterator);
function _FixedSizeListIterator_html_StyleSheet(array) {
  this._html_length = array.get$length();
  _VariableSizeListIterator_html_StyleSheet.call(this, array);
}
$inherits(_VariableSizeListIterator_html_Touch, _VariableSizeListIterator);
function _VariableSizeListIterator_html_Touch(array) {
  this._html_array = array;
  this._html_pos = (0);
}
$inherits(_FixedSizeListIterator_html_Touch, _FixedSizeListIterator);
function _FixedSizeListIterator_html_Touch(array) {
  this._html_length = array.get$length();
  _VariableSizeListIterator_html_Touch.call(this, array);
}
function _Lists() {}
function get$$window() {
  return window;
}
function get$$document() {
  return document;
}
var _cachedBrowserPrefix;
var _pendingRequests;
var _pendingMeasurementFrameCallbacks;
function Util() {}
Util.pos = function(elem, x, y) {
  elem.get$style().set$left(("" + x + "PX"));
  elem.get$style().set$top(("" + y + "PX"));
}
function LogicDevice(ID, deviceType) {
  this.CloneMode = false;
  this.acc = (0);
  this.rset = (4);
  this.ID = ID;
  this.deviceType = deviceType;
  this.inputs = new Array();
  this.outputs = new Array();
  var $$list = this.deviceType.inputPins;
  for (var $$i = $$list.iterator(); $$i.hasNext(); ) {
    var devicePin = $$i.next();
    this.inputs.add(new DeviceInput(this, devicePin.id, devicePin));
  }
  var $$list = this.deviceType.outputPins;
  for (var $$i = $$list.iterator(); $$i.hasNext(); ) {
    var devicePin = $$i.next();
    this.outputs.add(new DeviceOutput(this, devicePin.id, devicePin));
  }
  this.visible = true;
}
LogicDevice.prototype.InputPinHit = function(x, y) {
  if (this.CloneMode) return null;
  var $$list = this.inputs;
  for (var $$i = $$list.iterator(); $$i.hasNext(); ) {
    var input = $$i.next();
    if (input.get$connectable()) {
      if (input.pinHit(x, y)) return input;
    }
  }
  return null;
}
LogicDevice.prototype.OutputPinHit = function(x, y) {
  if (this.CloneMode) return null;
  var $$list = this.outputs;
  for (var $$i = $$list.iterator(); $$i.hasNext(); ) {
    var output = $$i.next();
    if (output.get$connectable()) {
      if (output.pinHit(x, y)) return output;
    }
  }
  return null;
}
LogicDevice.prototype.WireHit = function(x, y) {
  var $$list = this.inputs;
  for (var $$i = $$list.iterator(); $$i.hasNext(); ) {
    var input = $$i.next();
    if (input.wireHit(x, y) != null) return input.wireHit(x, y);
  }
  return null;
}
LogicDevice.prototype.MoveDevice = function(newX, newY) {
  if ($ne$(this.deviceType.images.$index((0)))) {
    Util.pos(this.deviceType.images.$index((0)), newX.toDouble(), newY.toDouble());
    this.X = newX;
    this.Y = newY;
  }
}
LogicDevice.prototype.clicked = function() {
  switch (this.deviceType.type) {
    case "SWITCH":

      this.outputs.$index((0)).set$value(!this.outputs.$index((0)).get$value());
      this.updated = true;
      break;

  }
}
LogicDevice.prototype.contains = function(pointX, pointY) {
  if ((pointX > this.X && pointX < $add$(this.X, this.deviceType.images.$index((0)).get$width())) && (pointY > this.Y && pointY < $add$(this.Y, this.deviceType.images.$index((0)).get$height()))) {
    return true;
  }
  else {
    return false;
  }
}
LogicDevice.prototype.Calculate = function() {
  if (!this.calculated) {
    this.calculated = true;
    var $$list = this.inputs;
    for (var $$i = $$list.iterator(); $$i.hasNext(); ) {
      var input = $$i.next();
      input.updated = false;
    }
    var outputState = this.outputs.$index((0)).get$value();
    switch (this.deviceType.type) {
      case "AND":

        this.outputs.$index((0)).set$value(this.inputs.$index((0)).get$value() && this.inputs.$index((1)).get$value());
        break;

      case "NAND":

        this.outputs.$index((0)).set$value(!(this.inputs.$index((0)).get$value() && this.inputs.$index((1)).get$value()));
        break;

      case "OR":

        this.outputs.$index((0)).set$value(this.inputs.$index((0)).get$value() || this.inputs.$index((1)).get$value());
        break;

      case "NOR":

        this.outputs.$index((0)).set$value(!(this.inputs.$index((0)).get$value() || this.inputs.$index((1)).get$value()));
        break;

      case "XOR":

        this.outputs.$index((0)).set$value(($ne$(this.inputs.$index((0)).get$value(), this.inputs.$index((1)).get$value())));
        break;

      case "XNOR":

        this.outputs.$index((0)).set$value(!($ne$(this.inputs.$index((0)).get$value(), this.inputs.$index((1)).get$value())));
        break;

      case "NOT":

        this.outputs.$index((0)).set$value(!(this.inputs.$index((0)).get$value()));
        break;

      case "SWITCH":

        this.outputs.$index((0)).set$value(this.outputs.$index((0)).get$value());
        break;

      case "DLOGO":
      case "LED":

        this.outputs.$index((0)).set$value(this.inputs.$index((0)).get$value());
        break;

      case "CLOCK":

        this.CalcClock(this);
        break;

    }
    if ($ne$(outputState, this.outputs.$index((0)).get$value())) {
      this.updated = true;
    }
    var $$list = this.inputs;
    for (var $$i = $$list.iterator(); $$i.hasNext(); ) {
      var input = $$i.next();
      input.checkUpdate();
    }
  }
}
LogicDevice.prototype.CalcClock = function(device) {
  if (device.acc > device.rset) {
    device.acc = (0);
    device.outputs.$index((0)).set$value(!device.outputs.$index((0)).get$value());
    device.outputs.$index((1)).set$value(!device.outputs.$index((0)).get$value());
  }
  else device.acc = device.acc + (1);
}
function DeviceInput(device, _id, devicePin) {
  this._value = false;
  this._connectable = true;
  this.device = device;
  this._id = _id;
  this.devicePin = devicePin;
  this.set$value(false);
  this.connectedOutput = null;
  this._pinX = this.devicePin.x;
  this._pinY = this.devicePin.y;
  this.wire = new Wire();
}
DeviceInput.prototype.get$connectable = function() {
  if (this._pinX < (0)) return false;
  else return this._connectable;
}
DeviceInput.prototype.get$offsetX = function() {
  return this.device.X + this._pinX;
}
DeviceInput.prototype.get$offsetY = function() {
  return this.device.Y + this._pinY;
}
DeviceInput.prototype.addWire = function(wirePoints) {
  this.clearWire();
  for (var $$i = wirePoints.iterator(); $$i.hasNext(); ) {
    var point = $$i.next();
    this.wire.AddPoint(point.x, point.y);
  }
}
DeviceInput.prototype.clearWire = function() {
  this.wire.clear$_();
}
DeviceInput.prototype.wireHit = function(x, y) {
  if (this.wire != null && this.connectedOutput != null) {
    if (this.wire.Contains(x, y, (1))) return this.connectedOutput;
  }
  return null;
}
DeviceInput.prototype.checkUpdate = function() {
  if (this.connectedOutput != null) {
    this.updated = this.connectedOutput.device.updated;
  }
  else this.updated = false;
}
DeviceInput.prototype.get$connected = function() {
  if (this.connectedOutput != null) return true;
  else return false;
}
DeviceInput.prototype.get$value = function() {
  if (this.connectedOutput != null) {
    if (!this.connectedOutput.get$calculated()) {
      this.connectedOutput.calculate();
    }
    return this.connectedOutput.get$value();
  }
  else return false;
}
DeviceInput.prototype.set$value = function(val) {
  this._value = val;
}
DeviceInput.prototype.pinHit = function(x, y) {
  if (x <= (this.get$offsetX() + (7)) && x >= (this.get$offsetX() - (7))) {
    if (y <= (this.get$offsetY() + (7)) && y >= (this.get$offsetY() - (7))) {
      return true;
    }
  }
  return false;
}
function DeviceOutput(device, _id, devicePin) {
  this._connectable = true;
  this.device = device;
  this._id = _id;
  this.devicePin = devicePin;
  this.set$value(false);
  this._pinX = this.devicePin.x;
  this._pinY = this.devicePin.y;
}
DeviceOutput.prototype.get$connectable = function() {
  if (this._pinX < (0)) return false;
  else return this._connectable;
}
DeviceOutput.prototype.get$calculated = function() {
  return this.device.calculated;
}
DeviceOutput.prototype.calculate = function() {
  this.device.Calculate();
}
DeviceOutput.prototype.get$offsetX = function() {
  return this.device.X + this._pinX;
}
DeviceOutput.prototype.get$offsetY = function() {
  return this.device.Y + this._pinY;
}
DeviceOutput.prototype.get$value = function() {
  return this._value;
}
DeviceOutput.prototype.set$value = function(val) {
  this._value = val;
}
DeviceOutput.prototype.pinHit = function(x, y) {
  if (x <= (this.get$offsetX() + (7)) && x >= (this.get$offsetX() - (7))) {
    if (y <= (this.get$offsetY() + (7)) && y >= (this.get$offsetY() - (7))) {
      return true;
    }
  }
  return false;
}
function DevicePin(id, x, y) {
  this.id = id;
  this.x = x;
  this.y = y;
}
DevicePin.prototype.get$x = function() { return this.x; };
DevicePin.prototype.get$y = function() { return this.y; };
function LogicDeviceType(type) {
  this.updateable = false;
  this.type = type;
  this.images = new Array();
  this.inputPins = new Array();
  this.outputPins = new Array();
}
LogicDeviceType.prototype.AddInput = function(id, x, y) {
  this.inputPins.add(new DevicePin(id, x, y));
}
LogicDeviceType.prototype.AddOutput = function(id, x, y) {
  this.outputPins.add(new DevicePin(id, x, y));
}
LogicDeviceType.prototype.AddImage = function(imageSrc) {
  var _elem;
  _elem = _ElementFactoryProvider.Element$tag$factory("img");
  _elem.src = imageSrc;
  this.images.add(_elem);
}
LogicDeviceType.prototype.getImage = function(state) {
  if (this.images.get$length() == (1)) return this.images.$index((0));
  switch (state) {
    case (0):

      return this.images.$index((0));

    case (1):

      return this.images.$index((1));

    case true:

      return this.images.$index((1));

    case false:

      return this.images.$index((0));

  }
}
function LogicDeviceTypes() {
  this.deviceTypes = new Array();
  this.LoadDefaultTypes();
}
LogicDeviceTypes.prototype.AddNewType = function(type) {
  var newType = new LogicDeviceType(type);
  this.deviceTypes.add(newType);
  return newType;
}
LogicDeviceTypes.prototype.getDeviceType = function(type) {
  var $$list = this.deviceTypes;
  for (var $$i = $$list.iterator(); $$i.hasNext(); ) {
    var deviceType = $$i.next();
    if ($eq$(deviceType.type, type)) return deviceType;
  }
  return null;
}
LogicDeviceTypes.prototype.LoadDefaultTypes = function() {
  var _and = this.AddNewType("AND");
  _and.AddImage("images/and2.png");
  _and.AddInput((0), (5), (15));
  _and.AddInput((1), (5), (35));
  _and.AddOutput((0), (95), (25));
  var _nand = this.AddNewType("NAND");
  _nand.AddImage("images/nand2.png");
  _nand.AddInput((0), (5), (15));
  _nand.AddInput((1), (5), (35));
  _nand.AddOutput((0), (95), (25));
  var _switch = this.AddNewType("SWITCH");
  _switch.AddImage("images/01Switch_Low.png");
  _switch.AddImage("images/01Switch_High.png");
  _switch.AddInput((0), (-1), (-1));
  _switch.AddOutput((0), (21), (0));
  _switch.updateable = true;
  var _led = this.AddNewType("LED");
  _led.AddImage("images/01Disp_Low.png");
  _led.AddImage("images/01Disp_High.png");
  _led.AddInput((0), (16), (0));
  _led.AddOutput((0), (-1), (-1));
  _led.updateable = true;
  var _or = this.AddNewType("OR");
  _or.AddImage("images/or.png");
  _or.AddInput((0), (5), (15));
  _or.AddInput((1), (5), (35));
  _or.AddOutput((0), (95), (25));
  var _nor = this.AddNewType("NOR");
  _nor.AddImage("images/nor.png");
  _nor.AddInput((0), (5), (15));
  _nor.AddInput((1), (5), (35));
  _nor.AddOutput((0), (95), (25));
  var _xor = this.AddNewType("XOR");
  _xor.AddImage("images/xor.png");
  _xor.AddInput((0), (5), (15));
  _xor.AddInput((1), (5), (35));
  _xor.AddOutput((0), (95), (25));
  var _xnor = this.AddNewType("XNOR");
  _xnor.AddImage("images/xnor.png");
  _xnor.AddInput((0), (5), (15));
  _xnor.AddInput((1), (5), (35));
  _xnor.AddOutput((0), (95), (25));
  var _not = this.AddNewType("NOT");
  _not.AddImage("images/not.png");
  _not.AddInput((0), (5), (25));
  _not.AddOutput((0), (94), (25));
  var _clock = this.AddNewType("CLOCK");
  _clock.AddImage("images/Clock.png");
  _clock.AddInput((0), (-1), (-1));
  _clock.AddOutput((0), (64), (14));
  _clock.AddOutput((1), (64), (39));
}
function Circuit(canvas) {
  var $this = this;
  this.showGrid = false;
  this.gridSnap = false;
  this.connectionMode = "INIT";
  this.connectingOutputToInput = false;
  this.connectingInputToOutput = false;
  this.canvas = canvas;
  this.deviceTypes = new LogicDeviceTypes();
  this.logicDevices = new Array();
  this.context = this.canvas.getContext("2d");
  this._width = this.canvas.width;
  this._height = this.canvas.height;
  this.dummyWire = new Wire();
  this.validPinImage = _ElementFactoryProvider.Element$tag$factory("img");
  this.validPinImage.src = "images/SelectPinGreen.png";
  this.selectPin = _ElementFactoryProvider.Element$tag$factory("img");
  this.selectPin.src = "images/SelectPinBlack.png";
  this.startWireImage = _ElementFactoryProvider.Element$tag$factory("img");
  this.startWireImage.src = "images/SelectPinBlack.png";
  this.connectablePinImage = _ElementFactoryProvider.Element$tag$factory("img");
  this.connectablePinImage.src = "images/SelectPinPurple.png";
  get$$window().setInterval($wrap_call$0(function f() {
    return $this.tick();
  }
  ), (50));
  this.canvas.get$on().get$mouseDown().add($wrap_call$1(this.get$onMouseDown()), false);
  this.canvas.get$on().get$doubleClick().add($wrap_call$1(this.get$onMouseDoubleClick()), false);
  this.canvas.get$on().get$mouseMove().add($wrap_call$1(this.get$onMouseMove()), false);
  this.canvas.get$on().get$touchEnter().add($wrap_call$1((function (event) {
    return $this.onTouchEnter(event);
  })
  ), false);
  this.canvas.get$on().get$touchStart().add($wrap_call$1((function (event) {
    return $this.onTouchStart(event);
  })
  ), false);
  this.canvas.get$on().get$touchMove().add($wrap_call$1((function (event) {
    return $this.onTouchMove(event);
  })
  ), false);
  this.canvas.get$on().get$touchEnd().add($wrap_call$1((function (event) {
    return $this.onTouchEnd(event);
  })
  ), false);
  this.canvas.get$on().get$touchCancel().add($wrap_call$1((function (event) {
    return $this.onTouchCancel(event);
  })
  ), false);
  this.canvas.get$on().get$touchLeave().add($wrap_call$1((function (event) {
    return $this.onTouchLeave(event);
  })
  ), false);
  get$$window().get$on().get$resize().add($wrap_call$1((function (event) {
    return $this.onResize();
  })
  ), true);
}
Circuit.prototype.get$width = function() {
  return this._width;
}
Circuit.prototype.set$width = function(val) {
  this._width = val;
  this.canvas.width = val;
}
Circuit.prototype.get$height = function() {
  return this._height;
}
Circuit.prototype.set$height = function(val) {
  this._height = val;
  this.canvas.height = val;
}
Circuit.prototype.onResize = function() {
  this.set$height(get$$window().innerHeight - (25));
  this.set$width(get$$window().innerWidth - (25));
  this.Paint();
}
Circuit.prototype.start = function() {
  this.createSelectorBar();
  this.onResize();
}
Circuit.prototype.createSelectorBar = function() {
  this.addNewCloneableDevice("Clock", "CLOCK", (0), (0));
  this.addNewCloneableDevice("Switch", "SWITCH", (0), (60));
  this.addNewCloneableDevice("Not", "NOT", (0), (120));
  this.addNewCloneableDevice("And", "AND", (0), (180));
  this.addNewCloneableDevice("Nand", "NAND", (0), (240));
  this.addNewCloneableDevice("Or", "OR", (0), (300));
  this.addNewCloneableDevice("Nor", "NOR", (0), (360));
  this.addNewCloneableDevice("XOR", "XOR", (0), (420));
  this.addNewCloneableDevice("XNOR", "XNOR", (0), (480));
  this.addNewCloneableDevice("LED", "LED", (50), (60));
  this.Paint();
}
Circuit.prototype.addNewCloneableDevice = function(id, type, x, y) {
  var deviceType = this.deviceTypes.getDeviceType(type);
  if (deviceType != null) {
    var newDevice = new LogicDevice(id, deviceType);
    this.logicDevices.add(newDevice);
    newDevice.CloneMode = true;
    newDevice.MoveDevice(x, y);
    return newDevice;
  }
}
Circuit.prototype.NewDeviceFrom = function(device) {
  var newDevice = new LogicDevice(this.getNewId(), device.deviceType);
  this.logicDevices.add(newDevice);
  newDevice.MoveDevice(device.X, device.Y);
  this.connectionMode = null;
  this.moveDevice = newDevice;
}
Circuit.prototype.drawBorder = function() {
  this.context.beginPath();
  this.context.rect((115), (0), this.get$width(), this.get$height());
  this.context.fillStyle = "#eeeeee";
  this.context.lineWidth = (1);
  this.context.strokeStyle = "#eeeeee";
  this.context.fillRect((115), (0), this.get$width(), this.get$height());
  this.context.stroke();
  this.context.closePath();
}
Circuit.prototype.tick = function() {
  if (this.logicDevices.get$length() <= (0)) return;
  var $$list = this.logicDevices;
  for (var $$i = $$list.iterator(); $$i.hasNext(); ) {
    var device = $$i.next();
    device.calculated = false;
  }
  var $$list = this.logicDevices;
  for (var $$i = $$list.iterator(); $$i.hasNext(); ) {
    var device = $$i.next();
    device.Calculate();
  }
  this.Paint();
}
Circuit.prototype.getNewId = function() {
  return this.logicDevices.get$length();
}
Circuit.prototype.tryDeviceSelect = function(x, y) {
  var $$list = this.logicDevices;
  for (var $$i = $$list.iterator(); $$i.hasNext(); ) {
    var device = $$i.next();
    if (device.contains(x, y)) {
      return device;
    }
  }
  return null;
}
Circuit.prototype.tryInputSelect = function(x, y) {
  var $$list = this.logicDevices;
  for (var $$i = $$list.iterator(); $$i.hasNext(); ) {
    var device = $$i.next();
    if (device.InputPinHit(x, y) != null) {
      return device.InputPinHit(x, y);
    }
  }
  return null;
}
Circuit.prototype.tryOutputSelect = function(x, y) {
  var $$list = this.logicDevices;
  for (var $$i = $$list.iterator(); $$i.hasNext(); ) {
    var device = $$i.next();
    if (device.OutputPinHit(x, y) != null) {
      return device.OutputPinHit(x, y);
    }
  }
  return null;
}
Circuit.prototype.onTouchEnter = function(e) {
  e.preventDefault();
  e.stopPropagation();
  this._touchX = e.targetTouches.$index((0)).pageX;
  this._touchY = e.targetTouches.$index((0)).pageY;
  if ($eq$(this.connectionMode)) {
    this.selectedInput = this.tryInputSelect(this._touchX, this._touchY);
    if (this.selectedInput != null) {
      this.connectionMode = "InputSelected";
      this.Paint();
      return;
    }
    this.selectedOutput = this.tryOutputSelect(this._touchX, this._touchY);
    if (this.selectedOutput != null) {
      this.connectionMode = "OutputSelected";
      this.Paint();
      return;
    }
  }
}
Circuit.prototype.onTouchStart = function(e) {
  e.preventDefault();
  e.stopPropagation();
  this._touchX = e.targetTouches.$index((0)).pageX;
  this._touchY = e.targetTouches.$index((0)).pageY;
  var selectedDevice = this.tryDeviceSelect(this._touchX, this._touchY);
  if (selectedDevice != null) {
    if (selectedDevice.CloneMode) {
      this.NewDeviceFrom(selectedDevice);
      this.Paint();
      return;
    }
    selectedDevice.clicked();
    this.Paint();
  }
  var _selectedInput = this.tryInputSelect(this._touchX, this._touchY);
  if (_selectedInput != null) {
    this.selectedInput = _selectedInput;
    this.connectionMode = "InputSelected";
    this.StartWire(this._touchX, this._touchY);
    return;
  }
  var _selectedOutput = this.tryOutputSelect(this._touchX, this._touchY);
  if (_selectedOutput != null) {
    this.selectedOutput = _selectedOutput;
    this.connectionMode = "OutputSelected";
    this.StartWire(this._touchX, this._touchY);
    return;
  }
}
Circuit.prototype.onTouchMove = function(e) {
  e.preventDefault();
  e.stopPropagation();
  this._touchX = e.targetTouches.$index((0)).pageX;
  this._touchY = e.targetTouches.$index((0)).pageY;
  if (this.moveDevice != null) {
    if (e.targetTouches.length >= (1)) {
      this.moveDevice.MoveDevice(this._touchX, this._touchY);
      this.Paint();
      return;
    }
  }
  this.Paint();
}
Circuit.prototype.onTouchEnd = function(e) {
  e.preventDefault();
  e.stopPropagation();
  this._touchX = e.targetTouches.$index((0)).pageX;
  this._touchY = e.targetTouches.$index((0)).pageY;
  if (this.moveDevice != null) {
    this.moveDevice = null;
    this.Paint();
    return;
  }
  switch (this.connectionMode) {
    case "InputToOutput":
    case "OutputToInput":

      this.AddWirePoint(this._touchX, this._touchY);
      if (this.checkValidConnection()) {
        this.EndWire();
      }
      return;

  }
}
Circuit.prototype.onTouchCancel = function(e) {
  if (this.moveDevice != null) {
    this.moveDevice = null;
    this.Paint();
    return;
  }
}
Circuit.prototype.onTouchLeave = function(e) {
  if (this.moveDevice != null) {
    this.moveDevice = null;
    this.Paint();
    return;
  }
}
Circuit.prototype.onMouseDown = function(e) {
  e.preventDefault();
  var selectedDevice = this.tryDeviceSelect(this._mouseX, this._mouseY);
  if (selectedDevice != null) {
    print$(selectedDevice.deviceType.type);
  }
  if (this.moveDevice != null) {
    this.moveDevice = null;
    return;
  }
  switch (this.connectionMode) {
    case "InputToOutput":
    case "OutputToInput":

      this.AddWirePoint(this._mouseX, this._mouseY);
      if (this.checkValidConnection()) {
        this.EndWire();
      }
      return;

    case "InputSelected":

      this.StartWire(this._mouseX, this._mouseY);
      return;

    case "OutputSelected":

      this.StartWire(this._mouseX, this._mouseY);
      return;

    case "CloneDevice":

      this.NewDeviceFrom(this.cloneDevice);
      return;

    case null:

      var device = this.tryDeviceSelect(this._mouseX, this._mouseY);
      if (device != null) device.clicked();
      break;

  }
}
Circuit.prototype.get$onMouseDown = function() {
  return this.onMouseDown.bind(this);
}
Circuit.prototype.onMouseDoubleClick = function(e) {
  e.stopPropagation();
  e.preventDefault();
}
Circuit.prototype.get$onMouseDoubleClick = function() {
  return this.onMouseDoubleClick.bind(this);
}
Circuit.prototype.onMouseMove = function(e) {
  this._mouseX = e.offsetX;
  this._mouseY = e.offsetY;
  if (this.gridSnap) {
    var x1 = this._mouseX.toDouble() / (10).toDouble();
    var y1 = this._mouseY.toDouble() / (10).toDouble();
    this._mouseX = x1.toInt() * (10);
    this._mouseY = y1.toInt() * (10);
  }
  if (this.moveDevice != null) {
    this.moveDevice.MoveDevice(this._mouseX, this._mouseY);
    this.Paint();
    return;
  }
  switch (this.connectionMode) {
    case "OutputToInput":

      this.selectedInput = this.checkForInputPinHit(e.offsetX, e.offsetY);
      if (this.selectedInput != null) {
        this._mouseX = this.selectedInput.get$offsetX();
        this._mouseY = this.selectedInput.get$offsetY();
      }
      this.dummyWire.UpdateLast(this._mouseX, this._mouseY);
      this.Paint();
      return;

    case "InputToOutput":

      this.selectedOutput = this.checkForOutputPinHit(e.offsetX, e.offsetY);
      if (this.selectedOutput != null) {
        this._mouseX = this.selectedOutput.get$offsetX();
        this._mouseY = this.selectedOutput.get$offsetY();
      }
      else {
        this.selectedOutput = this.checkForWireHit(e.offsetX, e.offsetY);
      }
      this.dummyWire.UpdateLast(this._mouseX, this._mouseY);
      this.Paint();
      return;

    default:


  }
  this.selectedInput = this.checkForInputPinHit(e.offsetX, e.offsetY);
  if (this.selectedInput != null) {
    this.connectionMode = "InputSelected";
    this._mouseX = this.selectedInput.get$offsetX();
    this._mouseY = this.selectedInput.get$offsetY();
    this.Paint();
    return;
  }
  this.selectedOutput = this.checkForOutputPinHit(e.offsetX, e.offsetY);
  if (this.selectedOutput != null) {
    this.connectionMode = "OutputSelected";
    this._mouseX = this.selectedOutput.get$offsetX();
    this._mouseY = this.selectedOutput.get$offsetY();
    this.Paint();
    return;
  }
  this.cloneDevice = this.checkCloneableDevices(e.offsetX, e.offsetY);
  if (this.cloneDevice != null) {
    this.connectionMode = "CloneDevice";
    return;
  }
  if ($ne$(this.connectionMode)) {
    this.connectionMode = null;
    this.Paint();
  }
}
Circuit.prototype.get$onMouseMove = function() {
  return this.onMouseMove.bind(this);
}
Circuit.prototype.checkCloneableDevices = function(x, y) {
  var $$list = this.logicDevices;
  for (var $$i = $$list.iterator(); $$i.hasNext(); ) {
    var device = $$i.next();
    if (device.CloneMode) if (device.contains(x, y)) return device;
  }
}
Circuit.prototype.checkValidConnection = function() {
  if (this.selectedOutput != null && this.selectedInput != null) return true;
  return false;
}
Circuit.prototype.checkForOutputPinHit = function(x, y) {
  var $$list = this.logicDevices;
  for (var $$i = $$list.iterator(); $$i.hasNext(); ) {
    var device = $$i.next();
    if (device.OutputPinHit(x, y) != null) {
      return device.OutputPinHit(x, y);
    }
  }
}
Circuit.prototype.checkForWireHit = function(x, y) {
  var $$list = this.logicDevices;
  for (var $$i = $$list.iterator(); $$i.hasNext(); ) {
    var device = $$i.next();
    if (device.WireHit(x, y) != null) {
      return device.WireHit(x, y);
    }
  }
}
Circuit.prototype.checkForInputPinHit = function(x, y) {
  var $$list = this.logicDevices;
  for (var $$i = $$list.iterator(); $$i.hasNext(); ) {
    var device = $$i.next();
    if (device.InputPinHit(x, y) != null) {
      return device.InputPinHit(x, y);
    }
  }
}
Circuit.prototype.AddWirePoint = function(x, y) {
  this.dummyWire.AddPoint(x, y);
}
Circuit.prototype.StartWire = function(x, y) {
  this.dummyWire.clear$_();
  this.dummyWire.AddPoint(x, y);
  switch (this.connectionMode) {
    case "InputSelected":

      this.connectionMode = "InputToOutput";
      break;

    case "OutputSelected":

      this.connectionMode = "OutputToInput";
      break;

  }
  this.drawPinSelectors();
}
Circuit.prototype.EndWire = function() {
  if (this.selectedOutput == null || this.selectedInput == null) {
    this.selectedInput = null;
    this.selectedOutput = null;
    this.connectionMode = null;
    return;
  }
  this.selectedInput.connectedOutput = this.selectedOutput;
  this.selectedInput.addWire(this.dummyWire.wirePoints);
  this.selectedInput = null;
  this.selectedOutput = null;
  this.connectionMode = null;
  this.dummyWire.clear$_();
  this.Paint();
}
Circuit.prototype.Paint = function() {
  this.clearCanvas();
  this.drawBorder();
  this.drawDevices();
  this.drawWires();
  this.drawPinSelectors();
}
Circuit.prototype.clearCanvas = function() {
  this.context.clearRect((0), (0), this._width, this._height);
}
Circuit.prototype.drawDevices = function() {
  var $$list = this.logicDevices;
  for (var $$i = $$list.iterator(); $$i.hasNext(); ) {
    var device = $$i.next();
    this.context.drawImage(device.deviceType.getImage(device.outputs.$index((0)).get$value()), device.X, device.Y);
  }
}
Circuit.prototype.drawDummyWire = function(state) {
  this.context.fillStyle = this.context.strokeStyle;
  this.context.beginPath();
  this.context.lineWidth = (3);
  switch (state) {
    case "VALID":

      this.context.strokeStyle = "#009900";
      break;

    case "INVALID":

      this.context.strokeStyle = "#999999";
      break;

    case "ERASE":

      this.context.strokeStyle = "#eeeeee";
      this.context.lineWidth = (4);
      break;

    case true:

      this.context.strokeStyle = "#ff4444";
      break;

    case false:

      this.context.strokeStyle = "#550091";
      break;

    default:

      this.context.strokeStyle = "#999999";

  }
  this.context.moveTo(this.dummyWire.startX, this.dummyWire.startY);
  var $$list = this.dummyWire.wirePoints;
  for (var $$i = $$list.iterator(); $$i.hasNext(); ) {
    var wirePoint = $$i.next();
    this.context.lineTo(wirePoint.x, wirePoint.y);
  }
  this.context.lineTo(this.dummyWire.lastX, this.dummyWire.lastY);
  this.context.stroke();
  this.context.closePath();
}
Circuit.prototype.drawWire = function(input, state) {
  if (input.wire == null) return;
  this.context.fillStyle = this.context.strokeStyle;
  this.context.beginPath();
  this.context.lineWidth = (3);
  switch (state) {
    case "VALID":

      this.context.strokeStyle = "#009900";
      break;

    case "INVALID":

      this.context.strokeStyle = "#999999";
      break;

    case "ERASE":

      this.context.strokeStyle = "#eeeeee";
      this.context.lineWidth = (4);
      break;

    case false:

      this.context.strokeStyle = "#550091";
      break;

    case true:

      this.context.strokeStyle = "#ff4444";
      break;

    default:

      this.context.strokeStyle = "#999999";

  }
  this.context.fillStyle = this.context.strokeStyle;
  if (input.wire.wirePoints.get$length() >= (2)) {
    this.context.moveTo(input.wire.wirePoints.$index((0)).get$x(), input.wire.wirePoints.$index((0)).get$y());
    var $$list = input.wire.wirePoints;
    for (var $$i = $$list.iterator(); $$i.hasNext(); ) {
      var point = $$i.next();
      this.context.lineTo(point.x, point.y);
    }
  }
  if (input.wire.lastX != input.wire.wirePoints.last().get$x() || input.wire.lastY != input.wire.wirePoints.last().get$y()) {
    this.context.moveTo(input.wire.wirePoints.last().get$x(), input.wire.wirePoints.last().get$y());
    this.context.lineTo(input.wire.lastX, input.wire.lastY);
  }
  this.context.stroke();
  this.context.closePath();
  if (input.connectedOutput != null) {
    if (input.connectedOutput.get$offsetX() != input.wire.wirePoints.last().get$x() && input.connectedOutput.get$offsetY() != input.wire.wirePoints.last().get$y()) {
      this.context.beginPath();
      this.context.lineWidth = (2);
      this.context.arc(input.wire.wirePoints.$index(input.wire.wirePoints.get$length() - (1)).get$x(), input.wire.wirePoints.$index(input.wire.wirePoints.get$length() - (1)).get$y(), (5), (0), (6.283185307179586), false);
      this.context.fill();
      this.context.stroke();
      this.context.closePath();
    }
  }
}
Circuit.prototype.drawWires = function() {
  var $$list = this.logicDevices;
  for (var $$i = $$list.iterator(); $$i.hasNext(); ) {
    var device = $$i.next();
    var $list0 = device.inputs;
    for (var $i0 = $list0.iterator(); $i0.hasNext(); ) {
      var input = $i0.next();
      if (input.connectedOutput != null) {
        this.drawWire(input, input.get$value());
      }
    }
  }
  if (this.dummyWire.wirePoints.get$length() > (0)) {
    if (this.checkValidConnection()) {
      this.drawDummyWire("VALID");
    }
    else {
      this.drawDummyWire("INVAILD");
    }
  }
}
Circuit.prototype.drawPinSelectors = function() {
  switch (this.connectionMode) {
    case "InputToOutput":

      this.drawConnectableOutputPins();
      if (this.selectedOutput != null) this.drawHighlightPin(this._mouseX, this._mouseY, "VALID");
      break;

    case "OutputToInput":

      this.drawConnectableInputPins();
      if (this.selectedInput != null) this.drawHighlightPin(this._mouseX, this._mouseY, "VALID");
      break;

    case "InputSelected":

      this.drawHighlightPin(this.selectedInput.get$offsetX(), this.selectedInput.get$offsetY(), "VALID");
      break;

    case "OutputSelected":

      this.drawHighlightPin(this.selectedOutput.get$offsetX(), this.selectedOutput.get$offsetY(), "VALID");
      break;

  }
}
Circuit.prototype.drawConnectableOutputPins = function() {
  var $$list = this.logicDevices;
  for (var $$i = $$list.iterator(); $$i.hasNext(); ) {
    var device = $$i.next();
    if (device.CloneMode) continue;
    var $list0 = device.outputs;
    for (var $i0 = $list0.iterator(); $i0.hasNext(); ) {
      var output = $i0.next();
      if ($eq$(output.get$connectable(), true)) this.drawHighlightPin(output.get$offsetX(), output.get$offsetY(), "CONNECTABLE");
    }
  }
}
Circuit.prototype.drawConnectableInputPins = function() {
  var $$list = this.logicDevices;
  for (var $$i = $$list.iterator(); $$i.hasNext(); ) {
    var device = $$i.next();
    if (device.CloneMode) continue;
    var $list0 = device.inputs;
    for (var $i0 = $list0.iterator(); $i0.hasNext(); ) {
      var input = $i0.next();
      if ($eq$(input.get$connected(), false) && $eq$(input.get$connectable(), true)) this.drawHighlightPin(input.get$offsetX(), input.get$offsetY(), "CONNECTABLE");
    }
  }
}
Circuit.prototype.drawHighlightPin = function(x, y, highlightMode) {
  x = x - (5);
  y = y - (5);
  switch (highlightMode) {
    case "VALID":

      this.context.drawImage(this.validPinImage, x, y);
      break;

    case "INVALID":

      this.context.drawImage(this.validPinImage, x, y);
      break;

    case "WIRECONNECT":

      this.context.drawImage(this.startWireImage, x, y);
      break;

    case "CONNECTED":

      this.context.drawImage(this.startWireImage, x, y);
      break;

    case "CONNECTABLE":

      this.context.drawImage(this.connectablePinImage, x, y);
      break;

    default:

      this.context.drawImage(this.validPinImage, x, y);

  }
}
function WirePoint(x, y) {
  this.x = x;
  this.y = y;
}
WirePoint.prototype.get$x = function() { return this.x; };
WirePoint.prototype.get$y = function() { return this.y; };
function Wire() {
  this.drawWireEndpoint = false;
  this.wirePoints = new Array();
}
Wire.prototype.clear$_ = function() {
  this.wirePoints.clear$_();
  this.startX = null;
  this.startY = null;
  this.lastX = null;
  this.lastY = null;
}
Wire.prototype.AddPoint = function(x, y) {
  this.lastX = x;
  this.lastY = y;
  if (this.startX == null) {
    this.startX = x;
    this.startY = y;
  }
  this.wirePoints.add(new WirePoint(x, y));
}
Wire.prototype.UpdateLast = function(x, y) {
  this.lastX = x;
  this.lastY = y;
}
Wire.prototype.Contains = function(x, y, d) {
  if (this.wirePoints.get$length() >= (2)) {
    var x1, x2, x3, y1, y2, y3;
    var d1;
    x3 = x;
    y3 = y;
    for (var t = (0);
     t < this.wirePoints.get$length() - (1); t++) {
      x1 = this.wirePoints.$index(t).get$x();
      x2 = this.wirePoints.$index(t + (1)).get$x();
      y1 = this.wirePoints.$index(t).get$y();
      y2 = this.wirePoints.$index(t + (1)).get$y();
      d1 = (Math.sqrt((y3 - y1) * (y3 - y1) + (x3 - x1) * (x3 - x1)) + Math.sqrt((y3 - y2) * (y3 - y2) + (x3 - x2) * (x3 - x2))) - Math.sqrt((y2 - y1) * (y2 - y1) + (x2 - x1) * (x2 - x1));
      if ($lte$(d1, d)) {
        return true;
      }
    }
  }
  return false;
}
function main() {
  new Circuit(get$$document().query("#canvas")).start();
}
(function(){
  var v0/*HTMLMediaElement*/ = 'HTMLMediaElement|HTMLAudioElement|HTMLVideoElement';
  var v1/*SVGTextPositioningElement*/ = 'SVGTextPositioningElement|SVGAltGlyphElement|SVGTRefElement|SVGTSpanElement|SVGTextElement';
  var v2/*CharacterData*/ = 'CharacterData|Comment|Text|CDATASection';
  var v3/*HTMLDocument*/ = 'HTMLDocument|SVGDocument';
  var v4/*DocumentFragment*/ = 'DocumentFragment|ShadowRoot';
  var v5/*Element*/ = [v0/*HTMLMediaElement*/,v1/*SVGTextPositioningElement*/,'Element|HTMLElement|HTMLAnchorElement|HTMLAppletElement|HTMLAreaElement|HTMLBRElement|HTMLBaseElement|HTMLBaseFontElement|HTMLBodyElement|HTMLButtonElement|HTMLCanvasElement|HTMLContentElement|HTMLDListElement|HTMLDetailsElement|HTMLDirectoryElement|HTMLDivElement|HTMLEmbedElement|HTMLFieldSetElement|HTMLFontElement|HTMLFormElement|HTMLFrameElement|HTMLFrameSetElement|HTMLHRElement|HTMLHeadElement|HTMLHeadingElement|HTMLHtmlElement|HTMLIFrameElement|HTMLImageElement|HTMLInputElement|HTMLKeygenElement|HTMLLIElement|HTMLLabelElement|HTMLLegendElement|HTMLLinkElement|HTMLMapElement|HTMLMarqueeElement|HTMLMenuElement|HTMLMetaElement|HTMLMeterElement|HTMLModElement|HTMLOListElement|HTMLObjectElement|HTMLOptGroupElement|HTMLOptionElement|HTMLOutputElement|HTMLParagraphElement|HTMLParamElement|HTMLPreElement|HTMLProgressElement|HTMLQuoteElement|SVGElement|SVGAElement|SVGAltGlyphDefElement|SVGAltGlyphItemElement|SVGAnimationElement|SVGAnimateColorElement|SVGAnimateElement|SVGAnimateMotionElement|SVGAnimateTransformElement|SVGSetElement|SVGCircleElement|SVGClipPathElement|SVGComponentTransferFunctionElement|SVGFEFuncAElement|SVGFEFuncBElement|SVGFEFuncGElement|SVGFEFuncRElement|SVGCursorElement|SVGDefsElement|SVGDescElement|SVGEllipseElement|SVGFEBlendElement|SVGFEColorMatrixElement|SVGFEComponentTransferElement|SVGFECompositeElement|SVGFEConvolveMatrixElement|SVGFEDiffuseLightingElement|SVGFEDisplacementMapElement|SVGFEDistantLightElement|SVGFEDropShadowElement|SVGFEFloodElement|SVGFEGaussianBlurElement|SVGFEImageElement|SVGFEMergeElement|SVGFEMergeNodeElement|SVGFEMorphologyElement|SVGFEOffsetElement|SVGFEPointLightElement|SVGFESpecularLightingElement|SVGFESpotLightElement|SVGFETileElement|SVGFETurbulenceElement|SVGFilterElement|SVGFontElement|SVGFontFaceElement|SVGFontFaceFormatElement|SVGFontFaceNameElement|SVGFontFaceSrcElement|SVGFontFaceUriElement|SVGForeignObjectElement|SVGGElement|SVGGlyphElement|SVGGlyphRefElement|SVGGradientElement|SVGLinearGradientElement|SVGRadialGradientElement|SVGHKernElement|SVGImageElement|SVGLineElement|SVGMPathElement|SVGMarkerElement|SVGMaskElement|SVGMetadataElement|SVGMissingGlyphElement|SVGPathElement|SVGPatternElement|SVGPolygonElement|SVGPolylineElement|SVGRectElement|SVGSVGElement|SVGScriptElement|SVGStopElement|SVGStyleElement|SVGSwitchElement|SVGSymbolElement|SVGTextContentElement|SVGTextPathElement|SVGTitleElement|SVGUseElement|SVGVKernElement|SVGViewElement|HTMLScriptElement|HTMLSelectElement|HTMLShadowElement|HTMLSourceElement|HTMLSpanElement|HTMLStyleElement|HTMLTableCaptionElement|HTMLTableCellElement|HTMLTableColElement|HTMLTableElement|HTMLTableRowElement|HTMLTableSectionElement|HTMLTextAreaElement|HTMLTitleElement|HTMLTrackElement|HTMLUListElement|HTMLUnknownElement'].join('|');
  var v6/*AbstractWorker*/ = 'AbstractWorker|SharedWorker|Worker';
  var v7/*IDBRequest*/ = 'IDBRequest|IDBVersionChangeRequest';
  var v8/*MediaStream*/ = 'MediaStream|LocalMediaStream';
  var v9/*Node*/ = [v2/*CharacterData*/,v3/*HTMLDocument*/,v4/*DocumentFragment*/,v5/*Element*/,'Node|Attr|DocumentType|Entity|EntityReference|Notation|ProcessingInstruction'].join('|');
  var v10/*WorkerContext*/ = 'WorkerContext|DedicatedWorkerContext|SharedWorkerContext';
  var table = [
    ['AbstractWorker', v6/*AbstractWorker*/]
    , ['AudioParam', 'AudioParam|AudioGain']
    , ['CSSValueList', 'CSSValueList|WebKitCSSTransformValue|WebKitCSSFilterValue']
    , ['CharacterData', v2/*CharacterData*/]
    , ['DOMTokenList', 'DOMTokenList|DOMSettableTokenList']
    , ['HTMLDocument', v3/*HTMLDocument*/]
    , ['DocumentFragment', v4/*DocumentFragment*/]
    , ['HTMLMediaElement', v0/*HTMLMediaElement*/]
    , ['SVGTextPositioningElement', v1/*SVGTextPositioningElement*/]
    , ['Element', v5/*Element*/]
    , ['Entry', 'Entry|DirectoryEntry|FileEntry']
    , ['EntrySync', 'EntrySync|DirectoryEntrySync|FileEntrySync']
    , ['IDBRequest', v7/*IDBRequest*/]
    , ['MediaStream', v8/*MediaStream*/]
    , ['Node', v9/*Node*/]
    , ['WorkerContext', v10/*WorkerContext*/]
    , ['EventTarget', [v6/*AbstractWorker*/,v7/*IDBRequest*/,v8/*MediaStream*/,v9/*Node*/,v10/*WorkerContext*/,'EventTarget|AudioContext|BatteryManager|DOMApplicationCache|DeprecatedPeerConnection|EventSource|FileReader|FileWriter|IDBDatabase|IDBTransaction|MediaController|MessagePort|Notification|PeerConnection00|SpeechRecognition|TextTrack|TextTrackCue|TextTrackList|WebSocket|DOMWindow|XMLHttpRequest|XMLHttpRequestUpload'].join('|')]
    , ['HTMLCollection', 'HTMLCollection|HTMLOptionsCollection']
    , ['Uint8Array', 'Uint8Array|Uint8ClampedArray']
  ];
  $dynamicSetMetadata(table);
})();
function $static_init(){
}
var const$0000 = Object.create(_DeletedKeySentinel.prototype, {});
var const$0001 = Object.create(NoMoreElementsException.prototype, {});
var const$0002 = Object.create(EmptyQueueException.prototype, {});
var const$0003 = Object.create(UnsupportedOperationException.prototype, {_message: {"value": "", writeable: false}});
var const$0004 = new JSSyntaxRegExp("^#[_a-zA-Z]\\w*$");
$static_init();
if (typeof window != 'undefined' && typeof document != 'undefined' &&
    window.addEventListener && document.readyState == 'loading') {
  window.addEventListener('DOMContentLoaded', function(e) {
    main();
  });
} else {
  main();
}
