local base = require("packages.base")

local package = pl.class(base)
package._name = "markdown"

function package:_init ()
  base._init(self)

  SILE.processMarkdown = function (content, callback)
    callback = callback or function (...) return ... end
    local lunamark = require("lunamark")
    local reader = lunamark.reader.markdown
    local writer = lunamark.writer.ast.new()
    local parse = reader.new(writer)
    local output = callback(parse(tostring(content[1])))
    SILE.process(output)
  end

end

function package:registerCommands ()

  self:registerCommand("processMarkdown", function (options, content)
    SILE.processMarkdown(SU.contentToString(content), options.callback)
  end)

  self:registerCommand("emphasis", function (options, content)
    SILE.call("em", options, content)
  end)

end

return package
