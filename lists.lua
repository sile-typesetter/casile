SILE.require("packages.counters")
SILE.scratch.liststyle = nil

local nestedlist = 0
local liststyles = {}
local listarealskip = nil

SILE.registerCommand("listarea", function (options, content)
  nestedlist = nestedlist + 1
  if nestedlist == 1 then listarealskip = SILE.settings.get("document.parindent").width end
  liststyles[nestedlist] = { options.numberstyle }
  SILE.call("set-counter", { id = "listarea" .. nestedlist, value = 1, display = options.numberstyle or "arabic" })
  SILE.settings.temporarily(function ()
    SILE.settings.set("document.parindent", SILE.nodefactory.glue())
    local factor = nestedlist == 1 and 0 or nestedlist / 2
    SILE.settings.set("document.lskip", SILE.nodefactory.glue(options.lskip or tostring(listarealskip + listarealskip * factor)))
	SILE.settings.set("document.rskip", SILE.nodefactory.glue(options.rskip or "0pt"))
    SILE.process(content)
  end)
  SILE.call("noindent")
  nestedlist = nestedlist - 1
end)

SILE.registerCommand("listitem", function (options, content)
  local markerwidth = SILE.length("1.5em")
  SILE.call("kern", { width = tostring(markerwidth:negate()) })
  SILE.call("rebox", { width = tostring(markerwidth) }, function ()
    if liststyles[nestedlist][1] then
      SILE.call("show-counter", { id = "listarea" .. nestedlist })
      SILE.typesetter:typeset(".")
    else
      SILE.typesetter:typeset("•")
    end
  end)
  SILE.call("increment-counter",  { id = "listarea" .. nestedlist })
  SILE.process(content)
  if nestedlist == 1 then SILE.call("smallskip") else SILE.call("par") end
end)
