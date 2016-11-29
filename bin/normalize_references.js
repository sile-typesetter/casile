#!/usr/bin/env node

var readline = require('readline');
var bcv_parser = require('bible-passage-reference-parser/js/tr_bcv_parser').bcv_parser;
var bcv = new bcv_parser();
var formatter = require('bible-reference-formatter/es6/tr');

bcv.set_options({
  'sequence_combination_strategy': 'separate'
});
bcv.include_apocrypha(true);

var rl = readline.createInterface({
  input: process.stdin,
  output: process.stdout,
  terminal: false
});

String.prototype.replaceSplice = function (start, end, string) {
  return this.substr(0,start) + string + this.substr(end);
};

function isChained(context, ref, line, offset) {
  var dist = ref.indices[0] - context.indices[1];
  if ( dist >= 4 ) { return false; }
  var connector = line.substr(context.indices[1] + offset, dist);
  return (/^[;, ]+$/).test(connector);
}

function mergeRefs(a, b) {
  return {
    osis: a.osis + "," + b.osis,
    translations: a.translations,
    indices: [ a.indices[0], b.indices[1] ]
  };
}

function process_line (line) {
  line = line + "\n"; // restore that which readline rightfully stole
  if (!line.match(/^(#|\[\^\d+\]:) /)) { // skip footnotes and headings for now
    var offset = 0;
    var previousOffset = 0;
    var context = null;
    var refs = bcv.parse(line).osis_and_indices();
    refs.forEach(function(ref) {
      if ( context && isChained(context, ref, line, offset) ) {
        var mref = mergeRefs(context, ref);
        ref = mref;
        offset -= previousOffset;
      } else {
        previousOffset = 0;
      }
      var pretty = formatter('yc-long', ref.osis);
      line = line.replaceSplice(ref.indices[0] + offset, ref.indices[1] + offset + previousOffset, pretty);
      previousOffset = ref.indices[0] - ref.indices[1] + pretty.length;
      offset += previousOffset;
      context = ref;
    });
  }
  process.stdout.write(line);
}

rl.on('line', process_line);
