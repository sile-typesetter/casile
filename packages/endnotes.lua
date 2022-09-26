local base = require("packages.base")

local package = pl.class(base)
package._name = "endnotes"

SILE.scratch.endnotes = {}

function package:_init ()
  base._init(self)
  self.class:loadPackage("footnotes")
  self.class:registerHook("finish", function ()
    if #SILE.scratch.endnotes >= 1 then
      SILE.call("endnotes")
    end
  end)
end

function package:registerCommands ()

  self:registerCommand("endnote", function (_, content)
    SILE.call("footnotemark")
    local material = function ()
      SILE.process(content)
    end
    local counter = self.class.packages.counters:formatCounter(SILE.scratch.counters.footnote)
    SILE.scratch.endnotes[#SILE.scratch.endnotes+1] = function ()
      return counter, material
    end
    SILE.scratch.counters.footnote.value = SILE.scratch.counters.footnote.value + 1
  end)

  self:registerCommand("endnote:counter", function (options, _)
    SILE.call("noindent")
    SILE.typesetter:typeset(options.value..".")
  end)

  self:registerCommand("endnotes", function (_, _)
    local indent = "1.5em"
    SILE.settings:temporarily(function ()
      SILE.settings:set("document.lskip", SILE.nodefactory.glue(indent))
      for i = 1, #SILE.scratch.endnotes do
        local counter, material = SILE.scratch.endnotes[i]()
        SILE.call("footnote:font", {}, function ()
          SILE.typesetter:pushGlue({ width = -SILE.length(indent) })
          SILE.call("rebox", { width = indent }, function ()
            SILE.call("endnote:counter", { value = counter })
          end)
          SILE.call("raggedright", {}, function ()
            material()
          end)
        end)
      end
    end)
    SILE.scratch.endnotes = {}
    SILE.scratch.counters.footnote.value = 1
  end)

end

return package
