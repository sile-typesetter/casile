local utf8 = require("lua-utf8")
local inputfilter = SILE.require("packages/inputfilter").exports
SILE.registerCommand("uppercase", function(options, content)
  content[1] = content[1]:gsub("i", "İ")
  SILE.process(inputfilter.transformContent(content, utf8.upper))
end, "Typeset the enclosed text as uppercase")

SILE.require("packages/color")
SILE.require("packages/raiselower")
SILE.require("packages/rebox")

SILE.registerCommand("quote", function(options, content)
  local author = options.author or nil
  local setback = options.setback or "20pt"
  local color = options.color or "#999999"
  SILE.settings.temporarily(function()
    SILE.settings.set("document.rskip", SILE.nodefactory.newGlue(setback))
    SILE.settings.set("document.lskip", SILE.nodefactory.newGlue(setback))

    SILE.settings.set("current.parindent", SILE.nodefactory.zeroGlue)
    SILE.Commands["font"]({family="Libertine Serif", features="+salt,+ss02,+onum,+liga,+dlig,+clig", weight=400, size="12pt"}, content)
    --SILE.process(content)
    SILE.typesetter:pushGlue(SILE.nodefactory.hfillGlue)
    SILE.call("par")
  end)
end, "Typeset verse blocks")

function tr_num2text (num)
  local ones = { "bir", "iki", "üç", "dört", "beş", "altı", "yedi", "sekiz", "dokuz" }
  local tens = { "on", "yirmi", "otuz", "kırk", "eli", "altmış", "yetmiş", "seksen", "dokuz" }
  local places = { "yüz", "bin", "milyon", "milyar" }
  local num = string.reverse(num)
  local str = ""
  for i = 1, #num do
    local val = tonumber(string.sub(num, i, i))
    if val >= 1 then
      if i == 1 then
        str = ones[val] .. " " .. str
      elseif i == 2 then
        str = tens[val] .. " " .. str
      elseif i >= 3 then
        str = places[i-2] .. " " .. str
        if val >= 2 then
          str = ones[val] .. " " .. str
        end
      end
    end
  end
  return str
end
