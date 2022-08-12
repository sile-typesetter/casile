local plain = require("classes/plain")
local cabinding = require("classes/cabinding")

local class = pl.class(plain)
class._name = "cageometry"

function class:_init (options)
  if not CASILE then
    SU.error("Cannot run without CASILE global instantiated")
  end
  plain._init(self, options)
end

function class:declareOptions ()
  cabinding.declareOptions(self)
end

function class:setOptions (options)
  cabinding.setOptions(self, options)
end

return class
