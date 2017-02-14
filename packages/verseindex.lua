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
  SILE.registerCommand("markverse", function (options, content)
    -- SU.dump(options, content)
    SILE.call("info", {
        category = "tov",
        value = {
          label = content
        }
      })
  end)

  SILE.registerCommand("tableofverses", function (options, content)
    SILE.call("chapter", { numbered = false }, { "Ek: Ayetler İndeksi" })
    SILE.typesetter:typeset("Frogs in a pond.")
    -- SU.dump(SILE.scratch.tableofverses)
    for i, ref in pairs(CASILE.verses) do
      SU.dump(ref, SILE.scratch.tableofverses[i])
    end
  end)

end

return {
  exports = {
    writeTov = writeTov,
    moveTovNodes = moveNodes
  },
  init = init
}
