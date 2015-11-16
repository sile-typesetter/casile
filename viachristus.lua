local utf8 = require("lua-utf8")
local inputfilter = SILE.require("packages/inputfilter").exports
SILE.registerCommand("uppercase", function(options, content)
  content[1] = content[1]:gsub("i", "İ")
  SILE.process(inputfilter.transformContent(content, utf8.upper))
end, "Typeset the enclosed text as uppercase")

SILE.require("packages/color")
SILE.require("packages/raiselower")
SILE.require("packages/rebox")

SILE.registerCommand("quote", function(options, content)
  local author = options.author or nil
  local setback = options.setback or "20pt"
  local color = options.color or "#999999"
  SILE.settings.temporarily(function()
    SILE.settings.set("document.rskip", SILE.nodefactory.newGlue(setback))
    SILE.settings.set("document.lskip", SILE.nodefactory.newGlue(setback))

    SILE.settings.set("current.parindent", SILE.nodefactory.zeroGlue)
    SILE.Commands["font"]({family="Libertine Serif", features="+salt,+ss02,+onum,+liga,+dlig,+clig", weight=400, size="12pt"}, content)
    --SILE.process(content)
    SILE.typesetter:pushGlue(SILE.nodefactory.hfillGlue)
    SILE.call("par")
  end)
end, "Typeset verse blocks")
