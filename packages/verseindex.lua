SILE.scratch.tableofverses = {}

local orig_href = SILE.Commands["href"]
local loadstring = loadstring or load

local writeTov = function (self)
  local contents = "return " .. std.string.pickle(SILE.scratch.tableofverses)
  local tovfile, err = io.open(SILE.masterFilename .. '.tov', "w")
  if not tovfile then return SU.error(err) end
  tovfile:write(contents)
end

local moveNodes = function (self)
  local node = SILE.scratch.info.thispage.tov
  if node then
    for i = 1, #node do
      node[i].pageno = SILE.formatCounter(SILE.scratch.counters.folio)
      SILE.scratch.tableofverses[#(SILE.scratch.tableofverses)+1] = node[i]
    end
  end
end

local init = function (self)

  self:loadPackage("infonode")
  self:loadPackage("leaders")

  local inpair = nil
  local defaultparskip = SILE.settings.get("typesetter.parfillskip")

  local continuepair = function (args)
    if inpair and args.frame.id == "content" then
      SILE.typesetter:pushState()
      SILE.call("tableofverses:book", { }, { inpair })
      SILE.typesetter:popState()
    end
  end

  local pushBack = SILE.typesetter.pushBack
  SILE.typesetter.pushBack = function(self)
    continuepair(self)
    pushBack(self)
  end

  local startpair = function (pair)
    SILE.call("makecolumns", { gutter = "5%pw" })
    SILE.settings.set("typesetter.parfillskip", SILE.nodefactory.zeroGlue)
    inpair = pair
  end

  local endpair = function (seq)
    inpair = nil
    if seq > 2 and seq % 2 == 0 then
      SILE.typesetter:typeset(" ")
      SILE.call("par")
    end
    SILE.call("mergecolumns")
    SILE.settings.set("typesetter.parfillskip", defaultparskip)
  end

  SILE.registerCommand("href", function (options, content)
    SILE.call("markverse", options, content)
    return orig_href(options, content)
  end)

  SILE.registerCommand("tableofverses:book", function (options, content)
    SILE.call("requireSpace", { height = "4em" })
    SILE.settings.set("typesetter.parfillskip", defaultparskip)
    SILE.call("section", { numbering = "false" }, content)
    SILE.call("breakframevertical")
    startpair(content[1])
  end)

  SILE.registerCommand("tableofverses:reference", function (options, content)
    if #options.pages < 1 then
      SU.warn("Verse in index doesn't have page marker")
      SU.debug("casile", content)
      pages = { "0" }
    end
    SILE.process(content)
    SILE.call("noindent")
    SILE.call("dotfill")
    local first = true
    for _, pageno in pairs(options.pages) do
      if not first then
        SILE.typesetter:typeset(", ")
      end
      SILE.typesetter:typeset(pageno)
      first = false
    end
    SILE.call("par")
  end)

  SILE.registerCommand("markverse", function (options, content)
    SILE.call("info", {
        category = "tov",
        value = {
          label = content
        }
      })
  end)

  SILE.registerCommand("tableofverses", function (options, content)
    SILE.call("chapter", { numbering = "false", appendix = true }, { "Ayet Referans İndeksi" })
    SILE.call("cabook:seriffont", { size = "0.95em" })
    local refshash = {}
    local lastbook = nil
    local seq = 1
    for i, ref in pairs(CASILE.verses) do
      if not refshash[ref.osis] then
        refshash[ref.osis] = true
        if not(lastbook == ref.b) then
          if inpair then endpair(seq) end
          SILE.call("tableofverses:book", { }, { ref.b })
          seq = 1
          lastbook = inpair
        end
        local label = ref.reformat:match(".* (.*)")
        local pages = {}
        local pageshash = {}
        for _, link in pairs(SILE.scratch.tableofverses) do
          if link.label[1] == ref.b .. " " .. label  then
            local pageno = link.pageno
            if not pageshash[pageno] then 
              pages[#pages+1] = pageno
              pageshash[pageno] = true
            end
          end
        end
        SILE.call("tableofverses:reference", { pages = pages }, { label })
        seq = seq + 1
      end
    end
    if inpair then endpair(seq) end
    inpair = nil
  end)

end

return {
  exports = {
    writeTov = writeTov,
    moveTovNodes = moveNodes
  },
  init = init
}
