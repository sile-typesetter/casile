local cabook = require("classes/cabook")

local class = pl.class(cabook)
class._name = "cabinding"

function class:_init (options)

  cabook._init(self, options)

  self:loadPackage("casile")

  require(CASILE.include)

  self:loadPackage("rotate")

  self.writeToc = function () end

  SILE.settings:set("document.language", CASILE.language, true)

  return self

end

function class:setOptions (options)
  options.layout = options.layout or CASILE.layout
  cabook.setOptions(self, options)
end

function class:registerCommands ()

  cabook.registerCommands(self)

  self:registerCommand("meta:surum", function (_, _)
    SILE.typesetter:typeset(CASILE.versioninfo)
  end)

  self:registerCommand("output-right-running-head", function (_, _) end)

end

return class
