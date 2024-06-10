local base = require("packages.base")

local package = pl.class(base)
package._name = "verseindex"

SILE.require("packages/url")

SILE.scratch.tableofverses = {}

local orig_href = SILE.Commands["href"]

function package.writeTov ()
   local contents = "return " .. pl.pretty.write(SILE.scratch.tableofverses)
   local tovfile, err = io.open(SILE.masterFilename .. ".tov", "w")
   if not tovfile then
      return SU.error(err)
   end
   tovfile:write(contents)
end

function package.moveTovNodes (class)
   local node = SILE.scratch.info.thispage.tov
   if node then
      for i = 1, #node do
         node[i].pageno = class.packages.counters:formatCounter(SILE.scratch.counters.folio)
         SILE.scratch.tableofverses[#SILE.scratch.tableofverses + 1] = node[i]
      end
   end
end

local inpair = nil
local repairbreak = function () end
local defaultparskip = SILE.settings:get("typesetter.parfillskip")

function package:_init ()
   base._init(self)

   self:loadPackage("infonode")
   self:loadPackage("leaders")

   local continuepair = function (args)
      if not args then
         return
      end
      if inpair and (args.frame.id == "content") then
         repairbreak = function ()
            SILE.call("break")
            repairbreak = function () end
         end
         SILE.typesetter:pushState()
         SILE.call("tableofverses:book", {}, { inpair })
         SILE.typesetter:popState()
      end
   end

   local pushBack = SILE.typesetter.pushBack
   SILE.typesetter.pushBack = function (current_typesetter)
      continuepair(current_typesetter)
      pushBack(current_typesetter)
      repairbreak()
   end

   self.class:registerHook("endpage", self.moveTovNodes)
   self.class:registerHook("finish", self.writeTov)
   self.class:registerHook("finish", function ()
      SILE.call("tableofverses")
   end)
end

function package:registerCommands ()
   local startpair = function (pair)
      -- Temporarily disable columns pending upstream bugfix
      -- https://github.com/sile-typesetter/sile/issues/891
      -- SILE.call("makecolumns", { gutter = "4%pw" })
      SILE.settings:set("typesetter.parfillskip", SILE.types.node.glue())
      inpair = pair
   end

   local endpair = function (_)
      inpair = nil
      SILE.call("mergecolumns")
      SILE.settings:set("typesetter.parfillskip", defaultparskip)
   end

   self:registerCommand("href", function (options, content)
      SILE.call("markverse", options, content)
      return orig_href(options, content)
   end)

   self:registerCommand("tableofverses:book", function (_, content)
      SILE.call("requireSpace", { height = "4em" })
      SILE.settings:set("typesetter.parfillskip", defaultparskip)
      SILE.call("hbox")
      SILE.call("skip", { height = "1ex" })
      SILE.call("section", { numbering = false, skiptoc = true }, content)
      SILE.call("breakframevertical")
      startpair(content[1])
   end)

   self:registerCommand("tableofverses:reference", function (options, content)
      if #options.pages < 1 then
         SU.warn("Verse in index doesn't have page marker")
         options.pages = { "0" }
      end
      SILE.process(content)
      SILE.call("noindent")
      SILE.call("font", { size = ".5em" }, function ()
         SILE.call("dotfill")
      end)
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

   self:registerCommand("markverse", function (options, content)
      SILE.typesetter:typeset("​") -- Protect hbox location from getting discarded
      SILE.call("info", {
         category = "tov",
         value = {
            label = options.title and { options.title } or content,
            osis = options.osis,
         },
      })
   end)

   self:registerCommand("tableofverses", function (_, _)
      SILE.call("chapter", { numbering = false, appendix = true }, { "Ayet Referans İndeksi" })
      SILE.call("cabook:font:serif", { size = "0.95em" })
      local origmethod = SILE.settings:get("linespacing.method")
      local origleader = SILE.settings:get("linespacing.fixed.baselinedistance")
      local origparskip = SILE.settings:get("document.parskip")
      SILE.settings:set("linespacing.method", "fixed")
      SILE.settings:set("linespacing.fixed.baselinedistance", SILE.types.length("1.1em"))
      SILE.settings:set("document.parskip", SILE.types.node.vglue({}))
      local refshash = {}
      local lastbook = nil
      local seq = 1
      -- TODO: should this be ipairs()?
      for _, ref in pairs(CASILE.verses) do
         if not refshash[ref.osis] then
            refshash[ref.osis] = true
            if lastbook ~= ref.b then
               if inpair then
                  endpair(seq)
               end
               SILE.call("tableofverses:book", {}, { ref.b })
               seq = 1
               lastbook = inpair
            end
            local pages = {}
            local pageshash = {}
            local addr = ref.reformat:match(".* (.*)")
            local label = ref.reformat:gsub(" ", " "):gsub(" ", " ")
            if ref.b == "Mezmurlar" then
               label = label:gsub("Mezmurlar", "Mezmur")
            end
            for _, link in pairs(SILE.scratch.tableofverses) do
               if link.osis == ref.osis then
                  local pageno = link.pageno
                  if not pageshash[pageno] then
                     pages[#pages + 1] = pageno
                     pageshash[pageno] = true
                  end
               end
            end
            SILE.call("tableofverses:reference", { pages = pages, label = label }, { addr })
            seq = seq + 1
         end
      end
      if inpair then
         endpair(seq)
      end
      inpair = nil
      SILE.settings:set("linespacing.fixed.baselinedistance", origleader)
      SILE.settings:set("linespacing.method", origmethod)
      SILE.settings:set("document.parskip", origparskip)
   end)
end

return package
