local function sentence_lines (element)
   local inlines = element.content
   for i = 2, #inlines do
      if inlines[i].t == "Space" and inlines[i - 1].t == "Str" and inlines[i - 1].text:match("[%.%!%?]%)?$") then
         inlines[i] = pandoc.SoftBreak()
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
   { Para = sentence_lines },
   { Plain = sentence_lines },
}
