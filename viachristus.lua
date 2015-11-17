local utf8 = require("lua-utf8")
local inputfilter = SILE.require("packages/inputfilter").exports
local function trupper (string)
  string = string:gsub("i", "İ")
  return utf8.upper(string)
end
SILE.registerCommand("uppercase", function(options, content)
  SILE.process(inputfilter.transformContent(content, trupper))
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

local function tr_num2text (num)
  local ones = { "Bir", "İki", "Üç", "Dört", "Beş", "Altı", "Yedi", "Sekiz", "Dokuz" }
  local tens = { "On", "Yirmi", "Otuz", "Kırk", "Eli", "Altmış", "Yetmiş", "Seksen", "Dokuz" }
  local places = { "Yüz", "Bin", "Milyon", "Milyar" }
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

SILE.formatCounter = function(options)
  if (options.display == "roman") then return romanize(options.value):lower() end
  if (options.display == "Roman") then return romanize(options.value) end
  if (options.display == "alpha") then return alpha(options.value) end
  --if (options.display == "Alpha") then return alpha(options.value):upper() end
  if (options.display == "string") then return tr_num2text(options.value):lower() end
  if (options.display == "String") then return tr_num2text(options.value) end
  if (options.display == "STRING") then return trupper(tr_num2text(options.value)) end
  return tostring(options.value);
end
