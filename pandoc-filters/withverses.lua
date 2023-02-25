local yaml = require("yaml")

Pandoc = function (document)
  local versedata = yaml.loadpath(document.meta.versedatafile)

  local blocks = document.blocks:walk {
    Note = function (element)
      return element:walk {
        Str = function (element_)
          if element_.text:match("^[;,]$") then
            return pandoc.Space()
          end
        end,
        Link = function (element_)
          local osis = element_.attr.attributes.osis
          local versecontent = tostring(versedata[osis]):gsub("\n", "")
          if #versecontent < 1 or versecontent == "nil" then
            error("Verse content for "..osis.." not found")
          end
          return versecontent and { pandoc.Strong(element_), pandoc.Space(), pandoc.Str(versecontent)} or element_
        end
      }
    end
  }

  document.meta.versedatafile = nil

  return pandoc.Pandoc(blocks, document.meta)
end

