local plain = require("classes.plain")
local cabook = require("classes.cabook")

local class = pl.class(plain)
class._name = "cageometry"

function class:_init (options)
  if not CASILE then
    SU.error("Cannot run without CASILE global instantiated")
  end
  plain._init(self, options)
  self:loadPackage("linespacing")
end

class.declareOptions = cabook.declareOptions
class.setOptions = cabook.setOptions

return class
