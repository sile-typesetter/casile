SILE.processMarkdown = function (content)
  local lunamark = require("lunamark")
  local reader = lunamark.reader.markdown
  local writer = lunamark.writer.ast.new()
  local parse = reader.new(writer)
  local output = parse(tostring(content[1]))
  SILE.process(output)
end

SILE.registerCommand("processMarkdown", function (option, content)
  SILE.processMarkdown(SU.contentToString(content))
end)

SILE.registerCommand("emphasis", function (options, content)
  SILE.call("em", options, content)
end)
