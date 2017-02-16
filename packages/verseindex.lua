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

  SILE.registerCommand("href", function (options, content)
    SILE.call("markverse", options, content)
    return orig_href(options, content)
  end)

  SILE.registerCommand("tableofverses:book", function (options, content)
    SILE.call("hbox")
    SILE.call("section", { numbering = "false" }, content)
    SILE.call("breakframevertical")
  end)

  SILE.registerCommand("tableofverses:reference", function (options, content)
    if #options.pages < 1 then
      SU.warn("Verse in index doesn't have page marker")
      SU.debug("casile", content)
      return
    end
    SILE.process(content)
    SILE.call("noindent")
    SILE.call("glue", { width = "1spc" })
    SILE.call("dotfill")
    SILE.call("glue", { width = "1spc" })
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
    local seq = 0
    local incol = false
    for i, ref in pairs(CASILE.verses) do
      if not refshash[ref.osis] then
        refshash[ref.osis] = true
        if not(lastbook == ref.b) then
          if incol then SILE.call("mergecolumns") end
          SILE.call("tableofverses:book", { }, { ref.b })
          SILE.call("makecolumns", { gutter = "5%pw" })
          incol = true
          seq = 0
          lastbook = ref.b
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
    if incol then SILE.call("mergecolumns") end
  end)

end

return {
  exports = {
    writeTov = writeTov,
    moveTovNodes = moveNodes
  },
  init = init
}
