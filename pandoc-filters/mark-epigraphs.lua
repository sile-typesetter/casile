local after_header

local function mark_epigraph_blocks (blocks)
   for i, block in ipairs(blocks) do
      if block.t == "Header" and block.level <= 2 then
         after_header = true
      elseif after_header then
         if block.t == "BlockQuote" then
            blocks[i] = pandoc.Div(block.content, { class = "epigraph" })
         else
            after_header = false
         end
      end
   end
   return blocks
end

return {
   traverse = "topdown",
   { Blocks = mark_epigraph_blocks },
}
