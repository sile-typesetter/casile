local base = require("packages.base")

local package = pl.class(base)
package._name = "dumpframes"

local seenframes = {}
local outfile

function package.writeTof ()
  local contents = "return " .. pl.pretty.write(seenframes)
  local toffile, err = io.open(outfile, "w")
  if not toffile then return SU.error(err) end
  toffile:write(contents)
end

function package.saveFrames (_)
  for id, spec in pairs(SILE.frames) do
    seenframes[id] = {
      spec:left():tonumber(),
      spec:top():tonumber(),
      spec:right():tonumber(),
      spec:bottom():tonumber()
    }
  end
end

function package:_init(options)
  base._init(self)
  outfile = options.outfile or SILE.masterFilename .. '.tof'
  self.class:registerHook("endpage", self.saveFrames)
  self.class:registerHook("finish", self.writeTof)
end

return package
