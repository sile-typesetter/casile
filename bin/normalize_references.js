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

function process_line (line) {
  line = line + "\n"; // restore that which readline rightfully stole
  var offset = 0;
  var refs = bcv.parse(line).osis_and_indices();
  refs.forEach(function(ref) {
      var pretty = formatter('yc-long', ref.osis);
      line = line.replaceSplice(ref.indices[0] + offset, ref.indices[1] + offset, pretty); 
      offset += ref.indices[0] - ref.indices[1] + pretty.length;
    });
  process.stdout.write(line);
}

rl.on('line', process_line);
