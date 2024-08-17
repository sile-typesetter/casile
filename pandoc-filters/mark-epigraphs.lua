local post_section

local function header (element)
   post_section = true
   return element
end

-- Note block quotes after section breaks are epigraphs
local function blockQuote (element)
   if post_section then
      post_section = false
      return pandoc.Div(element.content, { class = "epigraph" })
   else
      return element
   end
end

return {
   { Header = header },
   { BlockQuote = blockQuote },
}
