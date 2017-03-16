SILE.require("packages.counters")
SILE.scratch.liststyle = nil

local nestedlist = 0
local listarealskip = nil

SILE.registerCommand("listarea", function (options, content)
  nestedlist = nestedlist + 1
  if nestedlist == 1 then listarealskip = SILE.settings.get("document.parindent").width end
  SILE.scratch.liststyle = options.numberstyle
  SILE.call("set-counter", { id = "listarea", value = 1, display = SILE.scratch.liststyle or "arabic" })
  SU.debug("casile", "nested count", nestedlist, listarealskip)
  SILE.settings.temporarily(function ()
    SILE.settings.set("document.parindent", SILE.nodefactory.zeroGlue)
    SILE.settings.set("document.lskip", SILE.nodefactory.newGlue(options.lskip or tostring(listarealskip * nestedlist)))
    SILE.settings.set("document.rskip", SILE.nodefactory.newGlue(options.rskip or 0))
    SILE.process(content)
  end)
  SILE.call("noindent")
  nestedlist = nestedlist - 1
end)

SILE.registerCommand("listitem", function (options, content)
  local lskip = SILE.settings.get("document.lskip").width
  SILE.call("kern", { width = tostring(lskip * -0.75) })
  SILE.call("rebox", { width = tostring(lskip * 0.75) }, function ()
    if SILE.scratch.liststyle then
      SILE.call("show-counter", { id = "listarea" })
      SILE.typesetter:typeset(".")
    else
      SILE.typesetter:typeset("•")
    end
  end)
  SILE.call("increment-counter",  { id = "listarea" })
  SILE.process(content)
  SILE.call("smallskip")
end)
