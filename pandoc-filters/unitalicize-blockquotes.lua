local function unitalicize (element)
   element = pandoc.walk_block(element, {
      Para = function (el)
         if #el.content == 1 then
            local inner = el.content[1]
            if inner.tag == "Emph" then
               return pandoc.Plain(inner.content)
            end
         end
      end,
   })
   return element
end

return {
   { BlockQuote = unitalicize },
}
