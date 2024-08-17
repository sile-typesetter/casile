-- Convert Scrivner's exported document structure to the one we want for use with CaSILE
-- with top level explicit parts, then chapters and sections
local function header (element)
   if element.level == 1 then
      local inner = pandoc.utils.stringify(element)
      return pandoc.RawInline("markdown", ("\\part{%s}"):format(inner))
   else
      element.level = element.level - 1
      return element
   end
end

return {
   { Header = header },
}
