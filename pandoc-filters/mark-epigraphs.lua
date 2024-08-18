local after_header

local function header (element)
   if element.level <= 2 then
      after_header = true
   end
   return element
end

-- Re-process block quotes following headers as epigraph class divs
local function blockquote (element)
   if after_header then
      after_header = false
      return pandoc.Div(element.content, { class = "epigraph" })
   else
      return element
   end
end

-- Elements that should not be expected between headers and epigraphs should reset the marker so following block quotes
-- no longer count as epigraphs
local function other_block (element)
   after_header = false
   return element
end

return {
   { Header = header },
   { BlockQuote = blockquote },
   { BulletList = other_block },
   { CodeBlock = other_block },
   { DefinitionList = other_block },
   { Div = other_block },
   { Figure = other_block },
   { HorizontalRule = other_block },
   { LineBlock = other_block },
   { Para = other_block },
   { Plain = other_block },
   { RawBlock = other_block },
   { Table = other_block },
}
