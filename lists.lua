SILE.require("packages.counters")
SILE.scratch.liststyle = nil

SILE.registerCommand("listarea", function (options, content)
  SILE.scratch.liststyle = options.numberstyle
  SILE.call("set-counter", { id = "listarea", value = 1, display = SILE.scratch.liststyle or "arabic" })
  SILE.settings.temporarily(function ()
    SILE.settings.set("document.rskip", SILE.nodefactory.newGlue(tostring(SILE.settings.get("document.parindent").width)))
    SILE.settings.set("document.lskip", SILE.nodefactory.newGlue(tostring(SILE.settings.get("document.parindent").width)))
    SILE.settings.set("document.parindent", SILE.nodefactory.zeroGlue)
    SILE.process(content)
  end)
  SILE.call("noindent")
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
