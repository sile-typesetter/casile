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

var references = [];

function extract_references (data) {
  var res = bcv.parse(data).parsed_entities();
  res.forEach(function(match) {
    var ref = {};
    ref.original = data.slice(match.indices[0], match.indices[1]);
    ref.osis = match.osis;
    ref.seq = bcv.translations.default.order[match.start.b] * 1000000 + match.start.c * 1000 + match.start.v;
    ref.reformat = formatter('yc-long', match.osis);
    references.push(ref);
  });
}

function output_references () {
  var output = JSON.stringify(references, null, '  ');
  process.stdout.write(output);
}

rl.on('line', extract_references);
rl.on('close', output_references);
