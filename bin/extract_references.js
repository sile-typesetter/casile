#!/usr/bin/env node

var readline = require('readline');
var bcv_parser = require('bible-passage-reference-parser/js/full_bcv_parser').bcv_parser;
var bcv = new bcv_parser();

function extract_references (data) {
  console.log("DATA:", data);
  var res = bcv.parse(data);
  console.log("RESULTS:", res.osis());
}

var rl = readline.createInterface({
  input: process.stdin,
  output: process.stdout,
  terminal: false
});

rl.on('line', extract_references);
