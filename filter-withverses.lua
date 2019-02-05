local yaml = require("yaml")

Pandoc = function (document)
  local versedata = yaml.loadpath(document.meta.versedatafile)

  document.meta.versedatafile = nil

  document.blocks = pandoc.walk_block(pandoc.Div(document.blocks), {
      Note = function (element)
        return pandoc.walk_inline(element, {
            Str = function (element)
              if element.text:match("^[;,]$") then
                return pandoc.Space()
              end
            end,
            Link = function (element)
              local osis = element.attr.attributes.osis
              local versecontent = tostring(versedata[osis]):gsub("\n", "")
              return versecontent and { pandoc.Strong(element), pandoc.Space(), pandoc.Str(versecontent)} or element
            end
          })
      end
    })

  return pandoc.Doc(document.blocks, document.meta)
end

