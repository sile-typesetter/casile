local base = require("packages.base")
local lunamark = require("lunamark")

local package = pl.class(base)
package._name = "markdown"

function package:_init ()
   base._init(self)

   SILE.markdownToContent = function (input, callback)
      callback = callback or function (...)
         return ...
      end
      local reader = lunamark.reader.markdown
      local writer = lunamark.writer.ast.new()
      local parse = reader.new(writer)
      local output = callback(parse(input))
      return output
   end

   SILE.processMarkdown = function (input, callback)
      local output = SILE.markdownToContent(input, callback)
      SILE.process(output)
   end
end

function package:registerCommands ()
   self:registerCommand("processMarkdown", function (options, content)
      local input = SU.ast.contentToString(content)
      SILE.processMarkdown(input, options.callback)
   end)

   self:registerCommand("emphasis", function (options, content)
      SILE.call("em", options, content)
   end)
end

return package
