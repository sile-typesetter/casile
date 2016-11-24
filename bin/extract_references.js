#!/usr/bin/env node

var readline = require('readline');
var bcv_parser = require('bible-passage-reference-parser/js/tr_bcv_parser').bcv_parser;
var bcv = new bcv_parser();

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
  // console.log("DATA:", data);
  var res = bcv.parse(data);
  references.push(res.osis());
  // rl.write(res.osis());
  // console.log("RESULTS:", res.osis());
}

function output_references () {
  console.log(references);
}

rl.on('line', extract_references);

rl.on('close', output_references);
