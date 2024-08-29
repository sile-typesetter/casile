local locale = os.getenv("LANGUAGE") or "en"

-- Stuff we count as ending a sentence
local eos = "%P.+[%.%!%?]+%)?$"

local tr_non_terminal = {
   ["Bkz."] = true,
   ["bkz."] = true,
   ["(bkz."] = true,
   ["Krş."] = true,
   ["krş."] = true,
   ["(krş."] = true,
   ["Örn."] = true,
   ["örn."] = true,
   ["(örn."] = true,
   ["Ör."] = true,
   ["ör."] = true,
   ["(ör."] = true,
   ["Ç.N."] = true,
   ["Ç.n."] = true,
   ["ç.n."] = true,
   ["ÇN."] = true,
   ["çn."] = true,
}

local en_non_terminal = {
   ["i.e."] = true,
   ["(i.e."] = true,
   ["c.f."] = true,
   ["(c.f."] = true,
   ["e.g."] = true,
   ["(e.g."] = true,
}

local function is_tr_exception (previous, next)
   if tr_non_terminal[previous] then
      return true
   end
   -- Dates
   if previous:match("M%.?Ö%.$") and next:match("^%d") then
      return true
   end
   if previous:match("M%.?S%.$") and next:match("^%d") then
      return true
   end
   -- Roman numeral ordinals
   if previous:match("[IVXLCDM]+%.$") then
      return true
   end
end

local function is_en_exception (previous, next)
   if en_non_terminal[previous] then
      return true
   end
   -- Dates (reverse from most common order, but other way harder to match without negatives)
   if previous:match("A%.?D%.$") and next:match("^%d") then
      return true
   end
   if previous:match("B%.?C%.$") and next:match("^%d") then
      return true
   end
   if previous:match("C%.?E%.$") and next:match("^%d") then
      return true
   end
   if previous:match("B%.?C%.?E%.$") and next:match("^%d") then
      return true
   end
   -- Verse refs, e.g. Gen. 16
   if previous:match("^%u%P+%.$") and next:match("^%d") then
      return true
   end
end

local function wrap_sentences (element)
   local content = element.content
   for i = 2, #content do
      local previous = content[i - 1]
      local previous_stringly = pandoc.utils.stringify(previous.content and previous.content or previous)
      local next = content[i + 1]
      local next_stringly = next and pandoc.utils.stringify(next.content and next.content or next)
      if
         content[i].t == "Space"
         and previous_stringly:match(eos)
         -- Don't break if the next character is a lower case
         and not (next and next_stringly:match("^%l"))
         and not (locale == "en" and is_en_exception(previous_stringly, next_stringly))
         and not (locale == "tr" and is_tr_exception(previous_stringly, next_stringly))
      then
         content[i] = pandoc.SoftBreak()
      end
   end
   return element
end

local function extract_locale (doc)
   locale = pandoc.utils.stringify(doc.meta.language or locale)
   return doc
end

return {
   traverse = "topdown",
   { Pandoc = extract_locale },
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
