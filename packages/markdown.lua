SILE.processMarkdown = function (content, callback)
  callback = callback or function (...) return ... end
  local lunamark = require("lunamark")
  local reader = lunamark.reader.markdown
  local writer = lunamark.writer.ast.new()
  local parse = reader.new(writer)
  local output = callback(parse(tostring(content[1])))
  SILE.process(output)
end

SILE.registerCommand("processMarkdown", function (options, content)
  SILE.processMarkdown(SU.contentToString(content), options.callback)
end)

SILE.registerCommand("emphasis", function (options, content)
  SILE.call("em", options, content)
end)
