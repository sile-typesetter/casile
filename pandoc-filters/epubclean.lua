-- Remove footnotes from headers to pass epub validation for Play Books
Header = function (element)
   return pandoc.walk_block(element, {
      Note = function (_)
         return {}
      end,
   })
end
