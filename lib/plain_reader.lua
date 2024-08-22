-- A sample custom reader that just parses text into blankline-separated
-- paragraphs with space-separated words.

-- For better performance we put these functions in local variables:
local P, S, V, Ct = lpeg.P, lpeg.S, lpeg.V, lpeg.Ct

local whitespacechar = S(" \t\r\n")
local wordchar = (1 - whitespacechar)
local spacechar = S(" \t")
local newline = P("\r") ^ -1 * P("\n")
local blanklines = newline * (spacechar ^ 0 * newline) ^ 1
local endline = newline - blanklines

-- Grammar
local G = P({
   "Pandoc",
   Pandoc = Ct(V("Block") ^ 0) / pandoc.Pandoc,
   Block = blanklines ^ 0 * V("Para"),
   Para = Ct(V("Inline") ^ 1) / pandoc.Para,
   Inline = V("Str") + V("Space") + V("SoftBreak"),
   Str = wordchar ^ 1 / pandoc.Str,
   Space = spacechar ^ 1 / pandoc.Space,
   SoftBreak = endline / pandoc.SoftBreak,
})

function Reader (input)
   return lpeg.match(G, tostring(input))
end
