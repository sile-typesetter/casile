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
  local parts = {}
  for i = 1, #num do
    local val = tonumber(string.sub(num, i, i))
    if val >= 1 then
      if i == 1 then
        parts[#parts+1] = ones[val]
      elseif i == 2 then
        parts[#parts+1] = tens[val]
      elseif i >= 3 then
        parts[#parts+1] = places[i-2]
        if val >= 2 then
          parts[#parts+1] = ones[val]
        end
      end
    end
  end
  local words = {}
  for i = 1, #parts do
    words[#parts+1-i] = parts[i]
  end
  return table.concat( words, " " )
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

local _initml = function (c)
  if not(SILE.scratch.counters[c]) then
    SILE.scratch.counters[c] = { value= {0}, display= {"arabic"} };
  end
end

SILE.registerCommand("increment-multilevel-counter", function (options, content)
  local c = options.id; _initml(c)
  local this = SILE.scratch.counters[c]

  local currentLevel = #this.value
  local level = tonumber(options.level) or currentLevel
  local prev
  if level == currentLevel then
    this.value[level] = this.value[level] + 1
  elseif level > currentLevel then
    while level > currentLevel do
      if not(options.reset == false) then
        prev = 0
      else
        prev = this.value[currentLevel] + 1
      end
      currentLevel = currentLevel + 1
      this.value[currentLevel] = prev
      this.display[currentLevel] = this.display[currentLevel -1]
    end
  else -- level < currentLevel
    this.value[level] = this.value[level] + 1
    while currentLevel > level do
      this.value[currentLevel] = nil
      this.display[currentLevel] = nil
      currentLevel = currentLevel - 1
    end
  end
  if options.display then this.display[currentLevel] = options.display end
end)

SILE.registerCommand("tableofcontents:item", function (o,c)
  SILE.settings.temporarily(function ()
    SILE.settings.set("typesetter.parfillskip", SILE.nodefactory.zeroGlue)
    SILE.call("tableofcontents:level"..o.level.."item", {}, function()
      SILE.process({c})
      -- Ideally, leaders
      SILE.call("hss")
      if o.level == 2 then
        SILE.typesetter:typeset(o.pageno)
      end
    end)
  end)
end)

SILE.registerCommand("fullrule", function (options, content)
  SILE.call("hrule", { height = ".5pt", width = SILE.typesetter.frame:lineWidth() })
end)

SILE.doTexlike([[%
\define[command=tableofcontents:headerfont]{\center{\book:chapterfont{\font[size=14pt]{\process}}}}%
\define[command=tableofcontents:header]{\par\noindent\tableofcontents:headerfont{\tableofcontents:title}\medskip\fullrule}%
\define[command=tableofcontents:level1item]{\bigskip\noindent\book:sansfont{\font[size=10pt,weight=600]{\process}}\smallskip}%
\define[command=tableofcontents:level2item]{\noindent\glue[width=3ex]\font[size=12pt]{\process}\smallskip}%
]])
