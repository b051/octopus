// Generated by CoffeeScript 1.6.3
(function() {
  var Message, Parse, exports;

  if (typeof require !== "undefined" && require !== null) {
    Parse = require('parse').Parse;
  } else {
    Parse = window.Parse;
  }

  Parse.initialize('FPijVqDF5EAKrkGuFv1oj43Au7kOFguvoQgwt6Bp', 'l3EnH19I64YJC6q59v4A7fjZJ3bWJryyk5x8IWrm');

  if (typeof exports === "undefined" || exports === null) {
    exports = window;
  }

  exports.User = Parse.User;

  exports.Union = Parse.Object.extend({
    className: 'Union'
  });

  exports.Instrument = Parse.Object.extend({
    className: 'Instrument'
  });

  Message = exports.Message = Parse.Object.extend({
    className: 'Message'
  });

  exports.MessageCollection = Parse.Collection.extend({
    model: Message
  });

}).call(this);

/*
//@ sourceMappingURL=models.map
*/
