#!/usr/bin/env node

var readline = require('readline')
var BcvParser = require('bible-passage-reference-parser/js/tr_bcv_parser').bcv_parser
var bcv = new BcvParser()
var formatter = require('bible-reference-formatter/es6/tr')

bcv.set_options({
  sequence_combination_strategy: 'separate'
})
bcv.include_apocrypha(true)

var rl = readline.createInterface({
  input: process.stdin,
  output: process.stdout,
  terminal: false
})

var references = []

function extractReferences (data) {
  var res = bcv.parse(data).parsed_entities()
  res.forEach(function (match) {
    var ref = {}
    ref.original = data.slice(match.indices[0], match.indices[1])
    ref.osis = match.osis
    ref.b = formatter('yc-long', match.start.b)
    ref.c = match.start.c
    ref.v = match.start.v
    ref.seq = bcv.translations.default.order[match.start.b] * 1000000 + match.start.c * 1000 + match.start.v
    ref.reformat = formatter('yc-long', match.osis)
    references.push(ref)
  })
}

function outputReferences () {
  var output = JSON.stringify(references, null, '  ')
  process.stdout.write(output)
}

rl.on('line', extractReferences)
rl.on('close', outputReferences)
