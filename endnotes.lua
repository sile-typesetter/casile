SILE.require("packages/footnotes")
SILE.scratch.endnotes = {}

SILE.registerCommand("endnote", function(options, content)
  SILE.call("footnotemark")
  --local material = SILE.Commands["rebox"]({}, function()
  local material = SILE.Commands["vbox"]({}, function()
    SILE.Commands["footnote:font"]({}, function()
      SILE.call("footnote:atstart")
      SILE.call("footnote:counter")
      --SILE.process(content)
      --SU.debug("viachristus", content)
      SILE.typesetter:typeset("this is a test")
    end)
  end)
  --SU.debug("viachristus", material.height)
  SILE.scratch.endnotes[#SILE.scratch.endnotes+1] = material
  SILE.scratch.counters.footnote.value = SILE.scratch.counters.footnote.value + 1
end)

SILE.registerCommand("endnotes", function(options, content)
  for i=1, #SILE.scratch.endnotes do
    SILE.typesetter:pushVbox(SILE.scratch.endnotes[i])
  end
  SILE.scratch.endnotes = {}
end)

local class = SILE.documentState.documentClass
local originalfinish = class.finish
class.finish = function()
  if #SILE.scratch.endnotes >= 1 then
    SILE.call("endnotes")
  end
  return originalfinish(class)
end

