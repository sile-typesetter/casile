local cabook = require("classes/cabook")

local cabinding = pl.class(cabook)
cabinding._name = "cabinding"

function cabinding:_init (options)

  cabook._init(self, options)

  require(CASILE.include)

  self:loadPackage("rotate")

  self.writeToc = function () end

  cabinding:registerPostinit(function ()
    SILE.call("language", { main = CASILE.language })
  end)

  return self

end

function cabinding:setOptions (options)
  options.layout = options.layout or CASILE.layout
  cabook.setOptions(self, options)
end

function cabinding:registerCommands ()

  cabook.registerCommands(self)

  SILE.registerCommand("meta:surum", function (_, _)
    SILE.typesetter:typeset(CASILE.versioninfo)
  end)

  SILE.registerCommand("output-right-running-head", function (_, _) end)

end

return cabinding
