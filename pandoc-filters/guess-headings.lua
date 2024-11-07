local function guess_heading (element)
   -- Only catch lines entirely wrapped in emphasis
   if #element.content == 1 then
      local inner = element.content[1]
      if inner.tag == "Strong" or inner.tag == "Emph" then
         -- More than 20 words (spaces are nodes) is probably not a heading
         if inner.content and #inner.content <= 40 then
            -- Discard plain numbers in the hopes they are just chapter ids
            if pandoc.utils.stringify(inner):match("^%d+$") then
               return {}
            else
               local level = inner.tag == "Strong" and 1 or 2
               return pandoc.Header(level, inner.content)
            end
         end
      end
   end
end

return {
   { Para = guess_heading },
}
