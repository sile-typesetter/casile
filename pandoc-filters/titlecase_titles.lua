-- Convert all headings to title case following document language rules

local decasify = require("decasify")
local locale = os.getenv("LANGUAGE") or "en"
local style = os.getenv("STYLEGUIDE") or "gruber"

Pandoc = function (doc)
  locale = pandoc.utils.stringify(doc.meta.language or locale)
  style = pandoc.utils.stringify(doc.meta.styleguide or style)
  return doc:walk {
    Header = function (element)
      local title = pandoc.utils.stringify(element.content)
      local cased = decasify.titlecase(title, locale, style)
      element.content = cased
      return element
    end
  }
end
