local inputfilter = require("packages/inputfilter").exports
local discressionaryBreaksFilter = function (content, _, options)
  local currentText = ""
  local result = {}
  local process
  local function insertText()
    if (#currentText>0) then
      table.insert(result, currentText)
      currentText = ""
    end
  end
  local function insertPenalty()
    table.insert(result, inputfilter.createCommand(
      content.pos, content.col, content.line, options.breakwith, options.breakopts
    ))
    if not options.breakall then
      process = function (separator) currentText = currentText..separator end
    end
  end
  process = function (separator)
    if options.replace then
      insertText()
      insertPenalty()
    elseif options.breakbefore == true then
      insertText()
      insertPenalty()
      currentText = currentText .. separator
    else
      currentText = currentText .. separator
      insertText()
      insertPenalty()
    end
  end
  for token in SU.gtoke(content, options.breakat) do
    if(token.string) then
      currentText = currentText .. token.string
    else
      process(token.separator)
    end
  end
  insertText()
  return result
end

CASILE.addDiscressionaryBreaks = function (options, content)
  if type(options[1]) ~= "table" then options = { options } end
  for _, opts in pairs(options) do
    if not opts.breakat then opts.breakat = "[:]" end
    if not opts.breakwith then opts.breakwith = "aki" end
    if not opts.breakopts then opts.breakopts = {} end
    if not opts.breakall then opts.breakall = false end
    if not opts.breakbefore then opts.breakbefore = false end
    if not opts.replace then opts.replace = false end
    content = inputfilter.transformContent(content, discressionaryBreaksFilter, opts)
  end
  return content
end

local isolateDropcapLetter = function (str)
  local lpeg = require("lpeg")
  local R, P, C, S = lpeg.R, lpeg.P, lpeg.C, lpeg.S
  local letter = P"Ü" + P"Ö" + P"Ş" + P"Ç" + P"İ" + P"Â" + R"AZ" + R"09"
  local lpunct = P"'" + P'"' + P"‘" + P"“"
  local tpunct = P"'" + P'"' + P"’" + P"”" + P"."
  local whitespace = S"\r\n\f\t "
  local grp = whitespace^0 * C(lpunct^0 * letter * tpunct^0) * C(P(1)^1) * P(-1)
  return grp:match(str)
end

local originalTypeset
CASILE.dropcapNextLetter = function ()
  SILE.require("packages/dropcaps")
  originalTypeset = SILE.typesetter.typeset
  SILE.typesetter.typeset = function (self, text)
    local first, rest = isolateDropcapLetter(text)
    if first and rest then
      SILE.typesetter.typeset = originalTypeset
      SILE.call("dropcap", {}, { first })
      SILE.typesetter.typeset(self, rest)
    else
      originalTypeset(self, text)
    end
  end
end

SILE.registerUnit("%pmed", { relative = true, definition = function (v)
  return v / 100 * (SILE.documentState.orgPaperSize[1] + SILE.documentState.orgPaperSize[2]) / 2
end})

local parseSize = function (size)
  return SILE.length(size):absolute().length
end

CASILE.constrainSize = function (ideal, max, min)
  local idealSize = parseSize(ideal)
  if max then
    local maxSize = parseSize(max)
    if idealSize > maxSize then return max end
  end
  if min then
    local minSize = parseSize(min)
    if idealSize < minSize then return min end
  end
  return ideal
end

CASILE.isWideLayout = function ()
  return CASILE.layout == "banner" or CASILE.layout == "wide" or CASILE.layout == "screen"
end

CASILE.isScreenLayout = function ()
  return CASILE.layout == "app" or CASILE.layout == "screen"
end

-- Override SILE's language loaded to splice in our own translation(s)
local loadkit = require("loadkit")
local cldr = require("cldr")
loadkit.register("ftl", function (file)
  local contents = assert(file:read("*a"))
  file:close()
  return assert(SILE.fluent:add_messages(contents))
end)
SILE.languageSupport.loadLanguage = function (language)
  language = language or SILE.settings:get("document.language")
  language = cldr.locales[language] and language or "und"
  if SILE.languageSupport.languages[language] then return end
  if SILE.hyphenator.languages[language] then return end
  local langresource = string.format("languages.%s", language)
  local gotlang, lang = pcall(require, langresource)
  if not gotlang then
    if lang:match("not found") then lang = "no support for this language" end
    SU.warn("Error loading language " .. language .. ": " .. lang)
    SILE.languageSupport.languages[language] = {} -- Don't try again
  end
  local ftlresource = string.format("i18n.%s", language)
  SU.debug("fluent", "Loading FTL resource", ftlresource, "into locale", language)
  SILE.fluent:set_locale(language)
  local gotftl, ftl = pcall(require, ftlresource)
  if not gotftl then
    if ftl:match("not found") then ftl = "no localizations for this language" end
    SU.warn("Error loading localizations " .. language .. ": " .. ftl)
  end
  local ftlresource2 = string.format("assets.%s-%s.casile", language, string.upper(language))
  SU.debug("fluent", "Loading CaSILE FTL resource", ftlresource2, "into locale", language)
  local _, _ = pcall(require, ftlresource2)
  if type(lang) == "table" and lang.init then
    lang.init()
  end
end
