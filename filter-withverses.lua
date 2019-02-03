local yaml = require("yaml")

Pandoc = function (document)
  local versedata = yaml.loadpath(document.meta.versedatafile)

  document.meta.versedatafile = nil

  document.blocks = pandoc.walk_block(pandoc.Div(document.blocks), {
      Note = function (element)
        return pandoc.walk_inline(element, {
            Link = function (element)
              local verse = pandoc.pipe("./casile/bin/normalize_references.js", {}, element.title):gsub("^%s*(.-)%s*$", "%1")
              local versecontent = tostring(versedata[verse]):gsub("\n", "")
              return versecontent and { pandoc.Strong(element), pandoc.Space(), pandoc.Str(versecontent)} or element
            end
          })
      end
    })

  return pandoc.Doc(document.blocks, document.meta)
end

