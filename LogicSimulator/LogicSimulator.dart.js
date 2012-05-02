//  ********** Library dart:core **************
//  ********** Natives dart:core **************
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
// ********** Code for Object **************
$defProp(Object.prototype, "is$Collection", function() {
  return false;
});
$defProp(Object.prototype, "is$List", function() {
  return false;
});
$defProp(Object.prototype, "is$Map", function() {
  return false;
});
// ********** Code for IndexOutOfRangeException **************
function IndexOutOfRangeException(_index) {
  this._index = _index;
}
IndexOutOfRangeException.prototype.is$IndexOutOfRangeException = function(){return true};
IndexOutOfRangeException.prototype.toString = function() {
  return ("IndexOutOfRangeException: " + this._index);
}
// ********** Code for NoSuchMethodException **************
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
// ********** Code for ClosureArgumentMismatchException **************
function ClosureArgumentMismatchException() {

}
ClosureArgumentMismatchException.prototype.toString = function() {
  return "Closure argument mismatch";
}
// ********** Code for IllegalArgumentException **************
function IllegalArgumentException(arg) {
  this._arg = arg;
}
IllegalArgumentException.prototype.is$IllegalArgumentException = function(){return true};
IllegalArgumentException.prototype.toString = function() {
  return ("Illegal argument(s): " + this._arg);
}
// ********** Code for NoMoreElementsException **************
function NoMoreElementsException() {

}
NoMoreElementsException.prototype.toString = function() {
  return "NoMoreElementsException";
}
// ********** Code for UnsupportedOperationException **************
function UnsupportedOperationException(_message) {
  this._message = _message;
}
UnsupportedOperationException.prototype.toString = function() {
  return ("UnsupportedOperationException: " + this._message);
}
// ********** Code for dart_core_Function **************
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
// ********** Code for Math **************
// ********** Code for top level **************
//  ********** Library dart:coreimpl **************
// ********** Code for ListFactory **************
var ListFactory = Array;
$defProp(ListFactory.prototype, "is$List", function(){return true});
$defProp(ListFactory.prototype, "is$Collection", function(){return true});
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
// ********** Code for ListIterator **************
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
// ********** Code for JSSyntaxRegExp **************
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
JSSyntaxRegExp.prototype.hasMatch = function(str) {
  return this.re.test(str);
}
// ********** Code for NumImplementation **************
var NumImplementation = Number;
NumImplementation.prototype.abs = function() {
  'use strict'; return Math.abs(this);
}
NumImplementation.prototype.toDouble = function() {
  'use strict'; return this + 0;
}
// ********** Code for Collections **************
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
// ********** Code for HashMapImplementation **************
function HashMapImplementation() {}
HashMapImplementation.prototype.is$Map = function(){return true};
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
// ********** Code for HashSetImplementation **************
function HashSetImplementation() {}
HashSetImplementation.prototype.is$Collection = function(){return true};
HashSetImplementation.prototype.forEach = function(f) {
  this._backingMap.forEach(function _(key, value) {
    f(key);
  }
  );
}
HashSetImplementation.prototype.iterator = function() {
  return new HashSetIterator(this);
}
HashSetImplementation.prototype.toString = function() {
  return Collections.collectionToString(this);
}
// ********** Code for HashSetIterator **************
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
// ********** Code for _DeletedKeySentinel **************
function _DeletedKeySentinel() {

}
// ********** Code for Maps **************
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
  m.forEach((function (k, v) {
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
// ********** Code for DoubleLinkedQueue **************
function DoubleLinkedQueue() {}
DoubleLinkedQueue.prototype.is$Collection = function(){return true};
DoubleLinkedQueue.prototype.forEach = function(f) {
  var entry = this._sentinel._next;
  while ((null == entry ? null != (this._sentinel) : entry !== this._sentinel)) {
    var nextEntry = entry._next;
    f(entry._element);
    entry = nextEntry;
  }
}
DoubleLinkedQueue.prototype.iterator = function() {
  return new _DoubleLinkedQueueIterator(this._sentinel);
}
DoubleLinkedQueue.prototype.toString = function() {
  return Collections.collectionToString(this);
}
// ********** Code for _DoubleLinkedQueueIterator **************
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
// ********** Code for StringBufferImpl **************
function StringBufferImpl(content) {
  this.clear$_();
  this.add(content);
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
// ********** Code for StringBase **************
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
// ********** Code for StringImplementation **************
var StringImplementation = String;
StringImplementation.prototype.isEmpty = function() {
  return this.length == (0);
}
// ********** Code for DateImplementation **************
DateImplementation.now$ctor = function() {
  this.timeZone = new TimeZoneImplementation.local$ctor();
  this.value = DateImplementation._now();
  this._asJs();
}
DateImplementation.now$ctor.prototype = DateImplementation.prototype;
function DateImplementation() {}
DateImplementation.prototype.get$value = function() { return this.value; };
DateImplementation.prototype.get$timeZone = function() { return this.timeZone; };
DateImplementation.prototype.$eq = function(other) {
  if (!((other instanceof DateImplementation))) return false;
  return (this.value == other.get$value()) && ($eq$(this.timeZone, other.get$timeZone()));
}
DateImplementation.prototype.get$year = function() {
  return this.isUtc() ? this._asJs().getUTCFullYear() :
      this._asJs().getFullYear();
}
DateImplementation.prototype.get$month = function() {
  return this.isUtc() ? this._asJs().getUTCMonth() + 1 :
        this._asJs().getMonth() + 1;
}
DateImplementation.prototype.get$day = function() {
  return this.isUtc() ? this._asJs().getUTCDate() :
        this._asJs().getDate();
}
DateImplementation.prototype.get$hours = function() {
  return this.isUtc() ? this._asJs().getUTCHours() :
        this._asJs().getHours();
}
DateImplementation.prototype.get$minutes = function() {
  return this.isUtc() ? this._asJs().getUTCMinutes() :
        this._asJs().getMinutes();
}
DateImplementation.prototype.get$seconds = function() {
  return this.isUtc() ? this._asJs().getUTCSeconds() :
        this._asJs().getSeconds();
}
DateImplementation.prototype.get$milliseconds = function() {
  return this.isUtc() ? this._asJs().getUTCMilliseconds() :
      this._asJs().getMilliseconds();
}
DateImplementation.prototype.isUtc = function() {
  return this.timeZone.isUtc;
}
DateImplementation.prototype.get$isUtc = function() {
  return this.isUtc.bind(this);
}
DateImplementation.prototype.toString = function() {
  function fourDigits(n) {
    var absN = n.abs();
    var sign = n < (0) ? "-" : "";
    if (absN >= (1000)) return ("" + n);
    if (absN >= (100)) return ("" + sign + "0" + absN);
    if (absN >= (10)) return ("" + sign + "00" + absN);
    if (absN >= (1)) return ("" + sign + "000" + absN);
  }
  function threeDigits(n) {
    if (n >= (100)) return ("" + n);
    if (n > (10)) return ("0" + n);
    return ("00" + n);
  }
  function twoDigits(n) {
    if (n >= (10)) return ("" + n);
    return ("0" + n);
  }
  var y = fourDigits(this.get$year());
  var m = twoDigits(this.get$month());
  var d = twoDigits(this.get$day());
  var h = twoDigits(this.get$hours());
  var min = twoDigits(this.get$minutes());
  var sec = twoDigits(this.get$seconds());
  var ms = threeDigits(this.get$milliseconds());
  if (this.timeZone.isUtc) {
    return ("" + y + "-" + m + "-" + d + " " + h + ":" + min + ":" + sec + "." + ms + "Z");
  }
  else {
    return ("" + y + "-" + m + "-" + d + " " + h + ":" + min + ":" + sec + "." + ms);
  }
}
DateImplementation._now = function() {
  return new Date().valueOf();
}
DateImplementation.prototype._asJs = function() {
    if (!this.date) {
      this.date = new Date(this.value);
    }
    return this.date;
}
// ********** Code for TimeZoneImplementation **************
TimeZoneImplementation.local$ctor = function() {
  this.isUtc = false;
}
TimeZoneImplementation.local$ctor.prototype = TimeZoneImplementation.prototype;
function TimeZoneImplementation() {}
TimeZoneImplementation.prototype.$eq = function(other) {
  if (!((other instanceof TimeZoneImplementation))) return false;
  return $eq$(this.isUtc, other.get$isUtc());
}
TimeZoneImplementation.prototype.toString = function() {
  if (this.isUtc) return "TimeZone (UTC)";
  return "TimeZone (Local)";
}
TimeZoneImplementation.prototype.get$isUtc = function() { return this.isUtc; };
// ********** Code for _ArgumentMismatchException **************
$inherits(_ArgumentMismatchException, ClosureArgumentMismatchException);
function _ArgumentMismatchException(_message) {
  this._dart_coreimpl_message = _message;
  ClosureArgumentMismatchException.call(this);
}
_ArgumentMismatchException.prototype.toString = function() {
  return ("Closure argument mismatch: " + this._dart_coreimpl_message);
}
// ********** Code for _FunctionImplementation **************
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
// ********** Code for top level **************
//  ********** Library html **************
// ********** Code for _EventTargetImpl **************
// ********** Code for _NodeImpl **************
$dynamic("set$text").Node = function(value) {
  this.textContent = value;
}
// ********** Code for _ElementImpl **************
$dynamic("get$on").Element = function() {
  return new _ElementEventsImpl(this);
}
$dynamic("get$style").Element = function() { return this.style; };
// ********** Code for _HTMLElementImpl **************
// ********** Code for _AbstractWorkerImpl **************
// ********** Code for _AnchorElementImpl **************
// ********** Code for _AnimationImpl **************
// ********** Code for _EventImpl **************
// ********** Code for _AnimationEventImpl **************
// ********** Code for _AnimationListImpl **************
// ********** Code for _AppletElementImpl **************
$dynamic("get$height").HTMLAppletElement = function() { return this.height; };
$dynamic("get$width").HTMLAppletElement = function() { return this.width; };
// ********** Code for _AreaElementImpl **************
// ********** Code for _ArrayBufferImpl **************
// ********** Code for _ArrayBufferViewImpl **************
// ********** Code for _AttrImpl **************
$dynamic("get$value").Attr = function() { return this.value; };
$dynamic("set$value").Attr = function(value) { return this.value = value; };
// ********** Code for _AudioBufferImpl **************
// ********** Code for _AudioNodeImpl **************
// ********** Code for _AudioSourceNodeImpl **************
// ********** Code for _AudioBufferSourceNodeImpl **************
// ********** Code for _AudioChannelMergerImpl **************
// ********** Code for _AudioChannelSplitterImpl **************
// ********** Code for _AudioContextImpl **************
// ********** Code for _AudioDestinationNodeImpl **************
// ********** Code for _MediaElementImpl **************
$dynamic("get$on").HTMLMediaElement = function() {
  return new _MediaElementEventsImpl(this);
}
// ********** Code for _AudioElementImpl **************
// ********** Code for _AudioParamImpl **************
$dynamic("get$value").AudioParam = function() { return this.value; };
$dynamic("set$value").AudioParam = function(value) { return this.value = value; };
// ********** Code for _AudioGainImpl **************
// ********** Code for _AudioGainNodeImpl **************
// ********** Code for _AudioListenerImpl **************
// ********** Code for _AudioPannerNodeImpl **************
// ********** Code for _AudioProcessingEventImpl **************
// ********** Code for _BRElementImpl **************
// ********** Code for _BarInfoImpl **************
// ********** Code for _BaseElementImpl **************
// ********** Code for _BaseFontElementImpl **************
// ********** Code for _BatteryManagerImpl **************
// ********** Code for _BeforeLoadEventImpl **************
// ********** Code for _BiquadFilterNodeImpl **************
// ********** Code for _BlobImpl **************
// ********** Code for _BlobBuilderImpl **************
// ********** Code for _BodyElementImpl **************
$dynamic("get$on").HTMLBodyElement = function() {
  return new _BodyElementEventsImpl(this);
}
// ********** Code for _EventsImpl **************
function _EventsImpl(_ptr) {
  this._ptr = _ptr;
}
_EventsImpl.prototype._get = function(type) {
  return new _EventListenerListImpl(this._ptr, type);
}
// ********** Code for _ElementEventsImpl **************
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
// ********** Code for _BodyElementEventsImpl **************
$inherits(_BodyElementEventsImpl, _ElementEventsImpl);
function _BodyElementEventsImpl(_ptr) {
  _ElementEventsImpl.call(this, _ptr);
}
// ********** Code for _ButtonElementImpl **************
$dynamic("get$value").HTMLButtonElement = function() { return this.value; };
$dynamic("set$value").HTMLButtonElement = function(value) { return this.value = value; };
// ********** Code for _CharacterDataImpl **************
// ********** Code for _TextImpl **************
// ********** Code for _CDATASectionImpl **************
// ********** Code for _CSSRuleImpl **************
// ********** Code for _CSSCharsetRuleImpl **************
// ********** Code for _CSSFontFaceRuleImpl **************
// ********** Code for _CSSImportRuleImpl **************
// ********** Code for _CSSKeyframeRuleImpl **************
// ********** Code for _CSSKeyframesRuleImpl **************
// ********** Code for _CSSMatrixImpl **************
// ********** Code for _CSSMediaRuleImpl **************
// ********** Code for _CSSPageRuleImpl **************
// ********** Code for _CSSValueImpl **************
// ********** Code for _CSSPrimitiveValueImpl **************
// ********** Code for _CSSRuleListImpl **************
// ********** Code for _CSSStyleDeclarationImpl **************
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
// ********** Code for _CSSStyleRuleImpl **************
// ********** Code for _StyleSheetImpl **************
// ********** Code for _CSSStyleSheetImpl **************
// ********** Code for _CSSValueListImpl **************
// ********** Code for _CSSTransformValueImpl **************
// ********** Code for _CSSUnknownRuleImpl **************
// ********** Code for _CanvasElementImpl **************
$dynamic("get$height").HTMLCanvasElement = function() { return this.height; };
$dynamic("get$width").HTMLCanvasElement = function() { return this.width; };
// ********** Code for _CanvasGradientImpl **************
// ********** Code for _CanvasPatternImpl **************
// ********** Code for _CanvasPixelArrayImpl **************
$dynamic("is$List").CanvasPixelArray = function(){return true};
$dynamic("is$Collection").CanvasPixelArray = function(){return true};
$dynamic("get$length").CanvasPixelArray = function() { return this.length; };
$dynamic("$index").CanvasPixelArray = function(index) {
  return this[index];
}
$dynamic("iterator").CanvasPixelArray = function() {
  return new _FixedSizeListIterator_int(this);
}
$dynamic("add").CanvasPixelArray = function(value) {
  $throw(new UnsupportedOperationException("Cannot add to immutable List."));
}
$dynamic("forEach").CanvasPixelArray = function(f) {
  return _Collections.forEach(this, f);
}
$dynamic("last").CanvasPixelArray = function() {
  return this.$index(this.length - (1));
}
$dynamic("removeLast").CanvasPixelArray = function() {
  $throw(new UnsupportedOperationException("Cannot removeLast on immutable List."));
}
// ********** Code for _CanvasRenderingContextImpl **************
// ********** Code for _CanvasRenderingContext2DImpl **************
// ********** Code for _ClientRectImpl **************
$dynamic("get$height").ClientRect = function() { return this.height; };
$dynamic("get$width").ClientRect = function() { return this.width; };
// ********** Code for _ClientRectListImpl **************
// ********** Code for _ClipboardImpl **************
// ********** Code for _CloseEventImpl **************
// ********** Code for _CommentImpl **************
// ********** Code for _UIEventImpl **************
// ********** Code for _CompositionEventImpl **************
// ********** Code for _ContentElementImpl **************
// ********** Code for _ConvolverNodeImpl **************
// ********** Code for _CoordinatesImpl **************
// ********** Code for _CounterImpl **************
// ********** Code for _CryptoImpl **************
// ********** Code for _CustomEventImpl **************
// ********** Code for _DListElementImpl **************
// ********** Code for _DOMApplicationCacheImpl **************
// ********** Code for _DOMExceptionImpl **************
// ********** Code for _DOMFileSystemImpl **************
// ********** Code for _DOMFileSystemSyncImpl **************
// ********** Code for _DOMFormDataImpl **************
// ********** Code for _DOMImplementationImpl **************
// ********** Code for _DOMMimeTypeImpl **************
// ********** Code for _DOMMimeTypeArrayImpl **************
// ********** Code for _DOMParserImpl **************
// ********** Code for _DOMPluginImpl **************
// ********** Code for _DOMPluginArrayImpl **************
// ********** Code for _DOMSelectionImpl **************
// ********** Code for _DOMTokenListImpl **************
// ********** Code for _DOMSettableTokenListImpl **************
$dynamic("get$value").DOMSettableTokenList = function() { return this.value; };
$dynamic("set$value").DOMSettableTokenList = function(value) { return this.value = value; };
// ********** Code for _DOMURLImpl **************
// ********** Code for _DataTransferItemImpl **************
// ********** Code for _DataTransferItemListImpl **************
// ********** Code for _DataViewImpl **************
// ********** Code for _DatabaseImpl **************
// ********** Code for _DatabaseSyncImpl **************
// ********** Code for _WorkerContextImpl **************
// ********** Code for _DedicatedWorkerContextImpl **************
// ********** Code for _DelayNodeImpl **************
// ********** Code for _DeprecatedPeerConnectionImpl **************
// ********** Code for _DetailsElementImpl **************
// ********** Code for _DeviceMotionEventImpl **************
// ********** Code for _DeviceOrientationEventImpl **************
// ********** Code for _DirectoryElementImpl **************
// ********** Code for _EntryImpl **************
// ********** Code for _DirectoryEntryImpl **************
// ********** Code for _EntrySyncImpl **************
// ********** Code for _DirectoryEntrySyncImpl **************
// ********** Code for _DirectoryReaderImpl **************
// ********** Code for _DirectoryReaderSyncImpl **************
// ********** Code for _DivElementImpl **************
// ********** Code for _DocumentImpl **************
$dynamic("get$on").HTMLDocument = function() {
  return new _DocumentEventsImpl(this);
}
$dynamic("query").HTMLDocument = function(selectors) {
  if (const$0002.hasMatch(selectors)) {
    return this.getElementById(selectors.substring((1)));
  }
  return this.$dom_querySelector(selectors);
}
$dynamic("$dom_querySelector").HTMLDocument = function(selectors) {
  return this.querySelector(selectors);
}
// ********** Code for _DocumentEventsImpl **************
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
// ********** Code for _DocumentFragmentImpl **************
$dynamic("get$style").DocumentFragment = function() {
  return _ElementFactoryProvider.Element$tag$factory("div").get$style();
}
$dynamic("get$on").DocumentFragment = function() {
  return new _ElementEventsImpl(this);
}
// ********** Code for _DocumentTypeImpl **************
// ********** Code for _DynamicsCompressorNodeImpl **************
// ********** Code for _EXTTextureFilterAnisotropicImpl **************
// ********** Code for _ElementFactoryProvider **************
function _ElementFactoryProvider() {}
_ElementFactoryProvider.Element$tag$factory = function(tag) {
  return document.createElement(tag)
}
// ********** Code for _ElementTimeControlImpl **************
// ********** Code for _ElementTraversalImpl **************
// ********** Code for _EmbedElementImpl **************
$dynamic("get$height").HTMLEmbedElement = function() { return this.height; };
$dynamic("get$width").HTMLEmbedElement = function() { return this.width; };
// ********** Code for _EntityImpl **************
// ********** Code for _EntityReferenceImpl **************
// ********** Code for _EntryArrayImpl **************
// ********** Code for _EntryArraySyncImpl **************
// ********** Code for _ErrorEventImpl **************
// ********** Code for _EventExceptionImpl **************
// ********** Code for _EventSourceImpl **************
// ********** Code for _EventListenerListImpl **************
function _EventListenerListImpl(_ptr, _type) {
  this._ptr = _ptr;
  this._type = _type;
}
_EventListenerListImpl.prototype.add = function(listener, useCapture) {
  this._add(listener, useCapture);
  return this;
}
_EventListenerListImpl.prototype._add = function(listener, useCapture) {
  this._ptr.addEventListener(this._type, listener, useCapture);
}
// ********** Code for _FieldSetElementImpl **************
// ********** Code for _FileImpl **************
// ********** Code for _FileEntryImpl **************
// ********** Code for _FileEntrySyncImpl **************
// ********** Code for _FileErrorImpl **************
// ********** Code for _FileExceptionImpl **************
// ********** Code for _FileListImpl **************
// ********** Code for _FileReaderImpl **************
// ********** Code for _FileReaderSyncImpl **************
// ********** Code for _FileWriterImpl **************
// ********** Code for _FileWriterSyncImpl **************
// ********** Code for _Float32ArrayImpl **************
$dynamic("is$List").Float32Array = function(){return true};
$dynamic("is$Collection").Float32Array = function(){return true};
$dynamic("get$length").Float32Array = function() { return this.length; };
$dynamic("$index").Float32Array = function(index) {
  return this[index];
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
$dynamic("last").Float32Array = function() {
  return this.$index(this.length - (1));
}
$dynamic("removeLast").Float32Array = function() {
  $throw(new UnsupportedOperationException("Cannot removeLast on immutable List."));
}
// ********** Code for _Float64ArrayImpl **************
$dynamic("is$List").Float64Array = function(){return true};
$dynamic("is$Collection").Float64Array = function(){return true};
$dynamic("get$length").Float64Array = function() { return this.length; };
$dynamic("$index").Float64Array = function(index) {
  return this[index];
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
$dynamic("last").Float64Array = function() {
  return this.$index(this.length - (1));
}
$dynamic("removeLast").Float64Array = function() {
  $throw(new UnsupportedOperationException("Cannot removeLast on immutable List."));
}
// ********** Code for _FontElementImpl **************
// ********** Code for _FormElementImpl **************
// ********** Code for _FrameElementImpl **************
$dynamic("get$height").HTMLFrameElement = function() { return this.height; };
$dynamic("get$width").HTMLFrameElement = function() { return this.width; };
// ********** Code for _FrameSetElementImpl **************
$dynamic("get$on").HTMLFrameSetElement = function() {
  return new _FrameSetElementEventsImpl(this);
}
// ********** Code for _FrameSetElementEventsImpl **************
$inherits(_FrameSetElementEventsImpl, _ElementEventsImpl);
function _FrameSetElementEventsImpl(_ptr) {
  _ElementEventsImpl.call(this, _ptr);
}
// ********** Code for _GeolocationImpl **************
// ********** Code for _GeopositionImpl **************
// ********** Code for _HRElementImpl **************
$dynamic("get$width").HTMLHRElement = function() { return this.width; };
// ********** Code for _HTMLAllCollectionImpl **************
// ********** Code for _HTMLCollectionImpl **************
$dynamic("is$List").HTMLCollection = function(){return true};
$dynamic("is$Collection").HTMLCollection = function(){return true};
$dynamic("get$length").HTMLCollection = function() { return this.length; };
$dynamic("$index").HTMLCollection = function(index) {
  return this[index];
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
$dynamic("last").HTMLCollection = function() {
  return this.$index(this.get$length() - (1));
}
$dynamic("removeLast").HTMLCollection = function() {
  $throw(new UnsupportedOperationException("Cannot removeLast on immutable List."));
}
// ********** Code for _HTMLOptionsCollectionImpl **************
$dynamic("get$length").HTMLOptionsCollection = function() {
  return this.length;
}
// ********** Code for _HashChangeEventImpl **************
// ********** Code for _HeadElementImpl **************
// ********** Code for _HeadingElementImpl **************
// ********** Code for _HistoryImpl **************
// ********** Code for _HtmlElementImpl **************
// ********** Code for _IDBAnyImpl **************
// ********** Code for _IDBCursorImpl **************
// ********** Code for _IDBCursorWithValueImpl **************
$dynamic("get$value").IDBCursorWithValue = function() { return this.value; };
// ********** Code for _IDBDatabaseImpl **************
// ********** Code for _IDBDatabaseExceptionImpl **************
// ********** Code for _IDBFactoryImpl **************
// ********** Code for _IDBIndexImpl **************
// ********** Code for _IDBKeyImpl **************
// ********** Code for _IDBKeyRangeImpl **************
// ********** Code for _IDBObjectStoreImpl **************
// ********** Code for _IDBRequestImpl **************
// ********** Code for _IDBTransactionImpl **************
// ********** Code for _IDBVersionChangeEventImpl **************
// ********** Code for _IDBVersionChangeRequestImpl **************
// ********** Code for _IFrameElementImpl **************
$dynamic("get$height").HTMLIFrameElement = function() { return this.height; };
$dynamic("get$width").HTMLIFrameElement = function() { return this.width; };
// ********** Code for _IceCandidateImpl **************
// ********** Code for _ImageDataImpl **************
$dynamic("get$height").ImageData = function() { return this.height; };
$dynamic("get$width").ImageData = function() { return this.width; };
// ********** Code for _ImageElementImpl **************
$dynamic("get$height").HTMLImageElement = function() { return this.height; };
$dynamic("get$width").HTMLImageElement = function() { return this.width; };
$dynamic("get$x").HTMLImageElement = function() { return this.x; };
$dynamic("get$y").HTMLImageElement = function() { return this.y; };
// ********** Code for _InputElementImpl **************
$dynamic("get$on").HTMLInputElement = function() {
  return new _InputElementEventsImpl(this);
}
$dynamic("get$value").HTMLInputElement = function() { return this.value; };
$dynamic("set$value").HTMLInputElement = function(value) { return this.value = value; };
// ********** Code for _InputElementEventsImpl **************
$inherits(_InputElementEventsImpl, _ElementEventsImpl);
function _InputElementEventsImpl(_ptr) {
  _ElementEventsImpl.call(this, _ptr);
}
// ********** Code for _Int16ArrayImpl **************
$dynamic("is$List").Int16Array = function(){return true};
$dynamic("is$Collection").Int16Array = function(){return true};
$dynamic("get$length").Int16Array = function() { return this.length; };
$dynamic("$index").Int16Array = function(index) {
  return this[index];
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
$dynamic("last").Int16Array = function() {
  return this.$index(this.length - (1));
}
$dynamic("removeLast").Int16Array = function() {
  $throw(new UnsupportedOperationException("Cannot removeLast on immutable List."));
}
// ********** Code for _Int32ArrayImpl **************
$dynamic("is$List").Int32Array = function(){return true};
$dynamic("is$Collection").Int32Array = function(){return true};
$dynamic("get$length").Int32Array = function() { return this.length; };
$dynamic("$index").Int32Array = function(index) {
  return this[index];
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
$dynamic("last").Int32Array = function() {
  return this.$index(this.length - (1));
}
$dynamic("removeLast").Int32Array = function() {
  $throw(new UnsupportedOperationException("Cannot removeLast on immutable List."));
}
// ********** Code for _Int8ArrayImpl **************
$dynamic("is$List").Int8Array = function(){return true};
$dynamic("is$Collection").Int8Array = function(){return true};
$dynamic("get$length").Int8Array = function() { return this.length; };
$dynamic("$index").Int8Array = function(index) {
  return this[index];
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
$dynamic("last").Int8Array = function() {
  return this.$index(this.length - (1));
}
$dynamic("removeLast").Int8Array = function() {
  $throw(new UnsupportedOperationException("Cannot removeLast on immutable List."));
}
// ********** Code for _JavaScriptAudioNodeImpl **************
// ********** Code for _JavaScriptCallFrameImpl **************
// ********** Code for _KeyboardEventImpl **************
// ********** Code for _KeygenElementImpl **************
// ********** Code for _LIElementImpl **************
$dynamic("get$value").HTMLLIElement = function() { return this.value; };
$dynamic("set$value").HTMLLIElement = function(value) { return this.value = value; };
// ********** Code for _LabelElementImpl **************
// ********** Code for _LegendElementImpl **************
// ********** Code for _LinkElementImpl **************
// ********** Code for _MediaStreamImpl **************
// ********** Code for _LocalMediaStreamImpl **************
// ********** Code for _LocationImpl **************
// ********** Code for _MapElementImpl **************
// ********** Code for _MarqueeElementImpl **************
$dynamic("get$height").HTMLMarqueeElement = function() { return this.height; };
$dynamic("get$width").HTMLMarqueeElement = function() { return this.width; };
// ********** Code for _MediaControllerImpl **************
// ********** Code for _MediaElementEventsImpl **************
$inherits(_MediaElementEventsImpl, _ElementEventsImpl);
function _MediaElementEventsImpl(_ptr) {
  _ElementEventsImpl.call(this, _ptr);
}
// ********** Code for _MediaElementAudioSourceNodeImpl **************
// ********** Code for _MediaErrorImpl **************
// ********** Code for _MediaKeyErrorImpl **************
// ********** Code for _MediaKeyEventImpl **************
// ********** Code for _MediaListImpl **************
$dynamic("is$List").MediaList = function(){return true};
$dynamic("is$Collection").MediaList = function(){return true};
$dynamic("get$length").MediaList = function() { return this.length; };
$dynamic("$index").MediaList = function(index) {
  return this[index];
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
$dynamic("last").MediaList = function() {
  return this.$index(this.length - (1));
}
$dynamic("removeLast").MediaList = function() {
  $throw(new UnsupportedOperationException("Cannot removeLast on immutable List."));
}
// ********** Code for _MediaQueryListImpl **************
// ********** Code for _MediaQueryListListenerImpl **************
// ********** Code for _MediaStreamEventImpl **************
// ********** Code for _MediaStreamListImpl **************
// ********** Code for _MediaStreamTrackImpl **************
// ********** Code for _MediaStreamTrackListImpl **************
// ********** Code for _MemoryInfoImpl **************
// ********** Code for _MenuElementImpl **************
// ********** Code for _MessageChannelImpl **************
// ********** Code for _MessageEventImpl **************
// ********** Code for _MessagePortImpl **************
// ********** Code for _MetaElementImpl **************
// ********** Code for _MetadataImpl **************
// ********** Code for _MeterElementImpl **************
$dynamic("get$value").HTMLMeterElement = function() { return this.value; };
$dynamic("set$value").HTMLMeterElement = function(value) { return this.value = value; };
// ********** Code for _ModElementImpl **************
// ********** Code for _MouseEventImpl **************
$dynamic("get$x").MouseEvent = function() { return this.x; };
$dynamic("get$y").MouseEvent = function() { return this.y; };
// ********** Code for _MutationCallbackImpl **************
// ********** Code for _MutationEventImpl **************
// ********** Code for _MutationRecordImpl **************
// ********** Code for _NamedNodeMapImpl **************
$dynamic("is$List").NamedNodeMap = function(){return true};
$dynamic("is$Collection").NamedNodeMap = function(){return true};
$dynamic("get$length").NamedNodeMap = function() { return this.length; };
$dynamic("$index").NamedNodeMap = function(index) {
  return this[index];
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
$dynamic("last").NamedNodeMap = function() {
  return this.$index(this.length - (1));
}
$dynamic("removeLast").NamedNodeMap = function() {
  $throw(new UnsupportedOperationException("Cannot removeLast on immutable List."));
}
// ********** Code for _NavigatorImpl **************
// ********** Code for _NavigatorUserMediaErrorImpl **************
// ********** Code for _NodeFilterImpl **************
// ********** Code for _NodeIteratorImpl **************
// ********** Code for _ListWrapper **************
function _ListWrapper() {}
_ListWrapper.prototype.is$List = function(){return true};
_ListWrapper.prototype.is$Collection = function(){return true};
_ListWrapper.prototype.iterator = function() {
  return this._html_list.iterator();
}
_ListWrapper.prototype.forEach = function(f) {
  return this._html_list.forEach(f);
}
_ListWrapper.prototype.get$length = function() {
  return this._html_list.get$length();
}
_ListWrapper.prototype.$index = function(index) {
  return this._html_list.$index(index);
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
// ********** Code for _NodeListImpl **************
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
$dynamic("forEach").NodeList = function(f) {
  return _Collections.forEach(this, f);
}
$dynamic("last").NodeList = function() {
  return this.$index(this.length - (1));
}
$dynamic("get$length").NodeList = function() { return this.length; };
$dynamic("$index").NodeList = function(index) {
  return this[index];
}
// ********** Code for _NodeSelectorImpl **************
// ********** Code for _NotationImpl **************
// ********** Code for _NotificationImpl **************
// ********** Code for _NotificationCenterImpl **************
// ********** Code for _OESStandardDerivativesImpl **************
// ********** Code for _OESTextureFloatImpl **************
// ********** Code for _OESVertexArrayObjectImpl **************
// ********** Code for _OListElementImpl **************
// ********** Code for _ObjectElementImpl **************
$dynamic("get$height").HTMLObjectElement = function() { return this.height; };
$dynamic("get$width").HTMLObjectElement = function() { return this.width; };
// ********** Code for _OfflineAudioCompletionEventImpl **************
// ********** Code for _OperationNotAllowedExceptionImpl **************
// ********** Code for _OptGroupElementImpl **************
// ********** Code for _OptionElementImpl **************
$dynamic("get$value").HTMLOptionElement = function() { return this.value; };
$dynamic("set$value").HTMLOptionElement = function(value) { return this.value = value; };
// ********** Code for _OscillatorImpl **************
// ********** Code for _OutputElementImpl **************
$dynamic("get$value").HTMLOutputElement = function() { return this.value; };
$dynamic("set$value").HTMLOutputElement = function(value) { return this.value = value; };
// ********** Code for _OverflowEventImpl **************
// ********** Code for _PageTransitionEventImpl **************
// ********** Code for _ParagraphElementImpl **************
// ********** Code for _ParamElementImpl **************
$dynamic("get$value").HTMLParamElement = function() { return this.value; };
$dynamic("set$value").HTMLParamElement = function(value) { return this.value = value; };
// ********** Code for _PeerConnection00Impl **************
// ********** Code for _PerformanceImpl **************
// ********** Code for _PerformanceNavigationImpl **************
// ********** Code for _PerformanceTimingImpl **************
// ********** Code for _PointImpl **************
$dynamic("get$x").WebKitPoint = function() { return this.x; };
$dynamic("get$y").WebKitPoint = function() { return this.y; };
// ********** Code for _PointerLockImpl **************
// ********** Code for _PopStateEventImpl **************
// ********** Code for _PositionErrorImpl **************
// ********** Code for _PreElementImpl **************
$dynamic("get$width").HTMLPreElement = function() { return this.width; };
// ********** Code for _ProcessingInstructionImpl **************
// ********** Code for _ProgressElementImpl **************
$dynamic("get$value").HTMLProgressElement = function() { return this.value; };
$dynamic("set$value").HTMLProgressElement = function(value) { return this.value = value; };
// ********** Code for _ProgressEventImpl **************
// ********** Code for _QuoteElementImpl **************
// ********** Code for _RGBColorImpl **************
// ********** Code for _RangeImpl **************
// ********** Code for _RangeExceptionImpl **************
// ********** Code for _RealtimeAnalyserNodeImpl **************
// ********** Code for _RectImpl **************
// ********** Code for _SQLErrorImpl **************
// ********** Code for _SQLExceptionImpl **************
// ********** Code for _SQLResultSetImpl **************
// ********** Code for _SQLResultSetRowListImpl **************
// ********** Code for _SQLTransactionImpl **************
// ********** Code for _SQLTransactionSyncImpl **************
// ********** Code for _SVGElementImpl **************
// ********** Code for _SVGAElementImpl **************
// ********** Code for _SVGAltGlyphDefElementImpl **************
// ********** Code for _SVGTextContentElementImpl **************
// ********** Code for _SVGTextPositioningElementImpl **************
$dynamic("get$x").SVGTextPositioningElement = function() { return this.x; };
$dynamic("get$y").SVGTextPositioningElement = function() { return this.y; };
// ********** Code for _SVGAltGlyphElementImpl **************
// ********** Code for _SVGAltGlyphItemElementImpl **************
// ********** Code for _SVGAngleImpl **************
$dynamic("get$value").SVGAngle = function() { return this.value; };
$dynamic("set$value").SVGAngle = function(value) { return this.value = value; };
// ********** Code for _SVGAnimationElementImpl **************
// ********** Code for _SVGAnimateColorElementImpl **************
// ********** Code for _SVGAnimateElementImpl **************
// ********** Code for _SVGAnimateMotionElementImpl **************
// ********** Code for _SVGAnimateTransformElementImpl **************
// ********** Code for _SVGAnimatedAngleImpl **************
// ********** Code for _SVGAnimatedBooleanImpl **************
// ********** Code for _SVGAnimatedEnumerationImpl **************
// ********** Code for _SVGAnimatedIntegerImpl **************
// ********** Code for _SVGAnimatedLengthImpl **************
// ********** Code for _SVGAnimatedLengthListImpl **************
// ********** Code for _SVGAnimatedNumberImpl **************
// ********** Code for _SVGAnimatedNumberListImpl **************
// ********** Code for _SVGAnimatedPreserveAspectRatioImpl **************
// ********** Code for _SVGAnimatedRectImpl **************
// ********** Code for _SVGAnimatedStringImpl **************
// ********** Code for _SVGAnimatedTransformListImpl **************
// ********** Code for _SVGCircleElementImpl **************
// ********** Code for _SVGClipPathElementImpl **************
// ********** Code for _SVGColorImpl **************
// ********** Code for _SVGComponentTransferFunctionElementImpl **************
// ********** Code for _SVGCursorElementImpl **************
$dynamic("get$x").SVGCursorElement = function() { return this.x; };
$dynamic("get$y").SVGCursorElement = function() { return this.y; };
// ********** Code for _SVGDefsElementImpl **************
// ********** Code for _SVGDescElementImpl **************
// ********** Code for _SVGDocumentImpl **************
// ********** Code for _SVGElementInstanceImpl **************
// ********** Code for _SVGElementInstanceListImpl **************
// ********** Code for _SVGEllipseElementImpl **************
// ********** Code for _SVGExceptionImpl **************
// ********** Code for _SVGExternalResourcesRequiredImpl **************
// ********** Code for _SVGFEBlendElementImpl **************
$dynamic("get$height").SVGFEBlendElement = function() { return this.height; };
$dynamic("get$width").SVGFEBlendElement = function() { return this.width; };
$dynamic("get$x").SVGFEBlendElement = function() { return this.x; };
$dynamic("get$y").SVGFEBlendElement = function() { return this.y; };
// ********** Code for _SVGFEColorMatrixElementImpl **************
$dynamic("get$height").SVGFEColorMatrixElement = function() { return this.height; };
$dynamic("get$width").SVGFEColorMatrixElement = function() { return this.width; };
$dynamic("get$x").SVGFEColorMatrixElement = function() { return this.x; };
$dynamic("get$y").SVGFEColorMatrixElement = function() { return this.y; };
// ********** Code for _SVGFEComponentTransferElementImpl **************
$dynamic("get$height").SVGFEComponentTransferElement = function() { return this.height; };
$dynamic("get$width").SVGFEComponentTransferElement = function() { return this.width; };
$dynamic("get$x").SVGFEComponentTransferElement = function() { return this.x; };
$dynamic("get$y").SVGFEComponentTransferElement = function() { return this.y; };
// ********** Code for _SVGFECompositeElementImpl **************
$dynamic("get$height").SVGFECompositeElement = function() { return this.height; };
$dynamic("get$width").SVGFECompositeElement = function() { return this.width; };
$dynamic("get$x").SVGFECompositeElement = function() { return this.x; };
$dynamic("get$y").SVGFECompositeElement = function() { return this.y; };
// ********** Code for _SVGFEConvolveMatrixElementImpl **************
$dynamic("get$height").SVGFEConvolveMatrixElement = function() { return this.height; };
$dynamic("get$width").SVGFEConvolveMatrixElement = function() { return this.width; };
$dynamic("get$x").SVGFEConvolveMatrixElement = function() { return this.x; };
$dynamic("get$y").SVGFEConvolveMatrixElement = function() { return this.y; };
// ********** Code for _SVGFEDiffuseLightingElementImpl **************
$dynamic("get$height").SVGFEDiffuseLightingElement = function() { return this.height; };
$dynamic("get$width").SVGFEDiffuseLightingElement = function() { return this.width; };
$dynamic("get$x").SVGFEDiffuseLightingElement = function() { return this.x; };
$dynamic("get$y").SVGFEDiffuseLightingElement = function() { return this.y; };
// ********** Code for _SVGFEDisplacementMapElementImpl **************
$dynamic("get$height").SVGFEDisplacementMapElement = function() { return this.height; };
$dynamic("get$width").SVGFEDisplacementMapElement = function() { return this.width; };
$dynamic("get$x").SVGFEDisplacementMapElement = function() { return this.x; };
$dynamic("get$y").SVGFEDisplacementMapElement = function() { return this.y; };
// ********** Code for _SVGFEDistantLightElementImpl **************
// ********** Code for _SVGFEDropShadowElementImpl **************
$dynamic("get$height").SVGFEDropShadowElement = function() { return this.height; };
$dynamic("get$width").SVGFEDropShadowElement = function() { return this.width; };
$dynamic("get$x").SVGFEDropShadowElement = function() { return this.x; };
$dynamic("get$y").SVGFEDropShadowElement = function() { return this.y; };
// ********** Code for _SVGFEFloodElementImpl **************
$dynamic("get$height").SVGFEFloodElement = function() { return this.height; };
$dynamic("get$width").SVGFEFloodElement = function() { return this.width; };
$dynamic("get$x").SVGFEFloodElement = function() { return this.x; };
$dynamic("get$y").SVGFEFloodElement = function() { return this.y; };
// ********** Code for _SVGFEFuncAElementImpl **************
// ********** Code for _SVGFEFuncBElementImpl **************
// ********** Code for _SVGFEFuncGElementImpl **************
// ********** Code for _SVGFEFuncRElementImpl **************
// ********** Code for _SVGFEGaussianBlurElementImpl **************
$dynamic("get$height").SVGFEGaussianBlurElement = function() { return this.height; };
$dynamic("get$width").SVGFEGaussianBlurElement = function() { return this.width; };
$dynamic("get$x").SVGFEGaussianBlurElement = function() { return this.x; };
$dynamic("get$y").SVGFEGaussianBlurElement = function() { return this.y; };
// ********** Code for _SVGFEImageElementImpl **************
$dynamic("get$height").SVGFEImageElement = function() { return this.height; };
$dynamic("get$width").SVGFEImageElement = function() { return this.width; };
$dynamic("get$x").SVGFEImageElement = function() { return this.x; };
$dynamic("get$y").SVGFEImageElement = function() { return this.y; };
// ********** Code for _SVGFEMergeElementImpl **************
$dynamic("get$height").SVGFEMergeElement = function() { return this.height; };
$dynamic("get$width").SVGFEMergeElement = function() { return this.width; };
$dynamic("get$x").SVGFEMergeElement = function() { return this.x; };
$dynamic("get$y").SVGFEMergeElement = function() { return this.y; };
// ********** Code for _SVGFEMergeNodeElementImpl **************
// ********** Code for _SVGFEMorphologyElementImpl **************
$dynamic("get$height").SVGFEMorphologyElement = function() { return this.height; };
$dynamic("get$width").SVGFEMorphologyElement = function() { return this.width; };
$dynamic("get$x").SVGFEMorphologyElement = function() { return this.x; };
$dynamic("get$y").SVGFEMorphologyElement = function() { return this.y; };
// ********** Code for _SVGFEOffsetElementImpl **************
$dynamic("get$height").SVGFEOffsetElement = function() { return this.height; };
$dynamic("get$width").SVGFEOffsetElement = function() { return this.width; };
$dynamic("get$x").SVGFEOffsetElement = function() { return this.x; };
$dynamic("get$y").SVGFEOffsetElement = function() { return this.y; };
// ********** Code for _SVGFEPointLightElementImpl **************
$dynamic("get$x").SVGFEPointLightElement = function() { return this.x; };
$dynamic("get$y").SVGFEPointLightElement = function() { return this.y; };
// ********** Code for _SVGFESpecularLightingElementImpl **************
$dynamic("get$height").SVGFESpecularLightingElement = function() { return this.height; };
$dynamic("get$width").SVGFESpecularLightingElement = function() { return this.width; };
$dynamic("get$x").SVGFESpecularLightingElement = function() { return this.x; };
$dynamic("get$y").SVGFESpecularLightingElement = function() { return this.y; };
// ********** Code for _SVGFESpotLightElementImpl **************
$dynamic("get$x").SVGFESpotLightElement = function() { return this.x; };
$dynamic("get$y").SVGFESpotLightElement = function() { return this.y; };
// ********** Code for _SVGFETileElementImpl **************
$dynamic("get$height").SVGFETileElement = function() { return this.height; };
$dynamic("get$width").SVGFETileElement = function() { return this.width; };
$dynamic("get$x").SVGFETileElement = function() { return this.x; };
$dynamic("get$y").SVGFETileElement = function() { return this.y; };
// ********** Code for _SVGFETurbulenceElementImpl **************
$dynamic("get$height").SVGFETurbulenceElement = function() { return this.height; };
$dynamic("get$width").SVGFETurbulenceElement = function() { return this.width; };
$dynamic("get$x").SVGFETurbulenceElement = function() { return this.x; };
$dynamic("get$y").SVGFETurbulenceElement = function() { return this.y; };
// ********** Code for _SVGFilterElementImpl **************
$dynamic("get$height").SVGFilterElement = function() { return this.height; };
$dynamic("get$width").SVGFilterElement = function() { return this.width; };
$dynamic("get$x").SVGFilterElement = function() { return this.x; };
$dynamic("get$y").SVGFilterElement = function() { return this.y; };
// ********** Code for _SVGStylableImpl **************
// ********** Code for _SVGFilterPrimitiveStandardAttributesImpl **************
$dynamic("get$height").SVGFilterPrimitiveStandardAttributes = function() { return this.height; };
$dynamic("get$width").SVGFilterPrimitiveStandardAttributes = function() { return this.width; };
$dynamic("get$x").SVGFilterPrimitiveStandardAttributes = function() { return this.x; };
$dynamic("get$y").SVGFilterPrimitiveStandardAttributes = function() { return this.y; };
// ********** Code for _SVGFitToViewBoxImpl **************
// ********** Code for _SVGFontElementImpl **************
// ********** Code for _SVGFontFaceElementImpl **************
// ********** Code for _SVGFontFaceFormatElementImpl **************
// ********** Code for _SVGFontFaceNameElementImpl **************
// ********** Code for _SVGFontFaceSrcElementImpl **************
// ********** Code for _SVGFontFaceUriElementImpl **************
// ********** Code for _SVGForeignObjectElementImpl **************
$dynamic("get$height").SVGForeignObjectElement = function() { return this.height; };
$dynamic("get$width").SVGForeignObjectElement = function() { return this.width; };
$dynamic("get$x").SVGForeignObjectElement = function() { return this.x; };
$dynamic("get$y").SVGForeignObjectElement = function() { return this.y; };
// ********** Code for _SVGGElementImpl **************
// ********** Code for _SVGGlyphElementImpl **************
// ********** Code for _SVGGlyphRefElementImpl **************
$dynamic("get$x").SVGGlyphRefElement = function() { return this.x; };
$dynamic("get$y").SVGGlyphRefElement = function() { return this.y; };
// ********** Code for _SVGGradientElementImpl **************
// ********** Code for _SVGHKernElementImpl **************
// ********** Code for _SVGImageElementImpl **************
$dynamic("get$height").SVGImageElement = function() { return this.height; };
$dynamic("get$width").SVGImageElement = function() { return this.width; };
$dynamic("get$x").SVGImageElement = function() { return this.x; };
$dynamic("get$y").SVGImageElement = function() { return this.y; };
// ********** Code for _SVGLangSpaceImpl **************
// ********** Code for _SVGLengthImpl **************
$dynamic("get$value").SVGLength = function() { return this.value; };
$dynamic("set$value").SVGLength = function(value) { return this.value = value; };
// ********** Code for _SVGLengthListImpl **************
// ********** Code for _SVGLineElementImpl **************
// ********** Code for _SVGLinearGradientElementImpl **************
// ********** Code for _SVGLocatableImpl **************
// ********** Code for _SVGMPathElementImpl **************
// ********** Code for _SVGMarkerElementImpl **************
// ********** Code for _SVGMaskElementImpl **************
$dynamic("get$height").SVGMaskElement = function() { return this.height; };
$dynamic("get$width").SVGMaskElement = function() { return this.width; };
$dynamic("get$x").SVGMaskElement = function() { return this.x; };
$dynamic("get$y").SVGMaskElement = function() { return this.y; };
// ********** Code for _SVGMatrixImpl **************
// ********** Code for _SVGMetadataElementImpl **************
// ********** Code for _SVGMissingGlyphElementImpl **************
// ********** Code for _SVGNumberImpl **************
$dynamic("get$value").SVGNumber = function() { return this.value; };
$dynamic("set$value").SVGNumber = function(value) { return this.value = value; };
// ********** Code for _SVGNumberListImpl **************
// ********** Code for _SVGPaintImpl **************
// ********** Code for _SVGPathElementImpl **************
// ********** Code for _SVGPathSegImpl **************
// ********** Code for _SVGPathSegArcAbsImpl **************
$dynamic("get$x").SVGPathSegArcAbs = function() { return this.x; };
$dynamic("get$y").SVGPathSegArcAbs = function() { return this.y; };
// ********** Code for _SVGPathSegArcRelImpl **************
$dynamic("get$x").SVGPathSegArcRel = function() { return this.x; };
$dynamic("get$y").SVGPathSegArcRel = function() { return this.y; };
// ********** Code for _SVGPathSegClosePathImpl **************
// ********** Code for _SVGPathSegCurvetoCubicAbsImpl **************
$dynamic("get$x").SVGPathSegCurvetoCubicAbs = function() { return this.x; };
$dynamic("get$y").SVGPathSegCurvetoCubicAbs = function() { return this.y; };
// ********** Code for _SVGPathSegCurvetoCubicRelImpl **************
$dynamic("get$x").SVGPathSegCurvetoCubicRel = function() { return this.x; };
$dynamic("get$y").SVGPathSegCurvetoCubicRel = function() { return this.y; };
// ********** Code for _SVGPathSegCurvetoCubicSmoothAbsImpl **************
$dynamic("get$x").SVGPathSegCurvetoCubicSmoothAbs = function() { return this.x; };
$dynamic("get$y").SVGPathSegCurvetoCubicSmoothAbs = function() { return this.y; };
// ********** Code for _SVGPathSegCurvetoCubicSmoothRelImpl **************
$dynamic("get$x").SVGPathSegCurvetoCubicSmoothRel = function() { return this.x; };
$dynamic("get$y").SVGPathSegCurvetoCubicSmoothRel = function() { return this.y; };
// ********** Code for _SVGPathSegCurvetoQuadraticAbsImpl **************
$dynamic("get$x").SVGPathSegCurvetoQuadraticAbs = function() { return this.x; };
$dynamic("get$y").SVGPathSegCurvetoQuadraticAbs = function() { return this.y; };
// ********** Code for _SVGPathSegCurvetoQuadraticRelImpl **************
$dynamic("get$x").SVGPathSegCurvetoQuadraticRel = function() { return this.x; };
$dynamic("get$y").SVGPathSegCurvetoQuadraticRel = function() { return this.y; };
// ********** Code for _SVGPathSegCurvetoQuadraticSmoothAbsImpl **************
$dynamic("get$x").SVGPathSegCurvetoQuadraticSmoothAbs = function() { return this.x; };
$dynamic("get$y").SVGPathSegCurvetoQuadraticSmoothAbs = function() { return this.y; };
// ********** Code for _SVGPathSegCurvetoQuadraticSmoothRelImpl **************
$dynamic("get$x").SVGPathSegCurvetoQuadraticSmoothRel = function() { return this.x; };
$dynamic("get$y").SVGPathSegCurvetoQuadraticSmoothRel = function() { return this.y; };
// ********** Code for _SVGPathSegLinetoAbsImpl **************
$dynamic("get$x").SVGPathSegLinetoAbs = function() { return this.x; };
$dynamic("get$y").SVGPathSegLinetoAbs = function() { return this.y; };
// ********** Code for _SVGPathSegLinetoHorizontalAbsImpl **************
$dynamic("get$x").SVGPathSegLinetoHorizontalAbs = function() { return this.x; };
// ********** Code for _SVGPathSegLinetoHorizontalRelImpl **************
$dynamic("get$x").SVGPathSegLinetoHorizontalRel = function() { return this.x; };
// ********** Code for _SVGPathSegLinetoRelImpl **************
$dynamic("get$x").SVGPathSegLinetoRel = function() { return this.x; };
$dynamic("get$y").SVGPathSegLinetoRel = function() { return this.y; };
// ********** Code for _SVGPathSegLinetoVerticalAbsImpl **************
$dynamic("get$y").SVGPathSegLinetoVerticalAbs = function() { return this.y; };
// ********** Code for _SVGPathSegLinetoVerticalRelImpl **************
$dynamic("get$y").SVGPathSegLinetoVerticalRel = function() { return this.y; };
// ********** Code for _SVGPathSegListImpl **************
// ********** Code for _SVGPathSegMovetoAbsImpl **************
$dynamic("get$x").SVGPathSegMovetoAbs = function() { return this.x; };
$dynamic("get$y").SVGPathSegMovetoAbs = function() { return this.y; };
// ********** Code for _SVGPathSegMovetoRelImpl **************
$dynamic("get$x").SVGPathSegMovetoRel = function() { return this.x; };
$dynamic("get$y").SVGPathSegMovetoRel = function() { return this.y; };
// ********** Code for _SVGPatternElementImpl **************
$dynamic("get$height").SVGPatternElement = function() { return this.height; };
$dynamic("get$width").SVGPatternElement = function() { return this.width; };
$dynamic("get$x").SVGPatternElement = function() { return this.x; };
$dynamic("get$y").SVGPatternElement = function() { return this.y; };
// ********** Code for _SVGPointImpl **************
$dynamic("get$x").SVGPoint = function() { return this.x; };
$dynamic("get$y").SVGPoint = function() { return this.y; };
// ********** Code for _SVGPointListImpl **************
// ********** Code for _SVGPolygonElementImpl **************
// ********** Code for _SVGPolylineElementImpl **************
// ********** Code for _SVGPreserveAspectRatioImpl **************
// ********** Code for _SVGRadialGradientElementImpl **************
// ********** Code for _SVGRectImpl **************
$dynamic("get$height").SVGRect = function() { return this.height; };
$dynamic("get$width").SVGRect = function() { return this.width; };
$dynamic("get$x").SVGRect = function() { return this.x; };
$dynamic("get$y").SVGRect = function() { return this.y; };
// ********** Code for _SVGRectElementImpl **************
$dynamic("get$height").SVGRectElement = function() { return this.height; };
$dynamic("get$width").SVGRectElement = function() { return this.width; };
$dynamic("get$x").SVGRectElement = function() { return this.x; };
$dynamic("get$y").SVGRectElement = function() { return this.y; };
// ********** Code for _SVGRenderingIntentImpl **************
// ********** Code for _SVGSVGElementImpl **************
$dynamic("get$height").SVGSVGElement = function() { return this.height; };
$dynamic("get$width").SVGSVGElement = function() { return this.width; };
$dynamic("get$x").SVGSVGElement = function() { return this.x; };
$dynamic("get$y").SVGSVGElement = function() { return this.y; };
// ********** Code for _SVGScriptElementImpl **************
// ********** Code for _SVGSetElementImpl **************
// ********** Code for _SVGStopElementImpl **************
// ********** Code for _SVGStringListImpl **************
// ********** Code for _SVGStyleElementImpl **************
// ********** Code for _SVGSwitchElementImpl **************
// ********** Code for _SVGSymbolElementImpl **************
// ********** Code for _SVGTRefElementImpl **************
// ********** Code for _SVGTSpanElementImpl **************
// ********** Code for _SVGTestsImpl **************
// ********** Code for _SVGTextElementImpl **************
// ********** Code for _SVGTextPathElementImpl **************
// ********** Code for _SVGTitleElementImpl **************
// ********** Code for _SVGTransformImpl **************
// ********** Code for _SVGTransformListImpl **************
// ********** Code for _SVGTransformableImpl **************
// ********** Code for _SVGURIReferenceImpl **************
// ********** Code for _SVGUnitTypesImpl **************
// ********** Code for _SVGUseElementImpl **************
$dynamic("get$height").SVGUseElement = function() { return this.height; };
$dynamic("get$width").SVGUseElement = function() { return this.width; };
$dynamic("get$x").SVGUseElement = function() { return this.x; };
$dynamic("get$y").SVGUseElement = function() { return this.y; };
// ********** Code for _SVGVKernElementImpl **************
// ********** Code for _SVGViewElementImpl **************
// ********** Code for _SVGZoomAndPanImpl **************
// ********** Code for _SVGViewSpecImpl **************
// ********** Code for _SVGZoomEventImpl **************
// ********** Code for _ScreenImpl **************
$dynamic("get$height").Screen = function() { return this.height; };
$dynamic("get$width").Screen = function() { return this.width; };
// ********** Code for _ScriptElementImpl **************
// ********** Code for _ScriptProfileImpl **************
// ********** Code for _ScriptProfileNodeImpl **************
// ********** Code for _SelectElementImpl **************
$dynamic("get$value").HTMLSelectElement = function() { return this.value; };
$dynamic("set$value").HTMLSelectElement = function(value) { return this.value = value; };
// ********** Code for _SessionDescriptionImpl **************
// ********** Code for _ShadowElementImpl **************
// ********** Code for _ShadowRootImpl **************
// ********** Code for _SharedWorkerImpl **************
// ********** Code for _SharedWorkerContextImpl **************
// ********** Code for _SourceElementImpl **************
// ********** Code for _SpanElementImpl **************
// ********** Code for _SpeechGrammarImpl **************
// ********** Code for _SpeechGrammarListImpl **************
// ********** Code for _SpeechInputEventImpl **************
// ********** Code for _SpeechInputResultImpl **************
// ********** Code for _SpeechInputResultListImpl **************
// ********** Code for _SpeechRecognitionImpl **************
// ********** Code for _SpeechRecognitionAlternativeImpl **************
// ********** Code for _SpeechRecognitionErrorImpl **************
// ********** Code for _SpeechRecognitionEventImpl **************
// ********** Code for _SpeechRecognitionResultImpl **************
// ********** Code for _SpeechRecognitionResultListImpl **************
// ********** Code for _StorageImpl **************
$dynamic("is$Map").Storage = function(){return true};
$dynamic("$index").Storage = function(key) {
  return this.getItem(key);
}
$dynamic("forEach").Storage = function(f) {
  for (var i = (0);
   true; i = $add$(i, (1))) {
    var key = this.key(i);
    if ($eq$(key)) return;
    f(key, this.$index(key));
  }
}
// ********** Code for _StorageEventImpl **************
// ********** Code for _StorageInfoImpl **************
// ********** Code for _StyleElementImpl **************
// ********** Code for _StyleMediaImpl **************
// ********** Code for _StyleSheetListImpl **************
$dynamic("is$List").StyleSheetList = function(){return true};
$dynamic("is$Collection").StyleSheetList = function(){return true};
$dynamic("get$length").StyleSheetList = function() { return this.length; };
$dynamic("$index").StyleSheetList = function(index) {
  return this[index];
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
$dynamic("last").StyleSheetList = function() {
  return this.$index(this.length - (1));
}
$dynamic("removeLast").StyleSheetList = function() {
  $throw(new UnsupportedOperationException("Cannot removeLast on immutable List."));
}
// ********** Code for _TableCaptionElementImpl **************
// ********** Code for _TableCellElementImpl **************
$dynamic("get$height").HTMLTableCellElement = function() { return this.height; };
$dynamic("get$width").HTMLTableCellElement = function() { return this.width; };
// ********** Code for _TableColElementImpl **************
$dynamic("get$width").HTMLTableColElement = function() { return this.width; };
// ********** Code for _TableElementImpl **************
$dynamic("get$width").HTMLTableElement = function() { return this.width; };
// ********** Code for _TableRowElementImpl **************
// ********** Code for _TableSectionElementImpl **************
// ********** Code for _TextAreaElementImpl **************
$dynamic("get$value").HTMLTextAreaElement = function() { return this.value; };
$dynamic("set$value").HTMLTextAreaElement = function(value) { return this.value = value; };
// ********** Code for _TextEventImpl **************
// ********** Code for _TextMetricsImpl **************
$dynamic("get$width").TextMetrics = function() { return this.width; };
// ********** Code for _TextTrackImpl **************
// ********** Code for _TextTrackCueImpl **************
// ********** Code for _TextTrackCueListImpl **************
// ********** Code for _TextTrackListImpl **************
// ********** Code for _TimeRangesImpl **************
// ********** Code for _TitleElementImpl **************
// ********** Code for _TouchImpl **************
// ********** Code for _TouchEventImpl **************
// ********** Code for _TouchListImpl **************
$dynamic("is$List").TouchList = function(){return true};
$dynamic("is$Collection").TouchList = function(){return true};
$dynamic("get$length").TouchList = function() { return this.length; };
$dynamic("$index").TouchList = function(index) {
  return this[index];
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
$dynamic("last").TouchList = function() {
  return this.$index(this.length - (1));
}
$dynamic("removeLast").TouchList = function() {
  $throw(new UnsupportedOperationException("Cannot removeLast on immutable List."));
}
// ********** Code for _TrackElementImpl **************
// ********** Code for _TrackEventImpl **************
// ********** Code for _TransitionEventImpl **************
// ********** Code for _TreeWalkerImpl **************
// ********** Code for _UListElementImpl **************
// ********** Code for _Uint16ArrayImpl **************
$dynamic("is$List").Uint16Array = function(){return true};
$dynamic("is$Collection").Uint16Array = function(){return true};
$dynamic("get$length").Uint16Array = function() { return this.length; };
$dynamic("$index").Uint16Array = function(index) {
  return this[index];
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
$dynamic("last").Uint16Array = function() {
  return this.$index(this.length - (1));
}
$dynamic("removeLast").Uint16Array = function() {
  $throw(new UnsupportedOperationException("Cannot removeLast on immutable List."));
}
// ********** Code for _Uint32ArrayImpl **************
$dynamic("is$List").Uint32Array = function(){return true};
$dynamic("is$Collection").Uint32Array = function(){return true};
$dynamic("get$length").Uint32Array = function() { return this.length; };
$dynamic("$index").Uint32Array = function(index) {
  return this[index];
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
$dynamic("last").Uint32Array = function() {
  return this.$index(this.length - (1));
}
$dynamic("removeLast").Uint32Array = function() {
  $throw(new UnsupportedOperationException("Cannot removeLast on immutable List."));
}
// ********** Code for _Uint8ArrayImpl **************
$dynamic("is$List").Uint8Array = function(){return true};
$dynamic("is$Collection").Uint8Array = function(){return true};
$dynamic("get$length").Uint8Array = function() { return this.length; };
$dynamic("$index").Uint8Array = function(index) {
  return this[index];
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
$dynamic("last").Uint8Array = function() {
  return this.$index(this.length - (1));
}
$dynamic("removeLast").Uint8Array = function() {
  $throw(new UnsupportedOperationException("Cannot removeLast on immutable List."));
}
// ********** Code for _Uint8ClampedArrayImpl **************
// ********** Code for _UnknownElementImpl **************
// ********** Code for _ValidityStateImpl **************
// ********** Code for _VideoElementImpl **************
$dynamic("get$height").HTMLVideoElement = function() { return this.height; };
$dynamic("get$width").HTMLVideoElement = function() { return this.width; };
// ********** Code for _WaveShaperNodeImpl **************
// ********** Code for _WaveTableImpl **************
// ********** Code for _WebGLActiveInfoImpl **************
// ********** Code for _WebGLBufferImpl **************
// ********** Code for _WebGLCompressedTextureS3TCImpl **************
// ********** Code for _WebGLContextAttributesImpl **************
// ********** Code for _WebGLContextEventImpl **************
// ********** Code for _WebGLDebugRendererInfoImpl **************
// ********** Code for _WebGLDebugShadersImpl **************
// ********** Code for _WebGLFramebufferImpl **************
// ********** Code for _WebGLLoseContextImpl **************
// ********** Code for _WebGLProgramImpl **************
// ********** Code for _WebGLRenderbufferImpl **************
// ********** Code for _WebGLRenderingContextImpl **************
// ********** Code for _WebGLShaderImpl **************
// ********** Code for _WebGLShaderPrecisionFormatImpl **************
// ********** Code for _WebGLTextureImpl **************
// ********** Code for _WebGLUniformLocationImpl **************
// ********** Code for _WebGLVertexArrayObjectOESImpl **************
// ********** Code for _WebKitCSSFilterValueImpl **************
// ********** Code for _WebKitCSSRegionRuleImpl **************
// ********** Code for _WebKitMutationObserverImpl **************
// ********** Code for _WebKitNamedFlowImpl **************
// ********** Code for _WebSocketImpl **************
// ********** Code for _WheelEventImpl **************
$dynamic("get$x").WheelEvent = function() { return this.x; };
$dynamic("get$y").WheelEvent = function() { return this.y; };
// ********** Code for _WindowImpl **************
$dynamic("get$on").DOMWindow = function() {
  return new _WindowEventsImpl(this);
}
// ********** Code for _WindowEventsImpl **************
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
// ********** Code for _WorkerImpl **************
// ********** Code for _WorkerLocationImpl **************
// ********** Code for _WorkerNavigatorImpl **************
// ********** Code for _XMLHttpRequestImpl **************
// ********** Code for _XMLHttpRequestExceptionImpl **************
// ********** Code for _XMLHttpRequestProgressEventImpl **************
// ********** Code for _XMLHttpRequestUploadImpl **************
// ********** Code for _XMLSerializerImpl **************
// ********** Code for _XPathEvaluatorImpl **************
// ********** Code for _XPathExceptionImpl **************
// ********** Code for _XPathExpressionImpl **************
// ********** Code for _XPathNSResolverImpl **************
// ********** Code for _XPathResultImpl **************
// ********** Code for _XSLTProcessorImpl **************
// ********** Code for _Collections **************
function _Collections() {}
_Collections.forEach = function(iterable, f) {
  for (var $$i = iterable.iterator(); $$i.hasNext(); ) {
    var e = $$i.next();
    f(e);
  }
}
// ********** Code for _VariableSizeListIterator **************
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
// ********** Code for _FixedSizeListIterator **************
$inherits(_FixedSizeListIterator, _VariableSizeListIterator);
function _FixedSizeListIterator() {}
_FixedSizeListIterator.prototype.hasNext = function() {
  return this._html_length > this._html_pos;
}
// ********** Code for _VariableSizeListIterator_dart_core_String **************
$inherits(_VariableSizeListIterator_dart_core_String, _VariableSizeListIterator);
function _VariableSizeListIterator_dart_core_String(array) {
  this._html_array = array;
  this._html_pos = (0);
}
// ********** Code for _FixedSizeListIterator_dart_core_String **************
$inherits(_FixedSizeListIterator_dart_core_String, _FixedSizeListIterator);
function _FixedSizeListIterator_dart_core_String(array) {
  this._html_length = array.get$length();
  _VariableSizeListIterator_dart_core_String.call(this, array);
}
// ********** Code for _VariableSizeListIterator_int **************
$inherits(_VariableSizeListIterator_int, _VariableSizeListIterator);
function _VariableSizeListIterator_int(array) {
  this._html_array = array;
  this._html_pos = (0);
}
// ********** Code for _FixedSizeListIterator_int **************
$inherits(_FixedSizeListIterator_int, _FixedSizeListIterator);
function _FixedSizeListIterator_int(array) {
  this._html_length = array.get$length();
  _VariableSizeListIterator_int.call(this, array);
}
// ********** Code for _VariableSizeListIterator_num **************
$inherits(_VariableSizeListIterator_num, _VariableSizeListIterator);
function _VariableSizeListIterator_num(array) {
  this._html_array = array;
  this._html_pos = (0);
}
// ********** Code for _FixedSizeListIterator_num **************
$inherits(_FixedSizeListIterator_num, _FixedSizeListIterator);
function _FixedSizeListIterator_num(array) {
  this._html_length = array.get$length();
  _VariableSizeListIterator_num.call(this, array);
}
// ********** Code for _VariableSizeListIterator_html_Node **************
$inherits(_VariableSizeListIterator_html_Node, _VariableSizeListIterator);
function _VariableSizeListIterator_html_Node(array) {
  this._html_array = array;
  this._html_pos = (0);
}
// ********** Code for _FixedSizeListIterator_html_Node **************
$inherits(_FixedSizeListIterator_html_Node, _FixedSizeListIterator);
function _FixedSizeListIterator_html_Node(array) {
  this._html_length = array.get$length();
  _VariableSizeListIterator_html_Node.call(this, array);
}
// ********** Code for _VariableSizeListIterator_html_StyleSheet **************
$inherits(_VariableSizeListIterator_html_StyleSheet, _VariableSizeListIterator);
function _VariableSizeListIterator_html_StyleSheet(array) {
  this._html_array = array;
  this._html_pos = (0);
}
// ********** Code for _FixedSizeListIterator_html_StyleSheet **************
$inherits(_FixedSizeListIterator_html_StyleSheet, _FixedSizeListIterator);
function _FixedSizeListIterator_html_StyleSheet(array) {
  this._html_length = array.get$length();
  _VariableSizeListIterator_html_StyleSheet.call(this, array);
}
// ********** Code for _VariableSizeListIterator_html_Touch **************
$inherits(_VariableSizeListIterator_html_Touch, _VariableSizeListIterator);
function _VariableSizeListIterator_html_Touch(array) {
  this._html_array = array;
  this._html_pos = (0);
}
// ********** Code for _FixedSizeListIterator_html_Touch **************
$inherits(_FixedSizeListIterator_html_Touch, _FixedSizeListIterator);
function _FixedSizeListIterator_html_Touch(array) {
  this._html_length = array.get$length();
  _VariableSizeListIterator_html_Touch.call(this, array);
}
// ********** Code for top level **************
function get$$window() {
  return window;
}
function get$$document() {
  return document;
}
var _cachedBrowserPrefix;
var _pendingRequests;
var _pendingMeasurementFrameCallbacks;
//  ********** Library json **************
// ********** Code for top level **************
//  ********** Library C:\Users\rweaving **************
// ********** Code for Util **************
function Util() {}
Util.pos = function(elem, x, y) {
  elem.get$style().set$left(("" + x + "PX"));
  elem.get$style().set$top(("" + y + "PX"));
}
Util.currentTimeMillis = function() {
  return (new DateImplementation.now$ctor()).value;
}
// ********** Code for LogicDevice **************
function LogicDevice(ID, Type) {
  this.selected = false;
  this.SelectedInputPin = (-1);
  this.acc = (0);
  this.rset = (5);
  this._calculated = false;
  this._updated = false;
  this._visible = true;
  this._updateable = false;
  this.CloneMode = false;
  this.ID = ID;
  this.Type = Type;
  this.Input = new Array();
  this.Output = new Array();
  this.Images = new Array();
  Configure(this);
}
LogicDevice.prototype.get$InputCount = function() {
  return this.Input.get$length();
}
LogicDevice.prototype.set$InputCount = function(count) {
  if (this.get$InputCount() < count) {
    do {
      this.Input.add(new DeviceInput(this, this.get$InputCount().toString()));
    }
    while (this.get$InputCount() < count)
  }
}
LogicDevice.prototype.get$OutputCount = function() {
  return this.Output.get$length();
}
LogicDevice.prototype.set$OutputCount = function(count) {
  if (this.get$OutputCount() < count) {
    do {
      this.Output.add(new DeviceOutput(this, this.get$OutputCount().toString()));
    }
    while (this.get$OutputCount() < count)
  }
}
LogicDevice.prototype.get$calculated = function() {
  return this._calculated;
}
LogicDevice.prototype.set$calculated = function(calc) {
  this._calculated = calc;
  if (!this._calculated) this.Input.forEach((function (f) {
    f.set$updated(false);
  })
  );
}
LogicDevice.prototype.get$updateable = function() {
  return this._updateable;
}
LogicDevice.prototype.set$updateable = function(val) {
  this._updateable = val;
}
LogicDevice.prototype.get$updated = function() {
  return this._updated;
}
LogicDevice.prototype.set$updated = function(ud) {
  this._updated = ud;
}
LogicDevice.prototype.addImage = function(image) {
  var _elem;
  _elem = _ElementFactoryProvider.Element$tag$factory("img");
  _elem.src = image;
  this.Images.add(_elem);
}
LogicDevice.prototype.SetInputPinLocation = function(pin, xPos, yPos) {
  if (pin >= (0) && pin < this.Input.get$length()) {
    this.Input.$index(pin).SetPinLocation(xPos, yPos);
  }
}
LogicDevice.prototype.SetOutputPinLocation = function(pin, xPos, yPos) {
  if (pin >= (0) && pin < this.Output.get$length()) {
    this.Output.$index(pin).SetPinLocation(xPos, yPos);
  }
}
LogicDevice.prototype.SetInputConnectable = function(pin, connectable) {
  if (pin >= (0) && pin < this.Input.get$length()) {
    this.Input.$index(pin).set$connectable(false);
  }
}
LogicDevice.prototype.InputPinHit = function(x, y) {
  if (this.CloneMode) return null;
  if (this.get$InputCount() <= (0)) return null;
  var $$list = this.Input;
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
  if (this.get$OutputCount() <= (0)) return null;
  var $$list = this.Output;
  for (var $$i = $$list.iterator(); $$i.hasNext(); ) {
    var output = $$i.next();
    if (output.get$connectable()) {
      if (output.pinHit(x, y)) return output;
    }
  }
  return null;
}
LogicDevice.prototype.WireHit = function(x, y) {
  var hitDevice;
  var $$list = this.Input;
  for (var $$i = $$list.iterator(); $$i.hasNext(); ) {
    var input = $$i.next();
    hitDevice = input.wireHit(x, y);
    if (hitDevice != null) return hitDevice;
  }
  return null;
}
LogicDevice.prototype.MoveDevice = function(newX, newY) {
  if ($ne$(this.Images.$index((0)))) {
    Util.pos(this.Images.$index((0)), newX.toDouble(), newY.toDouble());
    this.X = newX;
    this.Y = newY;
  }
}
LogicDevice.prototype.clicked = function() {
  switch (this.Type) {
    case "SWITCH":

      this.Output.$index((0)).set$value(!this.Output.$index((0)).get$value());
      this._updated = true;
      break;

  }
}
LogicDevice.prototype.contains = function(pointX, pointY) {
  if ((pointX > this.X && pointX < $add$(this.X, this.Images.$index((0)).get$width())) && (pointY > this.Y && pointY < $add$(this.Y, this.Images.$index((0)).get$height()))) {
    return true;
  }
  else {
    return false;
  }
}
LogicDevice.prototype.Calculate = function() {
  if (!this._calculated) {
    this._calculated = true;
    var outputState = this.Output.$index((0)).get$value();
    switch (this.Type) {
      case "AND":

        this.Output.$index((0)).set$value(this.Input.$index((0)).get$value() && this.Input.$index((1)).get$value());
        break;

      case "NAND":

        this.Output.$index((0)).set$value(!(this.Input.$index((0)).get$value() && this.Input.$index((1)).get$value()));
        break;

      case "OR":

        this.Output.$index((0)).set$value(this.Input.$index((0)).get$value() || this.Input.$index((1)).get$value());
        break;

      case "NOR":

        this.Output.$index((0)).set$value(!(this.Input.$index((0)).get$value() || this.Input.$index((1)).get$value()));
        break;

      case "XOR":

        this.Output.$index((0)).set$value(($ne$(this.Input.$index((0)).get$value(), this.Input.$index((1)).get$value())));
        break;

      case "XNOR":

        this.Output.$index((0)).set$value(!($ne$(this.Input.$index((0)).get$value(), this.Input.$index((1)).get$value())));
        break;

      case "NOT":

        this.Output.$index((0)).set$value(!(this.Input.$index((0)).get$value()));
        break;

      case "SWITCH":

        this.Output.$index((0)).set$value(this.Output.$index((0)).get$value());
        break;

      case "DLOGO":
      case "LED":

        this.Output.$index((0)).set$value(this.Input.$index((0)).get$value());
        break;

      case "CLOCK":

        CalcClock(this);
        break;

    }
    if ($ne$(outputState, this.Output.$index((0)).get$value())) this._updated = true;
    this.Input.forEach((function (f) {
      f.checkUpdate();
    })
    );
  }
}
// ********** Code for DeviceInput **************
function DeviceInput(device, _id) {
  this._value = false;
  this._connectable = true;
  this.device = device;
  this._id = _id;
  this.set$value(false);
  this.connectedOutput = null;
  this.wire = new Wire();
}
DeviceInput.prototype.get$connectable = function() {
  if (this._pinX < (0)) return false;
  else return this._connectable;
}
DeviceInput.prototype.set$connectable = function(val) {
  this._connectable = val;
}
DeviceInput.prototype.set$updated = function(value) { return this.updated = value; };
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
    this.updated = this.connectedOutput.device.get$updated();
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
DeviceInput.prototype.SetPinLocation = function(x, y) {
  this._pinX = x;
  this._pinY = y;
}
DeviceInput.prototype.pinHit = function(x, y) {
  if (x <= (this.get$offsetX() + (7)) && x >= (this.get$offsetX() - (7))) {
    if (y <= (this.get$offsetY() + (7)) && y >= (this.get$offsetY() - (7))) {
      return true;
    }
  }
  return false;
}
// ********** Code for DeviceOutput **************
function DeviceOutput(device, _id) {
  this._connectable = true;
  this.device = device;
  this._id = _id;
  this.set$value(false);
}
DeviceOutput.prototype.get$connectable = function() {
  if (this._pinX < (0)) return false;
  else return this._connectable;
}
DeviceOutput.prototype.set$connectable = function(val) {
  this._connectable = val;
}
DeviceOutput.prototype.get$calculated = function() {
  return this.device.get$calculated();
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
DeviceOutput.prototype.SetPinLocation = function(x, y) {
  this._pinX = x;
  this._pinY = y;
}
DeviceOutput.prototype.pinHit = function(x, y) {
  if (x <= (this.get$offsetX() + (7)) && x >= (this.get$offsetX() - (7))) {
    if (y <= (this.get$offsetY() + (7)) && y >= (this.get$offsetY() - (7))) {
      return true;
    }
  }
  return false;
}
// ********** Code for Circuit **************
function Circuit(canvas) {
  var $this = this; // closure support
  this.showGrid = false;
  this.connectionMode = "INIT";
  this.connectingOutputToInput = false;
  this.connectingInputToOutput = false;
  this.canvas = canvas;
  this.lastTime = Util.currentTimeMillis();
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
  get$$window().setInterval(function f() {
    return $this.tick();
  }
  , (100));
  this.canvas.get$on().get$mouseDown().add(this.get$onMouseDown(), false);
  this.canvas.get$on().get$doubleClick().add(this.get$onMouseDoubleClick(), false);
  this.canvas.get$on().get$mouseMove().add(this.get$onMouseMove(), false);
  get$$window().get$on().get$resize().add((function (event) {
    return $this.onResize();
  })
  , true);
  this.createSelectorBar();
  this.Paint();
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
  var newDevice = new LogicDevice(id, type);
  this.logicDevices.add(newDevice);
  newDevice.CloneMode = true;
  newDevice.MoveDevice(x, y);
  return newDevice;
}
Circuit.prototype.NewDeviceFrom = function(device) {
  var newDevice = new LogicDevice(this.getNewId(), device.Type);
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
    device.set$calculated(false);
  }
  var $$list = this.logicDevices;
  for (var $$i = $$list.iterator(); $$i.hasNext(); ) {
    var device = $$i.next();
    device.Calculate();
  }
  if (this.logicDevices.get$length() <= (10)) this.Paint();
  this.drawUpdate();
}
Circuit.prototype.getNewId = function() {
  return this.logicDevices.get$length();
}
Circuit.prototype.onMouseDown = function(e) {
  e.preventDefault();
  this.Paint();
  if (this.moveDevice != null) this.moveDevice = null;
  switch (this.connectionMode) {
    case "InputToOutput":
    case "OutputToInput":

      this.AddWirePoint(this._mouseX, this._mouseY);
      if (this.checkValidConnection()) this.EndWire();
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

      var $$list = this.logicDevices;
      for (var $$i = $$list.iterator(); $$i.hasNext(); ) {
        var device = $$i.next();
        if (device.contains(e.offsetX, e.offsetY)) {
          device.clicked();
          break;
        }
      }
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
    if (device.OutputPinHit(x, y) != null) return device.OutputPinHit(x, y);
  }
}
Circuit.prototype.checkForWireHit = function(x, y) {
  var $$list = this.logicDevices;
  for (var $$i = $$list.iterator(); $$i.hasNext(); ) {
    var device = $$i.next();
    if (device.WireHit(x, y) != null) return device.WireHit(x, y);
  }
}
Circuit.prototype.checkForInputPinHit = function(x, y) {
  var $$list = this.logicDevices;
  for (var $$i = $$list.iterator(); $$i.hasNext(); ) {
    var device = $$i.next();
    if (device.InputPinHit(x, y) != null) return device.InputPinHit(x, y);
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
    var $list0 = device.Input;
    for (var $i0 = $list0.iterator(); $i0.hasNext(); ) {
      var input = $i0.next();
      if (input.connectedOutput != null) this.drawWire(input, input.get$value());
    }
  }
  if (this.dummyWire.wirePoints.get$length() > (0)) if (this.checkValidConnection()) this.drawDummyWire("VALID");
  else this.drawDummyWire("INVAILD");
}
Circuit.prototype.drawUpdatedWires = function() {
  var $$list = this.logicDevices;
  for (var $$i = $$list.iterator(); $$i.hasNext(); ) {
    var device = $$i.next();
    var $list0 = device.Input;
    for (var $i0 = $list0.iterator(); $i0.hasNext(); ) {
      var input = $i0.next();
      if (input.connectedOutput != null) if (input.updated) {
        this.drawWire(input, "ERASE");
        this.drawWire(input, input.get$value());
      }
    }
  }
}
Circuit.prototype.drawDevices = function() {
  var $$list = this.logicDevices;
  for (var $$i = $$list.iterator(); $$i.hasNext(); ) {
    var device = $$i.next();
    if (device.Images.get$length() > (1) && device.get$OutputCount() > (0)) {
      if ($eq$(device.Output.$index((0)).get$value(), true)) this.context.drawImage(device.Images.$index((1)), device.X, device.Y);
      else this.context.drawImage(device.Images.$index((0)), device.X, device.Y);
    }
    else this.context.drawImage(device.Images.$index((0)), device.X, device.Y);
  }
}
Circuit.prototype.drawUpdatedDevices = function() {
  var $$list = this.logicDevices;
  for (var $$i = $$list.iterator(); $$i.hasNext(); ) {
    var device = $$i.next();
    if (device.get$updateable() && device.get$updated()) {
      if (device.Images.get$length() > (1) && device.get$OutputCount() > (0)) {
        if ($eq$(device.Output.$index((0)).get$value(), true)) this.context.drawImage(device.Images.$index((1)), device.X, device.Y);
        else this.context.drawImage(device.Images.$index((0)), device.X, device.Y);
      }
      else this.context.drawImage(device.Images.$index((0)), device.X, device.Y);
    }
  }
}
Circuit.prototype.clearCanvas = function() {
  this.context.clearRect((0), (0), this._width, this._height);
}
Circuit.prototype.drawUpdate = function() {
  this.drawUpdatedDevices();
  this.drawUpdatedWires();
}
Circuit.prototype.Paint = function() {
  this.clearCanvas();
  this.drawBorder();
  this.drawDevices();
  this.drawWires();
  this.drawPinSelectors();
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
    var $list0 = device.Output;
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
    var $list0 = device.Input;
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
// ********** Code for WirePoint **************
function WirePoint(x, y) {
  this.x = x;
  this.y = y;
}
WirePoint.prototype.get$x = function() { return this.x; };
WirePoint.prototype.get$y = function() { return this.y; };
// ********** Code for Wire **************
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
// ********** Code for top level **************
function main() {
  new Circuit(get$$document().query("#canvas")).start();
}
function CalcClock(device) {
  if (device.acc > device.rset) {
    device.acc = (0);
    device.Output.$index((0)).set$value(!device.Output.$index((0)).get$value());
    device.Output.$index((1)).set$value(!device.Output.$index((0)).get$value());
  }
  else device.acc = device.acc + (1);
}
function Configure(device) {
  switch (device.Type) {
    case "AND":

      ConfigureAnd2(device);
      break;

    case "NAND":

      ConfigureNand2(device);
      break;

    case "OR":

      ConfigureOr2(device);
      break;

    case "NOR":

      ConfigureNor2(device);
      break;

    case "XOR":

      ConfigureXor2(device);
      break;

    case "XNOR":

      ConfigureXnor2(device);
      break;

    case "NOT":

      ConfigureNot(device);
      break;

    case "SWITCH":

      ConfigureSwitch(device);
      break;

    case "LED":

      ConfigureLed(device);
      break;

    case "DLOGO":

      ConfigureDartLogo(device);
      break;

    case "CLOCK":

      ConfigureClock(device);
      break;

  }
}
function ConfigureSwitch(device) {
  device.addImage("images/01Switch_Low.png");
  device.addImage("images/01Switch_High.png");
  device.set$InputCount((1));
  device.set$OutputCount((1));
  device.SetInputPinLocation((0), (-1), (-1));
  device.SetOutputPinLocation((0), (21), (0));
}
function ConfigureDartLogo(device) {
  device.addImage("images/dartLogo.png");
  device.addImage("images/dartLogo2.png");
  device.set$InputCount((1));
  device.set$OutputCount((1));
  device.set$updateable(true);
  device.SetOutputPinLocation((0), (-1), (-1));
  device.SetInputPinLocation((0), (28), (0));
}
function ConfigureLed(device) {
  device.addImage("images/01Disp_Low.png");
  device.addImage("images/01Disp_High.png");
  device.set$InputCount((1));
  device.set$OutputCount((1));
  device.SetInputPinLocation((0), (16), (0));
  device.SetOutputPinLocation((0), (-1), (-1));
  device.set$updateable(true);
}
function ConfigureAnd2(device) {
  device.addImage("images/and2.png");
  device.set$InputCount((2));
  device.SetInputPinLocation((0), (5), (15));
  device.SetInputPinLocation((1), (5), (35));
  device.set$OutputCount((1));
  device.SetOutputPinLocation((0), (95), (25));
}
function ConfigureNand2(device) {
  device.addImage("images/nand2.png");
  device.set$InputCount((2));
  device.SetInputPinLocation((0), (5), (15));
  device.SetInputPinLocation((1), (5), (35));
  device.set$OutputCount((1));
  device.SetOutputPinLocation((0), (95), (25));
}
function ConfigureOr2(device) {
  device.addImage("images/or.png");
  device.set$InputCount((2));
  device.SetInputPinLocation((0), (5), (15));
  device.SetInputPinLocation((1), (5), (35));
  device.set$OutputCount((1));
  device.SetOutputPinLocation((0), (95), (25));
}
function ConfigureNor2(device) {
  device.addImage("images/nor.png");
  device.set$InputCount((2));
  device.SetInputPinLocation((0), (5), (15));
  device.SetInputPinLocation((1), (5), (35));
  device.set$OutputCount((1));
  device.SetOutputPinLocation((0), (95), (25));
}
function ConfigureXor2(device) {
  device.addImage("images/xor.png");
  device.set$InputCount((2));
  device.SetInputPinLocation((0), (5), (15));
  device.SetInputPinLocation((1), (5), (35));
  device.set$OutputCount((1));
  device.SetOutputPinLocation((0), (95), (25));
}
function ConfigureXnor2(device) {
  device.addImage("images/xnor.png");
  device.set$InputCount((2));
  device.SetInputPinLocation((0), (5), (15));
  device.SetInputPinLocation((1), (5), (35));
  device.set$OutputCount((1));
  device.SetOutputPinLocation((0), (95), (25));
}
function ConfigureNot(device) {
  device.addImage("images/not.png");
  device.set$InputCount((1));
  device.SetInputPinLocation((0), (5), (25));
  device.set$OutputCount((1));
  device.SetOutputPinLocation((0), (94), (25));
}
function ConfigureClock(device) {
  device.addImage("images/Clock.png");
  device.set$InputCount((1));
  device.SetInputPinLocation((0), (0), (0));
  device.SetInputConnectable((0), false);
  device.set$OutputCount((2));
  device.SetOutputPinLocation((0), (64), (14));
  device.SetOutputPinLocation((1), (64), (39));
}
// 115 dynamic types.
// 226 types
// 16 !leaf
(function(){
  var v0/*HTMLMediaElement*/ = 'HTMLMediaElement|HTMLAudioElement|HTMLVideoElement';
  var v1/*SVGTextPositioningElement*/ = 'SVGTextPositioningElement|SVGAltGlyphElement|SVGTRefElement|SVGTSpanElement|SVGTextElement';
  var v2/*HTMLDocument*/ = 'HTMLDocument|SVGDocument';
  var v3/*DocumentFragment*/ = 'DocumentFragment|ShadowRoot';
  var v4/*Element*/ = [v0/*HTMLMediaElement*/,v1/*SVGTextPositioningElement*/,'Element|HTMLElement|HTMLAnchorElement|HTMLAppletElement|HTMLAreaElement|HTMLBRElement|HTMLBaseElement|HTMLBaseFontElement|HTMLBodyElement|HTMLButtonElement|HTMLCanvasElement|HTMLContentElement|HTMLDListElement|HTMLDetailsElement|HTMLDirectoryElement|HTMLDivElement|HTMLEmbedElement|HTMLFieldSetElement|HTMLFontElement|HTMLFormElement|HTMLFrameElement|HTMLFrameSetElement|HTMLHRElement|HTMLHeadElement|HTMLHeadingElement|HTMLHtmlElement|HTMLIFrameElement|HTMLImageElement|HTMLInputElement|HTMLKeygenElement|HTMLLIElement|HTMLLabelElement|HTMLLegendElement|HTMLLinkElement|HTMLMapElement|HTMLMarqueeElement|HTMLMenuElement|HTMLMetaElement|HTMLMeterElement|HTMLModElement|HTMLOListElement|HTMLObjectElement|HTMLOptGroupElement|HTMLOptionElement|HTMLOutputElement|HTMLParagraphElement|HTMLParamElement|HTMLPreElement|HTMLProgressElement|HTMLQuoteElement|SVGElement|SVGAElement|SVGAltGlyphDefElement|SVGAltGlyphItemElement|SVGAnimationElement|SVGAnimateColorElement|SVGAnimateElement|SVGAnimateMotionElement|SVGAnimateTransformElement|SVGSetElement|SVGCircleElement|SVGClipPathElement|SVGComponentTransferFunctionElement|SVGFEFuncAElement|SVGFEFuncBElement|SVGFEFuncGElement|SVGFEFuncRElement|SVGCursorElement|SVGDefsElement|SVGDescElement|SVGEllipseElement|SVGFEBlendElement|SVGFEColorMatrixElement|SVGFEComponentTransferElement|SVGFECompositeElement|SVGFEConvolveMatrixElement|SVGFEDiffuseLightingElement|SVGFEDisplacementMapElement|SVGFEDistantLightElement|SVGFEDropShadowElement|SVGFEFloodElement|SVGFEGaussianBlurElement|SVGFEImageElement|SVGFEMergeElement|SVGFEMergeNodeElement|SVGFEMorphologyElement|SVGFEOffsetElement|SVGFEPointLightElement|SVGFESpecularLightingElement|SVGFESpotLightElement|SVGFETileElement|SVGFETurbulenceElement|SVGFilterElement|SVGFontElement|SVGFontFaceElement|SVGFontFaceFormatElement|SVGFontFaceNameElement|SVGFontFaceSrcElement|SVGFontFaceUriElement|SVGForeignObjectElement|SVGGElement|SVGGlyphElement|SVGGlyphRefElement|SVGGradientElement|SVGLinearGradientElement|SVGRadialGradientElement|SVGHKernElement|SVGImageElement|SVGLineElement|SVGMPathElement|SVGMarkerElement|SVGMaskElement|SVGMetadataElement|SVGMissingGlyphElement|SVGPathElement|SVGPatternElement|SVGPolygonElement|SVGPolylineElement|SVGRectElement|SVGSVGElement|SVGScriptElement|SVGStopElement|SVGStyleElement|SVGSwitchElement|SVGSymbolElement|SVGTextContentElement|SVGTextPathElement|SVGTitleElement|SVGUseElement|SVGVKernElement|SVGViewElement|HTMLScriptElement|HTMLSelectElement|HTMLShadowElement|HTMLSourceElement|HTMLSpanElement|HTMLStyleElement|HTMLTableCaptionElement|HTMLTableCellElement|HTMLTableColElement|HTMLTableElement|HTMLTableRowElement|HTMLTableSectionElement|HTMLTextAreaElement|HTMLTitleElement|HTMLTrackElement|HTMLUListElement|HTMLUnknownElement'].join('|');
  var table = [
    // [dynamic-dispatch-tag, tags of classes implementing dynamic-dispatch-tag]
    ['AudioParam', 'AudioParam|AudioGain']
    , ['HTMLDocument', v2/*HTMLDocument*/]
    , ['DocumentFragment', v3/*DocumentFragment*/]
    , ['HTMLMediaElement', v0/*HTMLMediaElement*/]
    , ['SVGTextPositioningElement', v1/*SVGTextPositioningElement*/]
    , ['Element', v4/*Element*/]
    , ['HTMLCollection', 'HTMLCollection|HTMLOptionsCollection']
    , ['Node', [v2/*HTMLDocument*/,v3/*DocumentFragment*/,v4/*Element*/,'Node|Attr|CharacterData|Comment|Text|CDATASection|DocumentType|Entity|EntityReference|Notation|ProcessingInstruction'].join('|')]
    , ['Uint8Array', 'Uint8Array|Uint8ClampedArray']
  ];
  $dynamicSetMetadata(table);
})();
//  ********** Globals **************
function $static_init(){
}
var const$0000 = Object.create(_DeletedKeySentinel.prototype, {});
var const$0001 = Object.create(NoMoreElementsException.prototype, {});
var const$0002 = new JSSyntaxRegExp("^#[_a-zA-Z]\\w*$");
$static_init();
if (typeof window != 'undefined' && typeof document != 'undefined' &&
    window.addEventListener && document.readyState == 'loading') {
  window.addEventListener('DOMContentLoaded', function(e) {
    main();
  });
} else {
  main();
}
