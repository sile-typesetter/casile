-- Stuff we count as ending a sentence
local eos = "%P.+[%.%!%?]+%)?$"

local function wrap_sentences (element)
   local content = element.content
   for i = 2, #content do
      local previous = content[i - 1]
      local previous_stringly = pandoc.utils.stringify(previous.content and previous.content or previous)
      if
         content[i].t == "Space"
         and previous_stringly:match(eos)
         -- Don't break if the next character is a lower case
         and not (content[i+1] and pandoc.utils.stringify(content[i+1]):match("^%l"))
      then
         content[i] = pandoc.SoftBreak()
      end
   end
   return element
end

return {
   {
      SoftBreak = function ()
         return pandoc.Space()
      end,
   },
   { Para = wrap_sentences },
   { Plain = wrap_sentences },
   { Emph = wrap_sentences },
   { BlockQuote = wrap_sentences },
   { Div = wrap_sentences },
   { Quoted = wrap_sentences },
}
